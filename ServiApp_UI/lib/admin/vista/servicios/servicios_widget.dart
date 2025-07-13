import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controlador/admin_controller.dart';
import '../../styles/admin_theme.dart';

class ServiciosWidget extends StatefulWidget {
  @override
  _ServiciosWidgetState createState() => _ServiciosWidgetState();
}

class _ServiciosWidgetState extends State<ServiciosWidget> {
  final AdminController _adminController = AdminController();
  String? _filtroCategoriaServicios;
  String? _filtroEstadoServicios;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header con título y filtros
        Container(
          padding: const EdgeInsets.all(AdminTheme.spacing),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
            boxShadow: AdminTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Gestión de Servicios', style: AdminTheme.titleLarge),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: Icon(Icons.refresh, size: 18),
                    label: Text('Actualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AdminTheme.spacing),
              // Filtros responsivos
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    // Layout móvil - filtros en columna
                    return Column(
                      children: [
                        _buildFiltroCategoria(),
                        SizedBox(height: AdminTheme.smallSpacing),
                        _buildFiltroEstado(),
                      ],
                    );
                  } else {
                    // Layout desktop - filtros en fila
                    return Row(
                      children: [
                        Expanded(child: _buildFiltroCategoria()),
                        SizedBox(width: AdminTheme.spacing),
                        Expanded(child: _buildFiltroEstado()),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
        SizedBox(height: AdminTheme.spacing),
        // Lista de servicios
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AdminTheme.borderRadius),
              boxShadow: AdminTheme.cardShadow,
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminController.obtenerServicios(
                categoria: _filtroCategoriaServicios,
                estado: _filtroEstadoServicios,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(AdminTheme.spacing),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 64, color: AdminTheme.errorColor),
                          SizedBox(height: AdminTheme.spacing),
                          Text('Error al cargar servicios', style: AdminTheme.titleMedium),
                          Text(snapshot.error.toString(), style: AdminTheme.bodyMedium, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }

                final servicios = snapshot.data?.docs ?? [];

                if (servicios.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(AdminTheme.spacing),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business, size: 64, color: Colors.grey),
                          SizedBox(height: AdminTheme.spacing),
                          Text('No hay servicios disponibles', style: AdminTheme.titleMedium),
                          Text('Los servicios aparecerán aquí cuando se registren', 
                               style: AdminTheme.bodyMedium, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(AdminTheme.smallSpacing),
                  itemCount: servicios.length,
                  itemBuilder: (context, index) {
                    return _buildTarjetaServicio(servicios[index]);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltroCategoria() {
    return DropdownButtonFormField<String>(
      value: _filtroCategoriaServicios,
      decoration: InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      items: [
        DropdownMenuItem(value: null, child: Text('Todas las categorías')),
        DropdownMenuItem(value: 'Tecnología', child: Text('Tecnología')),
        DropdownMenuItem(value: 'Limpieza', child: Text('Limpieza')),
        DropdownMenuItem(value: 'Plomería', child: Text('Plomería')),
        DropdownMenuItem(value: 'Reparación', child: Text('Reparación')),
        DropdownMenuItem(value: 'Eventos', child: Text('Eventos')),
        DropdownMenuItem(value: 'Belleza', child: Text('Belleza')),
        DropdownMenuItem(value: 'Salud', child: Text('Salud')),
        DropdownMenuItem(value: 'Educación', child: Text('Educación')),
        DropdownMenuItem(value: 'Transporte', child: Text('Transporte')),
      ],
      onChanged: (value) {
        setState(() {
          _filtroCategoriaServicios = value;
        });
      },
    );
  }

  Widget _buildFiltroEstado() {
    return DropdownButtonFormField<String>(
      value: _filtroEstadoServicios,
      decoration: InputDecoration(
        labelText: 'Estado',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      items: [
        DropdownMenuItem(value: null, child: Text('Todos los estados')),
        DropdownMenuItem(value: 'activo', child: Text('Activo')),
        DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
        DropdownMenuItem(value: 'aprobado', child: Text('Aprobado')),
        DropdownMenuItem(value: 'rechazado', child: Text('Rechazado')),
        DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
      ],
      onChanged: (value) {
        setState(() {
          _filtroEstadoServicios = value;
        });
      },
    );
  }

  Widget _buildTarjetaServicio(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final estado = data['estado']?.toString() ?? 'inactivo';
    
    // Determinar color del estado
    Color estadoColor;
    switch (estado.toLowerCase()) {
      case 'activo':
      case 'aprobado':
      case 'true':
        estadoColor = AdminTheme.successColor;
        break;
      case 'pendiente':
        estadoColor = AdminTheme.warningColor;
        break;
      case 'rechazado':
      case 'inactivo':
      case 'false':
        estadoColor = AdminTheme.errorColor;
        break;
      default:
        estadoColor = AdminTheme.textMuted;
    }

    return Card(
      margin: EdgeInsets.only(bottom: AdminTheme.spacing),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AdminTheme.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data['titulo'] ?? 'Sin título',
                    style: AdminTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: AdminTheme.spacing),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    estado.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AdminTheme.smallSpacing),

            // Descripción
            if (data['descripcion'] != null)
              Text(
                data['descripcion'],
                style: AdminTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            SizedBox(height: AdminTheme.smallSpacing),

            // Información del servicio
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data['subcategoria'] != null)
                        _buildInfoChip(
                          'Categoría: ${data['subcategoria']}',
                          AdminTheme.infoColor,
                        ),
                      if (data['proveedorNombre'] != null)
                        _buildInfoChip(
                          'Proveedor: ${data['proveedorNombre']}',
                          AdminTheme.secondaryColor,
                        ),
                    ],
                  ),
                ),
                SizedBox(width: AdminTheme.spacing),
                // Precio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Precio',
                      style: AdminTheme.captionText,
                    ),
                    Text(
                      '\$${data['precio'] ?? '0'}',
                      style: AdminTheme.titleMedium.copyWith(
                        color: AdminTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AdminTheme.spacing),

            // Fecha y acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fecha: ${_formatearFecha(data['date'])}',
                  style: AdminTheme.captionText,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _mostrarDetallesServicio(doc.id, data),
                      icon: Icon(Icons.visibility, size: 20),
                      tooltip: 'Ver detalles',
                      visualDensity: VisualDensity.compact,
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleServicioAction(value, doc.id, data),
                      icon: Icon(Icons.more_vert, size: 20),
                      itemBuilder: (context) => [
                        if (estado != 'aprobado')
                          PopupMenuItem(
                            value: 'aprobar',
                            child: Row(
                              children: [
                                Icon(Icons.check, size: 18, color: AdminTheme.successColor),
                                SizedBox(width: 8),
                                Text('Aprobar'),
                              ],
                            ),
                          ),
                        if (estado != 'rechazado')
                          PopupMenuItem(
                            value: 'rechazar',
                            child: Row(
                              children: [
                                Icon(Icons.close, size: 18, color: AdminTheme.errorColor),
                                SizedBox(width: 8),
                                Text('Rechazar'),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: AdminTheme.errorColor),
                              SizedBox(width: 8),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AdminTheme.captionText.copyWith(color: color),
      ),
    );
  }

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return 'No especificada';
    try {
      final DateTime fechaDate = fecha is DateTime ? fecha : fecha.toDate();
      return '${fechaDate.day}/${fechaDate.month}/${fechaDate.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  void _mostrarDetallesServicio(String servicioId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del Servicio'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem('ID', servicioId),
              _buildDetalleItem('Título', data['titulo'] ?? 'N/A'),
              _buildDetalleItem('Descripción', data['descripcion'] ?? 'N/A'),
              _buildDetalleItem('Categoría', data['subcategoria'] ?? 'N/A'),
              _buildDetalleItem('Precio', '\$${data['precio'] ?? '0'}'),
              _buildDetalleItem('Estado', data['estado'] ?? 'N/A'),
              _buildDetalleItem('Proveedor', data['proveedorNombre'] ?? 'N/A'),
              _buildDetalleItem('Fecha', _formatearFecha(data['date'])),
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

  void _handleServicioAction(String action, String servicioId, Map<String, dynamic> data) async {
    switch (action) {
      case 'aprobar':
        final success = await _adminController.aprobarServicio(servicioId);
        _mostrarMensaje(success ? 'Servicio aprobado correctamente' : 'Error al aprobar servicio', success);
        break;
      case 'rechazar':
        _mostrarDialogoRechazo(servicioId);
        break;
      case 'eliminar':
        _confirmarEliminacion(servicioId, data['titulo'] ?? 'este servicio');
        break;
    }
  }

  void _mostrarDialogoRechazo(String servicioId) {
    final TextEditingController motivoController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rechazar Servicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ingresa el motivo del rechazo:'),
            SizedBox(height: AdminTheme.spacing),
            TextField(
              controller: motivoController,
              decoration: InputDecoration(
                labelText: 'Motivo del rechazo',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (motivoController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                final success = await _adminController.rechazarServicio(servicioId, motivoController.text.trim());
                _mostrarMensaje(success ? 'Servicio rechazado correctamente' : 'Error al rechazar servicio', success);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.errorColor),
            child: Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminacion(String servicioId, String titulo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Servicio'),
        content: Text('¿Estás seguro de que quieres eliminar "$titulo"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _adminController.eliminarServicio(servicioId);
              _mostrarMensaje(success ? 'Servicio eliminado correctamente' : 'Error al eliminar servicio', success);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.errorColor),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarMensaje(String mensaje, bool esExito) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esExito ? AdminTheme.successColor : AdminTheme.errorColor,
      ),
    );
  }
}
