import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalificacionModal extends StatefulWidget {
  final String notificacionId;
  final String proveedorId;
  final String clienteId;
  final String nombreProveedor;
  final String tipoServicio;

  const CalificacionModal({
    Key? key,
    required this.notificacionId,
    required this.proveedorId,
    required this.clienteId,
    required this.nombreProveedor,
    required this.tipoServicio,
  }) : super(key: key);

  @override
  _CalificacionModalState createState() => _CalificacionModalState();
}

class _CalificacionModalState extends State<CalificacionModal> {
  int puntuacion = 0;
  String comentarioPersonal = '';
  List<String> comentariosSeleccionados = [];
  bool mostrandoComentarios = false;
  bool enviando = false;
  final TextEditingController _comentarioController = TextEditingController();

  // Comentarios predefinidos según puntuación
  Map<int, Map<String, dynamic>> comentariosPorPuntuacion = {
    5: {
      'titulo': 'Excelente',
      'comentarios': ['Servicio excelente', 'Muy profesional', 'Recomendado']
    },
    4: {
      'titulo': 'Muy bueno',
      'comentarios': ['Buen servicio', 'Puntual', 'Limpio y ordenado']
    },
    3: {
      'titulo': 'Regular',
      'comentarios': ['Servicio aceptable', 'Puede mejorar']
    },
    2: {
      'titulo': 'Malo',
      'comentarios': ['No cumplió expectativas', 'Llegó tarde']
    },
    1: {
      'titulo': 'Muy malo',
      'comentarios': ['Muy mal servicio', 'No recomendado']
    },
  };

  void seleccionarPuntuacion(int nuevaPuntuacion) {
    setState(() {
      puntuacion = nuevaPuntuacion;
      mostrandoComentarios = true;
    });
  }

  void toggleComentario(String comentario) {
    setState(() {
      if (comentariosSeleccionados.contains(comentario)) {
        comentariosSeleccionados.remove(comentario);
      } else {
        comentariosSeleccionados.add(comentario);
      }
    });
  }

  Future<void> enviarCalificacion() async {
    if (puntuacion == 0) return;

    setState(() {
      enviando = true;
    });

    try {
      // Crear comentario final combinando seleccionados y personal
      String comentarioFinal = '';
      if (comentariosSeleccionados.isNotEmpty) {
        comentarioFinal = comentariosSeleccionados.join(', ');
      }
      if (_comentarioController.text.isNotEmpty) {
        if (comentarioFinal.isNotEmpty) {
          comentarioFinal += '. ${_comentarioController.text}';
        } else {
          comentarioFinal = _comentarioController.text;
        }
      }

      // Guardar en Firestore
      await FirebaseFirestore.instance.collection('calificaciones').add({
        'notificacionId': widget.notificacionId,
        'clienteId': widget.clienteId,
        'proveedorId': widget.proveedorId,
        'puntuacion': puntuacion,
        'comentario': comentarioFinal,
        'tipoServicio': widget.tipoServicio,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Cerrar modal y mostrar mensaje de éxito
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calificación enviada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar calificación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        enviando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header con botón cerrar
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mostrandoComentarios
                      ? comentariosPorPuntuacion[puntuacion]!['titulo']
                      : 'Califica el servicio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          Divider(height: 1),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: !mostrandoComentarios
                  ? _buildSeleccionEstrellas()
                  : _buildSeleccionComentarios(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeleccionEstrellas() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Califica a ${widget.nombreProveedor}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            int estrella = index + 1;
            return GestureDetector(
              onTap: () => seleccionarPuntuacion(estrella),
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.star,
                  size: 45,
                  color: estrella <= puntuacion ? Colors.amber : Colors.grey[300],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSeleccionComentarios() {
    final comentarios = comentariosPorPuntuacion[puntuacion]!['comentarios'] as List<String>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mostrar estrellas seleccionadas (solo visual)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Icon(
              Icons.star,
              size: 30,
              color: index < puntuacion ? Colors.amber : Colors.grey[300],
            );
          }),
        ),
        SizedBox(height: 20),

        // Comentarios predefinidos
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: comentarios.map((comentario) {
            bool seleccionado = comentariosSeleccionados.contains(comentario);
            return GestureDetector(
              onTap: () => toggleComentario(comentario),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: seleccionado ? Colors.blue : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  comentario,
                  style: TextStyle(
                    color: seleccionado ? Colors.white : Colors.black87,
                    fontWeight: seleccionado ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        SizedBox(height: 20),

        // Campo de comentario personal
        Text(
          'Comentarios',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _comentarioController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Agrega un comentario personal (opcional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.all(12),
          ),
        ),

        Spacer(),

        // Botón enviar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: enviando ? null : enviarCalificacion,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: enviando
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Enviar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }
}