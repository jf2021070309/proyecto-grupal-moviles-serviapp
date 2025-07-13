import 'package:flutter/material.dart';
import 'package:serviapp/modelo/usuario_model.dart';
import 'package:serviapp/controlador/usuario_controller.dart';
import 'package:serviapp/styles/usuario/editar_user_perfil_styles.dart';

class EditarPerfilUsuarioPage extends StatefulWidget {
  final Usuario usuario;

  const EditarPerfilUsuarioPage({Key? key, required this.usuario})
    : super(key: key);

  @override
  _EditarPerfilUsuarioPageState createState() =>
      _EditarPerfilUsuarioPageState();
}

class _EditarPerfilUsuarioPageState extends State<EditarPerfilUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final UsuarioController _usuarioController = UsuarioController();

  late TextEditingController _nombreController;
  late TextEditingController _dniController;
  late TextEditingController _celularController;
  late TextEditingController _rolController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario.nombre);
    _dniController = TextEditingController(text: widget.usuario.dni);
    _celularController = TextEditingController(text: widget.usuario.celular);
    _rolController = TextEditingController(text: widget.usuario.rol);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _dniController.dispose();
    _celularController.dispose();
    _rolController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      Usuario usuarioActualizado = Usuario(
        id: widget.usuario.id,
        nombre: _nombreController.text,
        dni: _dniController.text,
        celular: _celularController.text,
        rol: _rolController.text,
        tipoTrabajo: [], // eliminado el tipo de trabajo
        email: widget.usuario.email,
        password: widget.usuario.password,
      );

      try {
        await _usuarioController.updateUser(usuarioActualizado);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado correctamente')),
          );
          Navigator.pop(context, usuarioActualizado);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Estilos.backgroundColor,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        centerTitle: true,
        backgroundColor: Estilos.appBarColor,
        foregroundColor: Estilos.appBarTextColor,
      ),
      body: Padding(
        padding: Estilos.pagePadding,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nombreController,
                decoration: Estilos.inputDecoration.copyWith(
                  labelText: 'Nombre',
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Ingrese nombre'
                            : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _dniController,
                decoration: Estilos.inputDecoration.copyWith(labelText: 'DNI'),
                validator:
                    (value) =>
                        (value == null || value.isEmpty) ? 'Ingrese DNI' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _celularController,
                decoration: Estilos.inputDecoration.copyWith(
                  labelText: 'Celular',
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _rolController,
                decoration: Estilos.inputDecoration.copyWith(labelText: 'Rol'),
                readOnly: true,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: Estilos.elevatedButtonStyle,
                onPressed: _guardarCambios,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
