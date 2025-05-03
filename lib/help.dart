import 'package:flutter/material.dart';

class Help extends StatelessWidget {
  const Help({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'This is help page',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}
