import 'package:flutter/material.dart';
import 'package:serviapp/vista/Services/todo.dart';
import 'servicios_page_base.dart';
import 'package:serviapp/vista/Services/servicios_widgets.dart';

class BellezaEsteticaPage extends StatelessWidget {
  const BellezaEsteticaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServiciosPageBase(
      titulo: 'Belleza y Estética:',
      servicios: _getBellezaServices(),
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

  // Lista de servicios disponibles para belleza y estética
  List<ServiceModel> _getBellezaServices() {
    return [
      ServiceModel(
        title: 'Peluquería y barbería a domicilio',
        imageUrl: 'https://i.ibb.co/Q36CYSHt/6.jpg',
      ),
      ServiceModel(
        title: 'Manicure y pedicure',
        imageUrl: 'https://i.ibb.co/jZhfZ3FN/7.jpg',
      ),
      ServiceModel(
        title: 'Maquillaje y asesoría de imagen',
        imageUrl: 'https://i.ibb.co/MKLykQ4/8.jpg',
      ),
    ];
  }
}