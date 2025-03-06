
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:info_popup/info_popup.dart';
import 'package:intl/intl.dart';
import 'package:mamanike/viewmodel/main/order/order_viewmodel.dart';
import 'package:mamanike/widget/CustomAlert.dart';
import 'package:mamanike/widget/button.dart';
import 'package:mamanike/widget/modals/dateModals.dart';
import 'package:mamanike/screens/main/order/address_screen.dart';
import 'package:mamanike/screens/main/order/checkout_screen.dart';
import 'package:mamanike/service/database_service.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class DetailOrder extends HookWidget {
  const DetailOrder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OrderViewModel>(context);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.updateProductPrice();
      });
      return null;
    }, []);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final bool shouldPop =
            await _showCancelConfirmationDialog(context, viewModel) ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 76,
          elevation: 1,
          automaticallyImplyLeading: false,
          title: Text(
            'Pesan Barang',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFB113),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.orange),
            onPressed: () {
              _showCancelConfirmationDialog(context, viewModel);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Batas Waktu Pemesanan",
                            style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        Text("00 : 20 : 00",
                            style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  productCard(viewModel),
                  const SizedBox(height: 16),
                  rentDurationForm(context, viewModel),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey, thickness: 0.5),
                  const SizedBox(height: 16),
                  deliveryDetail(context, viewModel),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey, thickness: 0.5),
                  const SizedBox(height: 16),
                  returnDetail(context, viewModel),
                  const SizedBox(height: 36),
                  Column(children: [
                    ExpansionTile(
                      childrenPadding: EdgeInsets.symmetric(horizontal: 20),
                      shape: const Border(),
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Row(
                        children: [
                          Expanded(
                              child: Text(
                            'Total Bayar',
                            style: GoogleFonts.poppins(fontSize: 12),
                          )),
                          FutureBuilder(
                              future: viewModel.countTotalPrice(),
                              builder: (context, snapshot) {
                                return Text(
                                  'Rp. ${snapshot.data?.toStringAsFixed(0) ?? '0'}',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                );
                              }),
                        ],
                      ),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${viewModel.selectedProductData['nama']} \n${viewModel.rentDurationController.text} ${viewModel.selectedDuration}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[600],
                              ),
                            ),
                            FutureBuilder(
                                future: viewModel.updateRentPrice(),
                                builder: (context, snapshot) {
                                  return Text(
                                    'Rp. ${viewModel.updatedProductPrice}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                }),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pengiriman',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Rp. ${viewModel.updatedDeliveryPrice}' ??
                                  'Rp. 0',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Admin',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Rp. ${viewModel.updatedAdminPrice}' ?? 'Rp.0',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ]),
                  CustomButton(
                    text: 'Checkout',
                    onPressed: () {
                      viewModel.checkData(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _showCancelConfirmationDialog(
      BuildContext context, OrderViewModel viewModel) async {
    showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
              title: 'Batalkan Transaksi',
              content: 'Apakah Anda ingin membatalkan Pemesanan?',
              confirmText: 'YA',
              cancelText: 'TIDAK',
              onConfirm: () async {
                await viewModel.cancelTransaction();
                Navigator.pop(context);
                Navigator.of(context).pop();
              },
              onCancel: () {
                Navigator.of(context).pop();
              });
        });
  }

  Padding header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 24, 14, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const StepIndicator(isActive: false, label: 'Detail Kontak'),
          const SizedBox(width: 8),
          Container(color: const Color(0xFFFFB113), height: 1, width: 72),
          const SizedBox(width: 8),
          const StepIndicator(isActive: true, label: 'Detail Pesanan'),
        ],
      ),
    );
  }

  Padding returnDetail(BuildContext context, OrderViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Detail Pengembalian',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  InfoPopupWidget(
                    child: Icon(
                      IconlyBold.info_circle,
                      size: 18,
                    ),
                    contentTitle:
                        'Jenis Pengambilan dapat diatur lagi ketika sudah selesai memesan',
                    contentTheme: InfoPopupContentTheme(
                      infoTextStyle: GoogleFonts.poppins(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Jenis Pengembalian',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
              InkWell(
                onTap: () {
                  showReturnOptionsModal(
                    context: context,
                    selectedReturnType: viewModel.selectedReturnType,
                    onReturnTypeSelected: (value) {
                      viewModel.selectedReturnType = value;
                    },
                    selectAddress: () async {
                      final result = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddressScreen(),
                        ),
                      );
                      if (result != null) {
                        viewModel.returnData = result;
                      }
                    },
                  );
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (viewModel.returnData != null &&
                          viewModel.selectedReturnType ==
                              'Diambil di Alamat') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            '${viewModel.selectedReturnType} \n${viewModel.returnData!['name']} \n${viewModel.returnData!['phoneNumber']} \n${viewModel.returnData!['fullAddress']}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          viewModel.selectedReturnType ??
                              'Pilih Jenis Pengembalian',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                      Center(
                          child: SvgPicture.asset('assets/svg/arrow_down.svg')),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Padding deliveryDetail(BuildContext context, OrderViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Pengiriman',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Jenis Pengiriman',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
              InkWell(
                onTap: () {
                  showDeliveryOptionsModal(
                    context: context,
                  );
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(viewModel.selectedDeliveryType ?? 'Pilih Jenis Pengiriman'),
                      Center(
                          child: SvgPicture.asset('assets/svg/arrow_down.svg')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tanggal Pengiriman',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
              InkWell(
                onTap: () {
                  showCustomDatePicker(
                    context: context,
                    title: 'Tanggal Pengiriman',
                    onDateSelected: (DateTime date) {
                      viewModel.selectedDeliveryDate = date;
                    },
                  );
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        viewModel.selectedDeliveryDate != null
                            ? DateFormat('dd MMM yyyy')
                                .format(viewModel.selectedDeliveryDate!)
                            : 'Pilih Tanggal',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Center(
                          child: SvgPicture.asset('assets/svg/arrow_down.svg')),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Padding rentDurationForm(BuildContext context, OrderViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Durasi Sewa',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
          InkWell(
            onTap: () {
              showRentDurationSheet(
                context: context,
              );
            },
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      viewModel.rentDurationController.text.isEmpty
                          ? 'Pilih Durasi Sewa'
                          : '${viewModel.rentDurationController.text} ${viewModel.selectedDuration}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Center(child: SvgPicture.asset('assets/svg/arrow_down.svg')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding productCard(OrderViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Row(
            children: [
              Image.network(
                viewModel.selectedProductData['gambar'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.selectedProductData['nama'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp. ${viewModel.selectedProductData['harga']} / bulan\n${viewModel.selectedProductData['stok']} Tersedia',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  final bool isActive;
  final String label;

  const StepIndicator({
    Key? key,
    required this.isActive,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor:
              isActive ? const Color(0xFFFFB113) : Colors.grey[300],
          child: Text(
            (isActive ? '2' : '1'),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isActive ? const Color(0xFFFFB113) : Colors.grey[300],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
