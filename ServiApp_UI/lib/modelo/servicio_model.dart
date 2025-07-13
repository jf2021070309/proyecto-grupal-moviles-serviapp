import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Servicio {
  final String id;
  final String titulo;
  final String descripcion;
  final String telefono;
  final String subcategoria;
  final String idusuario; // ID del proveedor
  final String? imagen; // ✅ NUEVO CAMPO AGREGADO
  final double sumaCalificaciones;
  final int totalCalificaciones;
  final IconData icon;
  final Color color;

  // Constructor principal
  Servicio({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.telefono,
    required this.subcategoria,
    required this.idusuario,
    this.imagen, // ✅ CAMPO OPCIONAL AGREGADO
    required this.sumaCalificaciones,
    required this.totalCalificaciones,
    required this.icon,
    required this.color,
  });

  // Getter para calcular el promedio dinámicamente
  double get promedioCalificaciones {
    if (totalCalificaciones <= 0) return 0.0;
    return sumaCalificaciones / totalCalificaciones;
  }

  // Factory constructor para crear instancias desde Firestore
  factory Servicio.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Servicio(
      id: doc.id,
      titulo: data['titulo'] ?? 'Sin título',
      descripcion: data['descripcion'] ?? '',
      telefono: data['telefono'] ?? '',
      subcategoria: data['subcategoria'] ?? 'General',
      idusuario: data['idusuario'] ?? '', // Campo del proveedor
      imagen: data['imagen'], // ✅ CAMPO IMAGEN DESDE FIRESTORE
      sumaCalificaciones: (data['sumaCalificaciones'] ?? 0.0).toDouble(),
      totalCalificaciones: data['totalCalificaciones'] ?? 0,
      icon: _parseIconData(data['icon'] ?? ''),
      color: _parseColor(data['color'] ?? ''),
    );
  }

  // Método para generar el mapa de actualización en Firestore
  Map<String, dynamic> toUpdateMap(double nuevaCalificacion) {
    return {
      'sumaCalificaciones': FieldValue.increment(nuevaCalificacion),
      'totalCalificaciones': FieldValue.increment(1),
      'ultimaActualizacion': FieldValue.serverTimestamp(),
    };
  }

  // Método para convertir a mapa (útil para crear nuevos documentos)
  Map<String, dynamic> toFirestoreMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'telefono': telefono,
      'subcategoria': subcategoria,
      'idusuario': idusuario,
      'imagen': imagen, // ✅ INCLUIR IMAGEN EN EL MAPA
      'sumaCalificaciones': sumaCalificaciones,
      'totalCalificaciones': totalCalificaciones,
      'icon': _iconToString(icon),
      'color': _colorToString(color),
    };
  }

  // Helpers para conversión de datos
  static IconData _parseIconData(String iconName) {
    final iconMap = {
      'computer': Icons.computer,
      'cleaning': Icons.cleaning_services,
      'plumbing': Icons.plumbing,
      'repair': Icons.build,
      'event': Icons.event,
      'spa': Icons.spa,
      'favorite': Icons.favorite,
      'school': Icons.school,
      'directions_car': Icons.directions_car,
      'devices': Icons.devices,
    };
    return iconMap[iconName.toLowerCase()] ?? Icons.help_outline;
  }

  static Color _parseColor(String colorValue) {
    final colorMap = {
      'blue': Colors.blue,
      'red': Colors.red,
      'green': Colors.green,
      'teal': Colors.teal,
      'indigo': Colors.indigo,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'amber': Colors.amber,
    };
    return colorMap[colorValue.toLowerCase()] ?? Colors.grey;
  }

  static String _iconToString(IconData icon) {
    final iconMap = {
      Icons.computer: 'computer',
      Icons.cleaning_services: 'cleaning',
      Icons.plumbing: 'plumbing',
      Icons.build: 'repair',
      Icons.event: 'event',
      Icons.spa: 'spa',
      Icons.favorite: 'favorite',
      Icons.school: 'school',
      Icons.directions_car: 'directions_car',
      Icons.devices: 'devices',
    };
    return iconMap[icon] ?? 'help';
  }

  static String _colorToString(Color color) {
    final colorMap = {
      Colors.blue: 'blue',
      Colors.red: 'red',
      Colors.green: 'green',
      Colors.teal: 'teal',
      Colors.indigo: 'indigo',
      Colors.purple: 'purple',
      Colors.pink: 'pink',
      Colors.amber: 'amber',
    };
    return colorMap[color] ?? 'grey';
  }

  // Método para formatear el promedio para mostrar
  String get promedioFormateado => promedioCalificaciones.toStringAsFixed(1);

  // Método para mostrar información de calificaciones
  String get infoCalificaciones {
    if (totalCalificaciones == 0) return 'Sin calificaciones';
    return '$promedioFormateado ($totalCalificaciones ${totalCalificaciones == 1 ? 'reseña' : 'reseñas'})';
  }

  static Future<List<Servicio>> obtenerServiciosPorUsuario(
    String idusuario,
  ) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('servicios')
            .where('idusuario', isEqualTo: idusuario)
            .get();

    return snapshot.docs.map((doc) => Servicio.fromFirestore(doc)).toList();
  }

  // Método para obtener las calificaciones reales del proveedor desde Firestore
  static Future<Map<String, double>> obtenerCalificacionesProveedor(
    String proveedorId,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('calificaciones')
          .where('proveedorId', isEqualTo: proveedorId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {'promedio': 0.0, 'total': 0.0};
      }

      double sumaCalificaciones = 0.0;
      int totalCalificaciones = snapshot.docs.length;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        sumaCalificaciones += (data['puntuacion'] ?? 0.0).toDouble();
      }

      final promedio = sumaCalificaciones / totalCalificaciones;

      return {
        'promedio': promedio,
        'total': totalCalificaciones.toDouble(),
      };
    } catch (e) {
      print('Error obteniendo calificaciones: $e');
      return {'promedio': 0.0, 'total': 0.0};
    }
  }

  // Método para obtener datos completos del proveedor incluyendo calificaciones
  static Future<Map<String, dynamic>> obtenerDatosCompletosProveedor(
    String proveedorId,
  ) async {
    final Map<String, dynamic> resultado = {};
    
    try {
      // Obtener datos del usuario proveedor
      final proveedorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(proveedorId)
          .get();
      
      if (proveedorDoc.exists) {
        final data = proveedorDoc.data()!;
        resultado['nombre'] = data['nombre'] ?? 'Proveedor';
        resultado['ubicacion'] = data['ubicacion'] ?? 'Sin ubicación';
        resultado['fotoPerfil'] = data['fotoPerfil'] ?? '';
        resultado['celular'] = data['celular'] ?? '';
      }
      
      // Obtener calificaciones
      final calificaciones = await obtenerCalificacionesProveedor(proveedorId);
      resultado['promedioCalificaciones'] = calificaciones['promedio'];
      resultado['totalCalificaciones'] = calificaciones['total']?.toInt() ?? 0;
      
    } catch (e) {
      print('Error obteniendo datos completos del proveedor: $e');
      resultado['nombre'] = 'Proveedor';
      resultado['ubicacion'] = 'Sin ubicación';
      resultado['fotoPerfil'] = '';
      resultado['celular'] = '';
      resultado['promedioCalificaciones'] = 0.0;
      resultado['totalCalificaciones'] = 0;
    }
    
    return resultado;
  }
}