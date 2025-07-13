import 'package:flutter/material.dart';
import 'package:serviapp/vista/Services/todo.dart';
import 'servicios_page_base.dart';
import 'package:serviapp/vista/Services/servicios_widgets.dart';

class VehiculosTransportePage extends StatelessWidget {
  const VehiculosTransportePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServiciosPageBase(
      titulo: 'Mecánica automotriz:',
      servicios: _getVehiculosServices(),
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

  // Lista de servicios de vehículos y transporte disponibles
  List<ServiceModel> _getVehiculosServices() {
    return [
      ServiceModel(
        title: 'Mecánica automotriz',
        imageUrl: 'https://www.senati.edu.pe/sites/default/files/2017/carrera/09/mecanica-automotriz-senati1800-x-1190_0.jpg',
      ),
      ServiceModel(
        title: 'Lavado y detallado de autos',
        imageUrl: 'https://detailerlab.com/wp-content/uploads/2020/02/detailing-vs-autolavado.jpg',
      ),
      ServiceModel(
        title: 'Cambio de llantas y baterías',
        imageUrl: 'https://paautos.gt/inicio/wp-content/uploads/2022/09/Aparicion-de-grietas-a-los-laterales-de-la-llanta.jpg',
      ),
      ServiceModel(
        title: 'Servicio de grúa',
        imageUrl: 'https://gruasatelital.com/wp-content/uploads/2022/02/servicio1.jpg',
      ),
      ServiceModel(
        title: 'Transporte y mudanzas',
        imageUrl: 'https://gilmovers.com.pe/wp-content/uploads/transporte-y-mudanza-internacional.jpg',
      ),
      ServiceModel(
        title: 'Lubricentro',
        imageUrl: 'https://i0.wp.com/www.autodata.pe/wp-content/uploads/2016/02/cambio-de-aceite-AUTODATA-S.A.C..jpg?w=1260&ssl=1',
      ),
    ];
  }
}