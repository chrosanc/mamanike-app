import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const RecommendationCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: data['gambar'] != null
                  ? Image.network(data['gambar'], fit: BoxFit.cover)
                  : Container(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              data['nama'],
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${data['stok']} Tersedia',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rp${data['harga']}/bulan',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
