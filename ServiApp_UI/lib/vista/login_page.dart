import 'package:flutter/material.dart';
import 'package:serviapp/vista/home_page.dart';
import 'package:serviapp/vista/home_proveedor_page.dart';
import 'package:serviapp/vista/usuario/select_user_type_page.dart';
import 'package:serviapp/controlador/login_controller.dart';
import 'package:serviapp/styles/login_styles.dart';
import 'package:serviapp/admin/vista/admin_home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginController loginController = LoginController();
  bool _obscurePassword = true;

  void login() async {
    String email = emailController.text;
    String password = passwordController.text;

    final result = await loginController.loginUser(email, password);

    if (!mounted) return;

    if (result != null) {
      // VALIDACIÓN DE USUARIO BLOQUEADO - Verificar si el resultado indica usuario bloqueado
      if (result.containsKey('error') && result['error'] == 'blocked') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Tu cuenta ha sido bloqueada'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return; // Salir del método sin redirigir
      }
      // FIN VALIDACIÓN DE USUARIO BLOQUEADO

      // Depuración - verifica el rol que está llegando
      print("ROL DEL USUARIO: ${result['rol']}");

      // Comparación exacta de strings
      if (result['rol'] == 'Admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomePage()),
        );
      } else if (result['rol'] == 'proveedor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeProveedorPage()),
        );
      } else {
        // Si es cliente u otro rol, ir a la página regular
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo o contraseña incorrectos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Image.asset(
                'assets/images/login_illustration.png',
                height: 200,
              ),
            ),
            const SizedBox(height: 20),
            const Text("Log In", style: LoginStyles.titleStyle),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: LoginStyles.inputDecoration.copyWith(
                labelText: "EMAIL ID",
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: LoginStyles.inputDecoration.copyWith(
                labelText: "PASSWORD",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // lógica para recuperar contraseña
                },
                child: const Text(
                  "¿Has olvidado tu contraseña?",
                  style: LoginStyles.linkStyle,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: login,
              style: LoginStyles.buttonStyle,
              child: const Text("Login", style: LoginStyles.buttonTextStyle),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Or"),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(Icons.facebook, Colors.blue),
                _buildSocialButton(Icons.g_mobiledata, Colors.redAccent),
                _buildSocialButton(Icons.camera_alt, Colors.purple),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  // Redirigir a la página de registro
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectUserTypePage(),
                    ),
                  );
                },
                child: const Text(
                  "¿No tienes una cuenta? Regístrate",
                  style: LoginStyles.linkStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSocialButton(IconData icon, Color color) {
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: () {
          // lógica de login social
        },
      ),
    );
  }
}
