import 'package:flutter/material.dart';
import 'package:serviapp/styles/Services/servicios_styles.dart';
import 'package:serviapp/vista/Services/servicios_widgets.dart';

class ServiciosPageBase extends StatelessWidget {
  final String titulo;
  final List<ServiceModel> servicios;
  final Function(String)? onServiceTap;

  const ServiciosPageBase({
    Key? key,
    required this.titulo,
    required this.servicios,
    this.onServiceTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiciosStyles.backgroundColor,
      
      appBar: const ServiciosHeader(),

      body: Padding(
        padding: EdgeInsets.all(ServiciosStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                titulo,
                style: ServiciosStyles.sectionTitleStyle,
              ),
            ),
            SizedBox(height: ServiciosStyles.mediumSpacing),

            Expanded(
              child: ServiceGrid(
                services: servicios,
                onItemTap: (service) => onServiceTap?.call(service.title),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const ServiciosFooter(),
    );
  }
}