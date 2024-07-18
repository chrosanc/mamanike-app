import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:mamanike/screens/auth/forgotpassword_screen.dart';
import 'package:mamanike/screens/auth/phoneverification_screen.dart';
import 'package:mamanike/screens/auth/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamanike/screens/main/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> saveFCMToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();

  if (token != null) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
    }
  }
}


Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await saveFCMToken();

      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.phoneNumber == null) {
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PhoneverificationScreen(user: user)));
        }
        CherryToast.success(
          title: Text("Silahkan Verifikasi nomor telepon.", style: GoogleFonts.poppins(fontSize: 12),),
          animationType: AnimationType.fromTop,
        ).show(context);
      } else {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
        }
        CherryToast.success(
          title: const Text("Login Berhasil"),
          animationType: AnimationType.fromTop,
        ).show(context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        CherryToast.error(
          title: const Text("Akun tidak ditemukan. Silakan daftar."),
          animationType: AnimationType.fromTop,
        ).show(context);
      } else if (e.code == 'wrong-password') {
        CherryToast.error(
          title: const Text("Password Salah"),
          animationType: AnimationType.fromTop,
        ).show(context);
      } else {
        CherryToast.error(
          title: Text("Error: ${e.message}"),
          animationType: AnimationType.fromTop,
        ).show(context);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: null,
              bottom: null,
              child: SvgPicture.asset(
                'assets/svg/logindecor.svg',
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/mamanikelogo.png',
                        width: 67,
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Login.',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFB113),
                        ),
                      ),
                      const SizedBox(height: 84),
                      Text(
                        'Masuk ke akun Anda',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      border: Border.all(color: const Color(0xFF9E9E9E)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Email atau Nomor Telepon",
                        prefixIcon: const Icon(
                          IconlyBold.message,
                          color: Color(0xFF9E9E9E),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 140 / 100,
                          letterSpacing: 0.2,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      border: Border.all(color: const Color(0xFF9E9E9E)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Password",
                        prefixIcon: const Icon(
                          IconlyBold.lock,
                          color: Color(0xFF9E9E9E),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? IconlyBold.show : IconlyBold.hide,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 140 / 100,
                          letterSpacing: 0.2,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> ForgotpasswordScreen()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 27),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Lupa Password?',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFB113),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 55),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
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
                  ),
                  const SizedBox(height: 120),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Belum punya akun? ",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF9E9E9E),
                      ),
                      children: [
                        TextSpan(
                          text: "Daftar Sekarang",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFB113),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterScreen()),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
