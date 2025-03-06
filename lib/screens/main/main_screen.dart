import 'package:flutter/material.dart';
import 'package:mamanike/screens/main/account/account_screen.dart';
import 'package:mamanike/screens/main/category/category_screen.dart';
import 'package:mamanike/screens/main/home/home_screen.dart';
import 'package:mamanike/screens/main/order/order_screen.dart';

import 'package:mamanike/viewmodel/main/main_container_viewmodel.dart';
import 'package:mamanike/widget/navigation.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  MainScreen({Key? key}) : super(key: key);

  final List<Widget> _screens = [
    HomeScreen(),
    const CategoryScreen(),
    const OrderScreen(),
    const AccountScreen()
  ];

  @override
  Widget build(BuildContext context) {
    final mainViewModel = Provider.of<MainContainerViewmodel>(context);


    return Scaffold(
      body: _screens[mainViewModel.currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: mainViewModel.currentIndex,
        onTap: (index) => mainViewModel.navigateToPages(index),
      ),
    );
  }
}
