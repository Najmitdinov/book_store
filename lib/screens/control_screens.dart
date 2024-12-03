import 'package:flutter/material.dart';

import '../screens/book_categories.dart';
import '../screens/book_library.dart';
import '../screens/my_home_page.dart';
import '../screens/setting_screen.dart';

class ControlScreens extends StatefulWidget {
  const ControlScreens({super.key});

  static const routeName = '/main-screen';

  @override
  State<ControlScreens> createState() => _ControlScreensState();
}

class _ControlScreensState extends State<ControlScreens> {
  List<Widget> _pages = [];
  int initScreen = 0;

  @override
  void initState() {
    _pages = const [
      MyHomePage(),
      BookCategories(),
      BookLibrary(),
      SettingScreen(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[initScreen],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white30,
        currentIndex: initScreen,
        onTap: (ind) {
          setState(
            () {
              initScreen = ind;
            },
          );
        },
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
