import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String iconName;
  final String imageUrl;
  final int productCount;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.iconName = 'category',
    this.imageUrl = '',
    this.productCount = 0,
    this.isActive = true,
    this.sortOrder = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      iconName: data['iconName'] ?? 'category',
      imageUrl: data['imageUrl'] ?? '',
      productCount: data['productCount'] ?? 0,
      isActive: data['isActive'] ?? true,
      sortOrder: data['sortOrder'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconName': iconName,
      'imageUrl': imageUrl,
      'productCount': productCount,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    String? imageUrl,
    int? productCount,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      imageUrl: imageUrl ?? this.imageUrl,
      productCount: productCount ?? this.productCount,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}