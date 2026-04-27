import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _productsSubscription;
  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => [..._products];
  List<String> get categories => [..._categories];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    if (category == 'Tout') return products;
    return products.where((product) => product.category == category).toList();
  }

  // Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return products;
    final lowercaseQuery = query.toLowerCase();
    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(lowercaseQuery) ||
              product.brand.toLowerCase().contains(lowercaseQuery) ||
              product.description.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  // Load products from Firestore
  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      _products = snapshot.docs.map((doc) {
        return Product.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Extract unique categories
      _categories = [
        'Tout',
        ..._products.map((p) => p.category).toSet().where((c) => c.isNotEmpty),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      
      // Fallback to local data for demo purposes if Firebase fails
      _products = _getDemoProducts();
      _categories = [
        'Tout',
        ..._products.map((p) => p.category).toSet().where((c) => c.isNotEmpty),
      ];
      _error = null;
      
      notifyListeners();
      debugPrint('Error loading products: $e - Falling back to local demo data');
    }
  }

  // Local demo products fallback
  List<Product> _getDemoProducts() {
    return [
      Product(
        id: '1',
        name: 'Nike Air Max 270',
        description: 'Le confort ultime avec la technologie Air Max révolutionnaire.',
        price: 199.99,
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
        images: [
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
        ],
        sizes: ['39', '40', '41', '42'],
        colors: ['Noir', 'Blanc'],
        category: 'Running',
        brand: 'Nike',
        rating: 4.5,
        reviewCount: 128,
        inStock: true,
        stockQuantity: 25,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '2',
        name: 'Adidas Ultraboost 22',
        description: 'Conçu pour les coureurs qui exigent le meilleur.',
        price: 189.99,
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
        images: [
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
        ],
        sizes: ['38', '39', '40', '41'],
        colors: ['Noir', 'Blanc', 'Bleu'],
        category: 'Running',
        brand: 'Adidas',
        rating: 4.7,
        reviewCount: 95,
        inStock: true,
        stockQuantity: 18,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '3',
        name: 'Puma RS-X³',
        description: 'Style urbain rétro avec technologie moderne.',
        price: 149.99,
        imageUrl: 'https://images.unsplash.com/photo-1512374382149-4332c6c021f1',
        images: [
          'https://images.unsplash.com/photo-1512374382149-4332c6c021f1',
        ],
        sizes: ['39', '40', '41', '42'],
        colors: ['Multicolore', 'Noir'],
        category: 'Street',
        brand: 'Puma',
        rating: 4.3,
        reviewCount: 67,
        inStock: true,
        stockQuantity: 12,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Add a new product (for admin purposes)
  Future<void> addProduct(Product product) async {
    try {
      final docRef = await _firestore
          .collection('products')
          .add(product.toFirestore());
      final newProduct = product.copyWith(id: docRef.id);
      _products.insert(0, newProduct);

      // Update categories if new
      if (product.category.isNotEmpty &&
          !_categories.contains(product.category)) {
        _categories.add(product.category);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding product: $e');
      throw Exception('Erreur lors de l\'ajout du produit');
    }
  }

  // Update product
  Future<void> updateProduct(Product updatedProduct) async {
    try {
      await _firestore
          .collection('products')
          .doc(updatedProduct.id)
          .update(
            updatedProduct.copyWith(updatedAt: DateTime.now()).toFirestore(),
          );

      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      throw Exception('Erreur lors de la mise à jour du produit');
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      throw Exception('Erreur lors de la suppression du produit');
    }
  }

  // Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Listen to real-time updates
  void startListeningToProducts() {
    _productsSubscription?.cancel();
    _productsSubscription = _firestore
        .collection('products')
        .snapshots()
        .listen(
          (snapshot) {
            _products = snapshot.docs.map((doc) {
              return Product.fromFirestore(doc.data(), doc.id);
            }).toList();

            _categories = [
              'Tout',
              ..._products
                  .map((p) => p.category)
                  .toSet()
                  .where((c) => c.isNotEmpty),
            ];

            notifyListeners();
          },
          onError: (error) {
            _error = 'Erreur de connexion: $error';
            notifyListeners();
            debugPrint('Realtime error: $error');
          },
        );
  }

  // Seed initial data (for development)
  Future<void> seedInitialData() async {
    try {
      final batch = _firestore.batch();

      final initialProducts = [
        {
          'name': 'Nike Air Max 270',
          'description':
              'Le confort ultime avec la technologie Air Max révolutionnaire.',
          'price': 199.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
          'images': [
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
            'https://images.unsplash.com/photo-1512374382149-4332c6c021f1',
          ],
          'sizes': ['39', '40', '41', '42', '43', '44', '45'],
          'colors': ['Noir', 'Blanc', 'Rouge'],
          'category': 'Running',
          'brand': 'Nike',
          'rating': 4.5,
          'reviewCount': 128,
          'inStock': true,
          'stockQuantity': 25,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'Adidas Ultraboost 22',
          'description': 'Conçu pour les coureurs qui exigent le meilleur.',
          'price': 189.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
          'images': [
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
            'https://images.unsplash.com/photo-1512374382149-4332c6c021f1',
          ],
          'sizes': ['38', '39', '40', '41', '42', '43', '44'],
          'colors': ['Noir', 'Blanc', 'Bleu'],
          'category': 'Running',
          'brand': 'Adidas',
          'rating': 4.7,
          'reviewCount': 95,
          'inStock': true,
          'stockQuantity': 18,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'Puma RS-X³',
          'description': 'Style urbain rétro avec technologie moderne.',
          'price': 149.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1512374382149-4332c6c021f1',
          'images': [
            'https://images.unsplash.com/photo-1512374382149-4332c6c021f1',
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
          ],
          'sizes': ['37', '38', '39', '40', '41', '42', '43'],
          'colors': ['Multicolore', 'Noir', 'Blanc'],
          'category': 'Street',
          'brand': 'Puma',
          'rating': 4.3,
          'reviewCount': 67,
          'inStock': true,
          'stockQuantity': 12,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'name': 'Nike Air Jordan 1',
          'description': 'L\'icône du basketball qui a révolutionné le sport.',
          'price': 299.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1597043530274-07e0c40e0c8b',
          'images': [
            'https://images.unsplash.com/photo-1597043530274-07e0c40e0c8b',
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
          ],
          'sizes': ['40', '41', '42', '43', '44', '45', '46'],
          'colors': ['Rouge', 'Noir', 'Blanc'],
          'category': 'Basket',
          'brand': 'Nike',
          'rating': 4.8,
          'reviewCount': 203,
          'inStock': true,
          'stockQuantity': 8,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
      ];

      for (final productData in initialProducts) {
        final docRef = _firestore.collection('products').doc();
        batch.set(docRef, productData);
      }

      await batch.commit();
      debugPrint('Initial data seeded successfully');
    } catch (e) {
      debugPrint('Error seeding data: $e');
    }
  }
}
