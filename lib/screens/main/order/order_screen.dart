import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:mamanike/models/order_card.dart';
import 'package:mamanike/models/search_form.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({ Key? key }) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
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
              "Pesanan Anda",
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: const Color(0xFFFFB113),
                fontWeight: FontWeight.w600
              ),
              ),
              const SizedBox(height: 12,),

              Text("Barang yang sudah Anda Pesan",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.normal
              ),
              )
          ],),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _headerButton(),
              const SizedBox(height: 15,),
              const SearchForm(),
              const SizedBox(height: 15),
              const OrderCard(),
            ],
          ),
        ),
      ),
    );
  }

  Container _headerButton() {
    return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(width: 1,
              color: const Color(0xFFF2EAEA),
              ),
              borderRadius: BorderRadius.circular(12)
            ),
            child: Row(
              children: [
                Expanded(
                  child: 
                  TextButton(
                    onPressed: (){},
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB113),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ) 
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text("Proses",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      ),
                    ),
                  ),
                  ),
                  Expanded(
                    child: 
                  TextButton(
                  onPressed: (){},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text("Riwayat",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFFB113),
                      fontSize: 14
                    ),
                    ),
                  ),
                  )
                  ,)
              ],
            ),
          );
  }
}