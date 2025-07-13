import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:serviapp/app_theme2.dart';
import 'package:serviapp/modelo/global_user.dart';
import 'calificacion_modal.dart';

class SolicitudesPage extends StatefulWidget {
  @override
  _SolicitudesPageState createState() => _SolicitudesPageState();
}

class _SolicitudesPageState extends State<SolicitudesPage> {
  final String? clienteIdActual = GlobalUser.uid;
  Map<String, bool> estadosCalificacion = {};

  Future<String?> obtenerNombreProveedor(String proveedorId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(proveedorId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        return data?['nombre'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener el nombre del proveedor: $e');
      return null;
    }
  }

  // Método para obtener el servicioId real basado en la notificación
  Future<String?> obtenerServicioIdDeNotificacion(String notificacionId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('notificaciones')
          .doc(notificacionId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Primero intentar con servicioId directo
        if (data.containsKey('servicioId') && data['servicioId'] != null) {
          print('Encontrado servicioId directo: ${data['servicioId']}');
          return data['servicioId'] as String;
        }
        
        // Si no existe servicioId, buscar por proveedorId y subcategoria
        final proveedorId = data['proveedorId'] as String?;
        final subcategoria = data['subcategoria'] as String?;
        
        print('Buscando servicio - ProveedorId: $proveedorId, Subcategoria: "$subcategoria"');
        
        if (proveedorId != null && subcategoria != null) {
          return await buscarServicioPorProveedorYCategoria(proveedorId, subcategoria);
        }
      }
      return null;
    } catch (e) {
      print('Error al obtener servicioId de notificación: $e');
      return null;
    }
  }

  // Método para buscar servicio por proveedor y categoría
  Future<String?> buscarServicioPorProveedorYCategoria(String proveedorId, String subcategoria) async {
    try {
      // Primero intentar búsqueda exacta
      var query = await FirebaseFirestore.instance
          .collection('servicios')
          .where('idusuario', isEqualTo: proveedorId)
          .where('subcategoria', isEqualTo: subcategoria)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        print('Servicio encontrado con búsqueda exacta: ${query.docs.first.id}');
        return query.docs.first.id;
      }
      
      // Si no se encuentra, intentar búsqueda solo por proveedor
      print('No se encontró con búsqueda exacta, buscando solo por proveedor...');
      query = await FirebaseFirestore.instance
          .collection('servicios')
          .where('idusuario', isEqualTo: proveedorId)
          .get();
      
      print('Servicios encontrados para el proveedor: ${query.docs.length}');
      
      // Buscar coincidencia aproximada (sin case sensitive)
      for (var doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final servicioSubcategoria = (data['subcategoria'] ?? '').toString();
        print('Comparando: "$subcategoria" vs "$servicioSubcategoria"');
        
        if (servicioSubcategoria.toLowerCase().trim() == subcategoria.toLowerCase().trim()) {
          print('Servicio encontrado con búsqueda aproximada: ${doc.id}');
          return doc.id;
        }
      }
      
      // Si aún no se encuentra, tomar el primer servicio del proveedor
      if (query.docs.isNotEmpty) {
        print('Usando primer servicio del proveedor: ${query.docs.first.id}');
        return query.docs.first.id;
      }
      
      print('No se encontró ningún servicio para el proveedor');
      return null;
    } catch (e) {
      print('Error al buscar servicio por proveedor y categoría: $e');
      return null;
    }
  }

  Future<bool> yaCalificado(String notificacionId, String clienteId) async {
    // Primero verificar el estado local
    if (estadosCalificacion.containsKey(notificacionId)) {
      return estadosCalificacion[notificacionId]!;
    }
    
    try {
      final query = await FirebaseFirestore.instance
          .collection('calificaciones')
          .where('notificacionId', isEqualTo: notificacionId)
          .where('clienteId', isEqualTo: clienteId)
          .get();
      
      bool yaEstaCalificado = query.docs.isNotEmpty;
      // Guardar en estado local
      setState(() {
        estadosCalificacion[notificacionId] = yaEstaCalificado;
      });
      return yaEstaCalificado;
    } catch (e) {
      print('Error al verificar calificación: $e');
      return false;
    }
  }

  void mostrarModalCalificacion(
    BuildContext context,
    String notificacionId,
    String proveedorId,
    String clienteId,
    String nombreProveedor,
    String tipoServicio,
  ) {
    // Verificar una vez más antes de mostrar el modal
    yaCalificado(notificacionId, clienteId).then((yaEstaCalificado) {
      if (yaEstaCalificado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Este servicio ya ha sido calificado'),
            backgroundColor: ServiceAppTheme.warningColor,
          ),
        );
        return;
      }
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CalificacionModal(
          notificacionId: notificacionId,
          proveedorId: proveedorId,
          clienteId: clienteId,
          nombreProveedor: nombreProveedor,
          tipoServicio: tipoServicio,
        ),
      ).then((resultado) {
        // Si se envió la calificación, actualizar el estado local inmediatamente
        if (resultado == true) {
          setState(() {
            estadosCalificacion[notificacionId] = true;
          });
          
          // Mostrar mensaje de confirmación
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Calificación enviada exitosamente!'),
              backgroundColor: ServiceAppTheme.successColor,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (clienteIdActual == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Historial de Solicitudes')),
        body: ServiceAppWidgets.buildEmptyState(
          icon: Icons.person_off_outlined,
          title: 'Cliente no identificado',
          subtitle: 'No se pudo identificar la sesión del usuario',
        ),
      );
    }

    return Scaffold(
      backgroundColor: ServiceAppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Historial de Solicitudes'),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notificaciones')
            .where('clienteId', isEqualTo: clienteIdActual)
            .where('estado', isEqualTo: 'aceptado')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ServiceAppWidgets.buildEmptyState(
              icon: Icons.error_outline,
              title: 'Error al cargar datos',
              subtitle: 'Ocurrió un error: ${snapshot.error}',
              iconColor: ServiceAppTheme.errorColor,
            );
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ServiceAppWidgets.buildLoadingIndicator(
              message: 'Cargando tus solicitudes...',
            );
          }
          
          final docs = snapshot.data?.docs ?? [];
          
          if (docs.isEmpty) {
            return ServiceAppWidgets.buildEmptyState(
              icon: Icons.history_outlined,
              title: 'Sin solicitudes aceptadas',
              subtitle: 'Aún no tienes servicios completados para calificar',
              iconColor: ServiceAppTheme.mutedTextColor,
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(ServiceSpacing.md),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final notificacionId = docs[index].id;
              final servicio = data['subcategoria'] ?? 'Sin categoría';
              final proveedorId = data['proveedorId'] ?? '';
              final timestamp = data['timestamp'] as Timestamp?;
              final fechaUtc =
                  data['timestamp'] != null
                      ? (data['timestamp'] as Timestamp).toDate()
                      : null;

              final fechaForzada =
                  fechaUtc != null
                      ? fechaUtc.subtract(Duration(hours: 5)) // fuerza UTC-5
                      : null;

              final fechaHora =
                  fechaForzada != null
                      ? DateFormat('dd/MM/yyyy HH:mm').format(fechaForzada)
                      : 'Sin fecha';

              return FutureBuilder<String?>(
                future: obtenerNombreProveedor(proveedorId),
                builder: (context, proveedorSnapshot) {
                  final nombreProveedor =
                      proveedorSnapshot.data ?? 'Proveedor desconocido';
                  
                  return ServiceAppWidgets.buildServiceCard(
                    margin: EdgeInsets.only(bottom: ServiceSpacing.md),
                    useGradient: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con información del servicio
                        Row(
                          children: [
                            // Icono del servicio
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: ServiceAppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(ServiceRadius.md),
                                boxShadow: ServiceAppTheme.softShadow,
                              ),
                              child: Icon(
                                Icons.build_outlined,
                                color: ServiceAppTheme.onPrimaryTextColor,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: ServiceSpacing.md),
                            
                            // Información del servicio
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    servicio,
                                    style: ServiceTextStyles.headline3.copyWith(
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: ServiceSpacing.xs),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: ServiceAppTheme.secondaryTextColor,
                                      ),
                                      SizedBox(width: ServiceSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          nombreProveedor,
                                          style: ServiceTextStyles.bodyMedium.copyWith(
                                            color: ServiceAppTheme.secondaryTextColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: ServiceSpacing.xs),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_outlined,
                                        size: 16,
                                        color: ServiceAppTheme.mutedTextColor,
                                      ),
                                      SizedBox(width: ServiceSpacing.xs),
                                      Text(
                                        fechaHora,
                                        style: ServiceTextStyles.caption.copyWith(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: ServiceSpacing.lg),
                        
                        // Divisor sutil
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ServiceAppTheme.dividerColor.withOpacity(0),
                                ServiceAppTheme.dividerColor.withOpacity(0.5),
                                ServiceAppTheme.dividerColor.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                        
                        SizedBox(height: ServiceSpacing.lg),
                        
                        // Botones de acción
                        Row(
                          children: [
                            // Botón de calificar (expandido)
                            Expanded(
                              flex: 2,
                              child: _buildBotonCalificar(
                                notificacionId,
                                proveedorId,
                                nombreProveedor,
                                servicio,
                              ),
                            ),
                            
                            SizedBox(width: ServiceSpacing.md),
                            
                            // Botón de favoritos (más pequeño)
                            _buildBotonFavoritos(notificacionId),
                          ],
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

  Widget _buildBotonCalificar(
    String notificacionId,
    String proveedorId,
    String nombreProveedor,
    String servicio,
  ) {
    // Verificar primero el estado local
    if (estadosCalificacion[notificacionId] == true) {
      return _buildBotonCalificado();
    }
    
    // Si no está en el estado local, verificar en la base de datos
    return FutureBuilder<bool>(
      future: yaCalificado(notificacionId, clienteIdActual!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 48,
            decoration: BoxDecoration(
              color: ServiceAppTheme.lightBlue,
              borderRadius: BorderRadius.circular(ServiceRadius.md),
              border: Border.all(
                color: ServiceAppTheme.dividerColor,
                width: 1,
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ServiceAppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
          );
        }
        
        final yaEstaCalificado = snapshot.data ?? false;
        
        if (yaEstaCalificado) {
          return _buildBotonCalificado();
        } else {
          return Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ServiceRadius.md),
              boxShadow: ServiceAppTheme.softShadow,
            ),
            child: ElevatedButton.icon(
              onPressed: () => mostrarModalCalificacion(
                context,
                notificacionId,
                proveedorId,
                clienteIdActual!,
                nombreProveedor,
                servicio,
              ),
              icon: Icon(Icons.star_rate_rounded, size: 20),
              label: Text(
                'Calificar Servicio',
                style: ServiceTextStyles.button.copyWith(fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ServiceAppTheme.primaryBlue,
                foregroundColor: ServiceAppTheme.onPrimaryTextColor,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ServiceRadius.md),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: ServiceSpacing.md,
                  vertical: ServiceSpacing.md,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildBotonCalificado() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ServiceAppTheme.successColor.withOpacity(0.1),
            ServiceAppTheme.successColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(ServiceRadius.md),
        border: Border.all(
          color: ServiceAppTheme.successColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: ServiceAppTheme.successColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(width: ServiceSpacing.sm),
            Text(
              'Servicio Calificado',
              style: ServiceTextStyles.button.copyWith(
                color: ServiceAppTheme.successColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> esFavorito(String notificacionId) async {
    try {
      // Obtener el servicioId real de la notificación
      final servicioId = await obtenerServicioIdDeNotificacion(notificacionId);
      if (servicioId == null) return false;

      final query = await FirebaseFirestore.instance
          .collection('favoritos')
          .where('servicioId', isEqualTo: servicioId)
          .where('clienteId', isEqualTo: clienteIdActual!)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar favorito: $e');
      return false;
    }
  }

  Future<void> toggleFavorito(String notificacionId) async {
    try {
      // Obtener el servicioId real de la notificación
      final servicioId = await obtenerServicioIdDeNotificacion(notificacionId);
      if (servicioId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: No se pudo encontrar el servicio'),
            backgroundColor: ServiceAppTheme.errorColor,
          ),
        );
        return;
      }

      final query = await FirebaseFirestore.instance
          .collection('favoritos')
          .where('servicioId', isEqualTo: servicioId)
          .where('clienteId', isEqualTo: clienteIdActual!)
          .get();
      
      if (query.docs.isNotEmpty) {
        // Quitar de favoritos
        await query.docs.first.reference.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eliminado de favoritos'),
            backgroundColor: ServiceAppTheme.warningColor,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Agregar a favoritos
        await FirebaseFirestore.instance.collection('favoritos').add({
          'servicioId': servicioId, // Ahora usamos el servicioId real
          'clienteId': clienteIdActual!,
          'fechaAgregado': DateTime.now().millisecondsSinceEpoch,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agregado a favoritos'),
            backgroundColor: ServiceAppTheme.successColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
      setState(() {}); // Refrescar UI
    } catch (e) {
      print('Error al toggle favorito: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar favoritos'),
          backgroundColor: ServiceAppTheme.errorColor,
        ),
      );
    }
  }

  Widget _buildBotonFavoritos(String notificacionId) {
    return FutureBuilder<String?>(
      future: obtenerServicioIdDeNotificacion(notificacionId),
      builder: (context, servicioSnapshot) {
        if (servicioSnapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ServiceAppTheme.lightBlue,
              borderRadius: BorderRadius.circular(ServiceRadius.md),
              border: Border.all(
                color: ServiceAppTheme.dividerColor,
                width: 1,
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ServiceAppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
          );
        }
        
        final servicioId = servicioSnapshot.data;
        if (servicioId == null) {
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ServiceAppTheme.lightBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(ServiceRadius.md),
              border: Border.all(
                color: ServiceAppTheme.dividerColor,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.error_outline,
              size: 20,
              color: ServiceAppTheme.mutedTextColor,
            ),
          );
        }

        // Usar StreamBuilder para escuchar cambios en tiempo real
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('favoritos')
              .where('servicioId', isEqualTo: servicioId)
              .where('clienteId', isEqualTo: clienteIdActual!)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ServiceAppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(ServiceRadius.md),
                  border: Border.all(
                    color: ServiceAppTheme.dividerColor,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ServiceAppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
              );
            }

            final esFav = snapshot.data?.docs.isNotEmpty ?? false;

            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: esFav
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFFB800).withOpacity(0.2),
                          const Color(0xFFFF8F00).withOpacity(0.1),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ServiceAppTheme.lightBlue.withOpacity(0.8),
                          ServiceAppTheme.lightBlue.withOpacity(0.4),
                        ],
                      ),
                borderRadius: BorderRadius.circular(ServiceRadius.md),
                border: Border.all(
                  color: esFav
                      ? const Color(0xFFFFB800).withOpacity(0.5)
                      : ServiceAppTheme.dividerColor,
                  width: 1.5,
                ),
                boxShadow: esFav ? ServiceAppTheme.softShadow : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => toggleFavoritoConServicioId(servicioId),
                  borderRadius: BorderRadius.circular(ServiceRadius.md),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: Icon(
                        esFav ? Icons.star_rounded : Icons.star_outline_rounded,
                        key: ValueKey(esFav),
                        size: 24,
                        color: esFav
                            ? const Color(0xFFFFB800)
                            : ServiceAppTheme.mutedTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Método simplificado para toggle favoritos usando servicioId directamente
  Future<void> toggleFavoritoConServicioId(String servicioId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('favoritos')
          .where('servicioId', isEqualTo: servicioId)
          .where('clienteId', isEqualTo: clienteIdActual!)
          .get();
      
      if (query.docs.isNotEmpty) {
        // Quitar de favoritos
        await query.docs.first.reference.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eliminado de favoritos'),
            backgroundColor: ServiceAppTheme.warningColor,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Agregar a favoritos
        await FirebaseFirestore.instance.collection('favoritos').add({
          'servicioId': servicioId,
          'clienteId': clienteIdActual!,
          'fechaAgregado': DateTime.now().millisecondsSinceEpoch,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agregado a favoritos'),
            backgroundColor: ServiceAppTheme.successColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error al toggle favorito: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar favoritos'),
          backgroundColor: ServiceAppTheme.errorColor,
        ),
      );
    }
  }
}