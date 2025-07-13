import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controlador/admin_controller.dart';
import '../../styles/admin_theme.dart';

class DashboardWidget extends StatefulWidget {
  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final AdminController _adminController = AdminController();
  Map<String, dynamic> _estadisticas = {};
  bool _cargandoEstadisticas = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    final stats = await _adminController.obtenerEstadisticasDashboard();
    setState(() {
      _estadisticas = stats;
      _cargandoEstadisticas = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminTheme.largeSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Layout responsive
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Layout móvil - columna
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dashboard', style: AdminTheme.titleLarge),
                        Text('Resumen general del sistema', style: AdminTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: AdminTheme.spacing),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _cargarEstadisticas,
                        icon: Icon(Icons.refresh),
                        label: Text('Actualizar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.secondaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Layout desktop - fila
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dashboard', style: AdminTheme.titleLarge),
                        Text('Resumen general del sistema', style: AdminTheme.bodyMedium),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _cargarEstadisticas,
                      icon: Icon(Icons.refresh),
                      label: Text('Actualizar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminTheme.secondaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: AdminTheme.largeSpacing),
          
          if (_cargandoEstadisticas)
            Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                // Tarjetas de estadísticas - Layout responsive
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // Layout móvil - 2x1 grid (sin calificación)
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildStatCard(
                                'Clientes',
                                _estadisticas['totalClientes']?.toString() ?? '0',
                                Icons.person,
                                AdminTheme.successColor,
                              )),
                              const SizedBox(width: AdminTheme.spacing),
                              Expanded(child: _buildStatCard(
                                'Proveedores',
                                _estadisticas['totalProveedores']?.toString() ?? '0',
                                Icons.business,
                                AdminTheme.infoColor,
                              )),
                            ],
                          ),
                          const SizedBox(height: AdminTheme.spacing),
                          Row(
                            children: [
                              Expanded(child: _buildStatCard(
                                'Servicios',
                                _estadisticas['totalServicios']?.toString() ?? '0',
                                Icons.build,
                                AdminTheme.warningColor,
                              )),
                              // ELIMINADO: Tarjeta de Calificación
                              const SizedBox(width: AdminTheme.spacing),
                              Expanded(child: Container()), // Espacio vacío para mantener el layout
                            ],
                          ),
                        ],
                      );
                    } else {
                      // Layout desktop - 1x3 grid (sin calificación)
                      return Row(
                        children: [
                          Expanded(child: _buildStatCard(
                            'Clientes',
                            _estadisticas['totalClientes']?.toString() ?? '0',
                            Icons.person,
                            AdminTheme.successColor,
                          )),
                          const SizedBox(width: AdminTheme.spacing),
                          Expanded(child: _buildStatCard(
                            'Proveedores',
                            _estadisticas['totalProveedores']?.toString() ?? '0',
                            Icons.business,
                            AdminTheme.infoColor,
                          )),
                          const SizedBox(width: AdminTheme.spacing),
                          Expanded(child: _buildStatCard(
                            'Servicios',
                            _estadisticas['totalServicios']?.toString() ?? '0',
                            Icons.build,
                            AdminTheme.warningColor,
                          )),
                          // ELIMINADO: Tarjeta de Calificación
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: AdminTheme.largeSpacing),
                
                // Gráficos - Layout responsive
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 800) {
                      // Layout móvil - columnas apiladas
                      return Column(
                        children: [
                          _buildNotificacionesChart(),
                          const SizedBox(height: AdminTheme.spacing),
                          _buildRecentActivity(),
                        ],
                      );
                    } else {
                      // Layout desktop - lado a lado
                      return Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildNotificacionesChart(),
                          ),
                          const SizedBox(width: AdminTheme.spacing),
                          Expanded(
                            child: _buildRecentActivity(),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.spacing),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
        boxShadow: AdminTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const SizedBox(height: AdminTheme.spacing),
          Text(
            value,
            style: AdminTheme.titleLarge.copyWith(color: color),
          ),
          Text(
            title,
            style: AdminTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificacionesChart() {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.spacing),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
        boxShadow: AdminTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estado de Solicitudes', style: AdminTheme.titleMedium),
          const SizedBox(height: AdminTheme.spacing),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _crearSeccionesPieNotificaciones(),
                centerSpaceRadius: 60,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: AdminTheme.spacing),
          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLeyendaItem('Pendientes', AdminTheme.warningColor, _estadisticas['notificacionesPendientes'] ?? 0),
              _buildLeyendaItem('Aceptadas', AdminTheme.successColor, _estadisticas['notificacionesAceptadas'] ?? 0),
              _buildLeyendaItem('Rechazadas', AdminTheme.errorColor, _estadisticas['notificacionesRechazadas'] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeyendaItem(String label, Color color, int valor) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text('$label', style: AdminTheme.captionText),
        Text('$valor', style: AdminTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  List<PieChartSectionData> _crearSeccionesPieNotificaciones() {
    final pendientes = _estadisticas['notificacionesPendientes'] ?? 0;
    final aceptadas = _estadisticas['notificacionesAceptadas'] ?? 0;
    final rechazadas = _estadisticas['notificacionesRechazadas'] ?? 0;
    final total = pendientes + aceptadas + rechazadas;

    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          title: 'Sin datos',
          radius: 60,
          titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ];
    }

    List<PieChartSectionData> sections = [];
    
    if (pendientes > 0) {
      sections.add(PieChartSectionData(
        color: AdminTheme.warningColor,
        value: pendientes.toDouble(),
        title: '${(pendientes / total * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }
    
    if (aceptadas > 0) {
      sections.add(PieChartSectionData(
        color: AdminTheme.successColor,
        value: aceptadas.toDouble(),
        title: '${(aceptadas / total * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }
    
    if (rechazadas > 0) {
      sections.add(PieChartSectionData(
        color: AdminTheme.errorColor,
        value: rechazadas.toDouble(),
        title: '${(rechazadas / total * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }

    return sections;
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.spacing),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
        boxShadow: AdminTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actividad Reciente', style: AdminTheme.titleMedium),
          const SizedBox(height: AdminTheme.spacing),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _adminController.obtenerActividadReciente(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Column(
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.grey),
                    SizedBox(height: AdminTheme.smallSpacing),
                    Text('No hay actividad reciente', style: AdminTheme.bodyMedium),
                  ],
                );
              }

              return Column(
                children: snapshot.data!.take(5).map((actividad) =>
                  _buildActivityItem(
                    actividad['icono'] ?? Icons.info,
                    actividad['descripcion'] ?? 'Actividad',
                    _formatearTiempo(actividad['fecha']),
                  )
                ).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, String description, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdminTheme.secondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AdminTheme.secondaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description, style: AdminTheme.bodyMedium),
                Text('hace $time', style: AdminTheme.captionText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatearTiempo(dynamic timestamp) {
    if (timestamp == null) return 'un momento';
    try {
      final DateTime fecha = timestamp is DateTime ? timestamp : timestamp.toDate();
      final diferencia = DateTime.now().difference(fecha);
      
      if (diferencia.inDays > 0) {
        return '${diferencia.inDays} día${diferencia.inDays == 1 ? '' : 's'}';
      } else if (diferencia.inHours > 0) {
        return '${diferencia.inHours} hora${diferencia.inHours == 1 ? '' : 's'}';
      } else if (diferencia.inMinutes > 0) {
        return '${diferencia.inMinutes} minuto${diferencia.inMinutes == 1 ? '' : 's'}';
      } else {
        return 'un momento';
      }
    } catch (e) {
      return 'un momento';
    }
  }
}
