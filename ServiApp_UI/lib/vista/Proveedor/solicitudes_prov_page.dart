import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviapp/modelo/global_user.dart';

class SolicitudesPage extends StatelessWidget {
  final String? proveedorIdActual = GlobalUser.uid;

  @override
  Widget build(BuildContext context) {
    if (proveedorIdActual == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Solicitudes')),
        body: Center(child: Text('Proveedor no identificado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Solicitudes Aceptadas')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('notificaciones')
                .where('proveedorId', isEqualTo: proveedorIdActual)
                .where('estado', isEqualTo: 'aceptado')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(child: Text('No tienes solicitudes aceptadas.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final cliente = data['nombreCliente'] ?? 'Cliente desconocido';
              final subcategoria = data['subcategoria'] ?? 'Sin categoría';
              final fecha =
                  data['timestamp'] != null
                      ? (data['timestamp'] as Timestamp).toDate()
                      : null;

              return SolicitudCard(
                cliente: cliente,
                subcategoria: subcategoria,
                fecha: fecha,
                docId: docs[index].id,
              );
            },
          );
        },
      ),
    );
  }
}

class SolicitudCard extends StatefulWidget {
  final String cliente;
  final String subcategoria;
  final DateTime? fecha;
  final String docId;

  const SolicitudCard({
    required this.cliente,
    required this.subcategoria,
    required this.fecha,
    required this.docId,
    Key? key,
  }) : super(key: key);

  @override
  State<SolicitudCard> createState() => _SolicitudCardState();
}

class _SolicitudCardState extends State<SolicitudCard> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('notificaciones')
              .doc(widget.docId)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            child: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        if (data == null) return SizedBox.shrink();

        final etapaActual = (data['etapa'] as String?)?.trim();
        final estado = data['estado'] as String?;

        // Ocultar tarjeta si fue rechazado
        if (estado == 'rechazado') return SizedBox.shrink();

        final hayEtapa = etapaActual != null && etapaActual.isNotEmpty;
        final mostrarPreguntaAcuerdo = !hayEtapa;

        Future<void> _actualizarEstado(String nuevoEstado) async {
          await FirebaseFirestore.instance
              .collection('notificaciones')
              .doc(widget.docId)
              .update({'estado': nuevoEstado});
        }

        Future<void> _actualizarEtapa(String nuevaEtapa) async {
          await FirebaseFirestore.instance
              .collection('notificaciones')
              .doc(widget.docId)
              .update({'etapa': nuevaEtapa});
          if (!mounted) return;

          String mensaje;
          switch (nuevaEtapa) {
            case 'no iniciado':
              mensaje = '✅ Servicio marcado como no iniciado';
              break;
            case 'iniciado':
              mensaje = '✅ Servicio marcado como iniciado';
              break;
            case 'finalizado':
              mensaje = '✅ Servicio marcado como finalizado';
              break;
            default:
              mensaje = 'Etapa actualizada';
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(mensaje)));
        }

        Color _colorPorEtapa() {
          switch (etapaActual) {
            case 'iniciado':
              return Colors.orange;
            case 'finalizado':
              return Colors.green;
            default:
              return Colors.grey;
          }
        }

        String _textoPorEtapa() {
          switch (etapaActual) {
            case 'iniciado':
              return 'Iniciado';
            case 'finalizado':
              return 'Finalizado';
            default:
              return 'No iniciado';
          }
        }

        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Servicio: ${widget.subcategoria}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (hayEtapa)
                      Chip(
                        label: Text(
                          _textoPorEtapa(),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: _colorPorEtapa(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Cliente: ${widget.cliente}',
                  style: TextStyle(fontSize: 13),
                ),
                if (widget.fecha != null)
                  Text(
                    // Forzar UTC-5 restando 5 horas
                    () {
                      final fechaForzada = widget.fecha!.subtract(
                        Duration(hours: 5),
                      );
                      return 'Fecha y hora: '
                          '${fechaForzada.day}/${fechaForzada.month}/${fechaForzada.year} '
                          '${fechaForzada.hour.toString().padLeft(2, '0')}:'
                          '${fechaForzada.minute.toString().padLeft(2, '0')}';
                    }(),
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),

                SizedBox(height: 10),

                if (mostrarPreguntaAcuerdo) ...[
                  Text(
                    '¿Se llegó a un acuerdo con el cliente?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => _actualizarEtapa('no iniciado'),
                        child: Text(
                          'Sí, fue acordado',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(80, 30),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => _actualizarEstado('rechazado'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          minimumSize: Size(80, 30),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        child: Text(
                          'No, rechazar',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],

                if (hayEtapa) ...[
                  SizedBox(height: 12),
                  Text(
                    '¿En qué etapa se encuentra este servicio?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () => _actualizarEtapa('iniciado'),
                        child: Text('Iniciado', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(100, 30),
                          backgroundColor:
                              etapaActual == 'iniciado' ? Colors.orange : null,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _actualizarEtapa('finalizado'),
                        child: Text(
                          'Finalizado',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(100, 30),
                          backgroundColor:
                              etapaActual == 'finalizado' ? Colors.green : null,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
