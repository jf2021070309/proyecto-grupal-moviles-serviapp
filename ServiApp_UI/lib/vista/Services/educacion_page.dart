import 'package:flutter/material.dart';
import 'package:serviapp/vista/Services/todo.dart';
import 'servicios_page_base.dart';
import 'package:serviapp/vista/Services/servicios_widgets.dart';

class EducacionCapacitacionPage extends StatelessWidget {
  const EducacionCapacitacionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServiciosPageBase(
      titulo: 'Educación y Capacitación:',
      servicios: _getEducacionServices(),
      onServiceTap: (subcategoria) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TodoPage(subcategoria: subcategoria),
          ),
        );
      },
    );
  }

  // Lista de servicios disponibles para educación y capacitación
  List<ServiceModel> _getEducacionServices() {
    return [
      ServiceModel(
        title: 'Clases Particulares',
        imageUrl: 'https://i.ibb.co/pBSyFCMM/1.jpg',
      ),
      ServiceModel(
        title: 'Tutoriales en linea',
        imageUrl: 'https://i.ibb.co/d4wmRz59/2.jpg',
      ),
      ServiceModel(
        title: 'Capacitación en software',
        imageUrl: 'https://i.ibb.co/GfZSKrcb/3.jpg',
      ),
      ServiceModel(
        title: 'Programas académicos',
        imageUrl: 'https://i.ibb.co/dwWKd2Rj/4.jpg',
      ),
      ServiceModel(
        title: 'Cursos y Certificaciones',
        imageUrl: 'https://i.ibb.co/Y4dQ6MBd/5.webp',
      ),
      ServiceModel(
        title: 'Vacaciones útiles',
        imageUrl: 'https://i.ibb.co/spsy8hS0/5.jpg',
      ),
    ];
  }
}