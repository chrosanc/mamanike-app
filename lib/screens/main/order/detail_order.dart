import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:info_popup/info_popup.dart';
import 'package:mamanike/widget/CustomAlert.dart';
import 'package:mamanike/widget/button.dart';
import 'package:intl/intl.dart';
import 'package:mamanike/widget/modals/dateModals.dart';
import 'package:mamanike/screens/main/order/address_screen.dart';
import 'package:mamanike/screens/main/order/checkout_screen.dart';
import 'package:mamanike/service/database_service.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'dart:math';
import 'package:http/http.dart' as http;


class DetailOrder extends StatefulWidget {
  final Map<String, dynamic> data;
  final String invId;
  const DetailOrder({Key? key, required this.data, required this.invId})
      : super(key: key);

  @override
  _DetailOrderState createState() => _DetailOrderState();
}

class _DetailOrderState extends State<DetailOrder> {
  final DatabaseService _databaseService =
      DatabaseService(); // Tambahkan instance DatabaseService=
  String? selectedDuration = 'Bulan';
  String? selectedDeliveryType;
  DateTime? selectedDeliveryDate;
  String? selectedReturnType;
  Function(String)? onDeliveryTypeSelected;
  Map<String, dynamic>? deliveryData;
  Map<String, dynamic>? returnData;

  String? updatedProductPrice;
  String? updatedDeliveryPrice = '0';
  String? updatedAdminPrice = '0';
  String? totalPrice = '0';

  bool onPriceExpand = false;
  double arrowRotationAngle = 0.0;

  final TextEditingController rentDurationController = TextEditingController();
  late final MidtransSDK? _midtrans;

  @override
  void initState() {
    updateRentPrice();
    updateDeliveryPrice();
    updateAdminPrice();
    rentDurationController.text = '1';
    _initSDK();
    super.initState();
  }
  void _initSDK() async {
    _midtrans = await MidtransSDK.init(
      config: MidtransConfig(
        clientKey: 'SB-Mid-client-LxVoMud3iZV55Fdh',
        merchantBaseUrl: "",
        colorTheme: ColorTheme(
          colorPrimary: const Color(0xFFFFB113),
          colorPrimaryDark: Colors.blue,
          colorSecondary: Colors.blue,
        ),
      ),
    );
    _midtrans?.setUIKitCustomSetting(
      skipCustomerDetailsPages: true,
    );
    _midtrans!.setTransactionFinishedCallback((result) {
      print('Transaction Completed');
    });
  }

  

  void _checkData() async {
    if(deliveryData != null && returnData != null && selectedDuration != null && selectedDeliveryType != null && selectedDeliveryDate != null && selectedReturnType != null) {
      Map<String, dynamic> deliveryAddress;
      Map<String, dynamic> returnAddress;
      Map<String, dynamic> orderData;

      DateTime returnDate = calculateReturnDate(selectedDeliveryDate!, int.parse(rentDurationController.text), selectedDuration!);
      
      if(deliveryData != null && selectedDeliveryType == 'Antar ke Alamat'){
        deliveryAddress = {
          'deliveryType' : selectedDeliveryType,
          'deliveryData' : deliveryData
        };
      } else {
        deliveryAddress = {
          'deliveryType' : selectedDeliveryType
        };
      }
      if(returnData != null  && selectedReturnType == 'Diambil di Alamat') {
        returnAddress = {
          'returnType' : selectedReturnType,
          'returnData' : returnData
        };
      } else {
        returnAddress = {
          'returnType' : selectedReturnType
        };
      }
      orderData = {
        'productName' : widget.data['nama'],
        'deliveryDate' : selectedDeliveryDate,
        'returnDate' : returnDate,
        'rentDuration' : double.parse(rentDurationController.text),
        'rentDurationType' :selectedDuration!,
        'productPrice' : double.parse(updatedProductPrice ?? widget.data['harga'].toString()),
        'deliveryPrice' : double.parse(updatedDeliveryPrice!),
        'adminPrice' : double.parse(updatedAdminPrice!),
        'totalPrice' : double.parse(totalPrice!)
      };
      await DatabaseService().orderItem(deliveryAddress, returnAddress, orderData, widget.invId);
      print(returnAddress);
      _submitOrder(context);


    } else {
      CherryToast.info(
        title: Text('Silahkan isi detail order terlebih dahulu',
        style: GoogleFonts.poppins(
          fontSize: 12
        ),),
        animationType: AnimationType.fromTop,
      ).show(context);
    }
  }

  DateTime calculateReturnDate(DateTime startDate, int duration, String durationType) {
    if (durationType == 'Bulan') {
      return startDate.add(Duration(days: duration * 30));
    } else if (durationType == 'Minggu') {
      return startDate.add(Duration(days: duration * 7));
    } else {
      return startDate.add(Duration(days: duration * 30));
    }
  }


void _submitOrder(BuildContext context) async {
  const String serverKey = 'SB-Mid-server-SfXYioeZEwQ2exQL-5yqSMKl';
  final String basicAuth = 'Basic ' + base64Encode(utf8.encode(serverKey + ':'));

  // Create order payload
  Map<String, dynamic> orderDetail = {
    "transaction_details": {
      "order_id": widget.invId,
      "gross_amount": double.parse(totalPrice!),
    },
    "credit_card": {
      "secure": true,
    },
    "customer_details": {
      "first_name": widget.data['identityData']['fullName'],
      "last_name" : "",
      "email": widget.data['email'],
      "phone": widget.data['phoneNumber'],
    },
  };

  try {
    final response = await http.post(
      Uri.parse('https://app.sandbox.midtrans.com/snap/v1/transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': basicAuth,
      },
      body: jsonEncode(orderDetail),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final String paymentUrl = responseData['redirect_url'];

      // Navigate to WebView screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(url: paymentUrl, invId: widget.invId),
        ),
      );
    }
    
    else {
      print('Failed to create transaction: ${response.body}');
    }
  } catch (error) {
    print('Error: $error');
  }
}



void updateAdminPrice() {
  if (updatedProductPrice != null) {
    double productPrice;

    if(updatedProductPrice!= null) {
     productPrice = double.parse(updatedProductPrice!);
    } else {
    productPrice = (widget.data['harga'] as num).toDouble();    

    }
    
    double adminPrice = 0.01 * productPrice; // Menghitung 10% dari productPrice
    setState(() {
      updatedAdminPrice = adminPrice.toStringAsFixed(0);
    });
  }
}

  void updateDeliveryPrice() {
    int basePrice = 0; // Harga pengiriman dasar
    int distanceCostPerKm = 7000; // Biaya per kilometer
    double officeLatitude = -7.4019173;
    double officeLongitude = 109.2161779;

    if (deliveryData != null &&
        deliveryData!['pinpoint'] != null &&
        selectedDeliveryType == 'Antar ke Alamat') {
      double deliveryLatitude = deliveryData!['pinpoint']['latitude'];
      double deliveryLongitude = deliveryData!['pinpoint']['longitude'];

      // Hitung jarak antara kantor dan alamat pengiriman
      double distanceInKm = calculateDistanceInKm(
          officeLatitude, officeLongitude, deliveryLatitude, deliveryLongitude);

      // Hitung biaya tambahan berdasarkan jarak
      int additionalCost = (distanceInKm > 5)
          ? ((distanceInKm - 5) * distanceCostPerKm).round()
          : 0;
      int deliveryPrice = basePrice + additionalCost;
      int roundedDeliveryPrice = roundUpToNearest(deliveryPrice, 100);

      setState(() {
        updatedDeliveryPrice = roundedDeliveryPrice.toString();
      });
    } else {
      int deliveryPrice = 0;
      setState(() {
        updatedDeliveryPrice = deliveryPrice.toString();
      });
    }
  }

  int roundUpToNearest(int number, int nearest) {
    return ((number + nearest - 1) ~/ nearest) * nearest;
  }

// Fungsi untuk menghitung jarak dalam kilometer antara dua titik berdasarkan latitude dan longitude
  double calculateDistanceInKm(
      double lat1, double lon1, double lat2, double lon2) {
    const double radiusEarth = 6371.0; // Radius bumi dalam kilometer

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = radiusEarth * c;
    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  void updateRentPrice() {
    int price = 0;
    int rentDuration = 0;
    if (selectedDuration != null &&
        selectedDuration == 'Bulan' &&
        rentDurationController.text.isNotEmpty) {
      price = widget.data['harga'] as int;
      rentDuration = int.parse(rentDurationController.text);
      int totalPrice = price * rentDuration;
      setState(() {
        updatedProductPrice = totalPrice.toString();
      });
    }
    if (selectedDuration != null &&
        selectedDuration == 'Minggu' &&
        rentDurationController.text.isNotEmpty) {
      price = widget.data['harga'] as int;
      rentDuration = int.parse(rentDurationController.text);
      double totalPrice = (price / 4) * rentDuration;
      setState(() {
        updatedProductPrice = totalPrice.toStringAsFixed(0);
      });
    }
  }

  @override
  Widget build(BuildContext context ) {
    double productPrice;
    if (updatedProductPrice!= null){
     productPrice = double.tryParse(updatedProductPrice!)!;
    } else {
    productPrice = widget.data['harga'].toDouble();
    }
    double deliveryPrice = double.tryParse(updatedDeliveryPrice!)!;
    double adminPrice= double.tryParse(updatedAdminPrice!)!;
    double totalPayment = productPrice + deliveryPrice + adminPrice;
    totalPrice = totalPayment.toStringAsFixed(0);
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final bool shouldPop =
            await _showCancelConfirmationDialog(context) ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
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
            onPressed: () {
              _showCancelConfirmationDialog(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Batas Waktu Pemesanan",
                            style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        Text("00 : 07 : 00",
                            style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  productCard(),
                  const SizedBox(height: 16),
                  rentDurationForm(context),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey, thickness: 1),
                  const SizedBox(height: 16),
                  deliveryDetail(context),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey, thickness: 1),
                  const SizedBox(height: 16),
                  returnDetail(context),
                  const SizedBox(height: 36),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        AnimatedOpacity(
                          opacity: onPriceExpand ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: onPriceExpand
                              ? Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${widget.data['nama']} \n${rentDurationController.text} ${selectedDuration}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          'Rp. ${updatedProductPrice ?? widget.data['harga']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Pengiriman',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          'Rp. $updatedDeliveryPrice' ??
                                              'Rp. 0',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Admin',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          'Rp. $updatedAdminPrice' ?? 'Rp.0',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                  ],
                                )
                              : SizedBox
                                  .shrink(), // Hide using SizedBox.shrink() when not expanded
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              // Toggle the expand state and rotation angle
                              onPriceExpand = !onPriceExpand;
                              arrowRotationAngle = onPriceExpand ? -180 : 0;
                            });
                          },
                          child: AnimatedSlide(
                            offset:
                                onPriceExpand ? Offset(0, 0) : Offset(0, -0.2),
                            duration: const Duration(milliseconds: 300),
                            child: Row(
                              children: [
                                // Animated rotation for the arrow
                                AnimatedRotation(
                                  turns: arrowRotationAngle / 360,
                                  duration: const Duration(milliseconds: 300),
                                  child: SvgPicture.asset(
                                    'assets/svg/arrow_down.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                                const SizedBox(
                                  width: 18,
                                ),

                                Expanded(child: Text('Total Bayar',
                                style: GoogleFonts.poppins(
                                  fontSize: 12
                                ),)),
                                Text('Rp. $totalPrice'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomButton(
                    text: 'Checkout',
                    onPressed: () {
                      _checkData();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _showCancelConfirmationDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
              title: 'Batalkan Transaksi',
              content: 'Apakah Anda ingin membatalkan Pemesanan?',
              confirmText: 'YA',
              cancelText: 'TIDAK',
              onConfirm: () async {
                await _cancelTransaction();
                Navigator.pop(context);
                Navigator.of(context).pop();
              },
              onCancel: () {
                Navigator.of(context).pop();
              });
        });
  }

  Future<void> _cancelTransaction() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String uid = user.uid;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Dapatkan dokumen pesanan pengguna yang sedang berlangsung
      final CollectionReference ordersCollection =
          firestore.collection('order').doc(uid).collection('pesanan');
      final QuerySnapshot pendingOrders = await ordersCollection.get();

      for (final doc in pendingOrders.docs) {
        final orderData = doc.data() as Map<String, dynamic>;
        final String categoryName = orderData['productData']['categoryName'];

        // Panggil metode cancelReserve dari DatabaseService
        await _databaseService.cancelReserve(
            widget.invId, categoryName, widget.data['nama']);
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

  Padding returnDetail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Detail Pengembalian',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  InfoPopupWidget(
                    child: Icon(
                      IconlyBold.info_circle,
                      size: 18,
                    ),
                    contentTitle:
                        'Jenis Pengambilan dapat diatur lagi ketika sudah selesai memesan',
                    contentTheme: InfoPopupContentTheme(
                      infoTextStyle: GoogleFonts.poppins(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
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
                  showReturnOptionsModal(
                    context: context,
                    selectedReturnType: selectedReturnType,
                    onReturnTypeSelected: (value) {
                      setState(() {
                        selectedReturnType = value;
                      });
                    },
                    selectAddress: () async {
                      final result = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddressScreen(data: widget.data),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          returnData = result;
                        });
                      }
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
                      if (returnData != null &&
                          selectedReturnType == 'Diambil di Alamat') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            '$selectedReturnType \n${returnData!['name']} \n${returnData!['phoneNumber']} \n${returnData!['fullAddress']}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          selectedReturnType ?? 'Pilih Jenis Pengembalian',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                      Center(
                          child: SvgPicture.asset('assets/svg/arrow_down.svg')),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Padding deliveryDetail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
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
                    context: context,
                    selectedDeliveryType: selectedDeliveryType,
                    data: widget.data,
                    onDeliveryTypeSelected: (value) {
                      setState(() {
                        selectedDeliveryType = value;
                        updateDeliveryPrice();
                        updateAdminPrice();
                      });
                    },
                    selectAddress: () async {
                      final result = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddressScreen(data: widget.data),
                        ),
                      );

                      // Check if the result is not null and is a Map<String, dynamic>
                      if (result != null) {
                        setState(() {
                          deliveryData = result;
                          updateDeliveryPrice();
                          updateAdminPrice();

                        });
                      }
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
                      if (deliveryData != null &&
                          selectedDeliveryType == 'Antar ke Alamat') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            '$selectedDeliveryType \n${deliveryData!['name']} \n${deliveryData!['phoneNumber']} \n${deliveryData!['fullAddress']}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          selectedDeliveryType ?? 'Pilih Jenis Pengiriman',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                      Center(
                          child: SvgPicture.asset('assets/svg/arrow_down.svg')),
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
                            ? DateFormat('dd MMM yyyy')
                                .format(selectedDeliveryDate!)
                            : 'Pilih Tanggal',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Center(
                          child: SvgPicture.asset('assets/svg/arrow_down.svg')),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Padding rentDurationForm(BuildContext context) {
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
                selectedUnit: selectedDuration,
                context: context,
                onSave: (){
                  Navigator.of(context).pop();
                },
                controller: rentDurationController,
                onDurationChanged: (String value) {
                  setState(() {
                    rentDurationController.text = value;
                    if (rentDurationController.text.isNotEmpty) {
                      updateRentPrice();
                      updateAdminPrice();
                    }
                  });
                },
                onUnitChanged: (String value) {
                  setState(() {
                    selectedDuration = value;
                    if (rentDurationController.text.isNotEmpty) {
                      updateRentPrice();
                    }
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
                  Expanded(
                    child: Text(
                      rentDurationController.text.isEmpty
                          ? 'Pilih Durasi Sewa'
                          : '${rentDurationController.text} ${selectedDuration}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
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
          backgroundColor:
              isActive ? const Color(0xFFFFB113) : Colors.grey[300],
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
