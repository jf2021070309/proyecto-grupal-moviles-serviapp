import 'package:flutter/material.dart';
import 'package:serviapp/vista/Services/todo.dart';
import 'servicios_page_base.dart';
import 'package:serviapp/vista/Services/servicios_widgets.dart';

class LimpiezaMantenimientoPage extends StatelessWidget {
  const LimpiezaMantenimientoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServiciosPageBase(
      titulo: 'Limpieza y Mantenimiento:',
      servicios: _getLimpiezaServices(),
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

  // Lista de servicios disponibles para limpieza y mantenimiento
  List<ServiceModel> _getLimpiezaServices() {
    return [
      ServiceModel(
        title: 'Limpieza del hogar y oficinas',
        imageUrl: 'https://www.emiser.es/wp-content/uploads/2023/09/limpieza-de-oficinas.jpg',
      ),
      ServiceModel(
        title: 'Lavanderia y el planchado',
        imageUrl: 'https://bizplanner.ai/images/blog/business-plan-for-a-lanrodmat/business-plan-for-a-lanrodmat-1.jpg',
      ),
      ServiceModel(
        title: 'Desinfeccion',
        imageUrl: 'https://indualimentario.com/wp-content/uploads/2023/05/higiene158985.jpg',
      ),
      ServiceModel(
        title: 'Encerado y pulido de muebles',
        imageUrl: 'https://www.oficinasmontiel.com/blog/wp-content/uploads/2022/01/Portada-2-scaled.jpg',
      ),
    ];
  }
}