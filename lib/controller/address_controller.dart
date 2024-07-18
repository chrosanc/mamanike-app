import 'package:flutter/material.dart';

class AddressController implements Disposable {
  final TextEditingController pinpointController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController fullAddressController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    pinpointController.dispose();
    labelController.dispose();
    nameController.dispose();
    phoneNumberController.dispose();
    fullAddressController.dispose();
    detailController.dispose();
    noteController.dispose();
  }
}

abstract class Disposable {
  void dispose();
}
