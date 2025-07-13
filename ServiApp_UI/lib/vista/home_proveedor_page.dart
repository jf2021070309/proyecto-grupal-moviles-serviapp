import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de tener esto
import 'package:flutter/material.dart';
import 'package:serviapp/modelo/global_user.dart';
import 'package:serviapp/vista/Usuario/perfil_usuario.dart';
import '../controlador/login_controller.dart';
import '../controlador/home_controller.dart';
import '../modelo/categoria_model.dart';
import '../modelo/contacto_model.dart';
import 'Services/tecnologia_page.dart';
import 'Services/eventos_page.dart';
import 'Services/belleza_page.dart';
import 'Services/educacion_page.dart';
import 'Services/limpieza_page.dart';
import 'Services/vehiculos_page.dart';
import 'Services/salud_page.dart';
import 'Services/servicios_generales_page.dart';
import 'package:serviapp/styles/home_proveedor_styles.dart';
import 'package:serviapp/vista/Proveedor/agregar_servicio_page.dart';
import 'package:serviapp/vista/Proveedor/solicitudes_prov_page.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'Proveedor/mis_servicios.dart';
import 'Proveedor/recargar_tokens_page.dart';

class HomeProveedorPage extends StatefulWidget {
  @override
  State<HomeProveedorPage> createState() => _HomeProveedorPageState();
}

class _HomeProveedorPageState extends State<HomeProveedorPage> {
  final LoginController loginController = LoginController();
  final HomeController homeController = HomeController();
  StreamSubscription? _solicitudesSubscription;

  int _selectedIndex = 0;
  int _mostrarCantidadCalificaciones = 3;

  // Aquí asigna tu proveedorId actual, puede venir de tu login o controlador
  final String? proveedorIdActual = GlobalUser.uid;
  bool _dialogShowing = false;
  String? _currentSolicitudId;

  Future<void> _verificarPromocionesVencidas() async {
    final now = DateTime.now();
    final snap = await FirebaseFirestore.instance
        .collection('servicios')
        .where('slide', isEqualTo: 'true')
        .where('idusuario', isEqualTo: proveedorIdActual) // Solo tus servicios
        .get();

    for (final doc in snap.docs) {
      final data = doc.data();
      final promocionFin = data['promocionFin'];
      if (promocionFin != null && promocionFin is Timestamp) {
        if (promocionFin.toDate().isBefore(now)) {
          await FirebaseFirestore.instance
              .collection('servicios')
              .doc(doc.id)
              .update({
            'slide': 'false',
            'promocionInicio': FieldValue.delete(),
            'promocionFin': FieldValue.delete(),
            'promocionTipo': FieldValue.delete(),
            'promocionTokensUsados': FieldValue.delete(),
          });
        }
      }
    }
  }

  void logout(BuildContext context) async {
    await loginController.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

Widget _buildRendimientoDiario() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rendimiento diario', style: HomeProveedorStyles.titleStyle),
        SizedBox(height: 12),
        Container(
          height: 300,
          decoration: HomeProveedorStyles.cardDecoration,
          child: PageView(
            children: [
              _buildGraficoSolicitudes(),
              _buildGraficoFinalizados(),
            ],
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Desliza para ver trabajos finalizados →',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildGraficoSolicitudes() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.blue.shade50, Colors.white],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.trending_up, color: Colors.blue.shade700, size: 24),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solicitudes recibidas',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    'Esta semana',
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getStreamSolicitudesSemana(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.blue));
                }

                final datos = _procesarDatosSemana(snapshot.data?.docs ?? [], 'solicitudes');
                
                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: false,
                      drawVerticalLine: true,
                      horizontalInterval: 1,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 0.8,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 0.8,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true, 
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const dias = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                            return Container(
                              margin: EdgeInsets.only(top: 8),
                              child: Text(
                                dias[value.toInt()],
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: datos,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: Colors.blue.shade600,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 6,
                            color: Colors.white,
                            strokeWidth: 3,
                            strokeColor: Colors.blue.shade600,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.blue.shade400.withOpacity(0.3),
                              Colors.blue.shade100.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildGraficoFinalizados() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.green.shade50, Colors.white],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 24),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trabajos finalizados',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    'Esta semana',
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getStreamFinalizadosSemana(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.green));
                }

                final datos = _procesarDatosSemana(snapshot.data?.docs ?? [], 'finalizados');
                
                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: false,
                      drawVerticalLine: true,
                      horizontalInterval: 1,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 0.8,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 0.8,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true, 
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const dias = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                            return Container(
                              margin: EdgeInsets.only(top: 8),
                              child: Text(
                                dias[value.toInt()],
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: datos,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: Colors.green.shade600,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 6,
                            color: Colors.white,
                            strokeWidth: 3,
                            strokeColor: Colors.green.shade600,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.green.shade400.withOpacity(0.3),
                              Colors.green.shade100.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Stream<QuerySnapshot> _getStreamSolicitudesSemana() {
  return FirebaseFirestore.instance
      .collection('notificaciones')
      .where('proveedorId', isEqualTo: proveedorIdActual)
      .snapshots();
}

Stream<QuerySnapshot> _getStreamFinalizadosSemana() {
  return FirebaseFirestore.instance
      .collection('notificaciones')
      .where('proveedorId', isEqualTo: proveedorIdActual)
      .where('etapa', isEqualTo: 'finalizado')
      .snapshots();
}

List<FlSpot> _procesarDatosSemana(List<QueryDocumentSnapshot> docs, String tipo) {
  // Inicializar contadores para cada día de la semana (0=Lunes, 6=Domingo)
  List<int> contadores = List.filled(7, 0);
  
  final ahora = DateTime.now();
  final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
  
  for (var doc in docs) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = (data['timestamp'] as Timestamp).toDate();
    
    // Solo procesar documentos de esta semana
    final diferenciaDias = timestamp.difference(inicioSemana).inDays;
    if (diferenciaDias >= 0 && diferenciaDias < 7) {
      if (tipo == 'solicitudes') {
        // Para solicitudes: contar TODAS las notificaciones (contactos recibidos)
        contadores[diferenciaDias]++;
      } else if (tipo == 'finalizados') {
        // Para finalizados: SOLO contar las que tienen etapa exactamente 'finalizado'
        final etapa = data['etapa']?.toString() ?? '';
        if (etapa == 'finalizado') {
          contadores[diferenciaDias]++;
        }
      }
    }
  }
  
  // Convertir a FlSpot para el gráfico
  return contadores.asMap().entries.map((entry) {
    return FlSpot(entry.key.toDouble(), entry.value.toDouble());
  }).toList();
}

Widget _buildAgregarServicio() {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgregarServicioPage(),
            ),
          );
        },
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Agregar servicio',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
  );
}


Widget _buildUltimasCalificaciones() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mis últimas calificaciones', style: HomeProveedorStyles.titleStyle),
        SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('calificaciones')
              .where('proveedorId', isEqualTo: proveedorIdActual)
              .snapshots(),
          builder: (context, snapshot) {
            // ... tu código de error y loading existente ...
            
            var calificaciones = snapshot.data?.docs ?? [];
            
            // Ordenar por timestamp
            calificaciones.sort((a, b) {
              final timestampA = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
              final timestampB = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
              
              if (timestampA == null && timestampB == null) return 0;
              if (timestampA == null) return 1;
              if (timestampB == null) return -1;
              
              return timestampB.compareTo(timestampA);
            });
            
            if (calificaciones.isEmpty) {
              // ... tu código de empty state existente ...
            }
            
            // NUEVA LÓGICA EXPANDIBLE
            final totalCalificaciones = calificaciones.length;
            final calificacionesAMostrar = calificaciones.take(_mostrarCantidadCalificaciones).toList();
            final hayMas = totalCalificaciones > _mostrarCantidadCalificaciones;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cards de calificaciones
                ...calificacionesAMostrar.asMap().entries.map((entry) {
                  return _buildCalificacionCard(entry.value, entry.key);
                }).toList(),
                
                // Botón Ver más
                if (hayMas) ...[
                  SizedBox(height: 16),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _mostrarCantidadCalificaciones += 3;
                        });
                      },
                      icon: Icon(Icons.expand_more, size: 18),
                      label: Text('Ver más calificaciones'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                        side: BorderSide(color: Colors.blue[300]!),
                      ),
                    ),
                  ),
                ],
                
                // Botón Ver menos
                if (_mostrarCantidadCalificaciones > 3 && totalCalificaciones > 3) ...[
                  SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _mostrarCantidadCalificaciones = 3;
                        });
                      },
                      icon: Icon(Icons.expand_less, size: 18),
                      label: Text('Ver menos'),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    ),
  );
}

Widget _buildCalificacionCard(QueryDocumentSnapshot calificacionDoc, int index) {
  final calificacion = calificacionDoc.data() as Map<String, dynamic>;
  final clienteId = calificacion['clienteId'] ?? '';
  final puntuacion = calificacion['puntuacion'] ?? 0;
  final comentario = calificacion['comentario'] ?? '';
  final tipoServicio = calificacion['tipoServicio'] ?? 'Servicio no especificado';
  final timestamp = (calificacion['timestamp'] as Timestamp?)?.toDate();
  
  final colores = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal];
  final colorAvatar = colores[index % colores.length];
  
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(clienteId).get(),
      builder: (context, userSnapshot) {
        String nombreCliente = 'Cliente';
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          nombreCliente = userData?['nombre'] ?? 'Cliente';
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colorAvatar,
                  child: Icon(Icons.person, color: Colors.white, size: 22),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombreCliente, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < puntuacion ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                if (timestamp != null)
                  Text(
                    _formatearFecha(timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tipoServicio,
                style: TextStyle(fontSize: 13, color: Colors.blue[700], fontWeight: FontWeight.w500),
              ),
            ),
            if (comentario.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  comentario,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700], fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        );
      },
    ),
  );
}

    String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);
    
    // Si es hoy
    if (diferencia.inDays == 0) {
      if (diferencia.inHours == 0) {
        if (diferencia.inMinutes == 0) {
          return 'Ahora';
        } else if (diferencia.inMinutes < 60) {
          return 'Hace ${diferencia.inMinutes}m';
        }
      }
      if (diferencia.inHours < 24) {
        return 'Hace ${diferencia.inHours}h';
      }
    }
    
    // Si es ayer
    if (diferencia.inDays == 1) {
      return 'Ayer';
    }
    
    // Si es esta semana (menos de 7 días)
    if (diferencia.inDays < 7) {
      final diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return diasSemana[fecha.weekday - 1];
    }
    
    // Si es este año
    if (fecha.year == ahora.year) {
      final meses = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return '${fecha.day} ${meses[fecha.month - 1]}';
    }
    
    // Si es de otro año
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  Future<void> mostrarVentanaSolicitudes(BuildContext context) {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Nueva solicitud'),
            content: Text('Tienes una nueva solicitud pendiente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Aceptar'),
              ),
            ],
          ),
    );
  }

  Widget _buildSolicitudesList() {
    if (proveedorIdActual == null) {
      return Center(child: Text('No se encontró proveedor actual.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('notificaciones')
              .where('proveedorId', isEqualTo: proveedorIdActual)
              .where('estado', isEqualTo: 'pendiente') // solo pendientes
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
          return Center(child: Text('No tienes solicitudes pendientes.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final idSolicitud = docs[index].id;
            final subcategoria = data['subcategoria'] ?? 'Sin categoría';
            final clienteId = data['clienteId'] ?? 'Desconocido';
            final nombreCliente = data['nombreCliente'] ?? 'Desconocido';
            // Puedes consultar más datos del cliente si quieres, con clienteId

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Solicitud para: $subcategoria',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_outline, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cliente: $nombreCliente',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.check_circle, size: 18),
                          label: Text('Aceptar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('notificaciones')
                                .doc(idSolicitud)
                                .update({'estado': 'aceptado'});
                          },
                        ),
                        SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: Icon(Icons.cancel, size: 18),
                          label: Text('Rechazar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('notificaciones')
                                .doc(idSolicitud)
                                .update({'estado': 'rechazado'});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarBottomSheetSolicitudes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Solicitudes pendientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 400,
                child: _buildSolicitudesList(), // usa tu StreamBuilder aquí
              ),
            ],
          ),
        );
      },
    );
  }

  Set<String> _solicitudesMostradas = {};

  @override
  void initState() {
    super.initState();
    if (proveedorIdActual != null) {
      _verificarPromocionesVencidas();
    }

    if (proveedorIdActual != null) {
      _solicitudesSubscription = FirebaseFirestore.instance
          .collection('notificaciones')
          .where('proveedorId', isEqualTo: proveedorIdActual)
          .where('estado', isEqualTo: 'pendiente')
          .snapshots()
          .listen((snapshot) {
            for (var doc in snapshot.docs) {
              if (!_solicitudesMostradas.contains(doc.id)) {
                _solicitudesMostradas.add(doc.id);
                if (!_dialogShowing) {
                  _dialogShowing = true;
                  Future.delayed(Duration.zero, () async {
                    mostrarVentanaSolicitudes(context); // Aquí espero el cierre
                    _dialogShowing = false;
                  });
                }
              }
            }
          });
    }
  }

  @override
  void dispose() {
    _solicitudesSubscription?.cancel();
    super.dispose();
  }
  
  Widget _buildTokensInfo(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(proveedorIdActual)
          .snapshots(),
      builder: (context, snapshot) {
        int tokens = 0; // Declarado aquí, no dentro del if
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final tokensValue = data?['tokens'];
          tokens = (tokensValue is int) ? tokensValue : 0;
        }
        return Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.amber[700], size: 26),
            SizedBox(width: 4),
            Text(
              tokens.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber[900],
                fontSize: 18,
                letterSpacing: 1.2,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.blue, size: 26),
              tooltip: "Recargar tokens",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RecargarTokensPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categorias = homeController.obtenerCategorias();
    final List<Widget> pages = [
      ListView(
        children: [
          _buildAgregarServicio(),
          _buildRendimientoDiario(),
          _buildUltimasCalificaciones(),
        ],
      ),
      MisServiciosPage(),
      SolicitudesPage(),
      PerfilUsuarioPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Portal Proveedor'),
        actions: [
          _buildTokensInfo(context),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          pages[_selectedIndex],

          // Si quieres mostrar algo encima en cualquier página, por ejemplo una notificación o banner,
          // puedes usar StreamBuilder o cualquier widget aquí.

          // Ejemplo: mostrar un banner o indicador si hay solicitudes pendientes
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('notificaciones')
                    .where('proveedorId', isEqualTo: proveedorIdActual)
                    .where('estado', isEqualTo: 'pendiente')
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SizedBox.shrink();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SizedBox.shrink();
              }
              // Aquí puedes mostrar un pequeño banner o icono de notificación
              return Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () => _mostrarBottomSheetSolicitudes(context),
                  child: Icon(Icons.notifications_active),
                  backgroundColor: Colors.redAccent,
                  tooltip: 'Solicitudes pendientes',
                ),
              );
            },
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Mis Servicios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
