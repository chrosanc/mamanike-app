import 'dart:io';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mamanike/models/Order.dart';
import 'package:mamanike/viewmodel/main/order/order_viewmodel.dart';
import 'package:mamanike/widget/CustomForms.dart';
import 'package:mamanike/widget/button.dart';
import 'package:provider/provider.dart';

class IdentityFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const IdentityFormScreen({ Key? key, this.initialData }) : super(key: key);

  @override
  _IdentityFormScreenState createState() => _IdentityFormScreenState();
}

class _IdentityFormScreenState extends State<IdentityFormScreen> {





 Future<void> _saveData(BuildContext context, OrderViewModel viewModel) async {

  final Map<String, dynamic> formData = {
      'fullName': viewModel.fullNameController.text,
      'phoneNumber': viewModel.phoneNumberController.text,
      'email': viewModel.emailController.text,
      'identityNumber': viewModel.identityNumberController.text,
      'identityAddress': viewModel.addressController.text,
      'identityImage': viewModel.image?.path,
    };


  if (viewModel.fullNameController.text.isEmpty ||
      viewModel.phoneNumberController.text.isEmpty ||
      viewModel.emailController.text.isEmpty ||
      viewModel.identityNumberController.text.isEmpty ||
      viewModel.addressController.text.isEmpty ||
      viewModel.image == null) {
      CherryToast.error(
        title: Text('Isikan semua form terlebih dahulu',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.normal
        ),),
        animationType: AnimationType.fromTop,
      ).show(context);
  } else{
    viewModel.saveContactData(formData);
    Navigator.pop(context);
  }
 }

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
          'Identitas',
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomForms(
                      title: 'Nama Lengkap (sesuai identitas)',
                      hintText: 'Ex: John Doe',
                      controller: viewModel.fullNameController,
                      onChanged: (value) {
                        setState(() {
                          
                        });
                      },
                    ),
                    const SizedBox(height: 24,),
                    CustomForms(
                      title: 'Nomor Handphone',
                      controller: viewModel.phoneNumberController,
                      hintText: 'Ex: +62 xxxx xxxx xxx',
                      onChanged: (value) {
                        setState(() {
                          // Do something if needed
                        });
                      },
                    ),
                    const SizedBox(height: 24,),
                    CustomForms(
                      title: 'Email',
                      controller: viewModel.emailController,
                      hintText: 'Ex: JohnDoe@mail.com',
                      onChanged: (value) {
                        setState(() {
                          // Do something if needed
                        });
                      },
                    ),
                    const SizedBox(height: 24,),
                    CustomForms(
                      title: 'Alamat (Sesuai Identitas)',
                      hintText: 'Ex: Jl. BatuBesar no 99 Kec. Batu, Kab. Batu,',
                      controller: viewModel.addressController,
                      onChanged: (value) {
                        setState(() {
                          // Do something if needed
                        });
                      },
                    ),
                    const SizedBox(height: 24,),
                    CustomForms(
                      title: 'Nomor KTP/SIM/NPWP',
                      controller: viewModel.identityNumberController,
                      onChanged: (value) {
                        setState(() {
                          // Do something if needed
                        });
                      },
                    ),
                    const SizedBox(height: 24,),
                    Text(
                      'Unggah foto identitas (SIM/NPWP/KTP/AKTA)',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF383434),
                      ),
                    ),
                    const SizedBox(height: 12,),
                    GestureDetector(
                      onTap: viewModel.pickIdentityImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          border: Border.all(color: const Color(0xFF9E9E9E)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Center(
                            child: viewModel.image == null
                                ? const Icon(IconlyBold.upload, size: 102,)
                                : Image.file(File(viewModel.image!.path), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          CustomButton(
            text: 'Simpan',
            onPressed: () {
              _saveData(context, viewModel);
            },
          ),
        ],
      ),
    );
  }
}
