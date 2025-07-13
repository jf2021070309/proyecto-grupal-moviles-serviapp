import 'package:flutter/material.dart';
import 'package:serviapp/vista/Usuario/perfil_usuario.dart';
import '../controlador/login_controller.dart';
import '../controlador/home_controller.dart';
import '../modelo/categoria_model.dart';
import '../modelo/servicio_model.dart';
import 'package:serviapp/styles/home_styles.dart';
import 'Services/tecnologia_page.dart';
import 'Services/eventos_page.dart';
import 'Services/belleza_page.dart';
import 'Services/educacion_page.dart';
import 'Services/limpieza_page.dart';
import 'Services/vehiculos_page.dart';
import 'Services/salud_page.dart';
import 'Services/servicios_generales_page.dart';
import 'Services/misfavoritos.dart';
import 'package:serviapp/vista/Services/todo.dart';
import 'package:serviapp/vista/Usuario/historial_solicitudes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviapp/app_theme2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}



class _HomePageState extends State<HomePage> {
  final LoginController _loginController = LoginController();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    _HomeContent(),
    SolicitudesPage(),
    MisFavoritosPage(),
    PerfilUsuarioPage(),
  ];

  void _logout(BuildContext context) async {
    await _loginController.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Principal'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.flash_on, color: Colors.black),
            label: const Text(
              'Solicitud Rápida',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              _mostrarFormularioRapido(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),

      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Historial',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

void _mostrarFormularioRapido(BuildContext context) {
  String? categoriaSeleccionada;
  String? subcategoriaSeleccionada;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // fondo transparente para el modal
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scrollController) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                List<String> subcategorias =
                    categoriaSeleccionada == null
                        ? []
                        : obtenerSubcategorias(categoriaSeleccionada!);

                return SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Solicitud rápida',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Categoría'),
                        value: categoriaSeleccionada,
                        items:
                            categorias.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            categoriaSeleccionada = value;
                            subcategoriaSeleccionada = null;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Subcategoría'),
                        value: subcategoriaSeleccionada,
                        items:
                            subcategorias.map((sub) {
                              return DropdownMenuItem(
                                value: sub,
                                child: Text(sub),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            subcategoriaSeleccionada = value;
                          });
                        },
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (categoriaSeleccionada != null &&
                                  subcategoriaSeleccionada != null) {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => HistorialSolicitudesPage(
                                          subcategoria:
                                              subcategoriaSeleccionada!,
                                        ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Por favor selecciona ambas opciones.',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text('Aceptar'),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    },
  );
}

final List<String> categorias = [
  'Tecnologia',
  'Vehículos',
  'Eventos',
  'Estetica',
  'Salud y Bienestar',
  'Servicios Generales',
  'Educacion',
  'Limpieza',
];

List<String> obtenerSubcategorias(String categoria) {
  switch (categoria) {
    case 'Tecnologia':
      return [
        'Reparación de computadoras y laptops',
        'Mantenimiento',
        'Instalación de software',
        'Redes y conectividad',
        'Reparación de celulares',
        'Diseño web',
      ];
    case 'Vehículos':
      return [
        'Mecánica automotriz',
        'Lavado y detallado de autos',
        'Cambio de llantas y baterías',
        'Servicio de grúa',
        'Transporte y mudanzas',
        'Lubricentro',
      ];
    case 'Eventos':
      return [
        'Fotografía y filmación',
        'Organización de eventos',
        'Catering y banquetes',
        'Música en vivo y DJ',
      ];
    case 'Estetica':
      return [
        'Peluquería y barbería a domicilio',
        'Manicure y pedicure',
        'Maquillaje y asesoría de imagen',
      ];
    case 'Salud y Bienestar':
      return [
        'Consulta médica a domicilio',
        'Enfermería y cuidados a domicilio',
        'Terapia física y rehabilitación',
        'Masajes y relajación',
        'Entrenador personal',
      ];
    case 'Servicios Generales':
      return [
        'Albañileria',
        'Plomeria',
        'Electricidad',
        'Carpinteria',
        'Pintura y acabados',
        'Jardineria y paisajismo',
      ];
    case 'Educacion':
      return [
        'Clases particulares',
        'Tutoriales en linea',
        'Capacitación en software',
        'Programas académicos',
        'Cursos y Certificaciones',
        'Vacaciones útiles',
      ];
    case 'Limpieza':
      return [
        'Limpieza del hogar y oficinas',
        'Lavanderia y el planchado',
        'Desinfeccion',
        'Encerado y pulido de muebles',
      ];
    default:
      return [];
  }
}

class _HomeContent extends StatefulWidget {
  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final HomeController _homeController = HomeController();
  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _verificarPromocionesVencidas();
    _pageController = PageController();
    _startAutoSlide();
  }

  Future<void> _verificarPromocionesVencidas() async {
    final now = DateTime.now();
    // Trae todos los servicios promocionados activos
    final snap = await FirebaseFirestore.instance
        .collection('servicios')
        .where('slide', isEqualTo: 'true')
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

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categorias = _homeController.obtenerCategorias();
    final servicios = _homeController.obtenerServiciosPopulares();

    return ListView(
      children: [
        _buildAdvertisementSlides(), // Nuevo widget de slides
        _buildCategoriesGrid(categorias, context),
        _buildPopularServices(servicios),
      ],
    );
  }

  // Nuevo widget para los slides de anuncios
  Widget _buildAdvertisementSlides() {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Servicios Destacados', style: kTitleStyle),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('servicios')
                      .where('slide', isEqualTo: "true")
                      .where('estado', isEqualTo: "true")
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar anuncios'));
                }

                final slidesDocs = snapshot.data?.docs ?? [];
                if (slidesDocs.isEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('No hay anuncios disponibles'),
                    ),
                  );
                }

                return PageView.builder(
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    final slideData =
                        slidesDocs[index % slidesDocs.length].data()
                            as Map<String, dynamic>;
                    return _buildSlideCard(
                      slideData,
                      slidesDocs[index % slidesDocs.length].id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideCard(Map<String, dynamic> servicioData, String servicioId) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('users')
              .doc(servicioData['idusuario'])
              .get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final userData =
            userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
        final proveedorNombre = userData['nombre'] ?? 'Proveedor';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.purple[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.campaign, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'DESTACADO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      servicioData['titulo'] ?? 'Servicio',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Por: $proveedorNombre',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        servicioData['descripcion'] ?? 'Sin descripción',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        maxLines: 3, // Puedes usar 2, 3, o el número que prefieras
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: ElevatedButton(
                  onPressed:
                      () => _mostrarDetalleServicio(
                        servicioData,
                        servicioId,
                        proveedorNombre,
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Ver más',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _crearSolicitudAceptadaDesdeServicio(String servicioId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('⚠️ Usuario no autenticado');
        return false;
      }

      // Obtener datos del usuario actual
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

      if (!userDoc.exists) {
        print('⚠️ Datos del usuario no encontrados');
        return false;
      }

      final nombreCliente = userDoc.data()?['nombre'] ?? '';

      // Obtener datos del servicio
      final servicioDoc =
          await FirebaseFirestore.instance
              .collection('servicios')
              .doc(servicioId)
              .get();

      if (!servicioDoc.exists) {
        print('⚠️ El servicio con ID $servicioId no existe.');
        return false;
      }

      final servicioData = servicioDoc.data()!;
      final proveedorId = servicioData['idusuario'];
      final subcategoria = servicioData['subcategoria'];

      final uuid = Uuid();
      final solicitudId = uuid.v4();

      // Crear la notificación/solicitud aceptada
      await FirebaseFirestore.instance
          .collection('notificaciones')
          .doc(solicitudId)
          .set({
            'id': solicitudId,
            'clienteId': currentUser.uid,
            'nombreCliente': nombreCliente,
            'proveedorId': proveedorId,
            'estado': 'aceptado',
            'etapa': '',
            'subcategoria': subcategoria,
            'timestamp': FieldValue.serverTimestamp(),
          });

      print('✅ Solicitud creada desde slide destacado: $servicioId');
      return true;
    } catch (e) {
      print('❌ Error al crear la solicitud: $e');
      return false;
    }
  }

  void _mostrarDetalleServicio(
    Map<String, dynamic> servicioData,
    String servicioId,
    String proveedorNombre,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header del servicio
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue[400]!,
                                      Colors.purple[400]!,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      servicioData['titulo'] ?? 'Servicio',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: ServiceAppTheme.primaryTextColor,
                                      ),
                                    ),
                                    Text(
                                      'Proveedor: $proveedorNombre',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Información del servicio
                          _buildInfoSection(
                            'Categoría',
                            servicioData['subcategoria'] ?? 'General',
                          ),
                          _buildInfoSection(
                            'Descripción',
                            servicioData['descripcion'] ?? 'Sin descripción',
                          ),

                          const SizedBox(height: 20),

                          // Botones de acción
                          ServiceAppWidgets.buildActionButtonsRow(
                            onCallPressed: () async {
                              try {
                                // Mostrar indicador de carga
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Creando solicitud...'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );

                                final success =
                                    await _crearSolicitudAceptadaDesdeServicio(
                                      servicioId,
                                    );

                                if (success) {
                                  // Mostrar confirmación
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '✅ Solicitud creada. Iniciando llamada...',
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );

                                  // Realizar la llamada
                                  final Uri uri = Uri(
                                    scheme: 'tel',
                                    path: servicioData['telefono'],
                                  );
                                  await launchUrl(uri);
                                } else {
                                  throw Exception(
                                    'No se pudo crear la solicitud',
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '❌ Error: No se pudo completar la acción',
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            onWhatsAppPressed: () async {
                              try {
                                // Mostrar indicador de carga
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Creando solicitud...'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );

                                final success =
                                    await _crearSolicitudAceptadaDesdeServicio(
                                      servicioId,
                                    );

                                if (success) {
                                  // Mostrar confirmación
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '✅ Solicitud creada. Abriendo WhatsApp...',
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );

                                  // Abrir WhatsApp
                                  final formatted = servicioData['telefono']
                                      .replaceAll(RegExp(r'[^0-9]'), '');
                                  final Uri uri = Uri.parse(
                                    'https://wa.me/51$formatted',
                                  );
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  throw Exception(
                                    'No se pudo crear la solicitud',
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '❌ Error: No se pudo completar la acción',
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ServiceAppTheme.primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(
    List<Categoria> categorias,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Categorías', style: kTitleStyle)],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categorias.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              return _CategoryItem(categoria: categoria);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPopularServices(List<Servicio> servicios) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Servicios populares', style: kTitleStyle),
              //TextButton(onPressed: () {}, child: const Text('Ver todos')),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: servicios.length,
            itemBuilder: (context, index) {
              final service = servicios[index];
              return _ServiceItem(service: service);
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Categoria categoria;

  const _CategoryItem({required this.categoria});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToCategory(context),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: categoria.gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: categoria.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(categoria.icon, color: Colors.white, size: 30),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            categoria.label,
            textAlign: TextAlign.center,
            style: kCategoryLabelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _navigateToCategory(BuildContext context) {
    Widget? page;
    switch (categoria.label) {
      case 'Tecnologia':
        page = TecnologiayElectronicaPage();
        break;
      case 'Vehículos':
        page = VehiculosTransportePage();
        break;
      case 'Eventos':
        page = EventosEntretenimientoPage();
        break;
      case 'Estetica':
        page = BellezaEsteticaPage();
        break;
      case 'Salud y Bienestar':
        page = SaludBienestarPage();
        break;
      case 'Servicios Generales':
        page = ServiciosGeneralesPage();
        break;
      case 'Educacion':
        page = EducacionCapacitacionPage();
        break;
      case 'Limpieza':
        page = LimpiezaMantenimientoPage();
        break;
    }

    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }
}

class _ServiceItem extends StatelessWidget {
  final Servicio service;

  const _ServiceItem({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: kCardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: service.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(service.icon, color: service.color, size: 28),
        ),
        title: Text(service.titulo, style: kServiceTitleStyle),
        subtitle: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              '${service.promedioCalificaciones.toStringAsFixed(1)} (${service.totalCalificaciones} reseñas)',
              style: kSubtitleStyle,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navegar a detalle del servicio
        },
      ),
    );
  }
}
