import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/models/CustomAlert.dart';
import 'package:mamanike/models/address_card.dart';
import 'package:mamanike/models/button.dart';
import 'package:mamanike/screens/main/order/detailaddress_screen.dart';
import 'package:mamanike/service/database_service.dart';
import 'package:cherry_toast/cherry_toast.dart';

class AddressScreen extends StatefulWidget {
  final Map<String, dynamic>? data;

  const AddressScreen({Key? key, this.data}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final DatabaseService _service = DatabaseService();
  late Stream<List<Map<String, dynamic>>> _addressesStream;
  String? selectedAddressId;
  Map<String, dynamic>?   addressData;

  @override
  void initState() {
    super.initState();
    _service.startAddressStream();
    _addressesStream = _service.addressesStream;
  }

  @override
  void dispose() {
    _service.stopAddressStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 76,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          'Daftar Alamat',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFB113),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: const BorderSide(
                    color: Color(0xFFFFB113),
                  ),
                ),
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DetailaddressScreen(data: widget.data)));
              },
              child: Text(
                "Tambah Alamat",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFB113),
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _addressesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada Alamat, tambah yuk moms!',
                      style: GoogleFonts.poppins(),
                    ),
                  );
                } else {
                  final addresses = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView.builder(
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        final addressId = address['id'];
                        final isSelected = addressId == selectedAddressId;

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedAddressId = isSelected ? null : addressId;
                                  addressData = isSelected ? null : address;
                                  print(addressData);
                                });
                              },
                              child: AddressCard(
                                borderColor: isSelected ? Color(0xFFFFB113) : Colors.grey,
                                backgroundColor: isSelected ? Color(0xFFFFB113).withOpacity(0.1) : Colors.white,
                                label: address['label'],
                                namePerson: address['name'],
                                phoneNumber: address['phoneNumber'],
                                addressPerson: address['fullAddress'],
                                deleteAddress: () {
                                  _showDeleteDialog(context, address['id']);
                                },
                                changeAddress: () {
                                  // Implement logic to change address details
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
          CustomButton(
            text: 'Pilih Alamat',
            onPressed: () {
              if (addressData != null) {
                Navigator.pop(context, addressData);
              } else {
                CherryToast.warning(
                  title: Text(
                    'Pilih salah satu alamat terlebih dahulu',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ).show(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String addressId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
              title: 'Hapus Alamat',
              content: 'Apakah anda yakin untuk menghapus alamat ini?',
              confirmText: 'HAPUS',
              cancelText: 'TIDAK',
              onConfirm: () async {
                try {
                  await _service.deleteAddress(addressId);
                  CherryToast.success(
                    title: Text(
                      'Berhasil menghapus alamat',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ).show(context);
                } catch (e) {
                  print(e);
                  CherryToast.error(
                    title: Text(
                      'Gagal menghapus alamat',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ).show(context);
                } finally {
                  Navigator.of(context).pop();
                }
              },
              onCancel: () {
                Navigator.of(context).pop();
              });
        });
  }
}
