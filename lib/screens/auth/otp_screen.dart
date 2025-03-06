import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/theme.dart';
import 'package:mamanike/viewmodel/auth/otp_viewmodel.dart';
import 'package:mamanike/viewmodel/auth/phone_verification_viewmodel.dart';
import 'package:provider/provider.dart';

class Otpscreen extends HookWidget {
  const Otpscreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final viewModel = Provider.of<PhoneVerificationViewModel>(context);

    useEffect(() {
      viewModel.startResendCountdown();
    }, []);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: appTheme.colorScheme.primary),
        title: Text('Masukkan Kode OTP'),
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: appTheme.colorScheme.primary,
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text('Masukkan kode OTP anda yang sudah dikirim melalui SMS.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black
              ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            OtpTextField(
              showFieldAsBox: false,
              focusedBorderColor: appTheme.colorScheme.primary,
              onSubmit: (String verificationCode){
                viewModel.otpController.text = verificationCode;
              },
              numberOfFields: 6,
              textStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
            _resendButton(viewModel, context),
            _verifyButton(viewModel, context),
          ],
        ),
      ),
    );
  }

  Container _verifyButton(
      PhoneVerificationViewModel viewModel, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      width: double.infinity,
      child: ElevatedButton(
        onPressed:(){
          viewModel.verifyOtp(context);
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFFFB113),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: viewModel.isLoading
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

  Container _resendButton(
      PhoneVerificationViewModel viewModel, BuildContext context) {
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
                text: viewModel.resendCountdown > 0
                    ? 'Kirim ulang dalam ${viewModel.resendCountdown} detik'
                    : 'Kirim ulang',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFFB113),
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (viewModel.resendCountdown == 0 &&
                        !viewModel.isLoading) {
                      viewModel.sendOtp(context);
                      viewModel.startResendCountdown();
                    }
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Padding _otpInput(PhoneVerificationViewModel viewModel) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 24),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: List.generate(6, (index) {
  //         return _buildOtpInputBox(viewModel, index);
  //       }),
  //     ),
  //   );
  // }

  // Widget _buildOtpInputBox(PhoneVerificationViewModel viewModel, int index) {
  //   return Container(
  //     width: 45,
  //     height: 45,
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFFAFAFA),
  //       border: Border.all(color: const Color(0xFF9E9E9E)),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Center(
  //       child: TextField(
  //         controller: viewModel.controllers[index],
  //         focusNode: viewModel.focusNodes[index],
  //         keyboardType: TextInputType.number,
  //         textAlign: TextAlign.center,
  //         maxLength: 1,
  //         onChanged: (value) {
  //           if (value.isNotEmpty) {
  //             if (index < viewModel.focusNodes.length - 1) {
  //               viewModel.focusNodes[index + 1].requestFocus();
  //             } else {
  //               viewModel.focusNodes[index].unfocus();
  //             }
  //           } else if (value.isEmpty && index > 0) {
  //             viewModel.focusNodes[index - 1].requestFocus();
  //           }
  //         },
  //         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  //         decoration: const InputDecoration(
  //           border: InputBorder.none,
  //           counterText: '',
  //         ),
  //         style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
  //       ),
  //     ),
  //   );
  // }

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
              shape: BoxShape.circle,
              color: const Color(0xFFFFB113),
            ),
            child: IconButton(
              icon: SvgPicture.asset('assets/icons/arrow_right.svg'),
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Masukkan Kode OTP',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}