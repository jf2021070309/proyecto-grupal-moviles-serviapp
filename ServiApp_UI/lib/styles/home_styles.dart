import 'package:flutter/material.dart';

const TextStyle kTitleStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
);

const TextStyle kCategoryLabelStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: Colors.black87,
);

const TextStyle kServiceTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

const TextStyle kSubtitleStyle = TextStyle(fontSize: 13, color: Colors.black54);

final BoxDecoration kCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
  ],
);
