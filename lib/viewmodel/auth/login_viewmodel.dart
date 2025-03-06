import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/screens/admin/order_admin_screen.dart';
import 'package:mamanike/screens/auth/phoneverification_screen.dart';
import 'package:mamanike/screens/main/home/home_screen.dart';
import 'package:mamanike/screens/main/main_screen.dart';
import 'package:mamanike/widget/loadingwidget.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscureText = true;

  bool get obscureText => _obscureText;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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

  Future<void> login(BuildContext context) async {
    LoadingWidget.showLoadingDialog(context);

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await saveFCMToken();

      final User? user = _auth.currentUser;
      if (user == null) throw FirebaseAuthException(code: "user-not-found");

      // Tutup loading dialog sebelum navigasi
      Navigator.pop(context);

      if (user.phoneNumber == null) {
        // Navigasi ke verifikasi telepon jika belum diverifikasi
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhoneverificationScreen(user: user),
          ),
        );

        CherryToast.success(
          title: Text(
            "Silahkan verifikasi nomor telepon.",
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          animationType: AnimationType.fromTop,
        ).show(context);

        return; // Hindari eksekusi kode selanjutnya
      }

      // Navigasi ke Home jika sudah verifikasi
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(), // Ganti dengan layar utama
        ),
      );

      CherryToast.success(
        title: const Text("Login Berhasil"),
        animationType: AnimationType.fromTop,
      ).show(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Pastikan loading juga ditutup saat error
      _handleLoginError(e, context);
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
