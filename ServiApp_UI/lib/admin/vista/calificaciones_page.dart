import 'package:flutter/material.dart';
import '../styles/admin_theme.dart';

class CalificacionesPage extends StatefulWidget {
  @override
  _CalificacionesPageState createState() => _CalificacionesPageState();
}

class _CalificacionesPageState extends State<CalificacionesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Calificaciones', style: TextStyle(color: Colors.white)),
        backgroundColor: AdminTheme.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_rate, size: 64, color: AdminTheme.primaryColor),
            SizedBox(height: AdminTheme.spacing),
            Text('Calificaciones', style: AdminTheme.titleLarge),
            SizedBox(height: AdminTheme.smallSpacing),
            Text('Esta sección estará disponible próximamente', style: AdminTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
