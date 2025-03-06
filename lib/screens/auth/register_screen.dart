import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:mamanike/viewmodel/auth/register_viewmodel.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<RegisterViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom + 80
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    child: Stack(
                      children: [
                        Positioned(
                          child: SvgPicture.asset(
                            'assets/svg/registerdecor.svg',
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _header(context),
                            const SizedBox(height: 34),
                            _namapengguna(model),
                            const SizedBox(height: 12),
                            _email(model),
                            const SizedBox(height: 12),
                            _password(model),
                            const SizedBox(height: 12),
                            _konfirmasipassword(model),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _button(context, model),
            ),
          ],
        ),
      ),
    );
  }

  Container _button(BuildContext context, RegisterViewModel model) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: model.isFormFilled() ? () => model.register(context) : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: model.isFormFilled()
              ? const Color(0xFFFFB113)
              : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: model.isLoading
            ? const SizedBox(
            height: 24, width: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
              strokeWidth: 2,
            )
        )
            : Text(
          'Daftar',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Column _konfirmasipassword(RegisterViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            'Konfirmasi Password',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF9E9E9E),
            ),
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
            onChanged: (value) {
              model.updateConfirmPasswordFilled(value.isNotEmpty);
            },
            controller: model.confirmPasswordController,
            obscureText: model.confirmObscureText,
            validator: (value) {
              if (value != model.passwordController.text) {
                return 'Konfirmasi Password harus sama dengan password';
              }
              return null;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Konfirmasi Password",
              suffixIcon: IconButton(
                icon: Icon(
                  model.confirmObscureText ? IconlyBold.show : IconlyBold.hide,
                ),
                onPressed: model.toggleConfirmObscureText,
              ),
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
        const SizedBox(height: 6),
        if (model.confirmObscureText && model.confirmPasswordController.text !=
            model.passwordController.text) ...{
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                const Icon(IconlyBold.info_circle, color: Colors.red, size: 20),
                Text(
                  "Konfirmasi Password harus sama!",
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        },
      ],
    );
  }

  Column _password(RegisterViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            'Password',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF9E9E9E),
            ),
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
            onChanged: (value) {
              model.updatePasswordFilled(value.isNotEmpty);
            },
            controller: model.passwordController,
            obscureText: model.obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Password",
              suffixIcon: IconButton(
                icon: Icon(
                  model.obscureText ? IconlyBold.show : IconlyBold.hide,
                ),
                onPressed: model.toggleObscureText,
              ),
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

  Column _email(RegisterViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            'Email',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF9E9E9E),
            ),
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
            onChanged: (value) {
              model.updateEmailFilled(value.isNotEmpty);
            },
            controller: model.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Email",
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

  Column _namapengguna(RegisterViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            'Nama Pengguna',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF9E9E9E),
            ),
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
            onChanged: (value) {
              model.updateNamapenggunaFilled(value.isNotEmpty);
            },
            controller: model.nameController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Nama Pengguna",
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

  Container _header(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Silakan daftarkan akun anda untuk melanjutkan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

