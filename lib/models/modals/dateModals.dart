import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/models/CustomForms.dart';
import 'package:mamanike/models/button.dart';
import 'package:mamanike/models/custom_dropdown.dart';
import 'package:mamanike/screens/main/order/address_screen.dart';
import 'package:mamanike/screens/main/order/detailaddress_screen.dart';
import 'package:url_launcher/url_launcher.dart';

void showCustomBottomSheet({
  required BuildContext context,
  required String title,
  required List<String> options,
  required Function(String) onSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.3,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFB113),
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(options[index]),
                        onTap: () {
                          onSelected(options[index]);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Simpan',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}



void showRentDurationSheet({
  required BuildContext context,
  required TextEditingController controller,
  required Function(String) onDurationChanged,
  required Function(String) onUnitChanged,
  required String? selectedUnit,
  required Function() onSave,
}) {
  final duration = ['Minggu', 'Bulan'];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return DraggableScrollableSheet(
            expand: false,
            minChildSize: 0.3,
            initialChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Durasi Sewa',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFB113),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 138,
                            child: CustomForms(
                              title: 'Durasi Sewa',
                              controller: controller,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                onDurationChanged(value);
                              },
                            ),
                          ),
                          CustomDropdown(
                            items: duration,
                            value: selectedUnit?? duration[0],
                            onChanged: (value) {
                              setState(() {
                                selectedUnit = value!;
                                onUnitChanged(
                                    value); // Panggil fungsi onUnitChanged yang diberikan
                              });
                            },
                            controller: controller,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    CustomButton(
                      onPressed: (){
                        onSave();
                      },
                      text: 'Simpan',
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

void showCustomDatePicker({
  required BuildContext context,
  required String title,
  required Function(DateTime) onDateSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.4, // Minimum height of the sheet
          initialChildSize: 0.6, // Initial height of the sheet
          maxChildSize: 0.9, // Maximum height of the sheet
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFB113),
                      ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: CalendarDatePicker(
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        onDateChanged: (date) {
                          onDateSelected(date);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Simpan',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

_launchURL() async {
  final Uri uri = Uri.parse('https://maps.app.goo.gl/13Ly1S5yQ86tPcWZ6');
  if (!await launchUrl(uri)) {
    throw Exception('error opening maps $uri');
  }
}

void showDeliveryOptionsModal(
    {required BuildContext context,
    required String? selectedDeliveryType,
    required Map<String, dynamic> data,
    required Function(String) onDeliveryTypeSelected,
    required Function()? selectAddress}) {
      
  final showroomOption = {
    'label': 'Ambil di Showroom',
    'detail': 'Jam Operasional \n08.30 - 16.00',
  };

  final addressOption = {
    'label': 'Antar ke Alamat',
    'detail': 'Ubah',
  };

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.73,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text(
                        "Pilih Jenis Pengiriman",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFB113),
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RadioListTile(
                            activeColor: const Color(0xFFFFB113),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    showroomOption['label'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (showroomOption['detail'] != null)
                                  Text(
                                    showroomOption['detail'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFFFB113),
                                    ),
                                  ),
                              ],
                            ),
                            value: showroomOption['label'],
                            groupValue: selectedDeliveryType,
                            onChanged: (value) {
                              setState(() {
                                selectedDeliveryType = value as String?;
                                onDeliveryTypeSelected(value as String);
                                
                              });
                            },
                          ),
                          Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "Jl. Raya Beji Karangsalam No.41, Dusun III, Karangsalam Kidul, Kec. Kedungbanteng, Kabupaten Banyumas, Jawa Tengah 53132",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                ),
                              )),
                          const SizedBox(
                            height: 17,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    side: const BorderSide(
                                      color: Color(0xFFFFB113),
                                    )),
                                minimumSize: const Size(double.infinity, 48),
                                backgroundColor: Colors.white,
                                elevation: 0,
                              ),
                              onPressed: _launchURL,
                              child: Text(
                                "Lihat di Google Maps",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFFB113),
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Divider(),
                          RadioListTile(
                            activeColor: const Color(0xFFFFB113),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    addressOption['label'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (addressOption['detail'] != null)
                                  TextButton(
                                    onPressed: selectAddress,
                                    child: Text(
                                      addressOption['detail'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFFFB113),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            value: addressOption['label'],
                            groupValue: selectedDeliveryType,
                            onChanged: (value) {
                              setState(() {
                                selectedDeliveryType = value as String?;
                                onDeliveryTypeSelected(value as String);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                        child: CustomButton(
                      text: 'Simpan',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

void showReturnOptionsModal({
  required BuildContext context,
  required String? selectedReturnType,
  required Function(String) onReturnTypeSelected,
  required Function()? selectAddress,
}) {
  final showroomOption = {
    'label': 'Antar ke Showroom',
    'detail': 'Jam Operasional \n08.30 - 16.00',
  };

  final addressOption = {
    'label': 'Diambil di Alamat',
    'detail': 'Ubah',
  };

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.73,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text(
                        "Pilih Jenis Pengembalian",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFB113),
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: Column(
                        children: [
                          RadioListTile(
                            activeColor: const Color(0xFFFFB113),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    showroomOption['label'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (showroomOption['detail'] != null)
                                  Text(
                                    showroomOption['detail'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFFFB113),
                                    ),
                                  ),
                              ],
                            ),
                            value: showroomOption['label'],
                            groupValue: selectedReturnType,
                            onChanged: (value) {
                              setState(() {
                                selectedReturnType = value as String?;
                                onReturnTypeSelected(value as String);
                              });
                            },
                          ),
                          Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "Jl. Raya Beji Karangsalam No.41, Dusun III, Karangsalam Kidul, Kec. Kedungbanteng, Kabupaten Banyumas, Jawa Tengah 53132",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                ),
                              )),
                          const SizedBox(
                            height: 17,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    side: const BorderSide(
                                      color: Color(0xFFFFB113),
                                    )),
                                minimumSize: const Size(double.infinity, 48),
                                backgroundColor: Colors.white,
                                elevation: 0,
                              ),
                              onPressed: _launchURL,
                              child: Text(
                                "Lihat di Google Maps",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFFB113),
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Divider(),
                          RadioListTile(
                            activeColor: const Color(0xFFFFB113),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    addressOption['label'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (addressOption['detail'] != null)
                                  TextButton(
                                    onPressed: selectAddress,
                                    child: Text(
                                      addressOption['detail'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFFFB113),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            value: addressOption['label'],
                            groupValue: selectedReturnType,
                            onChanged: (value) {
                              setState(() {
                                selectedReturnType = value as String?;
                                onReturnTypeSelected(value as String);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                        child: CustomButton(
                      text: 'Simpan',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
