import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serviapp/controlador/servicio_controller.dart';
import 'package:serviapp/styles/Proveedor/agregar_servicio_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- AÑADE ESTO
import 'package:serviapp/modelo/global_user.dart';    // <--- Y ESTO

class AgregarServicioPage extends StatefulWidget {
  @override
  _AgregarServicioPageState createState() => _AgregarServicioPageState();
}

class _AgregarServicioPageState extends State<AgregarServicioPage> {
  final _formKey = GlobalKey<FormState>();
  final ServicioController _servicioController = ServicioController();
  
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  
  String? _categoriaSeleccionada;
  String? _subcategoriaSeleccionada;
  List<String> _subcategorias = [];
  bool _cargando = false;
  
  // Variable para almacenar la imagen seleccionada
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();
  
  // Lista de categorías disponibles
  final List<String> _categorias = [
    'Tecnologia',
    'Vehículos',
    'Eventos',
    'Estetica',
    'Salud y Bienestar',
    'Servicios Generales',
    'Educacion',
    'Limpieza',
  ];
  
  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _telefonoController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }
  
  void _actualizarSubcategorias(String categoria) {
    setState(() {
      _categoriaSeleccionada = categoria;
      _subcategorias = _servicioController.obtenerSubcategorias(categoria);
      _subcategoriaSeleccionada = null; // Resetear subcategoría al cambiar categoría
    });
  }
  
  // Método para seleccionar imagen de la galería
  Future<void> _seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75, // Reducir calidad para optimizar el tamaño
    );
    
    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }
  
  // Método para tomar una foto con la cámara
  Future<void> _tomarFoto() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    
    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }
  
  // Método para mostrar opciones de selección de imagen
  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Seleccionar de la galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagen();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Tomar una foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _tomarFoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Validador para título y ubicación (letras, números, puntos, comas)
  String? _validarTextoGeneral(String? value, String campo, int maxLength) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa $campo';
    }
    
    if (value.length > maxLength) {
      return '$campo no puede exceder $maxLength caracteres';
    }
    
    // Expresión regular que permite letras, números, espacios, puntos y comas
    RegExp regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s.,]+$');
    if (!regex.hasMatch(value)) {
      return '$campo solo puede contener letras, números, puntos y comas';
    }
    
    return null;
  }
  
  // Validador específico para teléfono
  String? _validarTelefono(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa un teléfono de contacto';
    }
    
    // Verificar que solo contenga números
    RegExp regex = RegExp(r'^[0-9]+$');
    if (!regex.hasMatch(value)) {
      return 'El teléfono solo puede contener números';
    }
    
    // Verificar que tenga exactamente 9 dígitos
    if (value.length != 9) {
      return 'El teléfono debe tener exactamente 9 dígitos';
    }
    
    return null;
  }
  
Future<void> _registrarServicio() async {
  if (_formKey.currentState!.validate()) {
    if (_categoriaSeleccionada == null || _subcategoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona categoría y subcategoría')),
      );
      return;
    }
    if (_imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona una imagen para el servicio')),
      );
      return;
    }

    setState(() {
      _cargando = true;
    });

    // 1. Chequear publicaciones y tokens antes de registrar
    try {
      final usuarioId = GlobalUser.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(usuarioId).get();
      int publicaciones = (userDoc.data()?['publicaciones'] ?? 0) as int;
      int tokens = (userDoc.data()?['tokens'] ?? 0) as int;

      if (publicaciones >= 2) {
        // Mostrar advertencia y pedir confirmación
        bool continuar = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Text('¿Deseas continuar?'),
            content: Text(
              'Ya usaste tus 2 publicaciones gratuitas.\n'
              'Para publicar un nuevo servicio se te descontarán 50 tokens.\n'
              'Tokens actuales: $tokens\n\n'
              '¿Deseas continuar?',
            ),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              ElevatedButton(
                child: Text('Sí, continuar'),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
        ) ?? false;

        if (!continuar) {
          setState(() => _cargando = false);
          return;
        }
      }

      // Si no canceló, intenta registrar
      bool resultado = await _servicioController.registrarServicio(
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        categoria: _categoriaSeleccionada!,
        subcategoria: _subcategoriaSeleccionada!,
        telefono: _telefonoController.text,
        ubicacion: _ubicacionController.text,
        imagenFile: _imagenSeleccionada,
      );

      setState(() {
        _cargando = false;
      });

      if (resultado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Servicio registrado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }

    } catch (e) {
      setState(() {
        _cargando = false;
      });
      final errorMsg = e.toString();
      if (errorMsg.contains('No tienes suficientes tokens')) {
        // Mensaje especial y opciones
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('¡Tokens insuficientes!'),
            content: Text(
              'Ya usaste tus 2 publicaciones gratuitas. Para publicar uno nuevo debes pagar 50 tokens.\n\n'
              'No tienes suficientes tokens. ¿Qué deseas hacer?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Aquí puedes llevarlo a la pantalla de recarga de tokens
                  // Navigator.pushNamed(context, '/recargar_tokens');
                },
                child: Text('Recargar tokens'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Servicio'),
        centerTitle: true,
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sección para la imagen del servicio
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: AgregarServicioStyles.containerDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Imagen del Servicio',
                            style: AgregarServicioStyles.titleStyle,
                          ),
                          SizedBox(height: 20),
                          
                          Center(
                            child: GestureDetector(
                              onTap: _mostrarOpcionesImagen,
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: _imagenSeleccionada != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          _imagenSeleccionada!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            size: 60,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Toca para agregar una imagen',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Sección de información del servicio
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: AgregarServicioStyles.containerDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información del Servicio',
                            style: AgregarServicioStyles.titleStyle,
                          ),
                          SizedBox(height: 20),
                          
                          // Título
                          TextFormField(
                            controller: _tituloController,
                            decoration: AgregarServicioStyles.inputDecoration.copyWith(
                              labelText: 'Título del Servicio',
                              prefixIcon: Icon(Icons.title),
                              helperText: 'Máximo 130 caracteres. Solo letras, números, puntos y comas',
                              counterText: '${_tituloController.text.length}/130',
                            ),
                            maxLength: 130,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s.,]')),
                            ],
                            onChanged: (value) => setState(() {}),
                            validator: (value) => _validarTextoGeneral(value, 'el título', 130),
                          ),
                          SizedBox(height: 16),
                          
                          // Descripción
                          TextFormField(
                            controller: _descripcionController,
                            decoration: AgregarServicioStyles.inputDecoration.copyWith(
                              labelText: 'Descripción',
                              prefixIcon: Icon(Icons.description),
                              alignLabelWithHint: true,
                              helperText: 'Máximo 500 caracteres. Solo letras, números, puntos y comas',
                              counterText: '${_descripcionController.text.length}/500',
                            ),
                            maxLines: 3,
                            maxLength: 500,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s.,]')),
                            ],
                            onChanged: (value) => setState(() {}),
                            validator: (value) => _validarTextoGeneral(value, 'la descripción', 500),
                          ),
                          SizedBox(height: 16),
                          
                          // Categoría
                          DropdownButtonFormField<String>(
                            decoration: AgregarServicioStyles.inputDecoration.copyWith(
                              labelText: 'Categoría',
                              prefixIcon: Icon(Icons.category),
                            ),
                            value: _categoriaSeleccionada,
                            items: _categorias.map((String categoria) {
                              return DropdownMenuItem<String>(
                                value: categoria,
                                child: Text(categoria),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                _actualizarSubcategorias(newValue);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor selecciona una categoría';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          
                          // Subcategoría
                          DropdownButtonFormField<String>(
                            decoration: AgregarServicioStyles.inputDecoration.copyWith(
                              labelText: 'Subcategoría',
                              prefixIcon: Icon(Icons.subdirectory_arrow_right),
                            ),
                            value: _subcategoriaSeleccionada,
                            items: _subcategorias.map((String subcategoria) {
                              return DropdownMenuItem<String>(
                                value: subcategoria,
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                                  child: Text(
                                    subcategoria,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: _subcategorias.isEmpty
                                ? null
                                : (String? newValue) {
                                    setState(() {
                                      _subcategoriaSeleccionada = newValue;
                                    });
                                  },
                            validator: (value) {
                              if (_categoriaSeleccionada != null &&
                                  (value == null || value.isEmpty)) {
                                return 'Por favor selecciona una subcategoría';
                              }
                              return null;
                            },
                            hint: Text(_categoriaSeleccionada == null
                                ? 'Primero selecciona una categoría'
                                : 'Selecciona una subcategoría'),
                            isExpanded: true,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Sección de información de contacto
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: AgregarServicioStyles.containerDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información de Contacto',
                            style: AgregarServicioStyles.titleStyle,
                          ),
                          SizedBox(height: 20),
                          
                          // Teléfono
                          TextFormField(
                            controller: _telefonoController,
                            decoration: AgregarServicioStyles.inputDecoration.copyWith(
                              labelText: 'Teléfono de contacto',
                              prefixIcon: Icon(Icons.phone),
                              helperText: 'Debe tener exactamente 9 dígitos numéricos',
                              counterText: '${_telefonoController.text.length}/9',
                              errorStyle: TextStyle(color: Colors.red),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 9,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) => setState(() {}),
                            validator: _validarTelefono,
                          ),
                          SizedBox(height: 16),
                          
                          // Ubicación
                          TextFormField(
                            controller: _ubicacionController,
                            decoration: AgregarServicioStyles.inputDecoration.copyWith(
                              labelText: 'Ubicación (opcional)',
                              prefixIcon: Icon(Icons.location_on),
                              helperText: 'Máximo 130 caracteres. Solo letras, números, puntos y comas',
                              counterText: '${_ubicacionController.text.length}/130',
                            ),
                            maxLength: 130,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s.,]')),
                            ],
                            onChanged: (value) => setState(() {}),
                            validator: (value) {
                              // Para ubicación permitimos que esté vacío
                              if (value != null && value.isNotEmpty) {
                                return _validarTextoGeneral(value, 'la ubicación', 130);
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: AgregarServicioStyles.secondaryButtonStyle,
                            child: Text('Cancelar'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _registrarServicio,
                            style: AgregarServicioStyles.primaryButtonStyle,
                            child: Text('Registrar Servicio'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}