import 'dart:async';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamanike/screens/auth/success_screen.dart';

class OtpViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _resendCountdown = 60;
  bool _isLoading = false;
  String? _verificationId;
  int? _resendToken;
  Timer? _resendTimer;

  List<TextEditingController> get controllers => _controllers;
  List<FocusNode> get focusNodes => _focusNodes;
  int get resendCountdown => _resendCountdown;
  bool get isLoading => _isLoading;
  String? get verificationId => _verificationId; // Public getter for _verificationId

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

  void showError(BuildContext context, String message) {
    CherryToast.error(
      title: Text(message),
      animationType: AnimationType.fromRight,
      animationDuration: const Duration(milliseconds: 1000),
      autoDismiss: true,
    ).show(context);
  }

  String _getOtp() {
    return _controllers.map((controller) => controller.text).join();
  }

  Future<void> sendOtp(BuildContext context, String phoneNumber) async {
    _isLoading = true;
    notifyListeners();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.currentUser?.linkWithCredential(credential);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SuccessScreen()));
      },
      verificationFailed: (FirebaseAuthException e) {
        _isLoading = false;
        notifyListeners();
        showError(context, e.message ?? 'Verifikasi Gagal');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        _isLoading = false;
        notifyListeners();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        notifyListeners();
      },
      timeout: const Duration(seconds: 60),
    );
  }

  void verifyOtp(BuildContext context, String? verificationId, User user) async {
    final otp = _getOtp();
    if (otp.length != 6) {
      showError(context, 'Kode OTP tidak valid');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otp,
      );
      await user.linkWithCredential(credential);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SuccessScreen()));
    } on FirebaseAuthException catch (e) {
      showError(context, e.message ?? 'Verifikasi Gagal');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }
}
