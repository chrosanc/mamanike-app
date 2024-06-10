// MainScreen.dart

import 'package:flutter/material.dart';
import 'package:mamanike/screens/main/account/account_screen.dart';
import 'package:mamanike/screens/main/category/category_screen.dart';
import 'package:mamanike/screens/main/home/home_screen.dart';
import 'package:mamanike/screens/main/order/order_screen.dart';
import 'package:mamanike/models/navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoryScreen(),
    const OrderScreen(),
    const AccountScreen()
  ];

  void navigateToCategory() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
