import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic>? data;

  const OrderCard({ Key? key, this.data }) : super(key: key);


  @override
  Widget build(BuildContext context) {
      if (data == null || data!['status'] == null || data!['gambar'] == null || data!['nama_barang'] == null || data!['jangka_waktu'] == null ||
      data!['harga_total'] == null || data!['tanggal_berakhir'] == null) {
        return SizedBox.shrink();
      }

      final String status = data!['status'] as String;
      final String imageUrl = data!['gambar'] as String;
      final String name = data!['nama_barang'] as String;
      final String rentTime = data!['jangka_waktu'] as String;
      final int price = data!['harga_total'] as int;
      final String datePeriod = data!['tanggal_berakhir'] as String;

      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200), // Set a max height for the card
        child: Card(
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
                          const SizedBox(width: 5,),
                          Text(
                            status,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.normal,
                              color: const Color(0xFFFACC15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        rentTime,
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
                      const SizedBox(height: 30,),
                      Row(
                        children: [
                          Text(
                            "Detail Pesanan",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                          const SizedBox(width: 12,),
                          SvgPicture.asset('assets/svg/arrow_right.svg', color: const Color(0xFF9E9E9E),),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      color: Colors.grey,
                      width: 100,
                      height: 100,
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 10,),
                    Text(
                      "Berakhir Pada: ",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                    Text(
                      datePeriod,
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