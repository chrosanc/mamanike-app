import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/models/CustomForms.dart';
import 'package:mamanike/models/backbutton.dart';
import 'package:mamanike/models/button.dart';
import 'package:intl/intl.dart';
import 'package:mamanike/models/modals/dateModals.dart'; 

class DetailOrder extends StatefulWidget {
  final Map<String, dynamic> data;
  const DetailOrder({ Key? key, required this.data }) : super(key: key);

  @override
  _DetailOrderState createState() => _DetailOrderState();
}

class _DetailOrderState extends State<DetailOrder> {
  String? selectedDuration;
  String? selectedDeliveryType;
  DateTime? selectedDeliveryDate;
  String? selectedReturnType;
  

  final TextEditingController rentDurationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showCancelConfirmationDialog(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 76,
          elevation: 1,
          leadingWidth: 100,
          leading: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 19),
            width: 34,
            height: 34,
            child: const CustomBackbutton(),
          ),
          title: Text(
            'Pesan Barang',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFB113),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Batas Waktu Pemesanan",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600
                      )
                    ),
      
                    Text(
                      "00 : 07 : 00",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600
                      )
                    ),
                ],),
              ),
              productCard(),
              const SizedBox(height: 16),
              rentDurationForm(),
              const SizedBox(height: 16),
              const Divider(color: Colors.grey, thickness: 1),
              const SizedBox(height: 16),
              deliveryDetail(context),
              const SizedBox(height: 16),
              const Divider(color: Colors.grey, thickness: 1),
              const SizedBox(height: 16),
              returnDetail(),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Checkout', 
                onPressed: () {
                  // Handle next button press
                }
              )
            ],
          ),
        ),
      ),
    );
  }

   void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Transaction'),
          content: Text('Are you sure you want to cancel this transaction?'),
          actions: <Widget>[  
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await _cancelTransaction();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

   Future<void> _cancelTransaction() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String uid = user.uid;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Delete the pending order from Firestore
      final CollectionReference ordersCollection = firestore.collection('order').doc(uid).collection('pesanan');
      final QuerySnapshot pendingOrders = await ordersCollection.get();

      for (final doc in pendingOrders.docs) {
        await doc.reference.delete();
      }
    }
  }

  Padding header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 24, 14, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const StepIndicator(isActive: false, label: 'Detail Kontak'),
          const SizedBox(width: 8),
          Container(color: const Color(0xFFFFB113), height: 1, width: 72),
          const SizedBox(width: 8),
          const StepIndicator(isActive: true, label: 'Detail Pesanan'),
        ],
      ),
    );
  }

  Padding returnDetail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Pengembalian',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Jenis Pengembalian',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
          InkWell(
            onTap: () {
              showCustomBottomSheet(
                context: context,
                title: 'Pilih Jenis Pengembalian',
                options: ['Options'],
                onSelected: (String selected) {
                  setState(() {
                    selectedReturnType = selected;
                  });
                },
              );
            },
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedReturnType ?? 'Pilih Jenis Pengembalian',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Center(child: SvgPicture.asset('assets/svg/arrow_down.svg')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding deliveryDetail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Pengiriman',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Jenis Pengiriman',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
          InkWell(
            onTap: () {
              showDeliveryOptionsModal(
                selectedDeliveryType: selectedDeliveryType,
                context: context,
                onDeliveryTypeSelected: (value) {
                  setState(() {
                    selectedDeliveryType = value;
                  });
                },
              );
            },
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDeliveryType ?? 'Pilih Jenis Pengiriman',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Center(child: SvgPicture.asset('assets/svg/arrow_down.svg')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tanggal Pengiriman',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
          InkWell(
            onTap: () {
              showCustomDatePicker(
                context: context,
                title: 'Tanggal Pengiriman',
                onDateSelected: (DateTime date) {
                  setState(() {
                    selectedDeliveryDate = date;
                  });
                },
              );
            },
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDeliveryDate != null
                        ? DateFormat('dd MMM yyyy').format(selectedDeliveryDate!)
                        : 'Pilih Tanggal',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Center(child: SvgPicture.asset('assets/svg/arrow_down.svg')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding rentDurationForm() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durasi Sewa',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Colors.grey,
          ),
        ),
        InkWell(
  onTap: () {
    showRentDurationSheet(
      context: context,
      controller: rentDurationController,
      onDurationChanged: (String value) {
        setState(() {
          selectedDuration = value;
        });
      },
      onUnitChanged: (String value) {
        
      },
    );
  },
  child: InputDecorator(
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          selectedDuration ?? 'Pilih Durasi Sewa',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
        Center(child: SvgPicture.asset('assets/svg/arrow_down.svg')),
      ],
    ),
  ),
),

      ],
    ),
  );
}


  Padding productCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Row(
            children: [
              Image.network(
                widget.data['gambar'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data['nama'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp. ${widget.data['harga']} / bulan\n${widget.data['stok']} Tersedia',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
            (isActive ? '2' : '1'),
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

