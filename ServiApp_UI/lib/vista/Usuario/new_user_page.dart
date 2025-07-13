import 'package:flutter/material.dart';
import 'package:serviapp/controlador/usuario_controller.dart';
import 'package:serviapp/modelo/usuario_model.dart';
import 'package:serviapp/styles/usuario/new_user_styles.dart';
import 'package:flutter/services.dart';

class NewUserPage extends StatefulWidget {
  @override
  _NewUserPageState createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _celularController = TextEditingController();
  final _dniController = TextEditingController();
  final _usuarioController = UsuarioController();

  String _errorMessage = "";
  bool _passwordsMatch = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswordsMatch);
    _confirmPasswordController.addListener(_validatePasswordsMatch);
  }

  void _validatePasswordsMatch() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  void _registerUser() async {
    String nombre = _nombreController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String dni = _dniController.text.trim();
    String celular = _celularController.text.trim();

    setState(() => _errorMessage = "");

    if (nombre.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        dni.isEmpty ||
        celular.isEmpty) {
      setState(() {
        _errorMessage = "Todos los campos son obligatorios.";
      });
      return;
    }

    if (!_passwordsMatch) {
      setState(() {
        _errorMessage = "Las contraseñas no coinciden.";
      });
      return;
    }

    if (!RegExp(r'^\d{8}$').hasMatch(dni)) {
      setState(() {
        _errorMessage = "El DNI debe tener 8 dígitos.";
      });
      return;
    }

    if (!RegExp(r'^\d{9}$').hasMatch(celular)) {
      setState(() {
        _errorMessage = "El número de celular debe tener 9 dígitos.";
      });
      return;
    }

    final usuario = Usuario(
      id: "",
      nombre: nombre,
      email: email,
      password: password,
      rol: "cliente",
      celular: celular,
      dni: dni,
    );

    try {
      await _usuarioController.createUser(usuario);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _errorMessage = "Error al registrar el usuario: $e";
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _celularController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                "Crear Cuenta",
                style: NewUserStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nombreController,
                decoration: NewUserStyles.inputDecoration("Nombre completo"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _dniController,
                keyboardType: TextInputType.number,
                decoration: NewUserStyles.inputDecoration("DNI"),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(8),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _celularController,
                keyboardType: TextInputType.phone,
                decoration: NewUserStyles.inputDecoration("Celular"),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(9),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: NewUserStyles.inputDecoration("Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: NewUserStyles.inputDecoration("Contraseña"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: NewUserStyles.inputDecoration(
                  "Confirmar contraseña",
                ).copyWith(
                  errorText:
                      _passwordsMatch
                          ? null
                          : "Asegurate que las contraseñas coinciden",
                ),
              ),
              const SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _errorMessage,
                    style: NewUserStyles.errorText,
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _registerUser,
                icon: const Icon(Icons.person_add),
                label: const Text("Crear Cuenta"),
                style: NewUserStyles.primaryButton,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿Ya tienes una cuenta? "),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: const Text(
                      "Inicia sesión",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
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
