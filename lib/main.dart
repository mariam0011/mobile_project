import 'package:flutter/material.dart';
import 'app_screen.dart'; // only import AppScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppScreen(), // returns the full layout from app_screen.dart
    );
  }
}
