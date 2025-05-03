import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'This is profile page',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}
