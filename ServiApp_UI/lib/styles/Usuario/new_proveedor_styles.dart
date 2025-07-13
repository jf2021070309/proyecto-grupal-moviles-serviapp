import 'package:flutter/material.dart';

class NewProveedorStyles {
  static const title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0D47A1), // azul oscuro
  );

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0D47A1)),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    );
  }

  static final primaryButton = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF0D47A1),
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );
}
