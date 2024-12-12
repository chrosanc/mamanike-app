import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/widget/product_card.dart';
import 'package:mamanike/screens/main/main_screen.dart'; // Import the MainScreen

class HomeScreen extends StatefulWidget {
  final VoidCallback? navigateToCategory;
  const HomeScreen({Key? key, this.navigateToCategory}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB113),
        toolbarHeight: 69,
        elevation: 0,
        title: _headerTitle(),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/svg/searchicon.svg',
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset('assets/svg/carticon.svg',
                color: Colors.white),
          ),
          const SizedBox(width: 14),
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
                _recommendationText(),
                const SizedBox(height: 16),
                _recommendationCard(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> _recommendationCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('produk').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return CherryToast.error(
            title: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return CherryToast.error(
            title: const Text('Tidak ada Data'),
          );
        }

        return SizedBox(
          height: 230,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              String namaKategori = document['nama_kategori'];
              return _buildCards(document.id, namaKategori);
            }).toList(),
          ),
        );
      },
    );
  }

  Column _recommendationText() {
    return Column(
      children: [
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
            ],
          ),
        ),
      ],
    );
  }

  Padding _categoryHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 40, 24, 12),
      child: Container(
        height: 168,
        padding: const EdgeInsets.all(16),
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
              child: GestureDetector(
                onTap: () {
                  if (widget.navigateToCategory != null) {
                    widget.navigateToCategory!(); // Call the callback
                  }
                },
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
                    SvgPicture.asset('assets/svg/arrow_right.svg',
                        width: 15, height: 15, fit: BoxFit.contain),
                  ],
                ),
              ),
            )
          ],
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
      height: 120,
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
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCards(String documentId, String namaKategori) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('produk')
          .doc(documentId)
          .collection('list')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return CherryToast.error(
            title: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return CherryToast.error(
            title: const Text('Tidak ada Data'),
          );
        }

        return Row(
          children: snapshot.data!.docs.map((DocumentSnapshot doc) {
            Map<String, dynamic> itemData = doc.data() as Map<String, dynamic>;
            itemData['nama_kategori'] = namaKategori;
            return ProductCard(data: itemData);
          }).toList(),
        );
      },
    );
  }
}
