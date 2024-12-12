import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/screens/admin/order_admin_screen.dart';
import 'package:mamanike/screens/auth/phoneverification_screen.dart';
import 'package:mamanike/screens/main/main_screen.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscureText = true;

  bool get obscureText => _obscureText;

  void togglePasswordVisibility() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  Future<void> saveFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    if (token != null) {
      final User? user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': token});
      }
    }
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    if (email == 'admin@gmail.com' && password == 'Admin#1234') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const OrderAdminScreen()));
    } else {
      try {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        await saveFCMToken();

        final User? user = _auth.currentUser;
        if (user != null) {
          if (user.phoneNumber == null) {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhoneverificationScreen(user: user),
                ),
              );
            }
            CherryToast.success(
              title: Text(
                "Silahkan Verifikasi nomor telepon.",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              animationType: AnimationType.fromTop,
            ).show(context);
          } else {
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            }
            CherryToast.success(
              title: const Text("Login Berhasil"),
              animationType: AnimationType.fromTop,
            ).show(context);
          }
        }
      } on FirebaseAuthException catch (e) {
        _handleLoginError(e, context);
      }
    }
  }

  void _handleLoginError(FirebaseAuthException e, BuildContext context) {
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
