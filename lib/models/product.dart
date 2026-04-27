import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final String category;
  final String brand;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final int stockQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.images = const [],
    this.sizes = const [],
    this.colors = const [],
    this.category = '',
    this.brand = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    this.stockQuantity = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isFavorite = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Create Product from Firestore document
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      sizes: List<String>.from(data['sizes'] ?? []),
      colors: List<String>.from(data['colors'] ?? []),
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      inStock: data['inStock'] ?? true,
      stockQuantity: data['stockQuantity'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      isFavorite: false, // This will be set by FavoritesProvider
    );
  }

  // Convert Product to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'images': images,
      'sizes': sizes,
      'colors': colors,
      'category': category,
      'brand': brand,
      'rating': rating,
      'reviewCount': reviewCount,
      'inStock': inStock,
      'stockQuantity': stockQuantity,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create a copy with updated fields
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    List<String>? images,
    List<String>? sizes,
    List<String>? colors,
    String? category,
    String? brand,
    double? rating,
    int? reviewCount,
    bool? inStock,
    int? stockQuantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      inStock: inStock ?? this.inStock,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}