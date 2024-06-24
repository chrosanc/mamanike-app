import 'package:flutter/material.dart';
import 'package:mamanike/screens/auth/login_screen.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3)).then((value) => {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              (route) => false)
        });

    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/mamanikelogo.png',
          width: 131,
        ),
      ),
    );
  }
}
