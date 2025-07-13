import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../styles/admin_theme.dart';

class AdminController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener estadísticas del dashboard
  Future<Map<String, dynamic>> obtenerEstadisticasDashboard() async {
    try {
      // Contar usuarios por rol
      final usuariosSnapshot = await _firestore.collection('users').get();
      int totalClientes = 0;
      int totalProveedores = 0;
      
      for (var doc in usuariosSnapshot.docs) {
        final data = doc.data();
        if (data['rol'] == 'cliente') {
          totalClientes++;
        } else if (data['rol'] == 'proveedor') {
          totalProveedores++;
        }
      }

      // Contar servicios activos
      final serviciosSnapshot = await _firestore
          .collection('servicios')
          .where('estado', isEqualTo: 'true')
          .get();
      final totalServicios = serviciosSnapshot.docs.length;

      // Contar notificaciones por estado
      final notificacionesSnapshot = await _firestore.collection('notificaciones').get();
      int pendientes = 0;
      int aceptadas = 0;
      int rechazadas = 0;
      
      for (var doc in notificacionesSnapshot.docs) {
        final data = doc.data();
        switch (data['estado']) {
          case 'pendiente':
            pendientes++;
            break;
          case 'aceptado':
            aceptadas++;
            break;
          case 'rechazado':
            rechazadas++;
            break;
        }
      }

      // Calcular promedio de calificaciones
      final calificacionesSnapshot = await _firestore.collection('calificaciones').get();
      double promedioCalificaciones = 0.0;
      if (calificacionesSnapshot.docs.isNotEmpty) {
        double suma = 0;
        for (var doc in calificacionesSnapshot.docs) {
          final data = doc.data();
          suma += (data['puntuacion'] ?? 0).toDouble();
        }
        promedioCalificaciones = suma / calificacionesSnapshot.docs.length;
      }

      return {
        'totalClientes': totalClientes,
        'totalProveedores': totalProveedores,
        'totalServicios': totalServicios,
        'notificacionesPendientes': pendientes,
        'notificacionesAceptadas': aceptadas,
        'notificacionesRechazadas': rechazadas,
        'promedioCalificaciones': promedioCalificaciones,
        'totalCalificaciones': calificacionesSnapshot.docs.length,
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {};
    }
  }

  // Obtener usuarios con filtros
  Stream<QuerySnapshot> obtenerUsuarios({String? filtroRol}) {
    Query query = _firestore.collection('users');
    
    if (filtroRol != null && filtroRol.isNotEmpty) {
      query = query.where('rol', isEqualTo: filtroRol);
    } else {
      // Solo mostrar clientes y proveedores si no hay filtro
      query = query.where('rol', whereIn: ['cliente', 'proveedor']);
    }
    
    return query.snapshots();
  }

  // Obtener servicios con filtros
  Stream<QuerySnapshot> obtenerServicios({String? categoria, String? estado}) {
    Query query = _firestore.collection('servicios');
    
    if (categoria != null && categoria.isNotEmpty) {
      query = query.where('categoria', isEqualTo: categoria);
    }
    
    if (estado != null && estado.isNotEmpty) {
      query = query.where('estado', isEqualTo: estado);
    }
    
    return query.orderBy('date', descending: true).snapshots();
  }

  // Obtener notificaciones con filtros
  Stream<QuerySnapshot> obtenerNotificaciones({String? estado}) {
    Query query = _firestore.collection('notificaciones');
    
    if (estado != null && estado.isNotEmpty) {
      query = query.where('estado', isEqualTo: estado);
    }
    
    return query.orderBy('timestamp', descending: true).snapshots();
  }

  // Obtener calificaciones
  Stream<QuerySnapshot> obtenerCalificaciones() {
    return _firestore
        .collection('calificaciones')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Cambiar estado de servicio
  Future<bool> cambiarEstadoServicio(String servicioId, String nuevoEstado) async {
    try {
      await _firestore.collection('servicios').doc(servicioId).update({
        'estado': nuevoEstado,
        'fechaModificacion': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error cambiando estado de servicio: $e');
      return false;
    }
  }

  // Eliminar calificación
  Future<bool> eliminarCalificacion(String calificacionId) async {
    try {
      await _firestore.collection('calificaciones').doc(calificacionId).delete();
      return true;
    } catch (e) {
      print('Error eliminando calificación: $e');
      return false;
    }
  }

  // Obtener datos de un usuario específico
  Future<DocumentSnapshot?> obtenerUsuario(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      print('Error obteniendo usuario: $e');
      return null;
    }
  }

  // Bloquear/desbloquear usuario
  Future<bool> cambiarEstadoUsuario(String userId, bool bloqueado) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'bloqueado': bloqueado,
        'fechaModificacion': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error cambiando estado de usuario: $e');
      return false;
    }
  }

  // Obtener servicios más solicitados
  Future<List<Map<String, dynamic>>> obtenerServiciosMasSolicitados() async {
    try {
      final notificaciones = await _firestore.collection('notificaciones').get();
      Map<String, int> conteoSubcategorias = {};
      
      for (var doc in notificaciones.docs) {
        final data = doc.data();
        final subcategoria = data['subcategoria'] ?? 'Sin categoría';
        conteoSubcategorias[subcategoria] = (conteoSubcategorias[subcategoria] ?? 0) + 1;
      }
      
      // Convertir a lista y ordenar
      var lista = conteoSubcategorias.entries
          .map((e) => {'subcategoria': e.key, 'cantidad': e.value})
          .toList();
      
      lista.sort((a, b) => (b['cantidad'] as int).compareTo(a['cantidad'] as int));
      return lista.take(10).toList();
    } catch (e) {
      print('Error obteniendo servicios más solicitados: $e');
      return [];
    }
  }

  // ========== MÉTODOS PARA ADMINISTRAR SERVICIOS ==========

  // Aprobar un servicio
  Future<bool> aprobarServicio(String servicioId) async {
    try {
      await _firestore.collection('servicios').doc(servicioId).update({
        'estado': 'aprobado',
        'fechaAprobacion': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error aprobando servicio: $e');
      return false;
    }
  }

  // Rechazar un servicio
  Future<bool> rechazarServicio(String servicioId, String motivo) async {
    try {
      await _firestore.collection('servicios').doc(servicioId).update({
        'estado': 'rechazado',
        'motivo_rechazo': motivo,
        'fechaRechazo': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error rechazando servicio: $e');
      return false;
    }
  }

  // Activar/Desactivar un servicio
  Future<bool> activarDesactivarServicio(String servicioId, bool activo) async {
    try {
      await _firestore.collection('servicios').doc(servicioId).update({
        'activo': activo,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error cambiando estado del servicio: $e');
      return false;
    }
  }

  // Eliminar un servicio
  Future<bool> eliminarServicio(String servicioId) async {
    try {
      await _firestore.collection('servicios').doc(servicioId).delete();
      return true;
    } catch (e) {
      print('Error eliminando servicio: $e');
      return false;
    }
  }

  // Obtener información del proveedor de un servicio
  Future<Map<String, dynamic>?> obtenerProveedorServicio(String proveedorId) async {
    try {
      final doc = await _firestore.collection('users').doc(proveedorId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error obteniendo proveedor: $e');
      return null;
    }
  }

  // Obtener categorías disponibles para filtros
  Future<List<String>> obtenerCategoriasServicios() async {
    try {
      final snapshot = await _firestore.collection('servicios').get();
      final categorias = <String>{};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['subcategoria'] != null) {
          categorias.add(data['subcategoria'] as String);
        }
      }
      
      return categorias.toList()..sort();
    } catch (e) {
      print('Error obteniendo categorías: $e');
      return [];
    }
  }

  // ========== MÉTODOS PARA REPORTES Y ESTADÍSTICAS ==========

  // Obtener estadísticas generales para reportes
  Future<Map<String, dynamic>> obtenerEstadisticasReportes() async {
    try {
      final Map<String, dynamic> estadisticas = {};

      // 1. Estadísticas de usuarios
      final usuariosSnapshot = await _firestore.collection('users').get();
      int totalUsuarios = usuariosSnapshot.docs.length;
      int clientes = 0;
      int proveedores = 0;
      int usuariosActivos = 0;

      for (var doc in usuariosSnapshot.docs) {
        final data = doc.data();
        if (data['rol'] == 'cliente') clientes++;
        if (data['rol'] == 'proveedor') proveedores++;
        if (data['activo'] == true) usuariosActivos++;
      }

      estadisticas['usuarios'] = {
        'total': totalUsuarios,
        'clientes': clientes,
        'proveedores': proveedores,
        'activos': usuariosActivos,
      };

      // 2. Estadísticas de servicios
      final serviciosSnapshot = await _firestore.collection('servicios').get();
      int totalServicios = serviciosSnapshot.docs.length;
      int serviciosActivos = 0;
      int serviciosAprobados = 0;
      int serviciosRechazados = 0;
      Map<String, int> serviciosPorCategoria = {};
      double promedioCalificaciones = 0.0;
      int totalCalificaciones = 0;

      for (var doc in serviciosSnapshot.docs) {
        final data = doc.data();
        if (data['estado'] == 'activo') serviciosActivos++;
        if (data['estado'] == 'aprobado') serviciosAprobados++;
        if (data['estado'] == 'rechazado') serviciosRechazados++;
        
        String categoria = data['subcategoria'] ?? 'Sin categoría';
        serviciosPorCategoria[categoria] = (serviciosPorCategoria[categoria] ?? 0) + 1;
        
        if (data['totalCalificaciones'] != null && data['totalCalificaciones'] > 0) {
          totalCalificaciones += data['totalCalificaciones'] as int;
          promedioCalificaciones += data['sumaCalificaciones'] ?? 0.0;
        }
      }

      if (totalCalificaciones > 0) {
        promedioCalificaciones = promedioCalificaciones / totalCalificaciones;
      }

      estadisticas['servicios'] = {
        'total': totalServicios,
        'activos': serviciosActivos,
        'aprobados': serviciosAprobados,
        'rechazados': serviciosRechazados,
        'porCategoria': serviciosPorCategoria,
        'promedioCalificaciones': promedioCalificaciones,
      };

      // 3. Estadísticas de notificaciones/solicitudes
      final notificacionesSnapshot = await _firestore.collection('notificaciones').get();
      int totalNotificaciones = notificacionesSnapshot.docs.length;
      int pendientes = 0;
      int aceptadas = 0;
      int rechazadas = 0;

      for (var doc in notificacionesSnapshot.docs) {
        final data = doc.data();
        switch (data['estado']) {
          case 'pendiente':
            pendientes++;
            break;
          case 'aceptado':
            aceptadas++;
            break;
          case 'rechazado':
            rechazadas++;
            break;
        }
      }

      estadisticas['notificaciones'] = {
        'total': totalNotificaciones,
        'pendientes': pendientes,
        'aceptadas': aceptadas,
        'rechazadas': rechazadas,
      };

      return estadisticas;
    } catch (e) {
      print('Error obteniendo estadísticas de reportes: $e');
      return {};
    }
  }

  // Obtener servicios más populares
  Future<List<Map<String, dynamic>>> obtenerServiciosMasPopulares({int limite = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('servicios')
          .orderBy('totalCalificaciones', descending: true)
          .limit(limite)
          .get();

      List<Map<String, dynamic>> servicios = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        servicios.add({
          'id': doc.id,
          'titulo': data['titulo'] ?? 'Sin título',
          'subcategoria': data['subcategoria'] ?? 'Sin categoría',
          'totalCalificaciones': data['totalCalificaciones'] ?? 0,
          'promedioCalificaciones': data['totalCalificaciones'] > 0 
              ? (data['sumaCalificaciones'] ?? 0.0) / data['totalCalificaciones']
              : 0.0,
        });
      }

      return servicios;
    } catch (e) {
      print('Error obteniendo servicios más populares: $e');
      return [];
    }
  }

  // Obtener actividad reciente
  Future<List<Map<String, dynamic>>> obtenerActividadReciente({int limite = 20}) async {
    try {
      List<Map<String, dynamic>> actividades = [];

      // Usuarios registrados recientemente
      final usuariosSnapshot = await _firestore
          .collection('users')
          .orderBy('fechaRegistro', descending: true)
          .limit(10)
          .get();

      for (var doc in usuariosSnapshot.docs) {
        final data = doc.data();
        actividades.add({
          'tipo': 'usuario_registrado',
          'titulo': 'Nuevo usuario registrado',
          'descripcion': '${data['nombre']} se registró como ${data['rol']}',
          'fecha': data['fechaRegistro'],
          'icono': Icons.person_add,
          'color': AdminTheme.successColor,
        });
      }

      // Servicios registrados recientemente
      final serviciosSnapshot = await _firestore
          .collection('servicios')
          .orderBy('date', descending: true)
          .limit(10)
          .get();

      for (var doc in serviciosSnapshot.docs) {
        final data = doc.data();
        actividades.add({
          'tipo': 'servicio_registrado',
          'titulo': 'Nuevo servicio registrado',
          'descripcion': data['titulo'] ?? 'Sin título',
          'fecha': data['date'],
          'icono': Icons.business,
          'color': AdminTheme.infoColor,
        });
      }

      // Ordenar por fecha más reciente
      actividades.sort((a, b) {
        final fechaA = a['fecha'];
        final fechaB = b['fecha'];
        if (fechaA == null || fechaB == null) return 0;
        return fechaB.compareTo(fechaA);
      });

      return actividades.take(limite).toList();
    } catch (e) {
      print('Error obteniendo actividad reciente: $e');
      return [];
    }
  }

  // Obtener tendencias por mes
  Future<Map<String, dynamic>> obtenerTendenciasMensuales() async {
    try {
      final ahora = DateTime.now();
      final inicioMes = DateTime(ahora.year, ahora.month, 1);
      final mesAnterior = DateTime(ahora.year, ahora.month - 1, 1);

      // Usuarios registrados este mes vs mes anterior
      final usuariosEsteMes = await _firestore
          .collection('users')
          .where('fechaRegistro', isGreaterThan: Timestamp.fromDate(inicioMes))
          .get();

      final usuariosMesAnterior = await _firestore
          .collection('users')
          .where('fechaRegistro', isGreaterThan: Timestamp.fromDate(mesAnterior))
          .where('fechaRegistro', isLessThan: Timestamp.fromDate(inicioMes))
          .get();

      // Servicios registrados este mes vs mes anterior
      final serviciosEsteMes = await _firestore
          .collection('servicios')
          .where('date', isGreaterThan: Timestamp.fromDate(inicioMes))
          .get();

      final serviciosMesAnterior = await _firestore
          .collection('servicios')
          .where('date', isGreaterThan: Timestamp.fromDate(mesAnterior))
          .where('date', isLessThan: Timestamp.fromDate(inicioMes))
          .get();

      return {
        'usuarios': {
          'este_mes': usuariosEsteMes.docs.length,
          'mes_anterior': usuariosMesAnterior.docs.length,
        },
        'servicios': {
          'este_mes': serviciosEsteMes.docs.length,
          'mes_anterior': serviciosMesAnterior.docs.length,
        },
      };
    } catch (e) {
      print('Error obteniendo tendencias mensuales: $e');
      return {};
    }
  }

  // Obtener servicios populares (ordenados por cantidad de solicitudes)
  Future<List<Map<String, dynamic>>> obtenerServiciosPopulares() async {
    try {
      // Simulamos datos de servicios populares basados en notificaciones
      final notificacionesSnapshot = await _firestore.collection('notificaciones').get();
      final serviciosSnapshot = await _firestore.collection('servicios').get();
      
      Map<String, int> conteoSolicitudes = {};
      Map<String, Map<String, dynamic>> datosServicios = {};
      
      // Contar solicitudes por servicio
      for (var doc in notificacionesSnapshot.docs) {
        final data = doc.data();
        final servicioId = data['idServicio'];
        if (servicioId != null) {
          conteoSolicitudes[servicioId] = (conteoSolicitudes[servicioId] ?? 0) + 1;
        }
      }
      
      // Obtener datos de servicios
      for (var doc in serviciosSnapshot.docs) {
        datosServicios[doc.id] = doc.data();
      }
      
      // Crear lista de servicios populares
      List<Map<String, dynamic>> serviciosPopulares = [];
      
      conteoSolicitudes.forEach((servicioId, solicitudes) {
        if (datosServicios.containsKey(servicioId)) {
          final servicio = datosServicios[servicioId]!;
          serviciosPopulares.add({
            'id': servicioId,
            'titulo': servicio['titulo'] ?? 'Sin título',
            'categoria': servicio['categoria'] ?? 'General',
            'solicitudes': solicitudes,
          });
        }
      });
      
      // Ordenar por número de solicitudes (descendente)
      serviciosPopulares.sort((a, b) => b['solicitudes'].compareTo(a['solicitudes']));
      
      return serviciosPopulares.take(10).toList();
    } catch (e) {
      print('Error obteniendo servicios populares: $e');
      return [];
    }
  }

  // Gestión de calificaciones
  Future<Map<String, dynamic>> obtenerEstadisticasCalificaciones() async {
    try {
      final calificacionesSnapshot = await _firestore.collection('calificaciones').get();
      
      if (calificacionesSnapshot.docs.isEmpty) {
        return {
          'total': 0,
          'promedio': 0.0,
          'cinco_estrellas': 0,
          'bajas': 0,
          'distribucion': {},
          'por_categoria': {},
        };
      }

      // Calcular estadísticas generales
      int total = calificacionesSnapshot.docs.length;
      double sumaCalificaciones = 0;
      Map<String, int> distribucion = {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0};
      int cincoEstrellas = 0;
      int bajas = 0; // 1-2 estrellas
      Map<String, List<double>> porCategoria = {};

      for (var doc in calificacionesSnapshot.docs) {
        final data = doc.data();
        final puntuacion = data['puntuacion'] ?? 0;
        final categoria = data['categoria'] ?? 'General';
        
        sumaCalificaciones += puntuacion;
        distribucion[puntuacion.toString()] = (distribucion[puntuacion.toString()] ?? 0) + 1;
        
        if (puntuacion == 5) cincoEstrellas++;
        if (puntuacion <= 2) bajas++;
        
        if (!porCategoria.containsKey(categoria)) {
          porCategoria[categoria] = [];
        }
        porCategoria[categoria]!.add(puntuacion.toDouble());
      }

      // Calcular promedios por categoría
      Map<String, double> promediosCategoria = {};
      porCategoria.forEach((categoria, calificaciones) {
        if (calificaciones.isNotEmpty) {
          promediosCategoria[categoria] = calificaciones.reduce((a, b) => a + b) / calificaciones.length;
        }
      });

      return {
        'total': total,
        'promedio': total > 0 ? sumaCalificaciones / total : 0.0,
        'cinco_estrellas': cincoEstrellas,
        'bajas': bajas,
        'distribucion': distribucion,
        'por_categoria': promediosCategoria,
      };
    } catch (e) {
      print('Error obteniendo estadísticas de calificaciones: $e');
      return {
        'total': 0,
        'promedio': 0.0,
        'cinco_estrellas': 0,
        'bajas': 0,
        'distribucion': {},
        'por_categoria': {},
      };
    }
  }

  Stream<QuerySnapshot> obtenerCalificacionesStream() {
    return _firestore
        .collection('calificaciones')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>> obtenerTendenciasCalificaciones() async {
    try {
      final DateTime ahora = DateTime.now();
      List<double> promediosMensuales = [];
      
      // Obtener promedios de los últimos 6 meses
      for (int i = 5; i >= 0; i--) {
        final DateTime inicioMes = DateTime(ahora.year, ahora.month - i, 1);
        final DateTime finMes = DateTime(ahora.year, ahora.month - i + 1, 0);
        
        final calificacionesMes = await _firestore
            .collection('calificaciones')
            .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioMes))
            .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(finMes))
            .get();
            
        if (calificacionesMes.docs.isNotEmpty) {
          double suma = 0;
          for (var doc in calificacionesMes.docs) {
            suma += (doc.data()['puntuacion'] ?? 0).toDouble();
          }
          promediosMensuales.add(suma / calificacionesMes.docs.length);
        } else {
          promediosMensuales.add(0.0);
        }
      }
      
      return {
        'promedios_mensuales': promediosMensuales,
      };
    } catch (e) {
      print('Error obteniendo tendencias de calificaciones: $e');
      return {
        'promedios_mensuales': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      };
    }
  }

  Future<List<Map<String, dynamic>>> obtenerServiciosMejorCalificados() async {
    try {
      final calificacionesSnapshot = await _firestore.collection('calificaciones').get();
      final serviciosSnapshot = await _firestore.collection('servicios').get();
      
      if (calificacionesSnapshot.docs.isEmpty || serviciosSnapshot.docs.isEmpty) {
        return [];
      }

      // Agrupar calificaciones por servicio
      Map<String, List<double>> calificacionesPorServicio = {};
      Map<String, Map<String, dynamic>> datosServicios = {};
      
      // Obtener datos de servicios
      for (var doc in serviciosSnapshot.docs) {
        datosServicios[doc.id] = doc.data();
      }
      
      // Agrupar calificaciones
      for (var doc in calificacionesSnapshot.docs) {
        final data = doc.data();
        final servicioId = data['servicioId'];
        final puntuacion = (data['puntuacion'] ?? 0).toDouble();
        
        if (servicioId != null && datosServicios.containsKey(servicioId)) {
          if (!calificacionesPorServicio.containsKey(servicioId)) {
            calificacionesPorServicio[servicioId] = [];
          }
          calificacionesPorServicio[servicioId]!.add(puntuacion);
        }
      }
      
      // Calcular promedios y crear lista
      List<Map<String, dynamic>> serviciosCalificados = [];
      
      calificacionesPorServicio.forEach((servicioId, calificaciones) {
        if (calificaciones.length >= 3) { // Solo servicios con al menos 3 calificaciones
          final promedio = calificaciones.reduce((a, b) => a + b) / calificaciones.length;
          final servicio = datosServicios[servicioId]!;
          
          serviciosCalificados.add({
            'id': servicioId,
            'titulo': servicio['titulo'] ?? 'Sin título',
            'categoria': servicio['categoria'] ?? 'General',
            'promedio': promedio,
            'total_calificaciones': calificaciones.length,
          });
        }
      });
      
      // Ordenar por promedio (descendente)
      serviciosCalificados.sort((a, b) => b['promedio'].compareTo(a['promedio']));
      
      return serviciosCalificados.take(10).toList();
    } catch (e) {
      print('Error obteniendo servicios mejor calificados: $e');
      return [];
    }
  }

  Future<void> reportarCalificacion(String calificacionId, String motivo) async {
    try {
      await _firestore.collection('reportes_calificaciones').add({
        'calificacionId': calificacionId,
        'motivo': motivo,
        'fecha': Timestamp.now(),
        'estado': 'pendiente',
      });
    } catch (e) {
      print('Error reportando calificación: $e');
      throw e;
    }
  }
}
