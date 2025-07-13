// lib/vista/Usuario/perfil_usuario.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serviapp/modelo/global_user.dart';
import 'package:serviapp/modelo/usuario_model.dart';
import 'package:serviapp/styles/home_styles.dart';
import 'package:serviapp/vista/usuario/editar_perfil_usuario.dart';
import 'package:serviapp/controlador/login_controller.dart';

class PerfilUsuarioPage extends StatelessWidget {
  const PerfilUsuarioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usuarioid = GlobalUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: kTitleStyle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editarPerfil(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(usuarioid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar datos'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No se encontraron datos'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          return FutureBuilder<List<String>>(
            future: _obtenerSubcategorias(usuarioid!),
            builder: (context, subcatSnapshot) {
              if (subcatSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tipoTrabajo =
                  subcatSnapshot.data?.map((e) => '- $e').join('\n') ?? '';

              return _buildProfileContent(context, userData, tipoTrabajo, usuarioid);
            },
          );
        },
      ),
    );
  }

  Future<List<String>> _obtenerSubcategorias(String usuarioId) async {
    try {
      print('Iniciando consulta de subcategorías para usuarioId: $usuarioId');

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('servicios')
              .where('idusuario', isEqualTo: usuarioId)
              .get();

      print(
        'Consulta completada. Documentos encontrados: ${querySnapshot.docs.length}',
      );

      for (var doc in querySnapshot.docs) {
        print('Documento ID: ${doc.id}, subcategoria: ${doc['subcategoria']}');
      }

      final subcategorias =
          querySnapshot.docs
              .map((doc) => doc['subcategoria'] as String?)
              .where((sub) => sub != null && sub.isNotEmpty)
              .toSet()
              .toList();

      print('Subcategorías únicas obtenidas: $subcategorias');

      return subcategorias.cast<String>();
    } catch (e) {
      print('Error al obtener subcategorías: $e');
      return [];
    }
  }

  // Stream para obtener estadísticas de calificaciones en tiempo real
  Stream<Map<String, dynamic>> _obtenerEstadisticasCalificacionesStream(String usuarioId) {
    return FirebaseFirestore.instance
        .collection('calificaciones')
        .where('proveedorId', isEqualTo: usuarioId)
        .snapshots()
        .map((querySnapshot) {
      try {
        print('Stream: Documentos de calificaciones encontrados: ${querySnapshot.docs.length}');

        if (querySnapshot.docs.isEmpty) {
          return {
            'promedio': 0.0,
            'totalCalificaciones': 0,
            'estrellas': 0,
          };
        }

        double sumaCalificaciones = 0;
        int totalCalificaciones = querySnapshot.docs.length;

        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          final puntuacion = (data['puntuacion'] ?? 0).toDouble();
          sumaCalificaciones += puntuacion;
          print('Stream: Puntuación encontrada: $puntuacion');
        }

        double promedio = sumaCalificaciones / totalCalificaciones;
        int estrellas = _calcularEstrellas(promedio);

        print('Stream: Suma total: $sumaCalificaciones, Promedio: $promedio, Estrellas: $estrellas');

        return {
          'promedio': promedio,
          'totalCalificaciones': totalCalificaciones,
          'estrellas': estrellas,
        };
      } catch (e) {
        print('Error en stream de calificaciones: $e');
        return {
          'promedio': 0.0,
          'totalCalificaciones': 0,
          'estrellas': 0,
        };
      }
    });
  }

  // Función para calcular estrellas basado en el promedio (ajustada para rango 1-5)
  int _calcularEstrellas(double promedio) {
    // Ajusté los rangos para ser más realistas con un sistema 1-5
    if (promedio >= 4.5) return 5;
    if (promedio >= 3.5) return 4;
    if (promedio >= 2.5) return 3;
    if (promedio >= 1.5) return 2;
    if (promedio >= 1.0) return 1;
    return 0;
  }

  // Widget para mostrar las estrellas
  Widget _buildEstrellas(int numeroEstrellas) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < numeroEstrellas ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  // Widget para la sección de calificaciones (SOLO PARA PROVEEDORES)
  Widget _buildSeccionCalificaciones(String usuarioId, String rol) {
    // Verificación estricta del rol
    if (rol.toLowerCase() != 'proveedor') {
      print('Usuario no es proveedor, rol: $rol');
      return const SizedBox.shrink(); // Widget vacío que no ocupa espacio
    }

    return StreamBuilder<Map<String, dynamic>>(
      stream: _obtenerEstadisticasCalificacionesStream(usuarioId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Cargando calificaciones...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          print('Error en snapshot de calificaciones: ${snapshot.error}');
          return Container();
        }

        final stats = snapshot.data!;
        final promedio = stats['promedio'] as double;
        final totalCalificaciones = stats['totalCalificaciones'] as int;
        final estrellas = stats['estrellas'] as int;

        if (totalCalificaciones == 0) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.star_outline, size: 32, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Sin calificaciones aún',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Completa tu primer servicio para recibir calificaciones',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Calificaciones',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildEstrellas(estrellas),
                    SizedBox(width: 12),
                    Text(
                      promedio.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '($totalCalificaciones)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  totalCalificaciones == 1 
                      ? '1 calificación'
                      : '$totalCalificaciones calificaciones',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Stream para estadísticas adicionales (solo proveedores)
  Widget _buildEstadisticasProveedor(String usuarioId, String rol) {
    // Verificación estricta del rol
    if (rol.toLowerCase() != 'proveedor') {
      return const SizedBox.shrink(); // Widget vacío que no ocupa espacio
    }

    return StreamBuilder<Map<String, int>>(
      stream: _obtenerEstadisticasProveedorStream(usuarioId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container();
        }

        final stats = snapshot.data!;
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Estadísticas de Servicios',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildEstadisticaItem(
                      Icons.check_circle,
                      'Completados',
                      stats['completados'].toString(),
                      Colors.green,
                    ),
                    _buildEstadisticaItem(
                      Icons.pending,
                      'Pendientes',
                      stats['pendientes'].toString(),
                      Colors.orange,
                    ),
                    _buildEstadisticaItem(
                      Icons.work,
                      'Total',
                      stats['total'].toString(),
                      Colors.blue,
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

  Widget _buildEstadisticaItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Stream<Map<String, int>> _obtenerEstadisticasProveedorStream(String usuarioId) {
    return FirebaseFirestore.instance
        .collection('notificaciones')
        .where('proveedorId', isEqualTo: usuarioId)
        .snapshots()
        .map((querySnapshot) {
      try {
        int completados = 0;
        int pendientes = 0;
        int total = querySnapshot.docs.length;

        for (var doc in querySnapshot.docs) {
          final estado = doc.data()['estado'] ?? '';
          if (estado == 'aceptado') {
            completados++;
          } else if (estado == 'pendiente') {
            pendientes++;
          }
        }

        return {
          'completados': completados,
          'pendientes': pendientes,
          'total': total,
        };
      } catch (e) {
        print('Error en stream de estadísticas del proveedor: $e');
        return {
          'completados': 0,
          'pendientes': 0,
          'total': 0,
        };
      }
    });
  }

  Widget _buildProfileContent(
    BuildContext context,
    Map<String, dynamic> userData,
    String tipoTrabajo,
    String usuarioId,
  ) {
    final rol = userData['rol'] ?? 'cliente';
    print('Rol del usuario: $rol'); // Debug para verificar el rol

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar con indicador de verificación
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
              ),
              if (rol.toLowerCase() == 'proveedor')
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Nombre y email
          Text(
            userData['nombre'] ?? 'Nombre no disponible',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            userData['email'] ?? '',
            style: TextStyle(color: Colors.grey[600]),
          ),
          
          // Badge del rol
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: rol.toLowerCase() == 'proveedor' ? Colors.blue[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              rol.toLowerCase() == 'proveedor' ? 'Proveedor de Servicios' : 'Cliente',
              style: TextStyle(
                color: rol.toLowerCase() == 'proveedor' ? Colors.blue[800] : Colors.green[800],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(height: 24),

          // Sección de calificaciones (SOLO para proveedores)
          _buildSeccionCalificaciones(usuarioId, rol),
          
          // Espaciado condicional
          if (rol.toLowerCase() == 'proveedor') const SizedBox(height: 16),

          // Estadísticas del proveedor (SOLO para proveedores)
          _buildEstadisticasProveedor(usuarioId, rol),
          
          // Espaciado condicional
          if (rol.toLowerCase() == 'proveedor') const SizedBox(height: 16),

          // Información personal
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información Personal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow(Icons.credit_card, 'DNI', userData['dni']),
                  const Divider(),
                  _buildInfoRow(
                    Icons.phone,
                    'Teléfono',
                    userData['celular'] ?? '',
                  ),

                  if (rol.toLowerCase() == 'proveedor' && tipoTrabajo.isNotEmpty) ...[
                    const Divider(),
                    _buildInfoRow(Icons.work, 'Servicios ofrecidos', tipoTrabajo),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Botones de acción
          _buildActionButton(
            icon: Icons.lock,
            text: 'Cambiar contraseña',
            onPressed: () => _cambiarContrasena(context),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.logout,
            text: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          foregroundColor: isDestructive ? Colors.white : Colors.black87,
          backgroundColor: isDestructive ? Colors.red : Colors.grey[200],
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _editarPerfil(BuildContext context) async {
    final usuarioid = GlobalUser.uid;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(usuarioid)
            .get();

    if (!snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontraron datos de usuario')),
      );
      return;
    }

    final data = snapshot.data()!;
    final usuario = Usuario(
      id: usuarioid!,
      nombre: data['nombre'] ?? '',
      dni: data['dni'] ?? '',
      celular: data['celular'] ?? '',
      rol: data['rol'] ?? 'cliente',
      email: data['email'] ?? '',
      password: '',
      tipoTrabajo:
          data['tipoTrabajo'] is List
              ? List<String>.from(data['tipoTrabajo'])
              : data['tipoTrabajo'] != null
              ? [data['tipoTrabajo'].toString()]
              : null,
      experiencia:
          data['experiencia'] is List
              ? List<String>.from(data['experiencia'])
              : data['experiencia'] != null
              ? [data['experiencia'].toString()]
              : null,
    );

    final actualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarPerfilUsuarioPage(usuario: usuario),
      ),
    );

    if (actualizado != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
    }
  }

  void _cambiarContrasena(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cambiar contraseña'),
            content: const Text(
              'Se enviará un enlace a tu correo para cambiar la contraseña',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _enviarEnlaceCambioContrasena(context);
                },
                child: const Text('Enviar enlace'),
              ),
            ],
          ),
    );
  }

  Future<void> _enviarEnlaceCambioContrasena(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: FirebaseAuth.instance.currentUser!.email!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enlace enviado a tu correo electrónico')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    try {
      await LoginController().logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
      );
    }
  }
}