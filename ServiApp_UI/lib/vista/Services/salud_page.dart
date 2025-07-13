import 'package:flutter/material.dart';
import 'package:serviapp/vista/Services/todo.dart';
import 'servicios_page_base.dart';
import 'package:serviapp/vista/Services/servicios_widgets.dart';

class SaludBienestarPage extends StatelessWidget {
  const SaludBienestarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServiciosPageBase(
      titulo: 'Salud y Bienestar:',
      servicios: _getSaludServices(),
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

  // Lista de servicios disponibles para salud y bienestar
  List<ServiceModel> _getSaludServices() {
    return [
      ServiceModel(
        title: 'Consulta médica a domicilio',
        imageUrl: 'https://i.ibb.co/6ct0vHTg/9.jpg',
      ),
      ServiceModel(
        title: 'Enfermería y cuidados a domicilio',
        imageUrl: 'https://i.ibb.co/Q36rJ2gC/10.jpg',
      ),
      ServiceModel(
        title: 'Terapia física y rehabilitación',
        imageUrl: 'https://i.ibb.co/HD8yyTJH/11.jpg',
      ),
      ServiceModel(
        title: 'Masajes y relajación',
        imageUrl: 'https://i.ibb.co/LhxnF3qN/14.jpg',
      ),
      ServiceModel(
        title: 'Entrenador personal',
        imageUrl: 'https://i.ibb.co/GQYYZmrZ/13.jpg',
      ),
    ];
  }
}