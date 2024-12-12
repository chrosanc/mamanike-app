import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/screens/main/product/detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic>? data;

  const ProductCard({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data == null || data!['gambar'] == null || data!['nama'] == null || data!['stok'] == null || data!['harga'] == null) {
      return SizedBox.shrink(); // Return an empty widget if any data is null
    }

    final String imageUrl = data!['gambar'] as String;
    final String name = data!['nama'] as String;
    final int stock = data!['stok'] as int;
    final int price = data!['harga'] as int;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(data: data!)));
      },
      child: AspectRatio(
        aspectRatio: 148 / 205,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          shadowColor: Colors.black,
          elevation: 5,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 12),
                Text(
                  '$stock Tersedia',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 12),
                Text(
                  'Rp$price /bulan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
