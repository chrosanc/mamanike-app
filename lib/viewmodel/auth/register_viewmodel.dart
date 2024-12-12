import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:mamanike/screens/auth/phoneverification_screen.dart';

class RegisterViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _obscureText = true;
  bool _confirmObscureText = true;
  bool _isLoading = false;
  bool _namapenggunaFilled = false;
  bool _emailFilled = false;
  bool _passwordFilled = false;
  bool _confirmPasswordFilled = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool get obscureText => _obscureText;
  bool get confirmObscureText => _confirmObscureText;
  bool get isLoading => _isLoading;

  void toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  void toggleConfirmObscureText() {
    _confirmObscureText = !_confirmObscureText;
    notifyListeners();
  }

  void updateNamapenggunaFilled(bool value) {
    _namapenggunaFilled = value;
    notifyListeners();
  }

  void updateEmailFilled(bool value) {
    _emailFilled = value;
    notifyListeners();
  }

  void updatePasswordFilled(bool value) {
    _passwordFilled = value;
    notifyListeners();
  }

  void updateConfirmPasswordFilled(bool value) {
    _confirmPasswordFilled = value;
    notifyListeners();
  }

  bool isFormFilled() {
    return _namapenggunaFilled &&
           _emailFilled &&
           _passwordFilled &&
           _confirmPasswordFilled &&
           passwordController.text == confirmPasswordController.text;
  }

  Future<void> register(BuildContext context) async {
    if (!isFormFilled()) return;

    _isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text, 
        password: passwordController.text,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'full_name': nameController.text,
        'email': emailController.text,
        'fcmToken': ''
      });

      if (userCredential.user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhoneverificationScreen(user: userCredential.user!),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      CherryToast.error(
        description: Text(e.message ?? 'An error occurred.'),
        animationType: AnimationType.fromTop,
      ).show(context);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
