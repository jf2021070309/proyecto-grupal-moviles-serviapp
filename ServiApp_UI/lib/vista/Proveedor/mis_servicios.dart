import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serviapp/modelo/global_user.dart';
import 'editar_servicio_page.dart';
import 'package:serviapp/vista/Proveedor/promocionar_servicio_page.dart'; // Importa tu nuevo PaymentScreen

class MisServiciosPage extends StatefulWidget {
  const MisServiciosPage({Key? key}) : super(key: key);

  @override
  State<MisServiciosPage> createState() => _MisServiciosPageState();
}

class _MisServiciosPageState extends State<MisServiciosPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _servicios = [];

  @override
  void initState() {
    super.initState();
    _cargarServicios();
  }

  Future<int?> _mostrarSeleccionPlan(BuildContext context) async {
    int? seleccion;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Selecciona un plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('3 días'),
              onTap: () {
                seleccion = 3;
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              title: Text('7 días'),
              onTap: () {
                seleccion = 7;
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              title: Text('15 días'),
              onTap: () {
                seleccion = 15;
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
    return seleccion;
  }

  Future<bool> _mostrarDialogoExtenderPromocion(BuildContext context, Timestamp promoFin, int diasExtra) async {
    final fechaActual = promoFin.toDate();
    final nuevaFecha = fechaActual.add(Duration(days: diasExtra));

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Ya estás promocionando!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Este servicio ya está siendo promocionado.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Actualmente la promoción termina el:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              '${fechaActual.day}/${fechaActual.month}/${fechaActual.year}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Si continúas, la promoción se extenderá hasta:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              '${nuevaFecha.day}/${nuevaFecha.month}/${nuevaFecha.year}',
              style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[800]
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Continuar'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _cargarServicios() async {
    try {
      setState(() => _isLoading = true);
      
      // Obtener el ID del usuario actual
      final String? proveedorIdActual = GlobalUser.uid;
      
      if (proveedorIdActual == null || proveedorIdActual.isEmpty) {
        print('Error: No hay usuario logueado');
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }
      
      print('Cargando servicios para proveedor: $proveedorIdActual');
      
      // Query para obtener servicios del usuario actual
      QuerySnapshot querySnapshot = await _firestore
          .collection('servicios')
          .where('idusuario', isEqualTo: proveedorIdActual)
          .where('estado', isEqualTo: 'true')
          .get();
          
      print('Documentos encontrados: ${querySnapshot.docs.length}');

      List<Map<String, dynamic>> servicios = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          servicios.add(data);
        } catch (e) {
          print('Error procesando documento ${doc.id}: $e');
        }
      }

      // Ordenar por fecha (más recientes primero)
      servicios.sort((a, b) {
        try {
          Timestamp? dateA = a['date'] as Timestamp?;
          Timestamp? dateB = b['date'] as Timestamp?;
          
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      if (mounted) {
        setState(() {
          _servicios = servicios;
          _isLoading = false;
        });
      }
      
    } catch (e) {
      print('Error al cargar servicios: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _eliminarServicio(String servicioId, String titulo) async {
    bool? confirmar = await _mostrarDialogoConfirmacion(titulo);

    if (confirmar == true) {
      try {
        await _firestore.collection('servicios').doc(servicioId).delete();

        // NUEVO: Descontar una publicación al usuario
        String? userId = GlobalUser.uid;
        if (userId != null) {
          final userRef = _firestore.collection('users').doc(userId);
          await _firestore.runTransaction((transaction) async {
            final userSnap = await transaction.get(userRef);
            int publicaciones = (userSnap.data()?['publicaciones'] ?? 0) as int;
            // Evitar negativos
            if (publicaciones > 0) {
              transaction.update(userRef, {'publicaciones': publicaciones - 1});
            }
          });
        }

        // Recargar la lista
        await _cargarServicios();

        if (mounted) {
          _mostrarMensaje('Servicio eliminado correctamente');
        }
      } catch (e) {
        print('Error al eliminar servicio: $e');
        if (mounted) {
          _mostrarError('Error al eliminar el servicio');
        }
      }
    }
  }

  Future<bool?> _mostrarDialogoConfirmacion(String tituloServicio) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Confirmar eliminación',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de que quieres eliminar el servicio:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"$tituloServicio"',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red.shade700, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Se eliminará y no se podrá recuperar.',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Eliminar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatearFecha(dynamic timestamp) {
    try {
      if (timestamp == null) return 'Fecha no disponible';
      
      DateTime fecha;
      if (timestamp is Timestamp) {
        fecha = timestamp.toDate();
      } else if (timestamp is DateTime) {
        fecha = timestamp;
      } else {
        return 'Fecha no válida';
      }
      
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    } catch (e) {
      return 'Fecha no válida';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Mis Servicios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cargando servicios...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : _servicios.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _cargarServicios,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _servicios.length,
                    itemBuilder: (context, index) {
                      return _buildServicioCard(_servicios[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a crear nuevo servicio
          print('Crear nuevo servicio');
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No tienes servicios registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Crea tu primer servicio para comenzar\na recibir solicitudes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navegar a crear servicio
              print('Crear primer servicio');
            },
            icon: Icon(Icons.add),
            label: Text('Crear Servicio'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromocionBadge(Timestamp? promoFin) {
    String fechaFin = '';
    if (promoFin != null) {
      final fecha = promoFin.toDate();
      fechaFin = 'Hasta: ${fecha.day}/${fecha.month}/${fecha.year}';
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber[700]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.campaign, size: 18, color: Colors.amber[900]),
          SizedBox(width: 6),
          Text(
            'Promocionando',
            style: TextStyle(
              color: Colors.amber[900],
              fontWeight: FontWeight.bold,
            ),
          ),
          if (fechaFin.isNotEmpty) ...[
            SizedBox(width: 12),
            Text(
              fechaFin,
              style: TextStyle(
                color: Colors.amber[900],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicioCard(Map<String, dynamic> servicio) {
    final bool promocionando = (servicio['slide'] ?? 'false') == 'true';
    final Timestamp? promoFin = servicio['promocionFin'] as Timestamp?;
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del servicio
          if (servicio['imagen'] != null && servicio['imagen'].toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                servicio['imagen'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título del servicio
                Text(
                  servicio['titulo']?.toString() ?? 'Sin título',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 8),
                
                // Descripción
                if (servicio['descripcion'] != null && servicio['descripcion'].toString().isNotEmpty)
                  Text(
                    servicio['descripcion'].toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                SizedBox(height: 12),
                
                // Información adicional
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      Icons.category,
                      servicio['categoria']?.toString() ?? 'Sin categoría',
                      Colors.blue,
                    ),
                    if (servicio['subcategoria'] != null && servicio['subcategoria'].toString().isNotEmpty)
                      _buildInfoChip(
                        Icons.label_outline,
                        servicio['subcategoria'].toString(),
                        Colors.green,
                      ),
                    if (servicio['ubicacion'] != null && servicio['ubicacion'].toString().isNotEmpty)
                      _buildInfoChip(
                        Icons.location_on_outlined,
                        servicio['ubicacion'].toString(),
                        Colors.orange,
                      ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Fecha de creación
                if (servicio['date'] != null)
                  Text(
                    'Creado: ${_formatearFecha(servicio['date'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                
                SizedBox(height: 16),
                if (promocionando)
                  _buildPromocionBadge(promoFin),
                
                // Botones de acción
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (promocionando && promoFin != null) {
                          // 1. Selecciona el plan
                          int? nuevosDias = await _mostrarSeleccionPlan(context);
                          if (nuevosDias == null) return;

                          // 2. Muestra el diálogo de advertencia
                          bool continuar = await _mostrarDialogoExtenderPromocion(context, promoFin, nuevosDias);
                          if (continuar) {
                            DateTime nuevaFechaFin = promoFin.toDate().add(Duration(days: nuevosDias));
                            await _firestore.collection('servicios').doc(servicio['id']).update({
                              'promocionFin': Timestamp.fromDate(nuevaFechaFin),
                            });
                            _mostrarMensaje('¡Promoción extendida hasta el ${nuevaFechaFin.day}/${nuevaFechaFin.month}/${nuevaFechaFin.year}!');
                            _cargarServicios();
                          }
                        } else {
                          // No está promocionando, ir al flujo normal
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PromocionarServicioPage(servicio: servicio),
                            ),
                          ).then((_) {
                            _cargarServicios();
                          });
                        }
                      },
                      icon: Icon(Icons.campaign, size: 18),
                      label: Text('Promocionar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8), // Espacio entre botones
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditarServicioPage(servicio: servicio),
                                ),
                              ).then((_) {
                                _cargarServicios();
                              });
                            },
                            icon: Icon(Icons.edit, size: 18),
                            label: Text('Editar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _eliminarServicio(
                              servicio['id'],
                              servicio['titulo']?.toString() ?? 'Sin título',
                            ),
                            icon: Icon(Icons.delete, size: 18),
                            label: Text('Eliminar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}