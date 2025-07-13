// lib/vista/Components/calificacion_widget.dart
import 'package:flutter/material.dart';
import 'package:serviapp/controlador/servicio_controller.dart';
import 'package:serviapp/modelo/global_user.dart';

class CalificacionWidget extends StatefulWidget {
  final String servicioId;
  final ServicioController servicioController;

  const CalificacionWidget({
    super.key,
    required this.servicioId,
    required this.servicioController,
  });

  @override
  State<CalificacionWidget> createState() => _CalificacionWidgetState();
}

class _CalificacionWidgetState extends State<CalificacionWidget> {
  int _puntuacion = 0;
  final _comentarioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Califica este servicio:'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _puntuacion ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 30,
              ),
              onPressed: () => setState(() => _puntuacion = index + 1),
            );
          }),
        ),
        TextField(
          controller: _comentarioController,
          decoration: const InputDecoration(
            labelText: 'Comentario (opcional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        ElevatedButton(
          onPressed: _puntuacion > 0 ? _enviarCalificacion : null,
          child: const Text('Enviar Calificación'),
        ),
      ],
    );
  }

  Future<void> _enviarCalificacion() async {
    try {
      await widget.servicioController.calificarServicio(
        servicioId: widget.servicioId,
        puntuacion: _puntuacion,
        usuarioId: GlobalUser.uid!,
        nombreUsuario: 'Nombre del Usuario', // Reemplaza con dato real
        comentario: _comentarioController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gracias por tu calificación!')),
      );
      setState(() {
        _puntuacion = 0;
        _comentarioController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}