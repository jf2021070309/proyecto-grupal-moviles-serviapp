import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../styles/admin_theme.dart';

class ReportesPublicacionesWidget extends StatefulWidget {
  @override
  _ReportesPublicacionesWidgetState createState() => _ReportesPublicacionesWidgetState();
}

class _ReportesPublicacionesWidgetState extends State<ReportesPublicacionesWidget> {
  Map<String, Map<String, dynamic>> _reportesAgrupados = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    setState(() => _cargando = true);
    
    try {
      final reportesSnapshot = await FirebaseFirestore.instance
          .collection('reportes')
          .orderBy('fechaReporte', descending: true)
          .get();

      Map<String, Map<String, dynamic>> reportesAgrupados = {};

      for (var reporteDoc in reportesSnapshot.docs) {
        final reporteData = reporteDoc.data();
        final servicioId = reporteData['servicioId'];

        if (reportesAgrupados.containsKey(servicioId)) {
          // Incrementar contador y agregar motivo
          reportesAgrupados[servicioId]!['totalReportes']++;
          reportesAgrupados[servicioId]!['motivos'].add(reporteData['motivo']);
          reportesAgrupados[servicioId]!['reportes'].add({
            'id': reporteDoc.id,
            'usuarioId': reporteData['usuarioId'],
            'motivo': reporteData['motivo'],
            'descripcion': reporteData['descripcion'] ?? '',
            'fechaReporte': reporteData['fechaReporte'],
          });
        } else {
          // Obtener datos del servicio
          final servicioSnapshot = await FirebaseFirestore.instance
              .collection('servicios')
              .doc(servicioId)
              .get();

          if (servicioSnapshot.exists) {
            final servicioData = servicioSnapshot.data()!;
            reportesAgrupados[servicioId] = {
              'servicioId': servicioId,
              'titulo': servicioData['titulo'] ?? 'Sin título',
              'descripcion': servicioData['descripcion'] ?? 'Sin descripción',
              'proveedorId': servicioData['idusuario'],
              'bloqueado': servicioData['bloqueado'] ?? false,
              'totalReportes': 1,
              'motivos': [reporteData['motivo']],
              'reportes': [{
                'id': reporteDoc.id,
                'usuarioId': reporteData['usuarioId'],
                'motivo': reporteData['motivo'],
                'descripcion': reporteData['descripcion'] ?? '',
                'fechaReporte': reporteData['fechaReporte'],
              }],
            };
          }
        }
      }

      // Ordenar por cantidad de reportes (mayor a menor)
      final reportesOrdenados = Map.fromEntries(
        reportesAgrupados.entries.toList()
          ..sort((a, b) => b.value['totalReportes'].compareTo(a.value['totalReportes']))
      );

      setState(() {
        _reportesAgrupados = reportesOrdenados;
        _cargando = false;
      });
    } catch (e) {
      print('Error cargando reportes: $e');
      setState(() => _cargando = false);
    }
  }

  // Método para obtener el nombre del usuario
  Future<String> _obtenerNombreUsuario(String usuarioId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(usuarioId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['nombre'] ?? 'Usuario sin nombre';
      } else {
        return 'Usuario no encontrado';
      }
    } catch (e) {
      print('Error al obtener nombre del usuario: $e');
      return 'Error al cargar nombre';
    }
  }

  // Método para formatear fecha
  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return 'Sin fecha';
    try {
      final DateTime fechaDate = fecha is DateTime ? fecha : fecha.toDate();
      return '${fechaDate.day}/${fechaDate.month}/${fechaDate.year} ${fechaDate.hour.toString().padLeft(2, '0')}:${fechaDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AdminTheme.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reportes de Publicaciones', style: AdminTheme.titleLarge),
                        Text(
                          'Publicaciones reportadas por los usuarios',
                          style: AdminTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _cargarReportes,
                    icon: Icon(Icons.refresh),
                    label: Text('Actualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.secondaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: AdminTheme.largeSpacing),

          // Contenido
          Expanded(
            child: _cargando
                ? Center(child: CircularProgressIndicator())
                : _reportesAgrupados.isEmpty
                    ? _buildEmptyState()
                    : _buildReportesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No hay reportes de publicaciones',
            style: AdminTheme.titleMedium.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Las publicaciones reportadas aparecerán aquí',
            style: AdminTheme.bodyMedium.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportesList() {
    return ListView.builder(
      itemCount: _reportesAgrupados.length,
      itemBuilder: (context, index) {
        final servicioId = _reportesAgrupados.keys.elementAt(index);
        final reporte = _reportesAgrupados[servicioId]!;
        return _buildReporteCard(servicioId, reporte);
      },
    );
  }

  Widget _buildReporteCard(String servicioId, Map<String, dynamic> reporte) {
    final totalReportes = reporte['totalReportes'] as int;
    final motivos = reporte['motivos'] as List;
    final bloqueado = reporte['bloqueado'] as bool;
    
    // Contar motivos más frecuentes
    Map<String, int> motivosCount = {};
    for (String motivo in motivos) {
      motivosCount[motivo] = (motivosCount[motivo] ?? 0) + 1;
    }
    final motivoPrincipal = motivosCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return Container(
      margin: EdgeInsets.only(bottom: AdminTheme.spacing),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
        boxShadow: AdminTheme.softShadow,
        border: bloqueado 
            ? Border.all(color: Colors.red.shade300, width: 2)
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(AdminTheme.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del reporte
            Row(
              children: [
                // Indicador de prioridad
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(totalReportes),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalReportes reporte${totalReportes > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                if (bloqueado) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'BLOQUEADO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    'Motivo principal: $motivoPrincipal',
                    style: AdminTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Información del servicio
            Text(
              reporte['titulo'],
              style: AdminTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              reporte['descripcion'],
              style: AdminTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: 16),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _mostrarDetallesReporte(servicioId, reporte),
                    icon: Icon(Icons.visibility),
                    label: Text('Ver Detalles'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleBloqueoPublicacion(servicioId, !bloqueado),
                    icon: Icon(bloqueado ? Icons.lock_open : Icons.block),
                    label: Text(bloqueado ? 'Desbloquear' : 'Bloquear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bloqueado ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(int totalReportes) {
    if (totalReportes >= 5) return Colors.red;
    if (totalReportes >= 3) return Colors.orange;
    return Colors.blue;
  }

  void _mostrarDetallesReporte(String servicioId, Map<String, dynamic> reporte) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Detalles del Reporte',
                        style: AdminTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Información del servicio
                _buildDetalleItem('Servicio', reporte['titulo']),
                _buildDetalleItem('Total de reportes', '${reporte['totalReportes']}'),
                _buildDetalleItem('Estado', reporte['bloqueado'] ? 'BLOQUEADO' : 'Activo'),
                
                SizedBox(height: 16),
                
                Text('Reportes individuales:', style: AdminTheme.titleMedium),
                SizedBox(height: 8),
                
                // Lista de reportes
                Flexible(
                  child: Container(
                    height: 200,
                    child: ListView.builder(
                      itemCount: reporte['reportes'].length,
                      itemBuilder: (context, index) {
                        final reporteIndividual = reporte['reportes'][index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Motivo: ${reporteIndividual['motivo']}',
                                style: TextStyle(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              if (reporteIndividual['descripcion'].isNotEmpty) ...[
                                SizedBox(height: 4),
                                Text(
                                  'Descripción: ${reporteIndividual['descripcion']}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ],
                              SizedBox(height: 4),
                              FutureBuilder<String>(
                                future: _obtenerNombreUsuario(reporteIndividual['usuarioId']),
                                builder: (context, snapshot) {
                                  final nombreUsuario = snapshot.data ?? 'Cargando...';
                                  return Text(
                                    'Usuario: $nombreUsuario',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  );
                                },
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Fecha: ${_formatearFecha(reporteIndividual['fechaReporte'])}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetalleItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AdminTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AdminTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBloqueoPublicacion(String servicioId, bool bloquear) async {
    try {
      await FirebaseFirestore.instance
          .collection('servicios')
          .doc(servicioId)
          .update({'bloqueado': bloquear});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bloquear 
                ? 'Publicación bloqueada correctamente'
                : 'Publicación desbloqueada correctamente',
          ),
          backgroundColor: bloquear ? Colors.red : Colors.green,
        ),
      );

      // Recargar los reportes para actualizar el estado
      _cargarReportes();
    } catch (e) {
      print('Error bloqueando/desbloqueando publicación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el estado de la publicación'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
