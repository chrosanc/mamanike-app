import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/models/button.dart';
import 'package:mamanike/screens/main/order/contact_detail.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const DetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {

  @override
  Widget build(BuildContext context) {
    final String categoryName = widget.data['nama_kategori'] as String;
    final String productName = widget.data['nama'] as String;
    final int price = widget.data['harga'] as int;
    final int stock = widget.data['stok'] as int;
    final String imageUrl = widget.data['gambar'] as String;
    final String description = widget.data['deskripsi'] as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _productImage(context, imageUrl),
                      _header(productName, price, stock),
                      Text(categoryName),
                      const Divider(color: Colors.grey, thickness: 1,),
                      const SizedBox(height: 24,),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Deskripsi Produk",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12,),
                            Text(description,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomButton(
                text: 'Pesan Sekarang',
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ContactDetail(data: widget.data)));
                }
              ),
            ],
          ),
          _backButton(context),
        ],
      ),
    );
  }

  


  Positioned _backButton(BuildContext context) {
    return Positioned(
      top: 64,
      left: 24,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB113),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/svg/back.svg',
              color: Colors.white,
              width: 24,
              height: 24,
            ),
          ),
        ),
      ),
    );
  }

  Container _header(String productName, int price, int stock) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  productName,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Center(child: SvgPicture.asset('assets/svg/carticon.svg', width: 32,)),
              ),
            ],
          ),
          const SizedBox(height: 16,),
          RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              text: "Rp. $price",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFB113),
              ),
              children: [
                TextSpan(
                  text: ' / bulan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF383434),
                  ),
                )
              ],
            ),
          ),
          Text(
            "$stock Tersedia",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Container _productImage(BuildContext context, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      width: MediaQuery.of(context).size.width,
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: Image.network(imageUrl, fit: BoxFit.contain),
      ),
    );
  }
}
