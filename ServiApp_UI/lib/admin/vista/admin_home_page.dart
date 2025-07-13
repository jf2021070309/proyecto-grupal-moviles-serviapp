import 'package:flutter/material.dart';
import '../styles/admin_theme.dart';
import 'dashboard/dashboard_widget.dart';
import 'usuarios/usuarios_widget.dart';
import 'servicios/servicios_widget.dart';
// import 'solicitudes/solicitudes_widget.dart'; // OCULTO
import 'reportes/reportes_widget.dart';
import 'reportes_publicaciones/reportes_publicaciones_widget.dart';
import '../../controlador/login_controller.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final LoginController _loginController = LoginController();
  int _selectedIndex = 0;

  // MÉTODO PARA CERRAR SESIÓN - Actualiza isOnline y redirige al login
  void _logout(BuildContext context) async {
    await _loginController.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }
  // FIN MÉTODO PARA CERRAR SESIÓN

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.backgroundColor,
      appBar: MediaQuery.of(context).size.width < 800 ? AppBar(
        title: Text('Panel Admin', style: TextStyle(color: Colors.white)),
        backgroundColor: AdminTheme.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        // BOTÓN DE LOGOUT EN MÓVIL - Icono de cerrar sesión en el AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _logout(context),
          ),
        ],
        // FIN BOTÓN DE LOGOUT EN MÓVIL
      ) : AppBar(
        title: Text('Panel Admin', style: TextStyle(color: Colors.white)),
        backgroundColor: AdminTheme.primaryColor,
        automaticallyImplyLeading: false, // Quitar el botón de menú en desktop
        // BOTÓN DE LOGOUT EN DESKTOP - Icono de cerrar sesión en el AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _logout(context),
          ),
        ],
        // FIN BOTÓN DE LOGOUT EN DESKTOP
      ),
      drawer: MediaQuery.of(context).size.width < 800 ? _buildMobileSidebar() : null,
      body: MediaQuery.of(context).size.width < 800 
          ? _buildMainContent()
          : Row(
              children: [
                // Sidebar de navegación (solo en desktop)
                _buildSidebar(),
                // Contenido principal
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AdminTheme.primaryColor,
        boxShadow: AdminTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Header del sidebar
          Container(
            padding: const EdgeInsets.all(AdminTheme.largeSpacing),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AdminTheme.secondaryColor,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: AdminTheme.spacing),
                Text(
                  'Panel Administrador',
                  style: AdminTheme.titleMedium.copyWith(color: Colors.white),
                ),
                Text(
                  'ServiApp',
                  style: AdminTheme.bodyMedium.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          // Opciones de navegación
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                _buildNavItem(1, Icons.people, 'Usuarios'),
                _buildNavItem(2, Icons.build, 'Servicios'),
                // _buildNavItem(3, Icons.notifications, 'Solicitudes'), // OCULTO
                _buildNavItem(3, Icons.analytics, 'Reportes'),
                _buildNavItem(4, Icons.flag, 'Reportes Publicaciones'),
              ],
            ),
          ),
          // Footer del sidebar
          Container(
            padding: const EdgeInsets.all(AdminTheme.spacing),
            child: ElevatedButton.icon(
              // BOTÓN DE LOGOUT EN SIDEBAR - Cerrar sesión y actualizar estado
              onPressed: () => _logout(context),
              // FIN BOTÓN DE LOGOUT EN SIDEBAR
              icon: Icon(Icons.logout),
              label: Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.errorColor,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AdminTheme.accentColor : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminTheme.smallBorderRadius),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildMobileSidebar() {
    return Drawer(
      child: Container(
        color: AdminTheme.primaryColor,
        child: Column(
          children: [
            // Header del drawer
            Container(
              padding: const EdgeInsets.all(AdminTheme.largeSpacing),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AdminTheme.secondaryColor,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: AdminTheme.spacing),
                  Text(
                    'Panel Administrador',
                    style: AdminTheme.titleMedium.copyWith(color: Colors.white),
                  ),
                  Text(
                    'ServiApp',
                    style: AdminTheme.bodyMedium.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            // Opciones de navegación
            Expanded(
              child: ListView(
                children: [
                  _buildMobileNavItem(0, Icons.dashboard, 'Dashboard'),
                  _buildMobileNavItem(1, Icons.people, 'Usuarios'),
                  _buildMobileNavItem(2, Icons.build, 'Servicios'),
                  // _buildMobileNavItem(3, Icons.notifications, 'Solicitudes'), // OCULTO
                  _buildMobileNavItem(3, Icons.analytics, 'Reportes'),
                  _buildMobileNavItem(4, Icons.flag, 'Reportes Publicaciones'),
                ],
              ),
            ),
            // Footer del drawer
            Container(
              padding: const EdgeInsets.all(AdminTheme.spacing),
              child: ElevatedButton.icon(
                // BOTÓN DE LOGOUT EN DRAWER MÓVIL - Cerrar sesión y actualizar estado
                onPressed: () => _logout(context),
                // FIN BOTÓN DE LOGOUT EN DRAWER MÓVIL
                icon: Icon(Icons.logout),
                label: Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.errorColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AdminTheme.accentColor : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminTheme.smallBorderRadius),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context); // Cerrar drawer después de seleccionar
        },
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return DashboardWidget();
      case 1:
        return UsuariosWidget();
      case 2:
        return ServiciosWidget();
      // case 3: return SolicitudesWidget(); // OCULTO
      case 3:
        return ReportesWidget();
      case 4:
        return ReportesPublicacionesWidget();
      default:
        return DashboardWidget();
    }
  }

}
