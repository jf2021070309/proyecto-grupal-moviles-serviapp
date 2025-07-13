import 'package:flutter/material.dart';
import 'package:serviapp/vista/usuario/new_user_page.dart';
import 'package:serviapp/vista/usuario/new_proveedor.dart';
import 'package:serviapp/styles/usuario/select_user_styles.dart';

class SelectUserTypePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Cuenta'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '¿Cómo deseas registrarte?',
              style: SelectUserStyles.titleText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Sección Cliente
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://interfono.com/wp-content/uploads/Primer-contacto-con-el-cliente-700x466.jpg.webp',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: SelectUserStyles.clienteButtonStyle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewUserPage()),
                );
              },
              icon: const Icon(Icons.person),
              label: const Text('Registrarse como Cliente'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Solicita servicios de manera rápida y segura.\nAccede a proveedores verificados.',
              style: SelectUserStyles.descriptionText,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Sección Proveedor
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://us.123rf.com/450wm/goodstudio/goodstudio1903/goodstudio190300383/119418587-retrato-de-grupo-de-lindos-trabajadores-felices-de-la-industria-o-la-construcci%C3%B3n-ingenieros-de-pie.jpg?ver=6',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: SelectUserStyles.proveedorButtonStyle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewProveedorPage()),
                );
              },
              icon: const Icon(Icons.build),
              label: const Text('Registrarse como Proveedor'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ofrece tus servicios a nuevos clientes.\nAumenta tu visibilidad en la plataforma.',
              style: SelectUserStyles.descriptionText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
