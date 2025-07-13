import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- Importante para inputFormatters
import 'package:serviapp/controlador/usuario_controller.dart';
import 'package:serviapp/modelo/usuario_model.dart';
import 'package:serviapp/styles/usuario/new_proveedor_styles.dart';
import 'package:serviapp/vista/home_proveedor_page.dart';

class NewProveedorPage extends StatefulWidget {
  @override
  _NewProveedorPageState createState() => _NewProveedorPageState();
}

class _NewProveedorPageState extends State<NewProveedorPage> {
  final _nombreController = TextEditingController();
  final _dniController = TextEditingController();
  final _celularController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _usuarioController = UsuarioController();

  String? _selectedCategoria;
  String? _selectedTipoTrabajo;
  String? _selectedExperiencia;

  String _errorMessage = "";

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
          'Soporte técnico',
          'Instalación de software',
          'Redes y conectividad',
          'Reparación de celulares',
          'Diseño web',
        ];
      case 'Vehículos':
        return [
          'Mecánica general',
          'Electricidad automotriz',
          'Planchado y pintura',
          'Cambio de aceite',
          'Lavado de autos',
          'Servicio de grúa',
        ];
      case 'Eventos':
        return [
          'Organización de eventos',
          'Catering',
          'Fotografía y video',
          'Animación',
          'Decoración',
          'DJ y sonido',
        ];
      case 'Estetica':
        return [
          'Corte de cabello',
          'Manicure y pedicure',
          'Maquillaje',
          'Tratamientos faciales',
          'Depilación',
          'Masajes',
        ];
      case 'Salud y Bienestar':
        return [
          'Enfermería a domicilio',
          'Fisioterapia',
          'Nutrición',
          'Psicología',
          'Entrenamiento personal',
          'Yoga y meditación',
        ];
      case 'Servicios Generales':
        return [
          'Electricidad',
          'Gasfitería',
          'Carpintería',
          'Albañilería',
          'Pintura',
          'Cerrajería',
        ];
      case 'Educacion':
        return [
          'Clases particulares',
          'Idiomas',
          'Música',
          'Arte',
          'Apoyo escolar',
          'Preparación universitaria',
        ];
      case 'Limpieza':
        return [
          'Limpieza de hogares',
          'Limpieza de oficinas',
          'Lavado de muebles',
          'Lavandería',
          'Fumigación',
          'Jardinería',
        ];
      default:
        return [];
    }
  }

  final List<String> experiencias = ['1 año', '2 años', '3 años o más'];

  void _registerProveedor() async {
    setState(() => _errorMessage = "");

    String nombre = _nombreController.text.trim();
    String dni = _dniController.text.trim();
    String celular = _celularController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Validar campos vacíos
    if (nombre.isEmpty ||
        dni.isEmpty ||
        celular.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        _selectedCategoria == null ||
        _selectedTipoTrabajo == null ||
        _selectedExperiencia == null) {
      setState(() {
        _errorMessage = "Por favor, complete todos los campos.";
      });
      return;
    }

    // Puedes mantener esta validación si quieres un doble chequeo, pero ya no es estrictamente necesario
    if (dni.length != 8) {
      setState(() {
        _errorMessage = "El DNI debe tener exactamente 8 dígitos.";
      });
      return;
    }

    if (celular.length != 9) {
      setState(() {
        _errorMessage =
            "El número de celular debe tener exactamente 9 dígitos.";
      });
      return;
    }

    // Validar email formato simple
    if (!RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email)) {
      setState(() {
        _errorMessage = "Ingrese un correo electrónico válido.";
      });
      return;
    }

    // Validar contraseña
    if (password.length < 6) {
      setState(() {
        _errorMessage = "La contraseña debe tener al menos 6 caracteres.";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Las contraseñas no coinciden.";
      });
      return;
    }

    // Crear modelo Usuario para proveedor
    final usuario = Usuario(
      id: "",
      nombre: nombre,
      email: email,
      password: password,
      rol: "proveedor",
      celular: celular,
      dni: dni,
      tipoTrabajo: [_selectedTipoTrabajo!],
      experiencia: [_selectedExperiencia!],
    );

    try {
      await _usuarioController.createUser(usuario);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeProveedorPage()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "Error al registrar: $e";
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _dniController.dispose();
    _celularController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> tiposTrabajo =
        _selectedCategoria == null
            ? []
            : obtenerSubcategorias(_selectedCategoria!);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                height: 180,
                child: Image.asset('assets/images/signup_illustration.png'),
              ),
              const SizedBox(height: 20),
              Text(
                "Crear Cuenta Proveedor",
                style: NewProveedorStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _nombreController,
                decoration: NewProveedorStyles.inputDecoration(
                  "Nombre completo",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _dniController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(8),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: NewProveedorStyles.inputDecoration("DNI"),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _celularController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(9),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: NewProveedorStyles.inputDecoration("Celular"),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: NewProveedorStyles.inputDecoration(
                  "Correo electrónico",
                ),
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                decoration: NewProveedorStyles.inputDecoration("Categoría"),
                value: _selectedCategoria,
                items:
                    categorias
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoria = value;
                    _selectedTipoTrabajo = null;
                  });
                },
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                decoration: NewProveedorStyles.inputDecoration(
                  "Tipo de trabajo",
                ),
                value: _selectedTipoTrabajo,
                items:
                    tiposTrabajo
                        .map(
                          (tipo) =>
                              DropdownMenuItem(value: tipo, child: Text(tipo)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTipoTrabajo = value;
                  });
                },
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                decoration: NewProveedorStyles.inputDecoration("Experiencia"),
                value: _selectedExperiencia,
                items:
                    experiencias
                        .map(
                          (exp) =>
                              DropdownMenuItem(value: exp, child: Text(exp)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedExperiencia = value;
                  });
                },
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: NewProveedorStyles.inputDecoration("Contraseña"),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: NewProveedorStyles.inputDecoration(
                  "Confirmar contraseña",
                ),
              ),
              const SizedBox(height: 10),

              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: _registerProveedor,
                child: const Text("Crear Cuenta"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
