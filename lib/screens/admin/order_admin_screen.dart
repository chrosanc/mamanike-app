import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/widget/button.dart';
import 'package:mamanike/widget/order_card.dart';
import 'package:mamanike/screens/admin/order_admin_detail_screen.dart';
import 'package:mamanike/service/database_service.dart';

class OrderAdminScreen extends StatefulWidget {
  const OrderAdminScreen({ Key? key }) : super(key: key);

  @override
  _OrderAdminScreenState createState() => _OrderAdminScreenState();
}

class _OrderAdminScreenState extends State<OrderAdminScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _ordersFuture = _databaseService.getAllOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = _databaseService.getAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pesanan",
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: const Color(0xFFFFB113),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading orders'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column (
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/noorders.jpg', width: 300,),
                      Text('Belum ada pesanan nih, Pesan dulu yuk Moms', style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      )
                    ],
                  ),
                );
              } else {
                final orders = snapshot.data!;
                return ListView(
                  children: [
                    ...orders.map((order) => OrderCard(
                      data: order,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => OrderAdminDetailScreen(invId: order['invId'])
                        ));
                      },
                    )).toList(),
                    const SizedBox(height: 20),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
