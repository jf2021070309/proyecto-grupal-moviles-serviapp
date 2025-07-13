import 'package:flutter/material.dart';
import 'package:serviapp/vista/Services/servicios_page_base.dart';
import 'package:serviapp/vista/Services/servicios_widgets.dart';
import 'package:serviapp/vista/Services/todo.dart';

class TecnologiayElectronicaPage extends StatelessWidget {
  const TecnologiayElectronicaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServiciosPageBase(
      titulo: 'Tecnologia y Electrónica',
      servicios: _getTecnologiaServices(),
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

  List<ServiceModel> _getTecnologiaServices() {
    return [
      ServiceModel(
        title: 'Reparación de computadoras y laptops',
        imageUrl: 'https://i.imgur.com/7OnU8Dw.jpeg',
      ),
      ServiceModel(
        title: 'Mantenimiento y Reparación de celulares',
        imageUrl: 'https://i.imgur.com/P3JiB71.jpeg',
      ),
      ServiceModel(
        title: 'Instalación de cámaras de seguridad',
        imageUrl: 'https://i.imgur.com/aGvzk21.jpeg',
      ),
      ServiceModel(
        title: 'Configuración de redes',
        imageUrl: 'https://i.imgur.com/vhBNvbo.jpeg',
      ),
      ServiceModel(
        title: 'Recuperación de datos',
        imageUrl: 'https://i.imgur.com/KRenwnx.png',
      ),
      ServiceModel(
        title: 'Reparacion de televisores y electrodomesticos',
        imageUrl: 'https://i.imgur.com/tUMptvo.jpeg',
      ),
    ];
  }
}