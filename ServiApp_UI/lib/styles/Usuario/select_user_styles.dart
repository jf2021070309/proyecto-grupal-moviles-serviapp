import 'package:flutter/material.dart';

class SelectUserStyles {
  static const TextStyle titleText = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static final ButtonStyle clienteButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    backgroundColor: Colors.blueAccent,
  );

  static final ButtonStyle proveedorButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    backgroundColor: Colors.green,
  );

  static const TextStyle descriptionText = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );
}
