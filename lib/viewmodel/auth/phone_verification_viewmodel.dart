import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:mamanike/screens/auth/otp_screen.dart';

class PhoneVerificationViewModel extends ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  bool phoneFilled = false;
  bool isLoading = false;
  final User user;

  PhoneVerificationViewModel(this.user);

  bool get isFormFilled => phoneFilled;

  void updatePhoneFilled(String value) {
    phoneFilled = value.isNotEmpty;
    notifyListeners();
  }

  Future<void> sendOtp(BuildContext context) async {
    if (!phoneFilled || isLoading) return;

    try {
      isLoading = true;
      notifyListeners();

      String phoneNumber = "+62${phoneController.text.replaceAll(" ", "")}";
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Otpscreen(phoneNumber: phoneNumber, user: user),
        ),
      );
    } catch (e) {
      print(e);
      CherryToast.error(
        title: Text('Terjadi kesalahan'),
        animationType: AnimationType.fromRight,
        animationDuration: const Duration(milliseconds: 1000),
        autoDismiss: true,
      ).show(context);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
