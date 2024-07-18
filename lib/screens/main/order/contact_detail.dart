import 'dart:io';
import 'dart:math';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/models/CustomAlert.dart';
import 'package:mamanike/models/CustomForms.dart';
import 'package:mamanike/models/button.dart';
import 'package:mamanike/screens/main/order/detail_order.dart';
import 'package:mamanike/screens/main/order/identityForm_screen.dart';
import 'package:mamanike/service/database_service.dart';

class ContactDetail extends StatefulWidget {
  final Map<String, dynamic> data;
  const ContactDetail({Key? key, required this.data}) : super(key: key);

  @override
  _ContactDetailState createState() => _ContactDetailState();
}

class _ContactDetailState extends State<ContactDetail> {
  bool orderForAnotherPerson = false;
  bool fullNameFilled = false;
  bool phoneNumberFilled = false;
  bool _isLoading = false;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  Map<String, dynamic> identityData = {};

  final DatabaseService _databaseService = DatabaseService();

  Future<void> _addToFirestore() async {
    setState(() {
      _isLoading = true;
    });

    String? anotherPersonName;
    String? anotherPersonNumber;
    String invId = 'Inv - ${_generateRandomString()}';

    final File imageFile = File(identityData['imagePath']);
 
    if (orderForAnotherPerson) {
      anotherPersonName = fullNameController.text;
      anotherPersonNumber = phoneNumberController.text;
      widget.data['anotherPersonName'] = anotherPersonName;
      widget.data['anotherPersonNumber'] = anotherPersonNumber;
    } else {
      widget.data.remove('anotherPersonName');
      widget.data.remove('anotherPersonNumber');
    }

      widget.data['identityData'] = identityData;


    try {
      await _databaseService.reserveItem(
        invId,
        widget.data['nama_kategori'],
        widget.data['nama'],
        widget.data['gambar'],
        identityData,
        imageFile,
        anotherPersonName,
        anotherPersonNumber
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetailOrder(data: widget.data, invId: invId,),
        ),
      );
    } catch (e) {
      print('Error adding to Firestore: $e');
      CherryToast.error(
        title: Text(
          'Gagal memproses identitas',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
        animationType: AnimationType.fromTop,
      ).show(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _generateRandomString({int length = 6}) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  return String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
}

  @override
  Widget build(BuildContext context) {
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
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IdentityFormScreen(
                            initialData: identityData,
                          ),
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          identityData = result;
                        });
                      }
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
                            identityData.isEmpty
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
                    value: orderForAnotherPerson,
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
                        orderForAnotherPerson = value!;
                      });
                    },
                  ),
                  if (orderForAnotherPerson) ...[
                    const SizedBox(height: 16),
                    CustomForms(
                      title: 'Nama Lengkap',
                      controller: fullNameController,
                      onChanged: (value) {
                        setState(() {
                          fullNameFilled = value.isNotEmpty;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomForms(
                      title: 'Nomor Handphone',
                      controller: phoneNumberController,
                      onChanged: (value) {
                        setState(() {
                          phoneNumberFilled = value.isNotEmpty;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Berikutnya',
              isLoading: _isLoading,
              onPressed: () {
                if (_validateFields()) {
                  _showConfirmationDialog();
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

  bool _validateFields() {
    if (orderForAnotherPerson) {
      return identityData.isNotEmpty &&
          fullNameController.text.isNotEmpty &&
          phoneNumberController.text.isNotEmpty;
    } else {
      return identityData.isNotEmpty;
    }
  }

  void _showConfirmationDialog() {
    showCustomAlertDialog(
      context,
      'Apakah data sudah sesuai?',
      'Pastikan data yang Anda masukkan telah sesuai. Anda tidak dapat mengubah detail pesanan setelah melanjutkan ke halaman pembayaran',
      () async {
        Navigator.of(context).pop();
        await _addToFirestore();
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
