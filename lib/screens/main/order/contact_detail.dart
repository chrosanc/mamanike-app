import 'dart:io';
import 'dart:math';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/viewmodel/main/order/order_viewmodel.dart';
import 'package:mamanike/widget/CustomAlert.dart';
import 'package:mamanike/widget/CustomForms.dart';
import 'package:mamanike/widget/button.dart';
import 'package:mamanike/screens/main/order/detail_order.dart';
import 'package:mamanike/screens/main/order/identityForm_screen.dart';
import 'package:mamanike/service/database_service.dart';
import 'package:provider/provider.dart';

class ContactDetail extends StatefulWidget {
  const ContactDetail({Key? key}) : super(key: key);

  @override
  _ContactDetailState createState() => _ContactDetailState();
}

class _ContactDetailState extends State<ContactDetail> {


  @override
  Widget build(BuildContext context) {

    final viewModel = Provider.of<OrderViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 76,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          'Pesan Barang',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFB113),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Kontak',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IdentityFormScreen(),
                        ),
                      );

                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            viewModel.contactFormData.isEmpty
                                ? 'Masukkan Identitas'
                                : 'Identitas Terisi',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Center(
                              child: SvgPicture.asset(
                                  'assets/svg/arrow_right.svg')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: viewModel.orderForAnotherPerson,
                    title: Text(
                      'Pesan untuk orang lain',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    activeColor: const Color(0xFFFFB113),
                    onChanged: (bool? value) {
                      setState(() {
                        viewModel.orderForAnotherPerson = value!;
                      });
                    },
                  ),
                  if (viewModel.orderForAnotherPerson) ...[
                    const SizedBox(height: 16),
                    CustomForms(
                      title: 'Nama Lengkap',
                      controller: viewModel.anotherPersonNameController,
                      onChanged: (value) {
                          viewModel.fullNameFilled = value.isNotEmpty;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomForms(
                      title: 'Nomor Handphone',
                      controller: viewModel.anotherPersonPhoneNumberController,
                      onChanged: (value) {
                          viewModel.phoneNumberFilled = value.isNotEmpty;
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Berikutnya',
              isLoading: viewModel.isLoading,
              onPressed: () {
                if (viewModel.validateContactFields()) {
                  _showConfirmationDialog(viewModel, context);
                } else {
                  CherryToast.error(
                    title: Text(
                      'Isikan semua form terlebih dahulu',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    animationType: AnimationType.fromTop,
                  ).show(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }


  void _showConfirmationDialog(OrderViewModel viewModel, BuildContext context) {
    showCustomAlertDialog(
      context,
      'Apakah data sudah sesuai?',
      'Pastikan data yang Anda masukkan telah sesuai. Anda tidak dapat mengubah detail pesanan setelah melanjutkan ke halaman pembayaran',
      () async {
        Navigator.of(context).pop();
        await viewModel.sendContactData(context);
      },
    );
  }

  Padding header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 24, 14, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const StepIndicator(isActive: true, label: 'Detail Kontak'),
          const SizedBox(width: 8),
          Container(color: const Color(0xFFFFB113), height: 1, width: 72),
          const SizedBox(width: 8),
          const StepIndicator(isActive: false, label: 'Detail Pesanan'),
        ],
      ),
    );
  }
}

void showCustomAlertDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        title: title,
        content: content,
        confirmText: 'YA, LANJUTKAN',
        cancelText: 'BELUM',
        onConfirm: onConfirm,
        onCancel: () {
          Navigator.of(context).pop();
        },
      );
    },
  );
}

class StepIndicator extends StatelessWidget {
  final bool isActive;
  final String label;

  const StepIndicator({
    Key? key,
    required this.isActive,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? const Color(0xFFFFB113) : Colors.grey[300],
          child: Text(
            (isActive ? '1' : '2'),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isActive ? const Color(0xFFFFB113) : Colors.grey[300],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
