import 'dart:async';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/screens/auth/success_screen.dart';

class Otpscreen extends StatefulWidget {
  final String phoneNumber;
  final User user;
  final String verificationId;

  const Otpscreen({
    Key? key,
    required this.phoneNumber,
    required this.user,
    required this.verificationId,
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

  void _startResendCountdown() {
    const oneSecond = Duration(seconds: 1);
    setState(() {
      _resendTimer = Timer.periodic(oneSecond, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown == 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _resendCountdown = 60;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _resendCountdown--;
          });
        }
      }
    });
    });
    
  }

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  void _handleKeyPress(int index, String value) {
    if (value.isNotEmpty) {
      if (index < _focusNodes.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  bool _isFormFilled() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  Future<void> _verifyOtp() async {
    if (!_isFormFilled()) {
      CherryToast.error(
        description: const Text("Isi Kode OTP"),
        animationType: AnimationType.fromTop,
      ).show(context);
      return;
    }

    String otp = _controllers.map((controller) => controller.text).join();

    try {
      setState(() {
        _isLoading = true;
      });

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      await widget.user.updatePhoneNumber(credential);
      setState(() {
        _resendTimer!.cancel();
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SuccessScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        CherryToast.error(
          description: Text(e.message ?? "Error occurred"),
          animationType: AnimationType.fromTop,
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _sendOtp() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await widget.user.updatePhoneNumber(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            CherryToast.error(
              description: Text(e.message!),
              animationType: AnimationType.fromTop,
            ).show(context);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _resendToken = resendToken;
              _startResendCountdown();
            });
            CherryToast.success(
              description: const Text("Kode verifikasi dikirim."),
              animationType: AnimationType.fromTop,
            ).show(context);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          
        },
      );
    } catch (e) {
      if (mounted) {
        CherryToast.error(
          description: Text(e.toString()),
          animationType: AnimationType.fromTop,
        ).show(context);
      }
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
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
          const SizedBox(height: 25),
          _description(),
          const SizedBox(height: 24),
          _form(),
          const SizedBox(height: 18),
          _resendotp(),
          const SizedBox(height: 12),
          _button(context),
        ],
      ),
    );
  }

  RichText _resendotp() {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        text: _resendCountdown == 0 ? "Kirim ulang kode" : "Kirim ulang kode ($_resendCountdown)",
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: _resendCountdown == 0 ? const Color(0xFFFFB113) : const Color(0xFF9E9E9E),
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = _resendCountdown == 0 ? _sendOtp : null,
      ),
    );
  }

  Row _form() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 50,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => _handleKeyPress(index, value),
            onTap: () {
              setState(() {});
            },
          ),
        );
      }),
    );
  }

  Padding _description() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 38),
      child: Text(
        'Kode Verifikasi Telah Dikirim Melalui Nomor Terdaftar',
        style: GoogleFonts.poppins(color: Colors.grey),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _button(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isFormFilled() ? _verifyOtp : null,
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
                'Konfirmasi',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Row _header(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 24),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB113),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: SvgPicture.asset('assets/svg/back.svg', color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Verifikasi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFB113),
              ),
            ),
          ),
        ),
        const SizedBox(width: 50),
      ],
    );
  }
}
