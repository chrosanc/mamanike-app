import 'dart:async';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/screens/auth/success_screen.dart';

class Otpscreen extends StatefulWidget {
  final String phoneNumber;
  final User user;

  const Otpscreen({
    Key? key,
    required this.phoneNumber,
    required this.user,
  }) : super(key: key);

  @override
  OtpscreenState createState() => OtpscreenState();
}

class OtpscreenState extends State<Otpscreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _resendCountdown = 60;
  bool _isLoading = false;
  String? _verificationId;
  int? _resendToken;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _sendOtp();
    _startResendCountdown();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    _resendCountdown = 60;
    const oneSecond = Duration(seconds: 1);
    _resendTimer = Timer.periodic(oneSecond, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCountdown == 0) {
          timer.cancel();
        } else {
          _resendCountdown--;
        }
      });
    });
  }

  void _handleKeyPress(int index, String value) {
    if (value.isNotEmpty) {
      if (index < _focusNodes.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getOtp() {
    return _controllers.map((controller) => controller.text).join();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.currentUser?.linkWithCredential(credential);
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SuccessScreen()));
      },
      verificationFailed: (FirebaseAuthException e) {
        CherryToast.error(
          title: Text(e.message ?? 'Verifikasi Gagal'),
          animationType: AnimationType.fromRight,
          animationDuration: const Duration(milliseconds: 1000),
          autoDismiss: true,
        ).show(context);
        setState(() {
          _isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      timeout: const Duration(seconds: 60),
    );
  }

  void _verifyOtp() async {
    final otp = _getOtp();
    if (otp.length != 6) {
      CherryToast.error(
        title: const Text('Kode OTP tidak valid'),
        animationType: AnimationType.fromRight,
        animationDuration: const Duration(milliseconds: 1000),
        autoDismiss: true,
      ).show(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await widget.user.linkWithCredential(credential);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SuccessScreen()));
    } on FirebaseAuthException catch (e) {
      CherryToast.error(
        title: Text(e.message ?? 'Verifikasi Gagal'),
        animationType: AnimationType.fromRight,
        animationDuration: const Duration(milliseconds: 1000),
        autoDismiss: true,
      ).show(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 68),
          _header(context),
          const SizedBox(height: 20),
          _otpInput(),
          const SizedBox(height: 20),
          _resendButton(context),
          const SizedBox(height: 20),
          _verifyButton(context),
        ],
      ),
    );
  }

  Container _verifyButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: !_isLoading ? _verifyOtp : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFFFB113),
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
                'Verifikasi OTP',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Container _resendButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      child: Center(
        child: Text.rich(
          TextSpan(
            text: 'Tidak menerima kode OTP? ',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9E9E9E),
            ),
            children: <TextSpan>[
              TextSpan(
                text: _resendCountdown > 0
                    ? 'Kirim ulang dalam $_resendCountdown detik'
                    : 'Kirim ulang',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFFB113),
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (_resendCountdown == 0 && !_isLoading) {
                      _sendOtp();
                      _startResendCountdown();
                    }
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _otpInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          return _buildOtpInputBox(index);
        }),
      ),
    );
  }

  Widget _buildOtpInputBox(int index) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border.all(color: const Color(0xFF9E9E9E)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          onChanged: (value) => _handleKeyPress(index, value),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
          ),
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
            'OTP Verifikasi.',
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
}
