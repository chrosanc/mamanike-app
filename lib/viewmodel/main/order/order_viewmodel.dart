import 'dart:convert';
import 'dart:math';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mamanike/models/Order.dart';
import 'package:mamanike/models/Product.dart';
import 'package:mamanike/screens/main/order/checkout_screen.dart';
import 'package:mamanike/screens/main/order/detail_order.dart';
import 'package:mamanike/service/database_service.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:http/http.dart' as http;

class OrderViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // =====================================
  // Product Data
  // =====================================
  Map<String,dynamic> selectedProductData  = {};
  // =====================================
  // Contact Data
  // =====================================
  bool orderForAnotherPerson = false;
  bool fullNameFilled = false;
  bool phoneNumberFilled = false;
  Map<String, dynamic> contactFormData = {};
  XFile? image;

  final TextEditingController anotherPersonNameController = TextEditingController();
  final TextEditingController anotherPersonPhoneNumberController = TextEditingController();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController identityNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();


  // =====================================
  // Address Data
  // =====================================
  Function(String)? onDeliveryTypeSelected;

  Map<String,dynamic> deliveryData = {};
  Map<String,dynamic> returnData = {};
  String? selectedDeliveryType;
  Map<String,dynamic> _selectedDeliveryAddress = {};
  Map<String,dynamic> get selectedDeliveryAddress => _selectedDeliveryAddress;
  DateTime? selectedDeliveryDate;
  String? selectedReturnType;
  String? selectedReturnAddress;

  // =====================================
  // Order Data
  // =====================================
  String? selectedDuration = 'Bulan';

  Map<String,dynamic> orderData = {};

  String? productPrice;
  String? updatedProductPrice = '0';
  String? updatedDeliveryPrice = '0';
  String? updatedAdminPrice = '0';
  String? _totalPrice = '0';
  String? get totalPrice => _totalPrice;
  String invId = '';

  bool onPriceExpand = false;
  double arrowRotationAngle = 0.0;

  final TextEditingController rentDurationController = TextEditingController(text: '1');
  late final MidtransSDK? _midtrans;

  Map<String, dynamic>? data;

  // =====================================
  // Contact Function
  // =====================================

  Future<void> saveContactData(Map<String, dynamic> formData) async {
    contactFormData = formData;
    notifyListeners();
  }

  Future<void> pickIdentityImage() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? _image = await _picker.pickImage(source: ImageSource.camera);
      image = _image;
      notifyListeners();

    } catch (e) {
      print('Error picking image: $e');
    }
  }

  String _generateRandomString({int length = 6}) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }


  bool validateContactFields() {
    if (orderForAnotherPerson) {
      return contactFormData.isNotEmpty &&
          anotherPersonPhoneNumberController.text.isNotEmpty &&
          anotherPersonNameController.text.isNotEmpty;
    } else {
      return contactFormData.isNotEmpty;
    }
  }

  Future<bool> checkProductStock() async {
    int stock = await _databaseService.checkProductStock(
        selectedProductData['nama'],
        selectedProductData['nama_kategori']
    );

    // Perbandingan harus dengan angka, bukan string
    return stock > 0;
  }

  Future<void> sendContactData(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    invId = 'Inv - ${_generateRandomString()}';

    if(orderForAnotherPerson) {
      contactFormData['anotherPerson'] = {
        'anotherPersonName' : anotherPersonNameController.text,
        'anotherPersonPhoneNumber' : anotherPersonPhoneNumberController.text
      };
    } else {
      contactFormData.remove('anotherPerson');
    }

    ContactItem contactData = ContactItem(
        email: contactFormData['email'],
        fullName: contactFormData['fullName'],
        phoneNumber: contactFormData['phoneNumber'],
        identityAddress: contactFormData['identityAddress'],
        identityNumber: contactFormData['identityNumber'],
        identityImage: contactFormData['identityImage'],
        anotherPerson: contactFormData['anotherPerson']
    );

    ProductItem productData = ProductItem(
        category: selectedProductData['nama_kategori'],
        description: selectedProductData['deskripsi'],
        productImage: selectedProductData['gambar'],
        productPrice: selectedProductData['harga'],
        productName: selectedProductData['nama'],
        stock: selectedProductData['stok']);


    try {
      bool isAvailable = await checkProductStock();
      if(isAvailable) {
        await _databaseService.reserveItem(
          invId,
          productData,
          contactData,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DetailOrder(),
          ),
        );
      } else {
        CherryToast.error(title: Text('Stok Produk Kosong'),).show(context);
      }

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
        _isLoading = false;
        notifyListeners();
    }
  }

  Future<void> cancelTransaction() async {
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

        // Panggil metode cancelReserve dari DatabaseService
        await _databaseService.cancelReserve(
            invId, selectedProductData['nama_kategori'], selectedProductData['nama']);
      }
    }
  }

  // =====================================
  // Address Modal Function
  // =====================================
  Future<String> showAddresses() async {
    return selectedDeliveryAddress.toString() ?? "Alamat belum dipilih";
  }

  void saveDelivery(Map<String,dynamic> address) async {
    _selectedDeliveryAddress = address;
    notifyListeners();
  }


  // =====================================
  // Order Function
  // =====================================

  //DeliveryModal Function
  Future<void> saveDeliveryAddressData() async {
    deliveryData = {
      'deliveryData' : _selectedDeliveryAddress,
      'deliveryType' : selectedDeliveryType,
    };
    print(deliveryData);
  }

  //RentDurationModal Function
  Future<void> saveRentDuration(String selectedUnit, String rentDuration) async {
    rentDurationController.text = rentDuration;
    selectedDuration = selectedUnit;
    notifyListeners();
  }

  Future<double> countTotalPrice() async {
    double productPrice = double.tryParse(selectedProductData['harga']?.toString() ?? '0') ?? 0.0;
    double updatedPrice = double.tryParse(updatedProductPrice?.isNotEmpty == true ? updatedProductPrice! : productPrice.toString()) ?? productPrice;
    double deliveryPrice = double.tryParse(updatedDeliveryPrice ?? '0') ?? 0.0;
    double adminPrice = double.tryParse(updatedAdminPrice ?? '0') ?? 0.0;

    return updatedPrice + deliveryPrice + adminPrice;
  }

  Future<void> updateProductPrice() async {
    double productPrice = double.tryParse(selectedProductData['harga'].toString()) ?? 0.0;
    double updatedPrice = double.tryParse(updatedProductPrice ?? '') ?? productPrice;
    double deliveryPrice = double.tryParse(updatedDeliveryPrice ?? '') ?? 0.0;
    double adminPrice = double.tryParse(updatedAdminPrice ?? '') ?? 0.0;

    double totalPayment = updatedPrice + deliveryPrice + adminPrice;

    _totalPrice = totalPayment.toStringAsFixed(0);
    notifyListeners();
  }

//
//   void initSDK() async {
//     _midtrans = await MidtransSDK.init(
//       config: MidtransConfig(
//         clientKey: 'SB-Mid-client-LxVoMud3iZV55Fdh',
//         merchantBaseUrl: "",
//         colorTheme: ColorTheme(
//           colorPrimary: const Color(0xFFFFB113),
//           colorPrimaryDark: Colors.blue,
//           colorSecondary: Colors.blue,
//         ),
//       ),
//     );
//     _midtrans?.setUIKitCustomSetting(
//       skipCustomerDetailsPages: true,
//     );
//     _midtrans!.setTransactionFinishedCallback((result) {
//       print('Transaction Completed');
//     });
//   }
//
  void checkData(BuildContext context) async {
    if (deliveryData != null &&
        returnData != null &&
        selectedDuration != null &&
        selectedDeliveryType != null &&
        selectedDeliveryDate != null &&
        selectedReturnType != null) {
      Map<String, dynamic> deliveryAddress;
      Map<String, dynamic> returnAddress;
      Map<String, dynamic> orderData;

      DateTime returnDate = calculateReturnDate(selectedDeliveryDate!,
          int.parse(rentDurationController.text), selectedDuration!);

      if (deliveryData != null && selectedDeliveryType == 'Antar ke Alamat') {
        deliveryAddress = {
          'deliveryType': selectedDeliveryType,
          'deliveryData': deliveryData
        };
      } else {
        deliveryAddress = {'deliveryType': selectedDeliveryType};
      }
      if (returnData != null && selectedReturnType == 'Diambil di Alamat') {
        returnAddress = {
          'returnType': selectedReturnType,
          'returnData': returnData
        };
      } else {
        returnAddress = {'returnType': selectedReturnType};
      }
      orderData = {
        'productName': selectedProductData['nama'],
        'deliveryDate': selectedDeliveryDate,
        'returnDate': returnDate,
        'rentDuration': double.parse(rentDurationController.text),
        'rentDurationType': selectedDuration!,
        'productPrice':
            double.parse(updatedProductPrice ?? selectedProductData['harga'].toString()),
        'deliveryPrice': double.parse(updatedDeliveryPrice!),
        'adminPrice': double.parse(updatedAdminPrice!),
        'totalPrice': double.parse(totalPrice!)
      };
      await DatabaseService()
          .orderItem(deliveryAddress, returnAddress, orderData, invId);
      print(returnAddress);
      submitOrder(context);
    } else {
      CherryToast.info(
        title: Text(
          'Silahkan isi detail order terlebih dahulu',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        animationType: AnimationType.fromTop,
      ).show(context);
    }
  }

  DateTime calculateReturnDate(
      DateTime startDate, int duration, String durationType) {
    if (durationType == 'Bulan') {
      return startDate.add(Duration(days: duration * 30));
    } else if (durationType == 'Minggu') {
      return startDate.add(Duration(days: duration * 7));
    } else {
      return startDate.add(Duration(days: duration * 30));
    }
  }

  void submitOrder(BuildContext context) async {
    const String serverKey = 'SB-Mid-server-SfXYioeZEwQ2exQL-5yqSMKl';
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode(serverKey + ':'));

    // Create order payload
    Map<String, dynamic> orderDetail = {
      "transaction_details": {
        "order_id": invId,
        "gross_amount": double.parse(totalPrice!),
      },
      "credit_card": {
        "secure": true,
      },
      "customer_details": {
        "first_name": contactFormData['fullName'],
        "last_name": "",
        "email": contactFormData['email'],
        "phone": contactFormData['phoneNumber'],
      },
    };

    try {
      final url =
          Uri.https('https://app.sandbox.midtrans.com/snap/v1/transactions');
      final response = await http.post(
        url,
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
            builder: (context) => CheckoutScreen(url: paymentUrl, invId: invId),
          ),
        );
      } else {
        print('Failed to create transaction: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }


  void updateAdminPrice() {
    if (updatedProductPrice != null) {
      double productPrice;

      if (updatedProductPrice != null) {
        productPrice = double.parse(updatedProductPrice!);
      } else {
        productPrice = (selectedProductData['harga'] as num).toDouble();
      }

      double adminPrice = 0.01 * productPrice; // Menghitung 10% dari productPrice
      updatedAdminPrice = adminPrice.toStringAsFixed(0);
      notifyListeners();
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

      updatedDeliveryPrice = roundedDeliveryPrice.toString();
      notifyListeners();
    } else {
      int deliveryPrice = 0;
      updatedDeliveryPrice = deliveryPrice.toString();
      notifyListeners();
    }
  }

  int roundUpToNearest(int number, int nearest) {
    return ((number + nearest - 1) ~/ nearest) * nearest;
  }

  double calculateDistanceInKm(
      double lat1, double lon1, double lat2, double lon2) {
    const double radiusEarth = 6371.0;

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

  Future<void> updateRentPrice() async {
    int price = selectedProductData['harga'] as int;
    int rentDuration = int.parse(rentDurationController.text);
    if (selectedDuration != null &&
        selectedDuration == 'Bulan' &&
        rentDurationController.text.isNotEmpty) {
      int totalPrice = price * rentDuration;
      updatedProductPrice = totalPrice.toString();
      WidgetsBinding.instance.addPostFrameCallback((_){
        notifyListeners();
      });
    }
    if (selectedDuration != null &&
        selectedDuration == 'Minggu' &&
        rentDurationController.text.isNotEmpty) {
      double totalPrice = (price / 4) * rentDuration;
      updatedProductPrice = totalPrice.toStringAsFixed(0);
      WidgetsBinding.instance.addPostFrameCallback((_){
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    anotherPersonNameController.dispose();
    anotherPersonPhoneNumberController.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    identityNumberController.dispose();
    addressController.dispose();
    rentDurationController.dispose();
    image = null;

    super.dispose();
  }
}
