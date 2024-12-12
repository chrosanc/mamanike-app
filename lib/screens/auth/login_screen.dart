import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:mamanike/screens/auth/forgotpassword_screen.dart';
import 'package:mamanike/screens/auth/register_screen.dart';
import 'package:mamanike/viewmodel/auth/login_viewmodel.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);

    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

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
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 18),
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      border: Border.all(color: const Color(0xFF9E9E9E)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: loginViewModel.obscureText,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Password",
                        prefixIcon: const Icon(
                          IconlyBold.lock,
                          color: Color(0xFF9E9E9E),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            loginViewModel.obscureText
                                ? IconlyBold.show
                                : IconlyBold.hide,
                          ),
                          onPressed: () {
                            loginViewModel.togglePasswordVisibility();
                          },
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 18),
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
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotpasswordScreen()));
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
                      onPressed: () {
                        loginViewModel.login(
                          _emailController.text,
                          _passwordController.text,
                          context,
                        );
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
                        'Login',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Belum memiliki akun? ',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF9E9E9E),
                        ),
                        children: [
                          TextSpan(
                            text: 'Daftar disini',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFB113),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RegisterScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
