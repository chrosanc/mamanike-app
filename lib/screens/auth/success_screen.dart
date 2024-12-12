import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/screens/auth/login_screen.dart';

class SuccessScreen extends StatelessWidget {
const SuccessScreen({ super.key });


  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset('assets/images/success.png'),

            const SizedBox(height: 48),
            Text(
              'Sukses',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF323232)
              )
              ),

              const SizedBox(height: 9,),
              Text(
                'Selamat! Akun Anda terverifikasi',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFB6B6B6)
                ),
              ),

              const SizedBox(height: 48),
              _button(context)
          ],
        )),
    );
  }
}

Widget _button(BuildContext context) {
    return Container(
    margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {

        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: const Color(0xFFFFB113),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        'Masuk',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
  }