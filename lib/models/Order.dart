import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamanike/models/Address.dart';
import 'Product.dart';

class Order {
  final String invoiceId;
  final String status;
  final Map<String, ContactItem> contactItem;
  final Map<String, ProductItem> productItem;
  final Map<String, OrderItem> orderItem;

  Order({
    required this.invoiceId,
    required this.status,
    required this.contactItem,
    required this.productItem,
    required this.orderItem,
  });

  // Convert JSON to Order
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      invoiceId: json['invoice_id'] ?? '',
      status: json['status'] ?? '',
      contactItem: (json['contactItem'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, ContactItem.fromJson(value)),
      ) ??
          {},
      productItem: (json['productItem'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, ProductItem.fromJson(value)),
      ) ??
          {},
      orderItem: (json['orderItem'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, OrderItem.fromJson(value)),
      ) ??
          {},
    );
  }

  // Convert Order to JSON
  Map<String, dynamic> toJson() {
    return {
      'invoiceId': invoiceId,
      'status': status,
      'contactItem': contactItem.map((key, value) => MapEntry(key, value.toJson())),
      'productItem': productItem.map((key, value) => MapEntry(key, value.toJson())),
      'orderItem': orderItem.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

// =====================================
// ContactItem Model
// =====================================
class ContactItem {
  final String email;
  final String fullName;
  final String phoneNumber;
  final String identityAddress;
  final String identityNumber;
  String identityImage;
  final Map<String, dynamic>? anotherPerson;

  ContactItem({
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.identityAddress,
    required this.identityNumber,
    required this.identityImage,
    this.anotherPerson,
  });

  factory ContactItem.fromJson(Map<String, dynamic> json) {
    return ContactItem(
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      identityAddress:  json['identityAddress'] ?? '',
      identityNumber: json['identityNumber'] ?? '',
      identityImage: json['identityImage'] ?? '',
      anotherPerson: json['anotherPerson'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'identityAddress' : identityAddress,
      'identityNumber': identityNumber,
      'identityImage': identityImage,
      'anotherPerson': anotherPerson,
    };
  }
}

// =====================================
// OrderItem Model
// =====================================
class OrderItem {
  final String adminFee;
  final int rentDuration;
  final String rentDurationType;
  final String totalPrice;
  final Timestamp orderDate;
  final Map<String, DeliveryItem> deliveryItems;
  final Map<String, ReturnItem> returnItems;

  OrderItem({
    required this.adminFee,
    required this.rentDuration,
    required this.rentDurationType,
    required this.totalPrice,
    required this.orderDate,
    required this.deliveryItems,
    required this.returnItems,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      adminFee: json['adminFee'] ?? '',
      rentDuration: json['rentDuration'] ?? 0,
      rentDurationType: json['rentDurationType'] ?? '',
      totalPrice: json['totalPrice'] ?? '',
      orderDate: json['orderDate'] ?? Timestamp.now(),
      deliveryItems: (json['deliveryItems'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, DeliveryItem.fromJson(value)),
      ) ??
          {},
      returnItems: (json['returnItems'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, ReturnItem.fromJson(value)),
      ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adminFee': adminFee,
      'rentDuration': rentDuration,
      'rentDurationType': rentDurationType,
      'totalPrice': totalPrice,
      'orderDate': orderDate,
      'deliveryItems': deliveryItems.map((key, value) => MapEntry(key, value.toJson())),
      'returnItems': returnItems.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

// =====================================
// DeliveryItem Model
// =====================================
class DeliveryItem {
  final String deliveryFee;
  final String deliveryType;
  final Timestamp deliveryDate;
  final Map<String, Address> deliveryAddress;

  DeliveryItem({
    required this.deliveryFee,
    required this.deliveryType,
    required this.deliveryDate,
    required this.deliveryAddress,
  });

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      deliveryFee: json['deliveryFee'] ?? '',
      deliveryType: json['deliveryType'] ?? '',
      deliveryDate: json['deliveryDate'] ?? Timestamp.now(),
      deliveryAddress: (json['deliveryAddress'] as Map<String,dynamic>).map((key, value) => MapEntry(key, Address.fromJson(value))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryFee': deliveryFee,
      'deliveryType': deliveryType,
      'deliveryDate': deliveryDate,
      'deliveryAddress': deliveryAddress.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

// =====================================
// ReturnItem Model
// =====================================
class ReturnItem {
  final String returnType;
  final Timestamp returnDate;
  final Map<String, Address> returnAddress;

  ReturnItem({
    required this.returnType,
    required this.returnDate,
    required this.returnAddress,
  });

  factory ReturnItem.fromJson(Map<String, dynamic> json) {
    return ReturnItem(
      returnType: json['returnType'] ?? '',
      returnDate: json['returnDate'] ?? Timestamp.now(),
      returnAddress: (json['returnAddress'] as Map<String, dynamic>).map((key, value) => MapEntry(key, Address.fromJson(json))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'returnType': returnType,
      'returnDate': returnDate,
      'returnAddress': returnAddress.map((key,value) => MapEntry(key, value.toJson())),
    };
  }
}
