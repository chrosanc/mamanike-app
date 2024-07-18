import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/models/category_card.dart';
import 'package:mamanike/screens/main/category/productlist_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({ Key? key }) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        actions: [
          IconButton(onPressed: (){

          }, icon:  SvgPicture.asset('assets/svg/carticon.svg', height: 32, width: 32,),),
                    const SizedBox(width: 20  ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              "Kategori",
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: const Color(0xFFFFB113),
                fontWeight: FontWeight.w600
              ),
              ),
              const SizedBox(height: 12,),

              Text("Kategori Sewa Barang",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.normal
              ),
              )
          ],),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('produk').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(),);
          }
          if (snapshot.hasError) {
            return CherryToast.error(
              title: Text("Error: ${snapshot.error}"),
            );
          }
          if(!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return CherryToast.error(
              title: Text("Kategori tidak Ditemukan"),
            );
          }
           return SizedBox(
          child: ListView(
            scrollDirection: Axis.vertical,
            children: snapshot.data!.docs.map((DocumentSnapshot document){
                  Map<String, dynamic> itemData = document.data() as Map<String, dynamic>;
                  return CategoryCard(data: itemData, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                     ProductlistScreen(data: itemData)
                    ));
                  },);
            }).toList(),
          ),
        );
        },

       

      ),
      
      
    );
  }
}