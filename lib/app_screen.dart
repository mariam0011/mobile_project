import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'bar.dart';

class AppScreen extends StatelessWidget {
  const AppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const MainScreen(),
      bottomNavigationBar: const BottomBar(),
    );
  }
}