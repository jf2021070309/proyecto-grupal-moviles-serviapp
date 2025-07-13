import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serviapp/controlador/servicio_controller.dart';
import 'package:serviapp/styles/Proveedor/agregar_servicio_styles.dart';

class EditarServicioPage extends StatefulWidget {
  final Map<String, dynamic> servicio;
  
  const EditarServicioPage({Key? key, required this.servicio}) : super(key: key);
  
  @override
  _EditarServicioPageState createState() => _EditarServicioPageState();
}

class _EditarServicioPageState extends State<EditarServicioPage> {
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
  
  // Variables para manejar la imagen
  File? _imagenSeleccionada;
  String? _imagenUrlOriginal;
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
  void initState() {
    super.initState();
    _cargarDatosServicio();
  }
  
  void _cargarDatosServicio() {
    // Cargar los datos del servicio en los controladores
    _tituloController.text = widget.servicio['titulo']?.toString() ?? '';
    _descripcionController.text = widget.servicio['descripcion']?.toString() ?? '';
    _telefonoController.text = widget.servicio['telefono']?.toString() ?? '';
    _ubicacionController.text = widget.servicio['ubicacion']?.toString() ?? '';
    
    // Cargar categoría y subcategoría
    _categoriaSeleccionada = widget.servicio['categoria']?.toString();
    _subcategoriaSeleccionada = widget.servicio['subcategoria']?.toString();
    
    // Cargar imagen original
    _imagenUrlOriginal = widget.servicio['imagen']?.toString();
    
    // Actualizar subcategorías si hay categoría seleccionada
    if (_categoriaSeleccionada != null) {
      _actualizarSubcategorias(_categoriaSeleccionada!);
    }
  }
  
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
      // Solo resetear subcategoría si no está en la nueva lista
      if (_subcategoriaSeleccionada != null && 
          !_subcategorias.contains(_subcategoriaSeleccionada)) {
        _subcategoriaSeleccionada = null;
      }
    });
  }
  
  // Método para seleccionar imagen de la galería
  Future<void> _seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
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
  
  Future<void> _actualizarServicio() async {
    if (_formKey.currentState!.validate()) {
      if (_categoriaSeleccionada == null || _subcategoriaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor selecciona categoría y subcategoría')),
        );
        return;
      }
      
      // Verificar si hay imagen (nueva o original)
      if (_imagenSeleccionada == null && (_imagenUrlOriginal == null || _imagenUrlOriginal!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor selecciona una imagen para el servicio')),
        );
        return;
      }
      
      setState(() {
        _cargando = true;
      });
      
      try {
        bool resultado = await _servicioController.actualizarServicio(
          servicioId: widget.servicio['id'],
          titulo: _tituloController.text,
          descripcion: _descripcionController.text,
          categoria: _categoriaSeleccionada!,
          subcategoria: _subcategoriaSeleccionada!,
          telefono: _telefonoController.text,
          ubicacion: _ubicacionController.text,
          imagenFile: _imagenSeleccionada, // Solo se actualiza si hay nueva imagen
          imagenUrlOriginal: _imagenUrlOriginal, // Mantener imagen original si no hay nueva
        );
        
        setState(() {
          _cargando = false;
        });
        
        if (resultado) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Servicio actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar el servicio'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _cargando = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Widget _buildImagenWidget() {
    if (_imagenSeleccionada != null) {
      // Mostrar imagen nueva seleccionada
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          _imagenSeleccionada!,
          fit: BoxFit.cover,
        ),
      );
    } else if (_imagenUrlOriginal != null && _imagenUrlOriginal!.isNotEmpty) {
      // Mostrar imagen original desde URL
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          _imagenUrlOriginal!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 60,
                  color: Colors.grey[600],
                ),
                SizedBox(height: 10),
                Text(
                  'Error al cargar imagen',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      );
    } else {
      // Mostrar placeholder para agregar imagen
      return Column(
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
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Servicio'),
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
                                child: _buildImagenWidget(),
                              ),
                            ),
                          ),
                          
                          if (_imagenSeleccionada != null || (_imagenUrlOriginal != null && _imagenUrlOriginal!.isNotEmpty))
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Center(
                                child: Text(
                                  'Toca la imagen para cambiarla',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
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
                            onPressed: _actualizarServicio,
                            style: AgregarServicioStyles.primaryButtonStyle,
                            child: Text('Actualizar Servicio'),
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