import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/widget/product_card.dart';
import 'package:mamanike/widget/search_form.dart';

class ProductlistScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  const ProductlistScreen({Key? key, required this.data}) : super(key: key);

  @override
  _ProductlistScreenState createState() => _ProductlistScreenState();
}

class _ProductlistScreenState extends State<ProductlistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 76,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          widget.data!['nama_kategori'],
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
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.orange),
            onPressed: () {
              // Add your cart action here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: SearchForm()
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('produk')
                  .where('nama_kategori', isEqualTo: widget.data!['nama_kategori'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text("Kategori tidak Ditemukan"),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('produk')
                          .doc(document.id)
                          .collection('list')
                          .snapshots(),
                      builder: (context, nestedSnapshot) {
                        if (nestedSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (nestedSnapshot.hasError) {
                          return Text('Error: ${nestedSnapshot.error}');
                        }
                        if (!nestedSnapshot.hasData || nestedSnapshot.data!.docs.isEmpty) {
                          return Text('Tidak ada Data');
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 148 / 205,
                          ),
                          itemCount: nestedSnapshot.data!.docs.length,
                          itemBuilder: (context, nestedIndex) {
                            DocumentSnapshot nestedDocument = nestedSnapshot.data!.docs[nestedIndex];
                            Map<String, dynamic> itemData = nestedDocument.data() as Map<String, dynamic>;
                            itemData['nama_kategori'] = document['nama_kategori'];
                            return ProductCard(data: itemData);
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
