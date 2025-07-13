// lib/servicios/calificacion_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviapp/modelo/calificacion_model.dart';

class CalificacionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> agregarCalificacion(Calificacion calificacion) async {
    final batch = _firestore.batch();
    
    // 1. Agregar a subcolección de calificaciones
    final calificacionRef = _firestore
        .collection('servicios')
        .doc(calificacion.servicioId)
        .collection('calificaciones')
        .doc();
    
    batch.set(calificacionRef, calificacion.toMap());

    // 2. Actualizar contadores en el servicio
    final servicioRef = _firestore.collection('servicios').doc(calificacion.servicioId);
    batch.update(servicioRef, {
      'totalCalificaciones': FieldValue.increment(1),
      'sumaCalificaciones': FieldValue.increment(calificacion.puntuacion),
    });

    // 3. Registrar en el usuario para evitar duplicados
    final usuarioRef = _firestore.collection('usuarios').doc(calificacion.usuarioId);
    batch.update(usuarioRef, {
      'serviciosCalificados': FieldValue.arrayUnion([calificacion.servicioId])
    });

    await batch.commit();
  }

  Stream<double> obtenerPromedio(String servicioId) {
    return _firestore.collection('servicios').doc(servicioId).snapshots().map(
      (doc) {
        final data = doc.data();
        if (data == null || data['totalCalificaciones'] == 0) return 0.0;
        return (data['sumaCalificaciones'] / data['totalCalificaciones']).toDouble();
      },
    );
  }

  Stream<List<Calificacion>> obtenerUltimasCalificaciones(String servicioId) {
    return _firestore
        .collection('servicios')
        .doc(servicioId)
        .collection('calificaciones')
        .orderBy('fecha', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Calificacion.fromFirestore(doc))
            .toList());
  }
}