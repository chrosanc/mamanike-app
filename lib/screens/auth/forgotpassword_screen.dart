import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';

class ForgotpasswordScreen extends StatefulWidget {
  const ForgotpasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotpasswordScreenState createState() => _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends State<ForgotpasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _emailFilled = false;
  bool _isLoading = false;

  bool _isFormFilled() {
    return _emailFilled;
  }

  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
      CherryToast.success(
        title: const Text("Email reset password telah dikirim."),
        animationType: AnimationType.fromTop,
      ).show(context);
    } on FirebaseAuthException catch (e) {
      CherryToast.error(
        title: Text("Error: ${e.message}"),
        animationType: AnimationType.fromTop,
      ).show(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 68),
          _header(context),
          const SizedBox(height: 50),
          _form(),
          const SizedBox(height: 25),
          _button(context),
        ],
      ),
    );
  }

  Row _header(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB113), // Background color of the button
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
            child: IconButton(
              icon: SvgPicture.asset('assets/svg/back.svg', color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Lupa Password.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFB113),
            ),
          ),
        ),
        const SizedBox(width: 60), // Add space between the text and the right edge of the screen
      ],
    );
  }

  Container _button(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isFormFilled() && !_isLoading ? _sendPasswordResetEmail : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _isFormFilled() ? const Color(0xFFFFB113) : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Kirim Reset Password',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Column _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            'Email',
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.normal, color: const Color(0xFF9E9E9E)),
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
            onChanged: (value) {
              setState(() {
                _emailFilled = value.isNotEmpty;
              });
            },
            controller: _emailController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Masukkan email Anda",
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                height: 140 / 100,
                letterSpacing: 0.2,
                color: const Color(0xFF9E9E9E),
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
