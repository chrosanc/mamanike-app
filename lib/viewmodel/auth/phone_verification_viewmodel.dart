import 'dart:async';

import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:mamanike/screens/auth/otp_screen.dart';
import 'package:mamanike/screens/auth/success_screen.dart';
import 'package:mamanike/widget/loadingwidget.dart';

class PhoneVerificationViewModel extends ChangeNotifier {
  bool phoneFilled = false;
  User? user;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _resendCountdown = 60;
  bool _isLoading = false;
  String? _verificationId;
  String? phoneNumber;
  int? _resendToken;
  Timer? _resendTimer;

  int get resendCountdown => _resendCountdown;
  bool get isLoading => _isLoading;

  bool get isFormFilled => phoneFilled;

  TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();


  void updatePhoneFilled(String value) {
    phoneFilled = value.isNotEmpty;
    notifyListeners();
  }

  Future<void> fillPhoneNumber(BuildContext context) async {
    if (!phoneFilled || _isLoading) return;

    try {
      LoadingWidget.showLoadingDialog(context);
      _isLoading = true;
      notifyListeners();

      phoneNumber = "+62${phoneNumberController.text.replaceAll(" ", "")}";
      bool isOtpSent = await sendOtp(context);

      if (!isOtpSent) {
        Navigator.pop(context);
        return;
      }

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Otpscreen(),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Pastikan loading ditutup sebelum menampilkan error
      CherryToast.error(
        title: const Text('Terjadi kesalahan'),
        animationType: AnimationType.fromRight,
        animationDuration: const Duration(milliseconds: 1000),
        autoDismiss: true,
      ).show(context);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void showError(BuildContext context, String message) {
    CherryToast.error(
      title: Text(message),
      animationType: AnimationType.fromRight,
      animationDuration: const Duration(milliseconds: 1000),
      autoDismiss: true,
    );
  }

  Future<bool> sendOtp(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.currentUser?.linkWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SuccessScreen()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          showError(context, e.message ?? 'Verifikasi Gagal');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
      );

      _isLoading = false;
      notifyListeners();
      return true; // Berhasil mengirim OTP
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showError(context, 'Terjadi kesalahan saat mengirim OTP');
      return false; // Gagal mengirim OTP
    }
  }

  void verifyOtp(BuildContext context) async {
    final otp = otpController.text.trim();
    user = _auth.currentUser;
    print(otp);

    if (otp.length != 6) {
      showError(context, 'Kode OTP harus 6 angka');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      LoadingWidget.showLoadingDialog(context);
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      if(user != null) {
        await user!.linkWithCredential(credential);
      } else {
        print('User Null');
      }
      LoadingWidget.hideloadingDialog(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SuccessScreen()));
    } on FirebaseAuthException catch (e) {
      showError(context, e.message ?? 'Verifikasi Gagal');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startResendCountdown() {
    _resendTimer?.cancel();
    _resendCountdown = 60;
    const oneSecond = Duration(seconds: 1);
    _resendTimer = Timer.periodic(oneSecond, (timer) {
      if (_resendCountdown == 0) {
        timer.cancel();
      } else {
        _resendCountdown--;
      }
      notifyListeners();
    });
  }

}
