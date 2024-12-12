import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // StreamController untuk mengirim alamat kepada pendengar
  late StreamController<List<Map<String, dynamic>>> _addressesController =
      _addressesController = StreamController<List<Map<String, dynamic>>>.broadcast();


  // Stream untuk mendengarkan perubahan alamat
  Stream<List<Map<String, dynamic>>> get addressesStream =>
      _addressesController.stream;

    Future<List<Map<String, dynamic>>> getOrders() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String uid = user.uid;
      CollectionReference ordersCollection = _firestore.collection('order').doc(uid).collection('pesanan');

      try {
        QuerySnapshot snapshot = await ordersCollection.get();
        return snapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      } catch (e) {
        print("Error getting orders: $e");
        return [];
      }
    } else {
      print("User not authenticated");
      return [];
    }
  }

Future<List<Map<String, dynamic>>> getAllOrders() async {
  try {
    // Ambil koleksi 'order' yang berisi dokumen pengguna
    CollectionReference ordersCollection = _firestore.collection('order');
    QuerySnapshot userSnapshot = await ordersCollection.get();

    print("Users Collection Size: ${userSnapshot.docs.length}"); // Debugging

    List<Map<String, dynamic>> allOrders = [];

    // Iterasi melalui setiap dokumen pengguna
    for (var userDoc in userSnapshot.docs) {
      CollectionReference userOrdersCollection = userDoc.reference.collection('pesanan');
      QuerySnapshot userOrdersSnapshot = await userOrdersCollection.get();

      print("User ${userDoc.id} Orders Size: ${userOrdersSnapshot.docs.length}"); // Debugging

      // Iterasi melalui setiap dokumen pesanan
      for (var orderDoc in userOrdersSnapshot.docs) {
        Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;
        allOrders.add(orderData);
      }
    }

    print('Fetched Orders: $allOrders'); // Debugging

    return allOrders;
  } catch (e) {
    print("Error getting all orders: $e");
    return [];
  }
}






  // Memulai streaming alamat pengguna
  void startAddressStream() async {
    try {
      if (_addressesController.isClosed) {
        _addressesController = StreamController<List<Map<String, dynamic>>>.broadcast();
      }

      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;
        CollectionReference addressesCollection =
            _firestore.collection('alamat').doc(uid).collection('addresses');

        addressesCollection.snapshots().listen((snapshot) {
          List<Map<String, dynamic>> addresses = [];
          for (var doc in snapshot.docs) {
            addresses.add(doc.data() as Map<String, dynamic>);
          }
          if (!_addressesController.isClosed) {
            _addressesController.sink.add(addresses);
          }
        });
      } else {
        throw Exception('User tidak ditemukan.');
      }
    } catch (e) {
    }
  }

  // Memberhentikan streaming alamat
  void stopAddressStream() {
    _addressesController.close();
  }

  Future<void> cancelReserve(String invId, String categoryName, String productName) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not signed in');
      }

      final String uid = user.uid;

      await _firestore.runTransaction((transaction) async {
        // Referensi ke dokumen pesanan yang ingin dibatalkan berdasarkan ID
        final DocumentReference orderRef = _firestore.collection('order').doc(uid).collection('pesanan').doc(invId);
        final DocumentSnapshot orderDoc = await transaction.get(orderRef);

        if (!orderDoc.exists) {
          throw Exception('Order not found');
        }

        // Memeriksa status pesanan
        final Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;
        if (orderData['status'] != 'Dikunci') {
          throw Exception('Order is not in a locked state');
        }

        // Query untuk mendapatkan dokumen produk berdasarkan kategori dan nama produk
        final QuerySnapshot productSnapshot = await _firestore
            .collection('produk')
            .where('nama_kategori', isEqualTo: categoryName)
            .get();

        if (productSnapshot.docs.isNotEmpty) {
          final DocumentReference categoryRef = productSnapshot.docs.first.reference;
          
          final QuerySnapshot productQuery = await categoryRef.collection('list')
            .where('nama', isEqualTo: productName)
            .get();

          if (productQuery.docs.isNotEmpty) {
            final DocumentSnapshot productDoc = productQuery.docs.first;
            final DocumentReference productRef = productDoc.reference;
            
            final int currentStock = productDoc['stok'] ?? 0;
            transaction.update(productRef, {'stok': currentStock + 1});

          } else {
            throw Exception('Product not found in category');
          }
        } else {
          throw Exception('Category not found');
        }

        // Menghapus dokumen pesanan
        transaction.delete(orderRef);
      });
    } catch (e) {
    }
  }

Future<void> changeStatusToOrderConfirmed(String invId) async {
  try {
    // Mengambil koleksi pengguna
    final CollectionReference usersCollection = _firestore.collection('order');
    
    // Mendapatkan daftar dokumen pengguna
    final QuerySnapshot userSnapshot = await usersCollection.get();

    // Iterasi melalui setiap dokumen pengguna
    for (var userDoc in userSnapshot.docs) {
      final String uid = userDoc.id;
      final CollectionReference ordersCollection = userDoc.reference.collection('pesanan');

      // Mencari dokumen pesanan dengan invId yang sesuai
      final QuerySnapshot existingDocs = await ordersCollection
          .where('invId', isEqualTo: invId)
          .limit(1)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        // Memperbarui dokumen jika ditemukan
        await existingDocs.docs.first.reference.update({
          'orderDate': Timestamp.now(),
          'status': 'Pesanan Dikonfirmasi'
        });
        return; // Keluar dari loop jika update berhasil
      }
    }

    // Menangani kasus jika dokumen dengan invId tidak ditemukan
    throw Exception('Pesanan dengan ID $invId tidak ditemukan di semua pengguna');
  } catch (e) {
    // Menangani kesalahan yang terjadi
    print('Error updating order status: $e');
    rethrow;
  }
}


  Future<void> changeStatusToWaitingConfirmation(invId) async {
    try{
      final User? user = _auth.currentUser;
      if (user  != null) {
        final String uid = user.uid;
        final CollectionReference ordersCollection = _firestore.collection('order').doc(uid).collection('pesanan');
        final existingDocs = await ordersCollection.where('invId', isEqualTo: invId).limit(1).get();

        await existingDocs.docs.first.reference.update({
          'orderDate' : Timestamp.now(),
          'status' : 'Menunggu Konfirmasi'
        });
      }
    } catch(e) {
      rethrow;
    }
  }

Future<void> orderItem(Map<String, dynamic> deliveryAddress, Map<String, dynamic> returnAddress,Map<String, dynamic> orderData, String invId) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final String uid = user.uid;
        final CollectionReference ordersCollection = _firestore.collection('order').doc(uid).collection('pesanan');

        // Check if there's an existing document with the same invId
        final existingDocs = await ordersCollection.where('invId', isEqualTo: invId).limit(1).get();

          await existingDocs.docs.first.reference.update({
            'deliveryAddress': deliveryAddress,
            'returnAddress' : returnAddress,
            'orderData': orderData,
            'invId': invId,
            'status' : 'Dalam Pembayaran',
          });

      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reserveItem(String invId, String categoryName, String productName, String productImage, Map<String, dynamic> identityData, File imageFile, String? anotherPersonName, String? anotherPersonNumber) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not signed in');
      }

      final String uid = user.uid;
      final String filePath = 'order/$uid/list_order/identityCard/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _firestore.runTransaction((transaction) async {
        final QuerySnapshot querySnapshot = await _firestore
            .collection('produk')
            .where('nama_kategori', isEqualTo: categoryName)
            .get();

        final QueryDocumentSnapshot categoryDoc = querySnapshot.docs.firstWhere(
          (doc) => doc['nama_kategori'] == categoryName,
          orElse: () => throw Exception('Kategori tidak ditemukan: $categoryName'),
        );

        final QuerySnapshot productSnapshot = await _firestore
            .collection('produk')
            .doc(categoryDoc.id)
            .collection('list')
            .where('nama', isEqualTo: productName)
            .get();

        if (productSnapshot.docs.isEmpty) {
          throw Exception('Produk tidak tersedia');
        }

        final DocumentSnapshot productDoc = productSnapshot.docs.first;
        final int currentStock = productDoc['stok'];

        if (currentStock > 0) {
          final DocumentReference ordersUID = _firestore.collection('order').doc(uid);
          final CollectionReference ordersCollection = _firestore.collection('order').doc(uid).collection('pesanan');

          bool isUnique = false;
          while (!isUnique) {
            final existingDocs = await ordersCollection.where('invId', isEqualTo: invId).limit(1).get();
            if (existingDocs.docs.isEmpty) {
              isUnique = true;
            }
          }

          // Upload image to storage
          await _storage.ref(filePath).putFile(imageFile);
          final String downloadURL = await _storage.ref(filePath).getDownloadURL();
          identityData['imagePath'] = downloadURL;

          final Map<String, dynamic> uidReference = {
            'uid' : uid
          };

          final Map<String, dynamic> orderData = {
            'invId': invId,
            'identityData': identityData,
            'anotherPerson' : {
              'anotherPersonName' : anotherPersonName,
              'anotherPersonNumber' : anotherPersonNumber,
            },
            'status' : 'Dikunci',
            'productData': {
              'categoryName': categoryName,
              'productName': productName,
              'productImage' : productImage,
            },
          };
          transaction.set(ordersUID, uidReference);
          transaction.set(ordersCollection.doc(invId), orderData);
          transaction.update(productDoc.reference, {'stok': currentStock - 1});
        } else {
          throw Exception('Produk tidak tersedia');
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentReference> saveAddress(Map<String, dynamic> addressData) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = _auth.currentUser!.uid;
        DocumentReference addressRef = _firestore.collection('alamat').doc(uid);

        // Membuat sub-koleksi 'addresses' jika belum ada
        CollectionReference addressesCollection = addressRef.collection('addresses');

        // Menambahkan ID ke addressData
        addressData['id'] = addressesCollection.doc().id;

        // Menambahkan data alamat dan mengembalikan referensi dokumen yang baru ditambahkan
        DocumentReference newAddressDocRef = await addressesCollection.add(addressData);

        return newAddressDocRef;
      } else {
        throw Exception('User tidak ditemukan.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> showUserAddress() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;
        CollectionReference addressesCollection = _firestore.collection('alamat').doc(uid).collection('addresses');
        QuerySnapshot snapshot = await addressesCollection.get();

        List<Map<String, dynamic>> addresses = [];
        for (var doc in snapshot.docs) {
          addresses.add(doc.data() as Map<String, dynamic>);
        }

        return addresses;
      } else {
        throw Exception('User tidak ditemukan.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> showDetailOrderfromAdmin(String invId) async {
    try {
      // Mengambil semua dokumen dalam koleksi 'order' (uid)
      CollectionReference ordersCollection = _firestore.collection('order');
      QuerySnapshot userSnapshot = await ordersCollection.get();

      // Iterasi melalui setiap dokumen pengguna (uid)
      for (var userDoc in userSnapshot.docs) {
        String userId = userDoc.id;

        // Mengambil koleksi 'pesanan' untuk setiap pengguna
        CollectionReference userOrdersCollection = ordersCollection.doc(userId).collection('pesanan');
        QuerySnapshot userOrdersSnapshot = await userOrdersCollection.where('invId', isEqualTo: invId).limit(1).get();

        // Jika pesanan dengan invId ditemukan, kembalikan data pesanan
        if (userOrdersSnapshot.docs.isNotEmpty) {
          return userOrdersSnapshot.docs.first.data() as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print("Error showing detail order from admin: $e");
      return null;
    }
  }

    Future<Map<String, dynamic>> showUserDetailOrder(String invId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot<Map<String, dynamic>> orderSnapshot = await _firestore
          .collection('order')
          .doc(uid)
          .collection('pesanan')
          .doc(invId)
          .get();
      return orderSnapshot.data()!;
    } else {
      throw Exception('No user logged in');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;
        // Mengambil referensi dokumen alamat berdasarkan 'id'
        QuerySnapshot snapshot = await _firestore
            .collection('alamat')
            .doc(uid)
            .collection('addresses')
            .where('id', isEqualTo: addressId)
            .get();

        // Memeriksa apakah ada dokumen dengan id yang sesuai
        if (snapshot.docs.isNotEmpty) {
          // Mengambil referensi dokumen pertama (seharusnya hanya ada satu)
          DocumentReference addressRef = snapshot.docs.first.reference;

          // Menghapus dokumen alamat
          await addressRef.delete();
        } else {
          throw Exception('Alamat dengan ID $addressId tidak ditemukan.');
        }
      } else {
        throw Exception('User tidak ditemukan.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
  try {
    User? user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return snapshot.data();
      } else {
        print('User data not found');
        return null;
      }
    } else {
      print('No user currently signed in');
      return null;
    }
  } catch (e) {
    print('Error getting user data: $e');
    return null;
  }
}

}
