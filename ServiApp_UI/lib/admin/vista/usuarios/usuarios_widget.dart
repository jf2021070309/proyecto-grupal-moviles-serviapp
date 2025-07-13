import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controlador/admin_controller.dart';
import '../../styles/admin_theme.dart';

class UsuariosWidget extends StatefulWidget {
  @override
  _UsuariosWidgetState createState() => _UsuariosWidgetState();
}

class _UsuariosWidgetState extends State<UsuariosWidget> {
  final AdminController _adminController = AdminController();
  String? _filtroRolUsuarios;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header con filtros
        Container(
          padding: const EdgeInsets.all(AdminTheme.spacing),
          decoration: BoxDecoration(
            color: AdminTheme.surfaceColor,
            boxShadow: AdminTheme.softShadow,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Gestión de Usuarios', style: AdminTheme.titleLarge),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {}); // Refrescar vista
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Actualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.secondaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AdminTheme.spacing),
              // Filtros
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Filtrar por rol',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AdminTheme.smallBorderRadius),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        DropdownMenuItem(value: '', child: Text('Todos los roles')),
                        DropdownMenuItem(value: 'cliente', child: Text('Clientes')),
                        DropdownMenuItem(value: 'proveedor', child: Text('Proveedores')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filtroRolUsuarios = value;
                        });
                      },
                      value: _filtroRolUsuarios,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Lista de usuarios
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _adminController.obtenerUsuarios(filtroRol: _filtroRolUsuarios?.isEmpty == true ? null : _filtroRolUsuarios),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 48, color: AdminTheme.errorColor),
                      SizedBox(height: AdminTheme.spacing),
                      Text('Error al cargar usuarios', style: AdminTheme.titleMedium),
                      Text('${snapshot.error}', style: AdminTheme.bodyMedium),
                    ],
                  ),
                );
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 48, color: AdminTheme.textMuted),
                      SizedBox(height: AdminTheme.spacing),
                      Text('No hay usuarios', style: AdminTheme.titleMedium),
                      Text('No se encontraron usuarios con los filtros aplicados', style: AdminTheme.bodyMedium),
                    ],
                  ),
                );
              }
              
              final usuarios = snapshot.data!.docs;
              
              return ListView.builder(
                padding: EdgeInsets.all(AdminTheme.spacing),
                itemCount: usuarios.length,
                itemBuilder: (context, index) {
                  final usuario = usuarios[index];
                  final data = usuario.data() as Map<String, dynamic>;
                  
                  return _buildUsuarioCard(usuario.id, data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUsuarioCard(String userId, Map<String, dynamic> data) {
    final nombre = data['nombre'] ?? 'Sin nombre';
    final email = data['email'] ?? 'Sin email';
    final rol = data['rol'] ?? 'Sin rol';
    final celular = data['celular'] ?? 'Sin celular';
    final dni = data['dni'] ?? 'Sin DNI';
    final isOnline = data['isOnline'] ?? false;
    final bloqueado = data['bloqueado'] ?? false;
    
    // Color según el rol
    Color roleColor;
    IconData roleIcon;
    switch (rol) {
      case 'proveedor':
        roleColor = AdminTheme.infoColor;
        roleIcon = Icons.business;
        break;
      case 'cliente':
        roleColor = AdminTheme.successColor;
        roleIcon = Icons.person;
        break;
      default:
        roleColor = AdminTheme.textMuted;
        roleIcon = Icons.help_outline;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: AdminTheme.spacing),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
        boxShadow: AdminTheme.softShadow,
        border: bloqueado ? Border.all(color: AdminTheme.errorColor, width: 2) : null,
      ),
      child: Column(
        children: [
          ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: roleColor.withOpacity(0.2),
                  child: Icon(roleIcon, color: roleColor),
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AdminTheme.successColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    nombre,
                    style: AdminTheme.titleMedium.copyWith(
                      color: bloqueado ? AdminTheme.errorColor : AdminTheme.textPrimary,
                      decoration: bloqueado ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (bloqueado)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AdminTheme.errorColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'BLOQUEADO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rol.toUpperCase(),
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    if (isOnline)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AdminTheme.successColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ONLINE',
                          style: TextStyle(
                            color: AdminTheme.successColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text('Email: $email', style: AdminTheme.bodyMedium),
                Text('Celular: $celular', style: AdminTheme.bodyMedium),
                Text('DNI: $dni', style: AdminTheme.bodyMedium),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleUsuarioAction(value, userId, data),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'ver',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 18),
                      SizedBox(width: 8),
                      Text('Ver detalles'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: bloqueado ? 'desbloquear' : 'bloquear',
                  child: Row(
                    children: [
                      Icon(
                        bloqueado ? Icons.lock_open : Icons.block,
                        size: 18,
                        color: bloqueado ? AdminTheme.successColor : AdminTheme.errorColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        bloqueado ? 'Desbloquear' : 'Bloquear',
                        style: TextStyle(
                          color: bloqueado ? AdminTheme.successColor : AdminTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Información adicional para proveedores
          if (rol == 'proveedor' && (data['tipoTrabajo'] != null || data['experiencia'] != null))
            Container(
              padding: EdgeInsets.all(AdminTheme.spacing),
              margin: EdgeInsets.all(AdminTheme.spacing),
              decoration: BoxDecoration(
                color: AdminTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AdminTheme.smallBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Información del Proveedor:', style: AdminTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  if (data['tipoTrabajo'] != null)
                    Text('Tipo de trabajo: ${_formatearLista(data['tipoTrabajo'])}', style: AdminTheme.captionText),
                  if (data['experiencia'] != null)
                    Text('Experiencia: ${_formatearLista(data['experiencia'])}', style: AdminTheme.captionText),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatearLista(dynamic lista) {
    if (lista is List) {
      return lista.join(', ');
    } else if (lista is String) {
      return lista;
    }
    return 'No especificado';
  }

  void _handleUsuarioAction(String action, String userId, Map<String, dynamic> userData) async {
    switch (action) {
      case 'ver':
        _mostrarDetallesUsuario(userId, userData);
        break;
      case 'bloquear':
        _confirmarBloqueoUsuario(userId, userData['nombre'] ?? 'Usuario', true);
        break;
      case 'desbloquear':
        _confirmarBloqueoUsuario(userId, userData['nombre'] ?? 'Usuario', false);
        break;
    }
  }

  void _mostrarDetallesUsuario(String userId, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del Usuario'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem('ID', userId),
              _buildDetalleItem('Nombre', userData['nombre'] ?? 'N/A'),
              _buildDetalleItem('Email', userData['email'] ?? 'N/A'),
              _buildDetalleItem('Rol', userData['rol'] ?? 'N/A'),
              _buildDetalleItem('DNI', userData['dni'] ?? 'N/A'),
              _buildDetalleItem('Celular', userData['celular'] ?? 'N/A'),
              _buildDetalleItem('Estado', userData['isOnline'] == true ? 'Online' : 'Offline'),
              _buildDetalleItem('Bloqueado', userData['bloqueado'] == true ? 'Sí' : 'No'),
              if (userData['rol'] == 'proveedor') ...[
                Divider(),
                Text('Información del Proveedor:', style: AdminTheme.titleMedium),
                _buildDetalleItem('Tipo de trabajo', _formatearLista(userData['tipoTrabajo'])),
                _buildDetalleItem('Experiencia', _formatearLista(userData['experiencia'])),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AdminTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, style: AdminTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _confirmarBloqueoUsuario(String userId, String nombreUsuario, bool bloquear) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bloquear ? 'Bloquear Usuario' : 'Desbloquear Usuario'),
        content: Text(
          bloquear 
            ? '¿Estás seguro de que quieres bloquear a "$nombreUsuario"? El usuario no podrá acceder a la aplicación.'
            : '¿Estás seguro de que quieres desbloquear a "$nombreUsuario"? El usuario podrá acceder nuevamente a la aplicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final success = await _adminController.cambiarEstadoUsuario(userId, bloquear);
              
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success 
                      ? (bloquear ? 'Usuario bloqueado correctamente' : 'Usuario desbloqueado correctamente')
                      : 'Error al ${bloquear ? 'bloquear' : 'desbloquear'} usuario',
                  ),
                  backgroundColor: success ? AdminTheme.successColor : AdminTheme.errorColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: bloquear ? AdminTheme.errorColor : AdminTheme.successColor,
              foregroundColor: Colors.white,
            ),
            child: Text(bloquear ? 'Bloquear' : 'Desbloquear'),
          ),
        ],
      ),
    );
  }
}
