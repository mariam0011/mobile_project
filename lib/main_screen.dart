import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'home.dart';
import 'help.dart';
import 'settings.dart';
import 'profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int the_current_page = 1; // 1=Home, 2=Help, 3=Settings, 4=Profile
  final Logger _logger = Logger('MainScreen');

  Widget _getPage() {
    switch (the_current_page) {
      case 1:
        return const Home();
      case 2:
        return const Help();
      case 3:
        return const Settings();
      case 4:
        return const Profile();
      default:
        return const Home();
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.info("the value of current page in main screen is $the_current_page");
    return Scaffold(
      backgroundColor: const Color.fromRGBO(23, 18, 28, 1),
      body: _getPage(),
    );
  }
}
