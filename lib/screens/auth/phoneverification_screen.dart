import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/screens/auth/otp_screen.dart';

class PhoneverificationScreen extends StatefulWidget {
  final User user;

  const PhoneverificationScreen({super.key, required this.user});

  @override
  _PhoneverificationScreenState createState() => _PhoneverificationScreenState();
}

class _PhoneverificationScreenState extends State<PhoneverificationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _phoneFilled = false;
  bool _isLoading = false;

  String? _verificationId;


  bool _isFormFilled() {
    return _phoneFilled;
  }

  void _sendOtp() async {
  setState(() {
    _isLoading = true;
  });

  String phoneNumber = "+62${_phoneController.text.replaceAll(" ", "")}";
  try {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await widget.user.updatePhoneNumber(credential);
        CherryToast.success(
          description: const Text("Verifikasi berhasil."),
          animationType: AnimationType.fromTop,
        ).show(context);
        setState(() {
          _isLoading = false;
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'credential-already-in-use') {
          CherryToast.error(
            description: const Text("Nomor telepon ini sudah digunakan."),
            animationType: AnimationType.fromTop,
          ).show(context);
        } else {
          print(e.message);
          CherryToast.error(
            description: Text('Error terjadi, silahkan coba lagi nanti'),
            animationType: AnimationType.fromTop,
          ).show(context);
        }
        setState(() {
          _isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
        CherryToast.success(
          description: const Text("Kode verifikasi dikirim."),
          animationType: AnimationType.fromTop,
        ).show(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Otpscreen(
              phoneNumber: phoneNumber,
              user: widget.user,
              verificationId: _verificationId!,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  } catch (e) {
    CherryToast.error(
      description: Text(e.toString()),
      animationType: AnimationType.fromTop,
    ).show(context);
    setState(() {
      _isLoading = false;
    });
  }
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
          _form(),
          const SizedBox(height: 20),
          _button(context),
        ],
      ),
    );
  }

  Container _button(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isFormFilled() && !_isLoading ? _sendOtp : null,
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
                'Kirim OTP',
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
            'Nomor Telepon',
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
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _PhoneNumberFormatter(),
            ],
            onChanged: (value) {
              setState(() {
                _phoneFilled = value.isNotEmpty;
              });
            },
            controller: _phoneController,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefix: Container(
                padding: const EdgeInsets.only(right: 12),
                child: const Text('+62'),
              ),
              hintText: "0000 0000 000 ",
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
            'Verifikasi.',
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

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;

    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();

    if (newTextLength >= 4) {
      newText.write('${newValue.text.substring(0, usedSubstringIndex = 3)} ');
      if (newValue.selection.end >= 3) selectionIndex++;
    }
    if (newTextLength >= 8) {
      newText.write('${newValue.text.substring(3, usedSubstringIndex = 7)} ');
      if (newValue.selection.end >= 7) selectionIndex++;
    }
    if (newTextLength >= 12) {
      newText.write('${newValue.text.substring(7, usedSubstringIndex = 11)} ');
      if (newValue.selection.end >= 11) selectionIndex++;
    }

    // Dump the rest.
    if (newTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
