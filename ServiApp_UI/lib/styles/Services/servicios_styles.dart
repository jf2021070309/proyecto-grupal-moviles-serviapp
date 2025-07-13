import 'package:flutter/material.dart';

/// Clase que contiene todos los estilos para las páginas de servicios
class ServiciosStyles {
  // Colores
  static final Color primaryColor = Colors.blue[800]!;
  static final Color unselectedItemColor = const Color.fromARGB(
    179,
    158,
    94,
    94,
  );
  static final Color selectedItemColor = const Color.fromARGB(
    255,
    111,
    134,
    160,
  );
  static final Color backgroundColor = Colors.white;
  static final Color titleTextColor = Colors.black87;
  static final Color buttonTextColor = Colors.white;

  // Estilos de texto
  static const TextStyle sectionTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Colors.black87,
  );

  static const TextStyle buttonTextStyle = TextStyle(color: Colors.white);

  // Espaciados
  static const double defaultPadding = 16.0;
  static const double itemSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 20.0;

  // Bordes
  static BorderRadius cardBorderRadius = BorderRadius.circular(12);
  static BorderRadius buttonBorderRadius = BorderRadius.circular(8);

  // Tamaños
  static const double serviceImageHeight = 100.0;
  static const double buttonHeight = 50.0;

  // Estilos de botones
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius),
    padding: const EdgeInsets.symmetric(horizontal: 8),
  );

  // Estilos de tarjetas
  static BoxDecoration providerCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
    ],
  );

  static const TextStyle providerNameStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle providerInfoStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  static ChipThemeData chipTheme = ChipThemeData(
    backgroundColor: Color(0xFFEDE7F6), // lila claro
    labelStyle: TextStyle(color: Color(0xFF512DA8)), // morado oscuro
    shape: StadiumBorder(),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  );
}
