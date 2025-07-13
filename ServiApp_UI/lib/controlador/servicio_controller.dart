import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:serviapp/modelo/global_user.dart';
import 'package:serviapp/modelo/servicio_model.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class ServicioController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Método para registrar un nuevo servicio (mantenido igual)
  Future<bool> registrarServicio({
    required String titulo,
    required String descripcion,
    required String categoria,
    required String subcategoria,
    required String telefono,
    required String ubicacion,
    File? imagenFile,
  }) async {
    try {
      final String? idUsuario = GlobalUser.uid;
      if (idUsuario == null) {
        print('Error: No hay un usuario logueado');
        return false;
      }

      // 1. Obtener datos del usuario (publicaciones y tokens)
      final userRef = _firestore.collection('users').doc(idUsuario);
      final userDoc = await userRef.get();

      int publicaciones = 0;
      int tokens = 0;

      if (userDoc.exists) {
        publicaciones = (userDoc.data()?['publicaciones'] ?? 0) as int;
        tokens = (userDoc.data()?['tokens'] ?? 0) as int;
      } else {
        // Si el usuario no existe por alguna razón, lo inicializamos
        await userRef.set({'publicaciones': 0, 'tokens': 0}, SetOptions(merge: true));
      }

      // 2. Lógica de cobro de tokens
      int costoTokens = 50; // <-- AQUÍ defines el costo de la publicación extra
      bool cobrar = publicaciones >= 2;

      if (cobrar) {
        if (tokens < costoTokens) {
          // No tiene suficientes tokens
          throw Exception('No tienes suficientes tokens para publicar un nuevo servicio. Elimina uno existente o recarga tokens.');
        }
      }

      // 3. Subir imagen (si hay)
      String? imagenUrl;
      if (imagenFile != null) {
        imagenUrl = await _subirImagen(imagenFile, idUsuario);
      }

      // 4. Crear el servicio
      Map<String, dynamic> servicioData = {
        'titulo': titulo,
        'descripcion': descripcion,
        'categoria': categoria,
        'subcategoria': subcategoria,
        'telefono': telefono,
        'ubicacion': ubicacion,
        'idusuario': idUsuario,
        'estado': 'true',
        'date': FieldValue.serverTimestamp(),
        'sumaCalificaciones': 0,
        'totalCalificaciones': 0,
        if (imagenUrl != null) 'imagen': imagenUrl,
      };

      await _firestore.collection('servicios').add(servicioData);

      // 5. Actualizar el contador de publicaciones y tokens
      await userRef.set({
        'publicaciones': publicaciones + 1,
        if (cobrar) 'tokens': tokens - costoTokens,
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error al registrar servicio: $e');
      rethrow;
    }
  }

  // Método para subir imágenes (mantenido igual)
  Future<String> _subirImagen(File imageFile, String userId) async {
    try {
      final String nombreArchivo = _uuid.v4();
      final Reference storageRef = _storage
          .ref()
          .child('servicios')
          .child(userId)
          .child('$nombreArchivo.jpg');

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen: $e');
      throw Exception('No se pudo subir la imagen');
    }
  }

  // Método para obtener subcategorías (mantenido igual)
  List<String> obtenerSubcategorias(String categoria) {
    switch (categoria) {
      case 'Tecnologia':
        return [
          'Reparación de computadoras y laptops',
          'Mantenimiento',
          'Instalación de software',
          'Redes y conectividad',
          'Reparación de celulares',
          'Diseño web',
        ];
      case 'Vehículos':
        return [
          'Mecánica automotriz',
          'Lavado y detallado de autos',
          'Cambio de llantas y baterías',
          'Servicio de grúa',
          'Transporte y mudanzas',
          'Lubricentro',
        ];
      case 'Eventos':
        return [
          'Fotografía y filmación',
          'Organización de eventos',
          'Catering y banquetes',
          'Música en vivo y DJ',
        ];
      case 'Estetica':
        return [
          'Peluquería y barbería a domicilio',
          'Manicure y pedicure',
          'Maquillaje y asesoría de imagen',
        ];
      case 'Salud y Bienestar':
        return [
          'Consulta médica a domicilio',
          'Enfermería y cuidados a domicilio',
          'Terapia física y rehabilitación',
          'Masajes y relajación',
          'Entrenador personal',
        ];
      case 'Servicios Generales':
        return [
          'Albañileria',
          'Plomeria',
          'Electricidad',
          'Carpinteria',
          'Pintura y acabados',
          'Jardineria y paisajismo',
        ];
      case 'Educacion':
        return [
          'Clases Particulares',
          'Tutoriales en linea',
          'Capacitación en software',
          'Programas académicos',
          'Cursos y Certificaciones',
          'Vacaciones útiles',
        ];
      case 'Limpieza':
        return [
          'Limpieza del hogar y oficinas',
          'Lavanderia y el planchado',
          'Desinfeccion',
          'Encerado y pulido de muebles',
        ];
      default:
        return [];
    }
  }

  // ========== NUEVOS MÉTODOS PARA CALIFICACIONES ==========

  // Obtener servicios por subcategoría (nuevo)
  Stream<List<Servicio>> obtenerServiciosPorSubcategoria(String subcategoria) {
    return _firestore
        .collection('servicios')
        .where('subcategoria', isEqualTo: subcategoria)
        .where('estado', isEqualTo: "true")
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Servicio.fromFirestore(doc))
            .toList());
  }

  // Calificar un servicio (nuevo)
  Future<void> calificarServicio({
    required String servicioId,
    required int puntuacion,
    required String usuarioId,
    required String nombreUsuario,
    String? comentario,
  }) async {
    final batch = _firestore.batch();
    final puntuacionValida = puntuacion.clamp(1, 5); // Asegurar 1-5

    // 1. Agregar calificación individual
    final calificacionRef = _firestore
        .collection('servicios')
        .doc(servicioId)
        .collection('calificaciones')
        .doc();
    
    batch.set(calificacionRef, {
      'puntuacion': puntuacionValida,
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'comentario': comentario,
      'fecha': FieldValue.serverTimestamp(),
    });

    // 2. Actualizar contadores en el servicio
    final servicioRef = _firestore.collection('servicios').doc(servicioId);
    batch.update(servicioRef, {
      'totalCalificaciones': FieldValue.increment(1),
      'sumaCalificaciones': FieldValue.increment(puntuacionValida),
    });

    // 3. Registrar en el usuario para evitar duplicados
    final usuarioRef = _firestore.collection('usuarios').doc(usuarioId);
    batch.update(usuarioRef, {
      'serviciosCalificados': FieldValue.arrayUnion([servicioId])
    });

    await batch.commit();
  }

  // Obtener calificaciones de un servicio (nuevo)
  Stream<List<Map<String, dynamic>>> obtenerCalificaciones(String servicioId) {
    return _firestore
        .collection('servicios')
        .doc(servicioId)
        .collection('calificaciones')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              return {
                'puntuacion': data['puntuacion'],
                'comentario': data['comentario'],
                'nombreUsuario': data['nombreUsuario'],
                'fecha': (data['fecha'] as Timestamp).toDate(),
              };
            })
            .toList());
  }

  // Verificar si usuario ya calificó (nuevo)
  Future<bool> usuarioYaCalifico(String servicioId, String usuarioId) async {
    final doc = await _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .get();
    
    final serviciosCalificados = List<String>.from(doc.data()?['serviciosCalificados'] ?? []);
    return serviciosCalificados.contains(servicioId);
  }

  //Editar Proveedor

  Future<bool> actualizarServicio({
    required String servicioId,
    required String titulo,
    required String descripcion,
    required String categoria,
    required String subcategoria,
    required String telefono,
    required String ubicacion,
    File? imagenFile,
    String? imagenUrlOriginal,
  }) async {
    try {
      // Preparar los datos a actualizar
      Map<String, dynamic> datosActualizados = {
        'titulo': titulo.trim(),
        'descripcion': descripcion.trim(),
        'categoria': categoria,
        'subcategoria': subcategoria,
        'telefono': telefono.trim(),
        'ubicacion': ubicacion.trim(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      String? urlImagen;

      // Si hay una nueva imagen, subirla
      if (imagenFile != null) {
        // Subir la nueva imagen
        String fileName = 'servicio_${servicioId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child('servicios/$fileName');
        
        UploadTask uploadTask = storageRef.putFile(imagenFile);
        TaskSnapshot snapshot = await uploadTask;
        urlImagen = await snapshot.ref.getDownloadURL();
        
        // Si había una imagen anterior, intentar eliminarla
        if (imagenUrlOriginal != null && imagenUrlOriginal.isNotEmpty) {
          try {
            Reference imagenAnteriorRef = FirebaseStorage.instance.refFromURL(imagenUrlOriginal);
            await imagenAnteriorRef.delete();
          } catch (e) {
            print('Error al eliminar imagen anterior: $e');
            // No es crítico si no se puede eliminar la imagen anterior
          }
        }
        
        datosActualizados['imagen'] = urlImagen;
      } else if (imagenUrlOriginal != null && imagenUrlOriginal.isNotEmpty) {
        // Mantener la imagen original si no hay nueva imagen
        datosActualizados['imagen'] = imagenUrlOriginal;
      }

      // Actualizar el documento en Firestore
      await FirebaseFirestore.instance
          .collection('servicios')
          .doc(servicioId)
          .update(datosActualizados);

      print('Servicio actualizado exitosamente');
      return true;

    } catch (e) {
      print('Error al actualizar servicio: $e');
      return false;
    }
  }

}