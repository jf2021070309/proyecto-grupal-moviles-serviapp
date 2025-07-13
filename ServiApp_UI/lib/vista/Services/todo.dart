import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:serviapp/app_theme2.dart';
import 'package:serviapp/modelo/servicio_model.dart'; 
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class TodoPage extends StatefulWidget {
  final String subcategoria;

  const TodoPage({Key? key, required this.subcategoria}) : super(key: key);

  @override
  _TodoPageState createState() => _TodoPageState();
}

class HistorialSolicitudesPage extends StatelessWidget {
  final String subcategoria;

  const HistorialSolicitudesPage({super.key, required this.subcategoria});

  void _mostrarProveedoresModal(
    BuildContext context,
    String subcategoria,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes iniciar sesión para ver proveedores.'),
          backgroundColor: ServiceAppTheme.errorColor,
        ),
      );
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final String userType = userDoc.data()?['rol'] ?? 'desconocido';

    if (userType != 'cliente') return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          builder: (ctx, scrollController) {
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text('Proveedores para: $subcategoria'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('servicios')  // ✅ Cambiar a servicios
                    .where('subcategoria', isEqualTo: subcategoria)
                    .where('estado', isEqualTo: "true")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  
                  // FILTRO PARA SERVICIOS BLOQUEADOS - Filtrar en código para compatibilidad
                  final docsNoBloqueados = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final bloqueado = data['bloqueado'] ?? false; // Si no existe el campo, asume false
                    return !bloqueado; // Solo mostrar servicios no bloqueados
                  }).toList();
                  // FIN FILTRO PARA SERVICIOS BLOQUEADOS
                  
                  if (docsNoBloqueados.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron proveedores disponibles.'),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: docsNoBloqueados.length,
                    itemBuilder: (context, index) {
                      final data = docsNoBloqueados[index].data() as Map<String, dynamic>;
                      final uidProveedor = data['idusuario']; // ✅ Cambiar a 'idusuario'
                      final titulo = data['titulo'] ?? 'Servicio sin título';
                      final descripcion = data['descripcion'] ?? 'Sin descripción';

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(uidProveedor)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const ListTile(
                              title: Text('Cargando...'),
                            );
                          }

                          final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                          final nombre = userData['nombre'] ?? 'Proveedor sin nombre';
                          final celular = userData['celular'] ?? 'Número no disponible';

                          return ListTile(
                            title: Text(titulo),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Proveedor: $nombre'),
                                Text('Celular: $celular'),
                                Text(descripcion, maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                            trailing: ElevatedButton(
                              child: const Text('Solicitar servicio'),
                              onPressed: () async {
                                final solicitudId = const Uuid().v4();
                                await FirebaseFirestore.instance
                                    .collection('notificaciones')
                                    .doc(solicitudId)
                                    .set({
                                      'id': solicitudId,
                                      'clienteId': currentUser.uid,
                                      'nombreCliente': userDoc.data()?['nombre'] ?? '',
                                      'proveedorId': uidProveedor,
                                      'estado': 'pendiente',
                                      'etapa': '',
                                      'subcategoria': subcategoria,
                                      'timestamp': FieldValue.serverTimestamp(),
                                    });
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Solicitud enviada al proveedor.'),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostrarProveedoresModal(context, subcategoria);
    });

    return Scaffold(
      backgroundColor: ServiceAppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Historial de solicitudes'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notificaciones')
            .where('clienteId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .where('estado', isEqualTo: 'aceptado')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ServiceAppWidgets.buildLoadingIndicator(
              message: 'Cargando historial...',
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return ServiceAppWidgets.buildEmptyState(
              icon: Icons.history,
              title: 'Sin solicitudes',
              subtitle: 'No tienes solicitudes aceptadas aún',
            );
          }

          final notificaciones = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notificaciones.length,
            itemBuilder: (context, index) {
              final data = notificaciones[index].data() as Map<String, dynamic>;
              final proveedorId = data['proveedorId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(proveedorId)
                    .get(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return ServiceAppWidgets.buildLoadingIndicator();
                  }
                  if (!snap.hasData || !snap.data!.exists) {
                    return const SizedBox();
                  }
                  final proveedor = snap.data!;
                  final nombre = proveedor['nombre'] ?? 'Proveedor';
                  final telefono = proveedor['celular'] ?? '';

                  return ServiceAppWidgets.buildServiceCard(
                    backgroundColor: ServiceAppTheme.successColor.withOpacity(0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ServiceAppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: ServiceAppTheme.successColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Servicio Aceptado',
                                    style: ServiceTextStyles.headline3.copyWith(
                                      color: ServiceAppTheme.successColor,
                                    ),
                                  ),
                                  Text(
                                    'Puedes contactarte con el proveedor',
                                    style: ServiceTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ServiceAppTheme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ServiceAppTheme.dividerColor,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: ServiceAppTheme.primaryBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Proveedor: $nombre',
                                    style: ServiceTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: ServiceAppTheme.primaryBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Teléfono: $telefono',
                                    style: ServiceTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ServiceAppWidgets.buildActionButtonsRow(
                          onCallPressed: () {
                            final Uri uri = Uri(scheme: 'tel', path: telefono);
                            launchUrl(uri);
                          },
                          onWhatsAppPressed: () {
                            final formatted = telefono.replaceAll(RegExp(r'[^0-9]'), '');
                            final Uri uri = Uri.parse('https://wa.me/51$formatted');
                            launchUrl(uri, mode: LaunchMode.externalApplication);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _TodoPageState extends State<TodoPage> {
  // Mapa para mantener el estado de expansión de cada descripción
  final Map<String, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiceAppTheme.backgroundColor,
      appBar: AppBar(
      title: Text(
        widget.subcategoria,
        style: const TextStyle(
          fontSize: 16, // Reduce el tamaño si es necesario
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis, // Trunca con "..." si es muy largo
        maxLines: 1, // Máximo una línea
      ),
      centerTitle: true,
      // Opcional: Agregar más espacio si es necesario
      titleSpacing: 0,
    ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('servicios')
            .where('subcategoria', isEqualTo: widget.subcategoria)
            .where('estado', isEqualTo: "true")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ServiceAppWidgets.buildEmptyState(
              icon: Icons.error_outline,
              title: 'Error al cargar',
              subtitle: 'Ha ocurrido un error al cargar los servicios',
              iconColor: ServiceAppTheme.errorColor,
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ServiceAppWidgets.buildLoadingIndicator(
              message: 'Cargando servicios...',
            );
          }
          
          // FILTRO PARA SERVICIOS BLOQUEADOS - Filtrar en código para compatibilidad
          final docsNoBloqueados = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final bloqueado = data['bloqueado'] ?? false; // Si no existe el campo, asume false
            return !bloqueado; // Solo mostrar servicios no bloqueados
          }).toList();
          // FIN FILTRO PARA SERVICIOS BLOQUEADOS
          
          if (docsNoBloqueados.isEmpty) {
            return ServiceAppWidgets.buildEmptyState(
              icon: Icons.search_off,
              title: 'Sin servicios',
              subtitle: 'No hay servicios disponibles en esta categoría',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docsNoBloqueados.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = docsNoBloqueados[index];
              final servicio = Servicio.fromFirestore(doc);
              return _buildServiceCard(context, servicio);
            },
          );
        },
      ),
    );
  }

  Future<void> _crearSolicitudAceptadaDesdeServicio(String idServicio) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final nombreCliente = userDoc.data()?['nombre'] ?? '';
    final uidSolicitud = const Uuid().v4();

    try {
      final servicioDoc = await FirebaseFirestore.instance
          .collection('servicios')
          .doc(idServicio)
          .get();

      if (!servicioDoc.exists) {
        print('⚠️ El servicio con ID $idServicio no existe.');
        return;
      }

      final data = servicioDoc.data()!;
      final proveedorId = data['idusuario'];
      final subcategoria = data['subcategoria'];

      await FirebaseFirestore.instance
          .collection('notificaciones')
          .doc(uidSolicitud)
          .set({
            'id': uidSolicitud,
            'clienteId': currentUser.uid,
            'nombreCliente': nombreCliente,
            'proveedorId': proveedorId,
            'estado': 'aceptado',
            'etapa': '',
            'subcategoria': subcategoria,
            'timestamp': FieldValue.serverTimestamp(),
          });

      print('✅ Solicitud creada desde publicación $idServicio');
    } catch (e) {
      print('❌ Error al crear la solicitud: $e');
    }
  }

  Widget _buildServiceCard(BuildContext context, Servicio servicio) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getProviderDataAndRating(servicio.idusuario),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ServiceAppWidgets.buildServiceCard(
            child: ServiceAppWidgets.buildLoadingIndicator(),
          );
        }

        final providerData = snapshot.data ?? {};
        final String nombreProveedor = providerData['nombre'] ?? 'Proveedor';
        final String ubicacionProveedor = providerData['ubicacion'] ?? 'Sin ubicación';
        final String fotoPerfilUrl = providerData['fotoPerfil'] ?? '';
        final double promedioCalificaciones = providerData['promedioCalificaciones'] ?? 0.0;
        final int totalCalificaciones = providerData['totalCalificaciones'] ?? 0;
        final String imagenServicioUrl = servicio.imagen ?? '';

        return ServiceAppWidgets.buildServiceCard(
          useGradient: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con información del proveedor
              _buildProviderHeader(
                nombreProveedor,
                ubicacionProveedor,
                fotoPerfilUrl,
                promedioCalificaciones,
                totalCalificaciones,
              ),
              
              const SizedBox(height: 20),
              
              // Título del servicio
              Text(
                servicio.titulo,
                style: ServiceTextStyles.headline3,
              ),
              
              const SizedBox(height: 12),
              
              // Imagen del servicio (si existe)
              if (imagenServicioUrl.isNotEmpty) ...[
                _buildServiceImage(imagenServicioUrl),
                const SizedBox(height: 16),
              ],
              
              // Descripción expandible del servicio
              _buildExpandableDescription(servicio.descripcion, servicio.id),
              
              const SizedBox(height: 20),
              
              // Botones de acción
              ServiceAppWidgets.buildActionButtonsRow(
                onCallPressed: () async {
                  await _crearSolicitudAceptadaDesdeServicio(servicio.id);
                  final Uri uri = Uri(scheme: 'tel', path: servicio.telefono);
                  launchUrl(uri);
                },
                onWhatsAppPressed: () async {
                  await _crearSolicitudAceptadaDesdeServicio(servicio.id);
                  final formatted = servicio.telefono.replaceAll(RegExp(r'[^0-9]'), '');
                  final Uri uri = Uri.parse('https://wa.me/51$formatted');
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
              
              const SizedBox(height: 12),
              
              // BOTÓN DE REPORTAR - Permite reportar la publicación
              _buildReportButton(context, servicio.id, servicio.titulo),
              // FIN BOTÓN DE REPORTAR
            ],
          ),
        );
      },
    );
  }

  Widget _buildProviderHeader(
    String nombre,
    String ubicacion,
    String fotoUrl,
    double rating,
    int totalRatings,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ServiceAppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ServiceAppTheme.dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar del proveedor
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: ServiceAppTheme.primaryGradient,
              boxShadow: ServiceAppTheme.softShadow,
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: fotoUrl.isNotEmpty
                    ? Image.network(
                        fotoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 28, color: ServiceAppTheme.mutedTextColor),
                      )
                    : const Icon(Icons.person, size: 28, color: ServiceAppTheme.mutedTextColor),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Información del proveedor
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: ServiceTextStyles.headline3.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: ServiceAppTheme.mutedTextColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ubicacion,
                        style: ServiceTextStyles.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildRatingRow(rating, totalRatings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceImage(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: ServiceAppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: ServiceAppTheme.lightBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: ServiceAppTheme.mutedTextColor,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Imagen no disponible',
                      style: TextStyle(
                        color: ServiceAppTheme.mutedTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpandableDescription(String description, String servicioId) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final textSpan = TextSpan(
        text: description,
        style: ServiceTextStyles.bodyMedium,
      );
      final textPainter = TextPainter(
        text: textSpan,
        maxLines: 3,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: constraints.maxWidth);
      
      final isTextOverflowing = textPainter.didExceedMaxLines;
      
      return StatefulBuilder(
        builder: (context, setLocalState) {
          final bool isExpanded = _expandedStates[servicioId] ?? false;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ServiceAppTheme.lightBlue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ServiceAppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Descripción',
                            style: TextStyle(
                              color: ServiceAppTheme.onPrimaryTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Text(
                        description,
                        style: ServiceTextStyles.bodyMedium,
                        maxLines: isExpanded ? null : 3,
                        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      ),
                    ),
                    if (isTextOverflowing) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setLocalState(() {
                            _expandedStates[servicioId] = !isExpanded;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isExpanded ? 'Ver menos' : 'Ver más',
                              style: ServiceTextStyles.bodySmall.copyWith(
                                color: ServiceAppTheme.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: const Icon(
                                Icons.expand_more,
                                color: ServiceAppTheme.primaryBlue,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

  Widget _buildRatingRow(double rating, int totalRatings) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating.floor() 
                ? Icons.star_rounded 
                : (index < rating) 
                    ? Icons.star_half_rounded 
                    : Icons.star_outline_rounded,
            size: 16,
            color: const Color(0xFFFFB800),
          );
        }),
        const SizedBox(width: 8),
        Text(
          '${rating.toStringAsFixed(1)} ($totalRatings)',
          style: ServiceTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _getProviderDataAndRating(String proveedorId) async {
    final Map<String, dynamic> result = {};
    
    try {
      // Obtener datos del proveedor
      final proveedorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(proveedorId)
          .get();
      
      if (proveedorDoc.exists) {
        final data = proveedorDoc.data()!;
        result['nombre'] = data['nombre'] ?? 'Proveedor';
        result['ubicacion'] = data['ubicacion'] ?? 'Sin ubicación';
        result['fotoPerfil'] = data['fotoPerfil'] ?? '';
      }
      
      // Obtener calificaciones del proveedor
      final calificacionesSnapshot = await FirebaseFirestore.instance
          .collection('calificaciones')
          .where('proveedorId', isEqualTo: proveedorId)
          .get();
      
      if (calificacionesSnapshot.docs.isNotEmpty) {
        double sumaCalificaciones = 0.0;
        int totalCalificaciones = calificacionesSnapshot.docs.length;
        
        for (var doc in calificacionesSnapshot.docs) {
          final data = doc.data();
          sumaCalificaciones += (data['puntuacion'] ?? 0.0).toDouble();
        }
        
        result['promedioCalificaciones'] = sumaCalificaciones / totalCalificaciones;
        result['totalCalificaciones'] = totalCalificaciones;
      } else {
        result['promedioCalificaciones'] = 0.0;
        result['totalCalificaciones'] = 0;
      }
      
    } catch (e) {
      print('Error obteniendo datos del proveedor: $e');
      result['nombre'] = 'Proveedor';
      result['ubicacion'] = 'Sin ubicación';
      result['fotoPerfil'] = '';
      result['promedioCalificaciones'] = 0.0;
      result['totalCalificaciones'] = 0;
    }
    
    return result;
  }

  // SISTEMA DE REPORTES - Métodos para reportar publicaciones

  /// Construye el botón de reportar publicación
  Widget _buildReportButton(BuildContext context, String servicioId, String tituloServicio) {
    return Container(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _mostrarModalReporte(context, servicioId, tituloServicio),
        icon: Icon(Icons.flag_outlined, color: Colors.red.shade600),
        label: Text(
          'Reportar publicación',
          style: TextStyle(color: Colors.red.shade600),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.shade300),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// Muestra el modal para reportar una publicación
  void _mostrarModalReporte(BuildContext context, String servicioId, String tituloServicio) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debes iniciar sesión para reportar una publicación'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verificar si ya reportó esta publicación
    final yaReporto = await _verificarSiYaReporto(currentUser.uid, servicioId);
    if (yaReporto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ya has reportado esta publicación anteriormente'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Verificar que no sea su propia publicación
    final propiaPublicacion = await _verificarSiEsPropiaPublicacion(currentUser.uid, servicioId);
    if (propiaPublicacion) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No puedes reportar tu propia publicación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar modal de reporte
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildModalReporte(context, servicioId, tituloServicio),
    );
  }

  /// Construye el modal de reporte
  Widget _buildModalReporte(BuildContext context, String servicioId, String tituloServicio) {
    String? motivoSeleccionado;
    TextEditingController descripcionController = TextEditingController();
    
    final List<String> motivosReporte = [
      'Contenido inapropiado',
      'Información falsa o engañosa',
      'Spam o contenido repetitivo', 
      'Precios excesivos',
      'Servicio inexistente o no disponible',
      'Otro',
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reportar publicación',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                Text(
                  'Servicio: $tituloServicio',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                
                SizedBox(height: 20),
                
                Text(
                  '¿Por qué reportas esta publicación?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Lista de motivos
                ...motivosReporte.map((motivo) => RadioListTile<String>(
                  title: Text(motivo),
                  value: motivo,
                  groupValue: motivoSeleccionado,
                  onChanged: (value) {
                    setState(() {
                      motivoSeleccionado = value;
                    });
                  },
                )).toList(),
                
                // Campo de descripción (solo si selecciona "Otro")
                if (motivoSeleccionado == 'Otro') ...[
                  SizedBox(height: 12),
                  TextField(
                    controller: descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Describe el motivo',
                      hintText: 'Explica por qué reportas esta publicación',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
                
                SizedBox(height: 20),
                
                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancelar'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: motivoSeleccionado == null ? null : () async {
                          final descripcion = motivoSeleccionado == 'Otro' 
                              ? descripcionController.text.trim()
                              : '';
                          
                          if (motivoSeleccionado == 'Otro' && descripcion.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Por favor describe el motivo del reporte'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          Navigator.pop(context);
                          await _enviarReporte(servicioId, motivoSeleccionado!, descripcion);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Reportar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Verifica si el usuario ya reportó esta publicación
  Future<bool> _verificarSiYaReporto(String usuarioId, String servicioId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reportes')
          .where('usuarioId', isEqualTo: usuarioId)
          .where('servicioId', isEqualTo: servicioId)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error verificando reporte: $e');
      return false;
    }
  }

  /// Verifica si es su propia publicación
  Future<bool> _verificarSiEsPropiaPublicacion(String usuarioId, String servicioId) async {
    try {
      final servicioDoc = await FirebaseFirestore.instance
          .collection('servicios')
          .doc(servicioId)
          .get();
      
      if (!servicioDoc.exists) return false;
      
      final data = servicioDoc.data() as Map<String, dynamic>;
      return data['idusuario'] == usuarioId;
    } catch (e) {
      print('Error verificando propiedad: $e');
      return false;
    }
  }

  /// Envía el reporte a Firebase
  Future<void> _enviarReporte(String servicioId, String motivo, String descripcion) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await FirebaseFirestore.instance.collection('reportes').add({
        'servicioId': servicioId,
        'usuarioId': currentUser.uid,
        'motivo': motivo,
        'descripcion': descripcion,
        'fechaReporte': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reporte enviado correctamente. Gracias por tu colaboración.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error enviando reporte: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar el reporte. Inténtalo nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // FIN SISTEMA DE REPORTES
}