import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/controller/address_controller.dart';
import 'package:mamanike/widget/CustomForms.dart';
import 'package:mamanike/widget/button.dart';
import 'package:mamanike/screens/main/order/map_screen.dart';
import 'package:mamanike/service/database_service.dart';

class DetailaddressScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  const DetailaddressScreen({Key? key, this.data}) : super(key: key);

  @override
  _DetailaddressScreenState createState() => _DetailaddressScreenState();
}

class _DetailaddressScreenState extends State<DetailaddressScreen> {
  AddressController controller = AddressController();
  Map<String,dynamic>? pinpoint;
  String? addressPinPoint;
  DatabaseService service = DatabaseService();
  Map<String,dynamic> addressData = {};

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if(widget.data != null && widget.data!['anotherPersonName'] != null && widget.data!['anotherPersonNumber'] != null) {
      String fullName = widget.data!['anotherPersonName'];
      String phoneNumber = widget.data!['anotherPersonNumber'];

      controller.nameController.text = fullName;
      controller.phoneNumberController.text = phoneNumber;

      
    } else {
      if (widget.data != null &&
        widget.data!['identityData'] != null &&
        widget.data!['identityData']['fullName'] != null &&
        widget.data!['identityData']['phoneNumber'] != null) {
      String fullName = widget.data!['identityData']['fullName'];
      String phoneNumber = widget.data!['identityData']['phoneNumber'];
      controller.nameController.text = fullName;
      controller.phoneNumberController.text = phoneNumber;
    }
    }
    
  }

  Future<void> _NavigateandSavePinpoint() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          address: (String address) {
            setState(() {
              addressPinPoint = address;
            });
          },
          pinpoint: (Map<String, dynamic> pinpointData) { 
            setState(() {
              pinpoint = {
                'latitude' : pinpointData['latitude'],
                'longitude' : pinpointData['longitude']};
            });
          },
        ),
      ),
    );
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
          'Detail Alamat',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFB113),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pinpoint',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: const Color(0xFF383434),
                          ),
                        ),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.place_outlined),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Text(
                                    addressPinPoint ??
                                        "Masukkan pinpoint yuk moms \nbiar lokasi lebih akurat!",
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _NavigateandSavePinpoint,
                                  child: Text(
                                    'Ubah',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Color(0xFFFFB113),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        CustomForms(
                          title: 'Label Alamat',
                          hintText: 'Rumah / Kantor / Apartemen / Kos',
                          controller: controller.labelController,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        CustomForms(
                          title: 'Nama Penerima',
                          controller: controller.nameController,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        CustomForms(
                          title: 'No. Handphone',
                          controller: controller.phoneNumberController,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        CustomForms(
                          title: 'Alamat Lengkap',
                          controller: controller.fullAddressController,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        CustomForms(
                          title: 'Catatan (Opsional)',
                          hintText: 'Warna Rumah, Patokan, Pesan Khusus, dll.',
                          controller: controller.noteController,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CustomButton(
                text: 'Simpan',
                onPressed: () {
                  if (_validateForm()) {
                    _saveData();
                  } else {
                    CherryToast.error(
                      title: Text('Isi Form Terlebih Dahulu',
                      style: GoogleFonts.poppins(
                        fontSize: 12
                      )
                      ),
                      animationType: AnimationType.fromTop,
                    ).show(context);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _validateForm() {
    return controller.labelController.text.isNotEmpty &&
        controller.nameController.text.isNotEmpty &&
        controller.phoneNumberController.text.isNotEmpty &&
        controller.fullAddressController.text.isNotEmpty &&
        pinpoint != null;
  }

 void _saveData() async {
  String label = controller.labelController.text;
  String name = controller.nameController.text;
  String phoneNumber = controller.phoneNumberController.text;
  String fullAddress = controller.fullAddressController.text;
  String? notes = controller.noteController.text;

  try {
    addressData = {
      'pinpoint' : pinpoint,
      'label' : label,
      'name' : name,
      'phoneNumber' : phoneNumber,
      'fullAddress' : fullAddress,
      'notes' : notes,
    };

    await service.saveAddress(addressData);

    CherryToast.success(
      title: Text(
        'Berhasil menambahkan alamat',
        style: GoogleFonts.poppins(fontSize: 12),
      ),
      animationType: AnimationType.fromTop,
    ).show(context);

    // Tunggu beberapa saat sebelum menutup halaman
    await Future.delayed(Duration(seconds: 2)); // Ganti dengan durasi yang sesuai

    Navigator.pop(context);
  } catch (e) {
    print(e);
  }
  
  print('Data saved successfully!');
}
}
