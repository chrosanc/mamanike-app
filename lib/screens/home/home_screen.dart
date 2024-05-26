import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/models/product_card.dart'; // Import the recommendation card widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 69,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        title: _headerTitle(),
        actions: [
          SvgPicture.asset('assets/svg/searchicon.svg'),
          const SizedBox(width: 20),
          SvgPicture.asset('assets/svg/carticon.svg'),
          const SizedBox(width: 25),
        ],
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          width: 40,
          height: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/avatar.png',
              width: 40,
              height: 40,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            _background(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _categoryHeader(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rekomendasi Barang",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('produk').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return CherryToast.error(
                              title: Text('Error: ${snapshot.error}'),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return CherryToast.error(
                              title: Text('Tidak ada Data'),
                            );
                          }

                          return SizedBox(
                            height: 200, // Height of each item card
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                                return RecommendationCard(data: data); // Use the RecommendationCard widget
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding _categoryHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 90, 24, 12),
      child: AspectRatio(
        aspectRatio: 312 / 150,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _categoryItem('assets/svg/stroller.svg', 'Stroller'),
                  _categoryItem('assets/svg/freezer.svg', 'Freezer'),
                  _categoryItem('assets/svg/carseat.svg', 'Carseat'),
                  _categoryItem('assets/svg/breastpump.svg', 'Breastpump'),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(
                color: Colors.grey,
                height: 1,
                thickness: 1,
                indent: 13,
                endIndent: 13,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lihat Detail Kategori',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    SvgPicture.asset('assets/svg/arrow_right.svg', width: 15, height: 15, fit: BoxFit.contain)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Column _categoryItem(String assetPath, String label) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            color: Colors.white,
          ),
          child: Center(
            child: SvgPicture.asset(
              assetPath,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Container _background() {
    return Container(
      height: 180,
      color: const Color(0xFFFFB113),
    );
  }

  Column _headerTitle() {
    return Column(
      children: [
        Text(
          "User",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Purwokerto",
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
