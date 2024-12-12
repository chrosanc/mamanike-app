import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mamanike/screens/main/order/orderproduct_detail.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic>? data;
  final VoidCallback onTap;

  const OrderCard({Key? key, this.data, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if data is null or any required nested field is null
    if (data == null ||
        data!['status'] == null ||
        data!['productData'] == null ||
        data!['productData']['productImage'] == null ||
        data!['productData']['productName'] == null ||
        data!['orderData'] == null ||
        data!['orderData']['rentDuration'] == null ||
        data!['orderData']['rentDurationType'] == null ||
        data!['orderData']['totalPrice'] == null ||
        data!['orderData']['returnDate'] == null) {
      return SizedBox.shrink();
    }

    final String invId = data!['invId'];
    final String status = data!['status'] as String;
    final String imageUrl = data!['productData']['productImage'] as String;
    final String name = data!['productData']['productName'] as String;
    final int rentDuration = (data!['orderData']['rentDuration'] as num).toInt();
    final String rentDurationType = data!['orderData']['rentDurationType'] as String;
    final int price = (data!['orderData']['totalPrice'] as num).toInt();
    final DateTime deliveryDate = (data!['orderData']['returnDate'] as Timestamp).toDate();

    // Format the date
    final DateFormat dateFormat = DateFormat('d MMMM yyyy', 'id_ID');
    final String formattedDate = dateFormat.format(deliveryDate);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200), // Set a max height for the card
      child: Card(
        elevation: 7,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 21),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFACC15),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          status,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.normal,
                            color: const Color(0xFFFACC15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$rentDuration $rentDurationType',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "Rp. $price",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xFFFFB113),
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: onTap,
                      child: Row(
                        children: [
                          Text(
                            "Detail Pesanan",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SvgPicture.asset(
                            'assets/svg/arrow_right.svg',
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 100,
                    height: 100,
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Berakhir Pada: ",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: const Color(0xFFFFB113),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
