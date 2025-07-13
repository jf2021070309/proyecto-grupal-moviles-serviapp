import 'package:flutter/material.dart';
import 'package:serviapp/vista/Services/todo.dart';
import 'servicios_page_base.dart';
import 'package:serviapp/vista/Services/servicios_widgets.dart';

class EventosEntretenimientoPage extends StatelessWidget {
  const EventosEntretenimientoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServiciosPageBase(
      titulo: 'Eventos y Entretenimiento:',
      servicios: _getEventosServices(),
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

  // Lista de servicios disponibles
  List<ServiceModel> _getEventosServices() {
    return [
      ServiceModel(
        title: 'Fotografía y filmación',
        imageUrl: 'https://i.imgur.com/5Nra9qH.png',
      ),
      ServiceModel(
        title: 'Organización de eventos',
        imageUrl: 'https://www.educativo.net/xframework/files/entities/articulos/616/img.jpg',
      ),
      ServiceModel(
        title: 'Catering y banquetes',
        imageUrl: 'https://287524.fs1.hubspotusercontent-na1.net/hubfs/287524/Imported_Blog_Media/banquetes-y-catering-conceptos-gastronomicos-una-historia-4-compressor-Dec-17-2022-07-46-40-0657-PM.jpg',
      ),
      ServiceModel(
        title: 'Música en vivo y DJ',
        imageUrl: 'https://elisglobalparty.wordpress.com/wp-content/uploads/2014/07/dj.jpeg',
      ),
    ];
  }
}