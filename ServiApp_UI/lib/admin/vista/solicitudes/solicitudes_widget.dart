import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controlador/admin_controller.dart';
import '../../styles/admin_theme.dart';

class SolicitudesWidget extends StatefulWidget {
  @override
  _SolicitudesWidgetState createState() => _SolicitudesWidgetState();
}

class _SolicitudesWidgetState extends State<SolicitudesWidget> {
  final AdminController _adminController = AdminController();
  String? _filtroEstado;

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
                  Text('Gestión de Solicitudes', style: AdminTheme.titleLarge),
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
                        labelText: 'Filtrar por estado',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AdminTheme.smallBorderRadius),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        DropdownMenuItem(value: '', child: Text('Todos los estados')),
                        DropdownMenuItem(value: 'pendiente', child: Text('Pendientes')),
                        DropdownMenuItem(value: 'aceptado', child: Text('Aceptadas')),
                        DropdownMenuItem(value: 'rechazado', child: Text('Rechazadas')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filtroEstado = value;
                        });
                      },
                      value: _filtroEstado,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Lista de solicitudes
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _adminController.obtenerNotificaciones(estado: _filtroEstado?.isEmpty == true ? null : _filtroEstado),
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
                      Text('Error al cargar solicitudes', style: AdminTheme.titleMedium),
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
                      Icon(Icons.notifications_none, size: 48, color: AdminTheme.textMuted),
                      SizedBox(height: AdminTheme.spacing),
                      Text('No hay solicitudes', style: AdminTheme.titleMedium),
                      Text('No se encontraron solicitudes con los filtros aplicados', style: AdminTheme.bodyMedium),
                    ],
                  ),
                );
              }
              
              final solicitudes = snapshot.data!.docs;
              
              return ListView.builder(
                padding: EdgeInsets.all(AdminTheme.spacing),
                itemCount: solicitudes.length,
                itemBuilder: (context, index) {
                  final solicitud = solicitudes[index];
                  final data = solicitud.data() as Map<String, dynamic>;
                  
                  return _buildSolicitudCard(solicitud.id, data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSolicitudCard(String solicitudId, Map<String, dynamic> data) {
    final estado = data['estado'] ?? 'pendiente';
    final clienteNombre = data['clienteNombre'] ?? 'Cliente no especificado';
    final proveedorNombre = data['proveedorNombre'] ?? 'Proveedor no especificado';
    final subcategoria = data['subcategoria'] ?? 'Sin categoría';
    final servicioTitulo = data['servicioTitulo'] ?? 'Servicio no especificado';
    final timestamp = data['timestamp'];
    
    // Color según el estado
    Color estadoColor;
    IconData estadoIcon;
    switch (estado.toLowerCase()) {
      case 'aceptado':
        estadoColor = AdminTheme.successColor;
        estadoIcon = Icons.check_circle;
        break;
      case 'rechazado':
        estadoColor = AdminTheme.errorColor;
        estadoIcon = Icons.cancel;
        break;
      case 'pendiente':
      default:
        estadoColor = AdminTheme.warningColor;
        estadoIcon = Icons.access_time;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: AdminTheme.spacing),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
        boxShadow: AdminTheme.softShadow,
        border: Border(left: BorderSide(color: estadoColor, width: 4)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AdminTheme.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(estadoIcon, color: estadoColor, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Solicitud #${solicitudId.substring(0, 8)}',
                        style: AdminTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: estadoColor),
                  ),
                  child: Text(
                    estado.toUpperCase(),
                    style: TextStyle(
                      color: estadoColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AdminTheme.spacing),
            
            // Información del servicio
            Container(
              padding: EdgeInsets.all(AdminTheme.smallSpacing),
              decoration: BoxDecoration(
                color: AdminTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AdminTheme.smallBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Servicio Solicitado:', style: AdminTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('• $servicioTitulo', style: AdminTheme.bodyMedium),
                  Text('• Categoría: $subcategoria', style: AdminTheme.captionText),
                ],
              ),
            ),
            SizedBox(height: AdminTheme.spacing),
            
            // Información de las partes
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 16, color: AdminTheme.successColor),
                          SizedBox(width: 8),
                          Text('Cliente:', style: AdminTheme.captionText),
                        ],
                      ),
                      Text(clienteNombre, style: AdminTheme.bodyMedium),
                    ],
                  ),
                ),
                SizedBox(width: AdminTheme.spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.business, size: 16, color: AdminTheme.infoColor),
                          SizedBox(width: 8),
                          Text('Proveedor:', style: AdminTheme.captionText),
                        ],
                      ),
                      Text(proveedorNombre, style: AdminTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AdminTheme.spacing),
            
            // Información adicional
            if (data['mensaje'] != null) ...[
              Text('Mensaje:', style: AdminTheme.captionText),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AdminTheme.smallSpacing),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(AdminTheme.smallBorderRadius),
                ),
                child: Text(
                  data['mensaje'],
                  style: AdminTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: AdminTheme.spacing),
            ],
            
            // Footer con fecha y acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fecha: ${_formatearFecha(timestamp)}',
                  style: AdminTheme.captionText,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _mostrarDetallesSolicitud(solicitudId, data),
                      icon: Icon(Icons.visibility, size: 20),
                      tooltip: 'Ver detalles',
                      visualDensity: VisualDensity.compact,
                    ),
                    if (estado == 'pendiente') ...[
                      IconButton(
                        onPressed: () => _confirmarAccion(solicitudId, 'aceptar', data),
                        icon: Icon(Icons.check, size: 20, color: AdminTheme.successColor),
                        tooltip: 'Aceptar',
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        onPressed: () => _confirmarAccion(solicitudId, 'rechazar', data),
                        icon: Icon(Icons.close, size: 20, color: AdminTheme.errorColor),
                        tooltip: 'Rechazar',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(dynamic timestamp) {
    if (timestamp == null) return 'No especificada';
    try {
      final DateTime fecha = timestamp is DateTime ? timestamp : timestamp.toDate();
      return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  void _mostrarDetallesSolicitud(String solicitudId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de la Solicitud'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem('ID', solicitudId),
              _buildDetalleItem('Estado', data['estado'] ?? 'N/A'),
              _buildDetalleItem('Cliente', data['clienteNombre'] ?? 'N/A'),
              _buildDetalleItem('Cliente ID', data['clienteId'] ?? 'N/A'),
              _buildDetalleItem('Proveedor', data['proveedorNombre'] ?? 'N/A'),
              _buildDetalleItem('Proveedor ID', data['proveedorId'] ?? 'N/A'),
              _buildDetalleItem('Servicio', data['servicioTitulo'] ?? 'N/A'),
              _buildDetalleItem('Servicio ID', data['idServicio'] ?? 'N/A'),
              _buildDetalleItem('Categoría', data['subcategoria'] ?? 'N/A'),
              _buildDetalleItem('Fecha', _formatearFecha(data['timestamp'])),
              if (data['mensaje'] != null) ...[
                Divider(),
                Text('Mensaje:', style: AdminTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AdminTheme.smallSpacing),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(AdminTheme.smallBorderRadius),
                  ),
                  child: Text(data['mensaje'], style: AdminTheme.bodyMedium),
                ),
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

  void _confirmarAccion(String solicitudId, String accion, Map<String, dynamic> data) {
    final esAceptar = accion == 'aceptar';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(esAceptar ? 'Aceptar Solicitud' : 'Rechazar Solicitud'),
        content: Text(
          esAceptar 
            ? '¿Estás seguro de que quieres aceptar esta solicitud?'
            : '¿Estás seguro de que quieres rechazar esta solicitud?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _procesarAccion(solicitudId, accion);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: esAceptar ? AdminTheme.successColor : AdminTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: Text(esAceptar ? 'Aceptar' : 'Rechazar'),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarAccion(String solicitudId, String accion) async {
    try {
      // Aquí podrías implementar la lógica para cambiar el estado de la solicitud
      // Por ahora, solo mostramos un mensaje
      final nuevoEstado = accion == 'aceptar' ? 'aceptado' : 'rechazado';
      
      await FirebaseFirestore.instance
          .collection('notificaciones')
          .doc(solicitudId)
          .update({'estado': nuevoEstado});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Solicitud ${accion == 'aceptar' ? 'aceptada' : 'rechazada'} correctamente',
          ),
          backgroundColor: accion == 'aceptar' ? AdminTheme.successColor : AdminTheme.errorColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar la solicitud: $e'),
          backgroundColor: AdminTheme.errorColor,
        ),
      );
    }
  }
}
