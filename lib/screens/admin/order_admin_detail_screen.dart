import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mamanike/widget/button.dart';
import 'package:mamanike/service/database_service.dart';

class OrderAdminDetailScreen extends StatefulWidget {
  final String invId;

  const OrderAdminDetailScreen({ Key? key, required this.invId }) : super(key: key);

  @override
  _OrderAdminDetailScreenState createState() => _OrderAdminDetailScreenState();
}

class _OrderAdminDetailScreenState extends State<OrderAdminDetailScreen> {
  final TextEditingController extendDurationController = TextEditingController();
  final TextEditingController extendUnitController = TextEditingController();
  late Future<Map<String, dynamic>?> _orderDetailsFuture;
  late DatabaseService _databaseService;
  String? selectedUnit;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _orderDetailsFuture = _databaseService.showDetailOrderfromAdmin(widget.invId);
  }

  String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date); // Customize the date format as needed
  }

  Future<void> _confirmOrder() async {
    try {
      await _databaseService.changeStatusToOrderConfirmed(widget.invId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pesanan berhasil dikonfirmasi')),
      );
      setState(() {
        _orderDetailsFuture = _databaseService.showDetailOrderfromAdmin(widget.invId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengonfirmasi pesanan: $e')),
      );
    }
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
          'Detail Pemesanan',
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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _orderDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading order details'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No order details found'));
          } else {
            final orderDetails = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(orderDetails),
                  Divider(thickness: 1,),
                  _orderInformation(orderDetails),
                  Divider(thickness: 1,),
                  _deliveryInformation(orderDetails),
                  Divider(thickness: 1,),
                  _returnInformation(orderDetails),
                  Divider(thickness: 1,),
                  _invoiceInformation(orderDetails),
                  Divider(thickness: 1,),
                  CustomButton(
                    text: 'Konfirmasi Pesanan',
                    onPressed: _confirmOrder,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Padding _invoiceInformation(Map<String, dynamic> orderDetails) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  orderDetails['productData']['productName'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Text(
                'Rp. ${orderDetails['orderData']['productPrice'].toInt()}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Admin',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Text(
                'Rp. ${orderDetails['orderData']['adminPrice'].toInt()}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pengiriman',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Text(
                'Rp. ${orderDetails['orderData']['deliveryPrice'].toInt()}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(thickness: 1,),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Bayar',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Text(
                'Rp. ${orderDetails['orderData']['totalPrice'].toInt()}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding _returnInformation(Map<String, dynamic> orderDetails) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pengembalian',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Jenis Pengembalian',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Text(
                orderDetails['returnAddress']['returnType'] ?? 'Tidak Diketahui',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          if (orderDetails['returnAddress']['returnType'] != 'Antar ke Showroom') ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Alamat Pengembalian',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  '${orderDetails['returnAddress']['returnData']['name']} \n${orderDetails['returnAddress']['returnData']['phoneNumber']} \n${orderDetails['returnAddress']['returnData']['fullAddress']}' ?? 'Dalam Konfirmasi',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Padding _deliveryInformation(Map<String, dynamic> orderDetails) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pengiriman',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Jenis Pengiriman',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Text(
                orderDetails['deliveryAddress']['deliveryType'] ?? 'Tidak Diketahui',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          if (orderDetails['deliveryAddress']['deliveryType'] != 'Ambil di Showroom') ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Alamat Pengiriman',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  '${orderDetails['deliveryAddress']['deliveryData']['name']} \n${orderDetails['deliveryAddress']['deliveryData']['phoneNumber']} \n${orderDetails['deliveryAddress']['deliveryData']['fullAddress']}' ?? 'Dalam Konfirmasi',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Padding _orderInformation(Map<String, dynamic> orderDetails) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pesanan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Status Pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Text(
                orderDetails['status'] ?? 'Tidak Diketahui',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kode Pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Text(
                widget.invId,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tanggal Pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Text(
                formatDate(orderDetails['orderDate']) ?? 'Belum Dibayar',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column _header(Map<String, dynamic> orderDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Berakhir Pada Tanggal',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  formatDate(orderDetails['orderData']['returnDate']),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFFFFB113),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
