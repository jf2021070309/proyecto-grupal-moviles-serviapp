import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controlador/admin_controller.dart';
import '../../styles/admin_theme.dart';

class ReportesWidget extends StatefulWidget {
  @override
  _ReportesWidgetState createState() => _ReportesWidgetState();
}

class _ReportesWidgetState extends State<ReportesWidget> {
  final AdminController _adminController = AdminController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // Header con pestañas
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // Título principal
                Padding(
                  padding: EdgeInsets.all(AdminTheme.spacing),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        // Layout móvil - columna
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reportes y Estadísticas', style: AdminTheme.titleLarge),
                            SizedBox(height: AdminTheme.smallSpacing),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => setState(() {}),
                                icon: Icon(Icons.refresh, size: 18),
                                label: Text('Actualizar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminTheme.primaryColor,
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
                            Flexible(
                              child: Text('Reportes y Estadísticas', style: AdminTheme.titleLarge),
                            ),
                            SizedBox(width: AdminTheme.spacing),
                            ElevatedButton.icon(
                              onPressed: () => setState(() {}),
                              icon: Icon(Icons.refresh, size: 18),
                              label: Text('Actualizar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AdminTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                // Pestañas
                TabBar(
                  labelColor: AdminTheme.primaryColor,
                  unselectedLabelColor: AdminTheme.textSecondary,
                  indicatorColor: AdminTheme.primaryColor,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.pie_chart, size: 20),
                      text: 'General',
                    ),
                    Tab(
                      icon: Icon(Icons.bar_chart, size: 20),
                      text: 'Servicios',
                    ),
                    Tab(
                      icon: Icon(Icons.trending_up, size: 20),
                      text: 'Actividad',
                    ),
                    Tab(
                      icon: Icon(Icons.timeline, size: 20),
                      text: 'Tendencias',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              children: [
                _buildReporteGeneral(),
                _buildReporteServicios(),
                _buildReporteActividad(),
                _buildReporteTendencias(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReporteGeneral() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AdminTheme.spacing),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _adminController.obtenerEstadisticasReportes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorCard('Error al cargar estadísticas generales');
          }

          final stats = snapshot.data!;
          final usuarios = stats['usuarios'] ?? {};
          final notificaciones = stats['notificaciones'] ?? {};

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estadísticas en cards
              _buildEstadisticasGenerales(stats),
              SizedBox(height: AdminTheme.spacing),
              
              // Gráfico de distribución de usuarios
              Container(
                padding: EdgeInsets.all(AdminTheme.spacing),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
                  boxShadow: AdminTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Distribución de Usuarios', style: AdminTheme.titleMedium),
                    SizedBox(height: AdminTheme.spacing),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 500) {
                          // Layout móvil - gráfico arriba, leyenda abajo
                          return Column(
                            children: [
                              SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections: _crearSeccionesPieUsuarios(usuarios),
                                    centerSpaceRadius: 30,
                                    sectionsSpace: 2,
                                  ),
                                ),
                              ),
                              SizedBox(height: AdminTheme.spacing),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildLeyendaItemCompacta('Clientes', AdminTheme.primaryColor, usuarios['clientes'] ?? 0),
                                  _buildLeyendaItemCompacta('Proveedores', AdminTheme.accentColor, usuarios['proveedores'] ?? 0),
                                ],
                              ),
                            ],
                          );
                        } else {
                          // Layout desktop - lado a lado
                          return SizedBox(
                            height: 250,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: PieChart(
                                    PieChartData(
                                      sections: _crearSeccionesPieUsuarios(usuarios),
                                      centerSpaceRadius: 40,
                                      sectionsSpace: 2,
                                    ),
                                  ),
                                ),
                                SizedBox(width: AdminTheme.spacing),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildLeyendaItem('Clientes', AdminTheme.primaryColor, usuarios['clientes'] ?? 0),
                                      SizedBox(height: AdminTheme.spacing),
                                      _buildLeyendaItem('Proveedores', AdminTheme.accentColor, usuarios['proveedores'] ?? 0),
                                      SizedBox(height: AdminTheme.spacing),
                                      _buildLeyendaTotal('Total', usuarios['total'] ?? 0),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: AdminTheme.spacing),

              // Estado de solicitudes
              Container(
                padding: EdgeInsets.all(AdminTheme.spacing),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
                  boxShadow: AdminTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estado de Solicitudes', style: AdminTheme.titleMedium),
                    SizedBox(height: AdminTheme.spacing),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _crearSeccionesPieNotificaciones(notificaciones),
                          centerSpaceRadius: 40,
                          sectionsSpace: 3,
                        ),
                      ),
                    ),
                    SizedBox(height: AdminTheme.spacing),
                    // Leyenda
                    Wrap(
                      spacing: AdminTheme.smallSpacing,
                      runSpacing: AdminTheme.smallSpacing,
                      children: [
                        _buildLeyendaItemCompacta('Pendientes', AdminTheme.warningColor, notificaciones['pendientes'] ?? 0),
                        _buildLeyendaItemCompacta('Aceptadas', AdminTheme.successColor, notificaciones['aceptadas'] ?? 0),
                        _buildLeyendaItemCompacta('Rechazadas', AdminTheme.errorColor, notificaciones['rechazadas'] ?? 0),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReporteServicios() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AdminTheme.spacing),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _adminController.obtenerEstadisticasReportes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorCard('Error al cargar estadísticas de servicios');
          }

          final stats = snapshot.data!;
          final servicios = stats['servicios'] ?? {};
          final porCategoria = servicios['porCategoria'] as Map<String, int>? ?? {};

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gráfico de barras - Servicios por categoría
              Container(
                padding: EdgeInsets.all(AdminTheme.spacing),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
                  boxShadow: AdminTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Servicios por Categoría', style: AdminTheme.titleMedium),
                    SizedBox(height: AdminTheme.spacing),
                    
                    // Contenedor principal con gráfico y leyenda
                    porCategoria.isEmpty
                        ? Container(
                            height: 300,
                            child: Center(child: Text('No hay datos disponibles', style: AdminTheme.bodyMedium)),
                          )
                        : Column(
                            children: [
                              // Gráfico de barras
                              SizedBox(
                                height: 250,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: (porCategoria.values.isEmpty ? 10 : porCategoria.values.reduce((a, b) => a > b ? a : b)).toDouble() * 1.2,
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (double value, TitleMeta meta) {
                                            // Solo mostrar números de índice en lugar de nombres largos
                                            return Padding(
                                              padding: EdgeInsets.only(top: 8),
                                              child: Text(
                                                '${value.toInt() + 1}',
                                                style: AdminTheme.captionText,
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          },
                                          reservedSize: 30,
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (double value, TitleMeta meta) {
                                            return Text(
                                              value.toInt().toString(),
                                              style: AdminTheme.captionText,
                                            );
                                          },
                                          reservedSize: 40,
                                        ),
                                      ),
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: _crearGruposBarrasConColores(porCategoria),
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: AdminTheme.spacing),
                              
                              // Leyenda con colores
                              Container(
                                padding: EdgeInsets.all(AdminTheme.smallSpacing),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(AdminTheme.smallBorderRadius),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Leyenda:', style: AdminTheme.captionText.copyWith(fontWeight: FontWeight.bold)),
                                    SizedBox(height: AdminTheme.smallSpacing),
                                    Wrap(
                                      spacing: AdminTheme.spacing,
                                      runSpacing: AdminTheme.smallSpacing,
                                      children: _crearLeyendaCategorias(porCategoria),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReporteActividad() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AdminTheme.spacing),
      child: Column(
        children: [
          _buildActividadReciente(),
        ],
      ),
    );
  }

  Widget _buildReporteTendencias() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AdminTheme.spacing),
      child: Column(
        children: [
          _buildTendenciasMensuales(),
        ],
      ),
    );
  }

  // Métodos auxiliares
  Widget _buildErrorCard(String mensaje) {
    return Container(
      padding: EdgeInsets.all(AdminTheme.spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
        boxShadow: AdminTheme.cardShadow,
      ),
      child: Column(
        children: [
          Icon(Icons.error, size: 64, color: AdminTheme.errorColor),
          SizedBox(height: AdminTheme.spacing),
          Text(mensaje, style: AdminTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildEstadisticasGenerales(Map<String, dynamic> stats) {
    final usuarios = stats['usuarios'] ?? {};
    final servicios = stats['servicios'] ?? {};

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Layout móvil - 2 columnas
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Usuarios', usuarios['total']?.toString() ?? '0', Icons.people, AdminTheme.primaryColor)),
                  SizedBox(width: AdminTheme.smallSpacing),
                  Expanded(child: _buildStatCard('Total Servicios', servicios['total']?.toString() ?? '0', Icons.business, AdminTheme.accentColor)),
                ],
              ),
              SizedBox(height: AdminTheme.smallSpacing),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Clientes', usuarios['clientes']?.toString() ?? '0', Icons.person, AdminTheme.successColor)),
                  SizedBox(width: AdminTheme.smallSpacing),
                  Expanded(child: _buildStatCard('Proveedores', usuarios['proveedores']?.toString() ?? '0', Icons.work, AdminTheme.infoColor)),
                ],
              ),
            ],
          );
        } else {
          // Layout desktop - 4 columnas
          return Row(
            children: [
              Expanded(child: _buildStatCard('Total Usuarios', usuarios['total']?.toString() ?? '0', Icons.people, AdminTheme.primaryColor)),
              SizedBox(width: AdminTheme.spacing),
              Expanded(child: _buildStatCard('Total Servicios', servicios['total']?.toString() ?? '0', Icons.business, AdminTheme.accentColor)),
              SizedBox(width: AdminTheme.spacing),
              Expanded(child: _buildStatCard('Clientes', usuarios['clientes']?.toString() ?? '0', Icons.person, AdminTheme.successColor)),
              SizedBox(width: AdminTheme.spacing),
              Expanded(child: _buildStatCard('Proveedores', usuarios['proveedores']?.toString() ?? '0', Icons.work, AdminTheme.infoColor)),
            ],
          );
        }
      },
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AdminTheme.spacing),
          Text(value, style: AdminTheme.titleLarge.copyWith(color: color)),
          Text(title, style: AdminTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildActividadReciente() {
    return Container(
      padding: EdgeInsets.all(AdminTheme.spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
        boxShadow: AdminTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actividad Reciente', style: AdminTheme.titleMedium),
          SizedBox(height: AdminTheme.spacing),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _adminController.obtenerActividadReciente(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(AdminTheme.spacing),
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey),
                      SizedBox(height: AdminTheme.smallSpacing),
                      Text('No hay actividad reciente', style: AdminTheme.bodyMedium),
                    ],
                  ),
                );
              }

              return Column(
                children: snapshot.data!.map((actividad) =>
                  Container(
                    margin: EdgeInsets.only(bottom: AdminTheme.smallSpacing),
                    padding: EdgeInsets.all(AdminTheme.smallSpacing),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AdminTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(actividad['icono'] ?? Icons.info, 
                                     color: Colors.white, size: 16),
                        ),
                        SizedBox(width: AdminTheme.smallSpacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(actividad['descripcion'] ?? 'Actividad', 
                                   style: AdminTheme.bodyMedium),
                              Text(_formatearTiempo(actividad['fecha']), 
                                   style: AdminTheme.captionText),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTendenciasMensuales() {
    return Container(
      padding: EdgeInsets.all(AdminTheme.spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
        boxShadow: AdminTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Métricas Detalladas', style: AdminTheme.titleMedium),
          SizedBox(height: AdminTheme.spacing),
          FutureBuilder<Map<String, dynamic>>(
            future: _adminController.obtenerTendenciasMensuales(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Text('Error al cargar tendencias', style: AdminTheme.bodyMedium);
              }

              final tendencias = snapshot.data!;
              final usuarios = tendencias['usuarios'] ?? {};
              final servicios = tendencias['servicios'] ?? {};

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricaComparativa(
                          'Usuarios',
                          usuarios['este_mes'] ?? 0,
                          usuarios['mes_anterior'] ?? 0,
                          AdminTheme.primaryColor,
                        ),
                      ),
                      SizedBox(width: AdminTheme.spacing),
                      Expanded(
                        child: _buildMetricaComparativa(
                          'Servicios',
                          servicios['este_mes'] ?? 0,
                          servicios['mes_anterior'] ?? 0,
                          AdminTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricaComparativa(String titulo, int valorActual, int valorAnterior, Color color) {
    final diferencia = valorActual - valorAnterior;
    final porcentaje = valorAnterior > 0 ? (diferencia / valorAnterior * 100) : 0.0;
    final esPositivo = diferencia >= 0;

    return Container(
      padding: EdgeInsets.all(AdminTheme.spacing),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: AdminTheme.bodyMedium.copyWith(color: color)),
          SizedBox(height: AdminTheme.smallSpacing),
          Text('$valorActual', style: AdminTheme.titleLarge.copyWith(color: color)),
          SizedBox(height: AdminTheme.smallSpacing),
          Row(
            children: [
              Icon(
                esPositivo ? Icons.trending_up : Icons.trending_down,
                color: esPositivo ? AdminTheme.successColor : AdminTheme.errorColor,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                '${porcentaje.toStringAsFixed(1)}%',
                style: AdminTheme.captionText.copyWith(
                  color: esPositivo ? AdminTheme.successColor : AdminTheme.errorColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Función para generar colores únicos para cada categoría
  List<Color> _generarColoresUnicos(int cantidad) {
    final colores = <Color>[
      AdminTheme.primaryColor,
      AdminTheme.secondaryColor,
      AdminTheme.accentColor,
      AdminTheme.successColor,
      AdminTheme.warningColor,
      AdminTheme.errorColor,
      AdminTheme.infoColor,
      const Color(0xFF9B59B6), // Púrpura
      const Color(0xFFE67E22), // Naranja
      const Color(0xFF1ABC9C), // Turquesa
      const Color(0xFF34495E), // Azul grisáceo
      const Color(0xFFE74C3C), // Rojo
      const Color(0xFF2ECC71), // Verde
      const Color(0xFFF39C12), // Amarillo
      const Color(0xFF8E44AD), // Violeta
    ];

    if (cantidad <= colores.length) {
      return colores.take(cantidad).toList();
    }

    // Si necesitamos más colores, generamos algunos adicionales
    final coloresExtendidos = List<Color>.from(colores);
    for (int i = colores.length; i < cantidad; i++) {
      coloresExtendidos.add(Color((0xFF000000 + (i * 123456)) % 0xFFFFFFFF));
    }
    return coloresExtendidos.take(cantidad).toList();
  }

  // Crear secciones del gráfico de pie para usuarios
  List<PieChartSectionData> _crearSeccionesPieUsuarios(Map<String, dynamic> usuarios) {
    final clientes = usuarios['clientes'] ?? 0;
    final proveedores = usuarios['proveedores'] ?? 0;
    final total = clientes + proveedores;
    
    if (total == 0) return [];
    
    return [
      PieChartSectionData(
        color: AdminTheme.primaryColor,
        value: clientes.toDouble(),
        title: '${(clientes / total * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: AdminTheme.captionText.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: AdminTheme.accentColor,
        value: proveedores.toDouble(),
        title: '${(proveedores / total * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: AdminTheme.captionText.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }

  // Crear secciones del gráfico de pie para notificaciones
  List<PieChartSectionData> _crearSeccionesPieNotificaciones(Map<String, dynamic> notificaciones) {
    final pendientes = notificaciones['pendientes'] ?? 0;
    final aceptadas = notificaciones['aceptadas'] ?? 0;
    final rechazadas = notificaciones['rechazadas'] ?? 0;
    final total = pendientes + aceptadas + rechazadas;
    
    if (total == 0) return [];
    
    return [
      PieChartSectionData(
        color: AdminTheme.warningColor,
        value: pendientes.toDouble(),
        title: '${(pendientes / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: AdminTheme.captionText.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: AdminTheme.successColor,
        value: aceptadas.toDouble(),
        title: '${(aceptadas / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: AdminTheme.captionText.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: AdminTheme.errorColor,
        value: rechazadas.toDouble(),
        title: '${(rechazadas / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: AdminTheme.captionText.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }

  Widget _buildLeyendaItemCompacta(String label, Color color, int valor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text('$label: $valor', style: AdminTheme.captionText),
      ],
    );
  }

  Widget _buildLeyendaItem(String label, Color color, int valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Text(label, style: AdminTheme.bodyMedium),
          ],
        ),
        SizedBox(height: 4),
        Text('$valor', style: AdminTheme.titleMedium.copyWith(color: color)),
      ],
    );
  }

  Widget _buildLeyendaTotal(String label, int valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AdminTheme.bodyMedium),
        SizedBox(height: 4),
        Text('$valor', style: AdminTheme.titleMedium),
      ],
    );
  }

  // Crear grupos de barras con colores únicos
  List<BarChartGroupData> _crearGruposBarrasConColores(Map<String, dynamic> porCategoria) {
    final categorias = porCategoria.keys.toList();
    final colores = _generarColoresUnicos(categorias.length);
    
    return categorias.asMap().entries.map((entry) {
      final index = entry.key;
      final categoria = entry.value;
      final valor = porCategoria[categoria] ?? 0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: valor.toDouble(),
            color: colores[index % colores.length],
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  // Crear widgets de leyenda para las categorías
  List<Widget> _crearLeyendaCategorias(Map<String, dynamic> porCategoria) {
    final categorias = porCategoria.keys.toList();
    final colores = _generarColoresUnicos(categorias.length);
    
    return categorias.asMap().entries.map((entry) {
      final index = entry.key;
      final categoria = entry.value;
      final valor = porCategoria[categoria] ?? 0;
      
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AdminTheme.smallBorderRadius),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${index + 1}.',
              style: AdminTheme.captionText.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colores[index % colores.length],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                '$categoria ($valor)',
                style: AdminTheme.captionText,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();
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
