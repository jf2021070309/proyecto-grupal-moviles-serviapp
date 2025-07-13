// lib/modelo/calificacion_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Calificacion {
  final String id;
  final String servicioId;
  final String usuarioId;
  final String nombreUsuario;
  final int puntuacion; // 1-5
  final String? comentario;
  final DateTime fecha;

  Calificacion({
    required this.id,
    required this.servicioId,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.puntuacion,
    this.comentario,
    required this.fecha,
  });

  factory Calificacion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Calificacion(
      id: doc.id,
      servicioId: data['servicioId'],
      usuarioId: data['usuarioId'],
      nombreUsuario: data['nombreUsuario'],
      puntuacion: data['puntuacion'],
      comentario: data['comentario'],
      fecha: (data['fecha'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'servicioId': servicioId,
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'puntuacion': puntuacion,
      'comentario': comentario,
      'fecha': Timestamp.fromDate(fecha),
    };
  }
}