import 'package:flutter/material.dart';

class Estilos {
  static const Color appBarColor = Colors.blueAccent;
  static const Color appBarTextColor = Colors.white;
  static const Color backgroundColor = Color(0xFFF6F9FC);

  static const EdgeInsets pagePadding = EdgeInsets.all(16.0);

  static const TextStyle labelTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  static final InputDecoration inputDecoration = InputDecoration(
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
    ),
    labelStyle: TextStyle(color: Colors.blueAccent),
  );

  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.blueAccent,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
