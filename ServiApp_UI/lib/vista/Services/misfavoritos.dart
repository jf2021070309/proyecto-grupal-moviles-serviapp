import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviapp/modelo/global_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class MisFavoritosPage extends StatefulWidget {
  @override
  _MisFavoritosPageState createState() => _MisFavoritosPageState();
}

class _MisFavoritosPageState extends State<MisFavoritosPage> {
  final String? clienteIdActual = GlobalUser.uid;

  Future<Map<String, dynamic>?> obtenerServicio(String servicioId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('servicios')
          .doc(servicioId)
          .get();

      if (doc.exists) {
        return doc.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener servicio: $e');
      return null;
    }
  }

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

  Future<void> eliminarFavorito(String favoritoId) async {
    try {
      await FirebaseFirestore.instance
          .collection('favoritos')
          .doc(favoritoId)
          .delete();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eliminado de favoritos'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error al eliminar favorito: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar favorito'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void mostrarContactoModal(
    BuildContext context,
    String servicioId,
    String proveedorId,
    String subcategoria,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes iniciar sesión para contactar.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Primero verificar si el proveedor está conectado
    final proveedorDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(proveedorId)
        .get();

    if (!proveedorDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Proveedor no encontrado.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final proveedorData = proveedorDoc.data() as Map<String, dynamic>;
    final estaConectado = proveedorData['isOnline'] == true;

    if (!estaConectado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El proveedor no está disponible en este momento.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          builder: (ctx, scrollController) {
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Text('Contactar Proveedor'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('servicios')
                    .where(FieldPath.documentId, isEqualTo: servicioId)
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
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Este servicio ya no está disponible.'),
                    );
                  }

                  final data = docs[0].data() as Map<String, dynamic>;
                  final titulo = data['titulo'] ?? 'Servicio sin título';
                  final descripcion = data['descripcion'] ?? 'Sin descripción';

                  // Verificar nuevamente el estado de conexión del proveedor en tiempo real
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(proveedorId)
                        .snapshots(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return const Center(
                          child: Text('No se encontraron proveedores disponibles.'),
                        );
                      }

                      final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                      final conectado = userData['isOnline'] == true;
                      
                      if (!conectado) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wifi_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No se encontraron proveedores disponibles.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'El proveedor no está conectado actualmente.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      final nombre = userData['nombre'] ?? 'Proveedor sin nombre';
                      final celular = userData['celular'] ?? 'Número no disponible';

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Indicador de estado conectado
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Conectado',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text('Proveedor: $nombre', style: TextStyle(fontSize: 16)),
                                    Text('Celular: $celular', style: TextStyle(fontSize: 16)),
                                    const SizedBox(height: 12),
                                    Text(descripcion, maxLines: 3, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Contactar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () async {
                                  final solicitudId = const Uuid().v4();
                                  await FirebaseFirestore.instance
                                      .collection('notificaciones')
                                      .doc(solicitudId)
                                      .set({
                                        'id': solicitudId,
                                        'clienteId': currentUser.uid,
                                        'nombreCliente': userDoc.data()?['nombre'] ?? '',
                                        'proveedorId': proveedorId,
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
                            ),
                          ],
                        ),
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
    if (clienteIdActual == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Mis Favoritos')),
        body: Center(child: Text('Cliente no identificado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Mis Favoritos')),
      body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('favoritos')
          .where('clienteId', isEqualTo: clienteIdActual)
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tienes servicios favoritos',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

              // Ordenar los documentos por fecha en el cliente
              final sortedDocs = docs.toList();
              sortedDocs.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aFecha = aData['fechaAgregado'] ?? 0;
                final bFecha = bData['fechaAgregado'] ?? 0;
                return bFecha.compareTo(aFecha); // Descendente (más reciente primero)
              });

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: sortedDocs.length,
                itemBuilder: (context, index) {
                  final favoritoData = sortedDocs[index].data() as Map<String, dynamic>;
                  final favoritoId = sortedDocs[index].id;
                  final servicioId = favoritoData['servicioId'] ?? '';

              return FutureBuilder<Map<String, dynamic>?>(
                future: obtenerServicio(servicioId),
                builder: (context, servicioSnapshot) {
                  if (servicioSnapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final servicioData = servicioSnapshot.data;
                  if (servicioData == null) {
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text('Servicio no encontrado'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => eliminarFavorito(favoritoId),
                        ),
                      ),
                    );
                  }

                  final titulo = servicioData['titulo'] ?? 'Sin título';
                  final subcategoria = servicioData['subcategoria'] ?? 'Sin categoría';
                  final ubicacion = servicioData['ubicacion'] ?? 'Sin ubicación';
                  final proveedorId = servicioData['idusuario'] ?? '';
                  final descripcion = servicioData['descripcion'] ?? '';
                  final imagen = servicioData['imagen'] ?? '';

                  return FutureBuilder<String?>(
                    future: obtenerNombreProveedor(proveedorId),
                    builder: (context, proveedorSnapshot) {
                      final nombreProveedor = proveedorSnapshot.data ?? 'Proveedor desconocido';

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Imagen del servicio
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imagen.isNotEmpty
                                    ? Image.network(
                                        imagen,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[300],
                                            child: Icon(Icons.image_not_supported),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.image),
                                      ),
                              ),
                              SizedBox(width: 12),
                              // Información del servicio
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      titulo,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      subcategoria,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Proveedor: $nombreProveedor',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, 
                                             size: 14, color: Colors.grey),
                                        SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            ubicacion,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (descripcion.isNotEmpty) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        descripcion,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Botones de acción
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.message, color: Colors.blue),
                                    onPressed: () => mostrarContactoModal(
                                      context,
                                      servicioId,
                                      proveedorId,
                                      subcategoria,
                                    ),
                                  ),
                                  Text(
                                    'Contactar',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  IconButton(
                                    icon: Icon(Icons.star, color: Colors.amber),
                                    onPressed: () => eliminarFavorito(favoritoId),
                                  ),
                                  Text(
                                    'Quitar',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.red,
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
                },
              );
            },
          );
        },
      ),
    );
  }
}