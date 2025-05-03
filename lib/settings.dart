import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'This is settings page',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}
