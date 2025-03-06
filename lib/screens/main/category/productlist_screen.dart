import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/viewmodel/main/category/category_viewmodel.dart';
import 'package:mamanike/viewmodel/main/category/product_viewmodel.dart';
import 'package:mamanike/widget/product_card.dart';
import 'package:mamanike/widget/search_form.dart';
import 'package:provider/provider.dart';

class ProductlistScreen extends HookWidget {
  final Map<String, dynamic> data;
  const ProductlistScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productViewModel = Provider.of<ProductViewModel>(context);
    final categoryViewModel = Provider.of<CategoryViewModel>(context);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        productViewModel.fetchProducts(
            context, categoryViewModel.selectedCategory!['nama_kategori']);
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 76,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          categoryViewModel.selectedCategory!['nama_kategori'],
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
          const Padding(padding: EdgeInsets.all(24), child: SearchForm()),
          Expanded(
            child: Consumer<ProductViewModel>(
              builder: (context, productViewModel, child) {
                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 148 / 205,
                  ),
                  itemCount: productViewModel.products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      data: productViewModel.products[index],
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
