import 'package:flutter/material.dart';
import 'package:serviapp/vista/Services/todo.dart';
import 'servicios_page_base.dart';
import 'package:serviapp/vista/Services/servicios_widgets.dart';

class ServiciosGeneralesPage extends StatelessWidget {
  const ServiciosGeneralesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServiciosPageBase(
      titulo: 'Servicios Generales:',
      servicios: _getServiciosGenerales(),
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

  // Lista de servicios generales disponibles
  List<ServiceModel> _getServiciosGenerales() {
    return [
      ServiceModel(
        title: 'Albañileria',
        imageUrl: 'https://www.cementosinka.com.pe/wp-content/uploads/2023/09/Todo-sobre-la-alba_ileria-confinada.jpg',
      ),
      ServiceModel(
        title: 'Plomeria',
        imageUrl: 'https://todoferreteria.com.mx/wp-content/uploads/2022/12/plomero-entrada-01.png',
      ),
      ServiceModel(
        title: 'Electricidad',
        imageUrl: 'https://sp-ao.shortpixel.ai/client/to_auto,q_glossy,ret_img,w_700,h_438/https://www.kwelectricistas.pe/wp-content/uploads/2019/04/Empresa-De-Instalaciones-Electricas-Domiciliarias-Residenciales-e-industriales-en-lima-peru.png',
      ),
      ServiceModel(
        title: 'Carpinteria',
        imageUrl: 'https://www.mndelgolfo.com/blog/wp-content/uploads/2018/03/Todo-lo-que-necesitas-saber-para-armar-tu-taller-de-carpinteri%CC%81a1.jpg',
      ),
      ServiceModel(
        title: 'Pintura y acabados',
        imageUrl: 'https://lirp.cdn-website.com/c9fb4062/dms3rep/multi/opt/02-640w.jpg',
      ),
      ServiceModel(
        title: 'Jardineria y paisajismo',
        imageUrl: 'https://paisajismodigital.com/blog/wp-content/uploads/2020/11/beneficios-de-la-jardineria.jpg',
      ),
    ];
  }
}