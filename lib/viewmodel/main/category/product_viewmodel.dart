import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mamanike/widget/loadingwidget.dart';

class ProductViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _products = [];

  List<Map<String, dynamic>> get products => _products;

  Future<void> fetchProducts(BuildContext context, String categoryName) async {
    LoadingWidget.showLoadingDialog(context);
    try {
      QuerySnapshot categorySnapshot = await _firestore
          .collection('produk')
          .where('nama_kategori', isEqualTo: categoryName)
          .get();
      List<Map<String, dynamic>> allProducts = [];

      for (var productDoc in categorySnapshot.docs) {
        QuerySnapshot productSnapshot = await _firestore
            .collection('produk')
            .doc(productDoc.id)
            .collection('list')
            .get();

        for (var listDoc in productSnapshot.docs) {
          Map<String, dynamic> productData =
              listDoc.data() as Map<String, dynamic>;

          // Tambahkan kategori ke dalam data produk
          productData['nama_kategori'] = categoryName;

          allProducts.add(productData);
        }
      }
      _products = allProducts;
      notifyListeners();
    } catch (e) {
      print(e);
    } finally {
      LoadingWidget.hideloadingDialog(context);
    }
  }
}
