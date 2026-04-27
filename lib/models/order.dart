import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // 'pending', 'paid', 'shipped', 'delivered', 'cancelled'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? paymentIntentId;
  final ShippingAddress? shippingAddress;
  final String? notes;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.paymentIntentId,
    this.shippingAddress,
    this.notes,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromMap(item))
          .toList() ?? [],
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      paymentIntentId: data['paymentIntentId'],
      shippingAddress: data['shippingAddress'] != null
          ? ShippingAddress.fromMap(data['shippingAddress'])
          : null,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'paymentIntentId': paymentIntentId,
      'shippingAddress': shippingAddress?.toMap(),
      'notes': notes,
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentIntentId,
    ShippingAddress? shippingAddress,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      notes: notes ?? this.notes,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String? size;
  final String? color;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.size,
    this.color,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      size: map['size'],
      color: map['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'size': size,
      'color': color,
    };
  }
}

class ShippingAddress {
  final String fullName;
  final String address;
  final String city;
  final String postalCode;
  final String country;
  final String? phone;

  ShippingAddress({
    required this.fullName,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.country,
    this.phone,
  });

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      fullName: map['fullName'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? '',
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
    };
  }
}