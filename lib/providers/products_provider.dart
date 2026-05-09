import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductsProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => [..._products];
  List<String> get categories => [..._categories];
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> getProductsByCategory(String category) {
    if (category == 'Tout') return products;
    return products.where((product) => product.category == category).toList();
  }

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

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final productsList = await _productService.getProducts();
      _products = productsList;

      _categories = [
        'Tout',
        ..._products.map((p) => p.category).toSet().where((c) => c.isNotEmpty),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _products = _getDemoProducts();
      _categories = [
        'Tout',
        ..._products.map((p) => p.category).toSet().where((c) => c.isNotEmpty),
      ];
      _error = null;
      notifyListeners();
      debugPrint(
        'Error loading products: $e - Falling back to local demo data',
      );
    }
  }

  List<Product> _getDemoProducts() {
    return [
      Product(
        id: '1',
        name: 'Nike Air Max 270',
        description:
            'Le confort ultime avec la technologie Air Max révolutionnaire.',
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
        description: 'ConÃ§u pour les coureurs qui exigent le meilleur.',
        price: 189.99,
        imageUrl:
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
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
        name: 'Puma RS-XÂ³',
        description: 'Style urbain rétro avec technologie moderne.',
        price: 149.99,
        imageUrl:
            'https://images.unsplash.com/photo-1512374382149-4332c6c021f1',
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

  Future<void> addProduct(Product product) async {
    try {
      final newProduct = await _productService.addProduct(product);
      _products.insert(0, newProduct);

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

  Future<void> updateProduct(Product updatedProduct) async {
    try {
      await _productService.updateProduct(updatedProduct);

      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      throw Exception('Erreur lors de la mise Ã  jour du produit');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      throw Exception('Erreur lors de la suppression du produit');
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Seed initial data (for development via backend)
  Future<void> seedInitialData() async {
    try {
      final initialProducts = _getDemoProducts();
      for (final product in initialProducts) {
        try {
          await _productService.addProduct(product);
        } catch (e) {
          debugPrint('Error seeding product: $e');
        }
      }
      debugPrint('Initial data seeded successfully');
    } catch (e) {
      debugPrint('Error seeding data: $e');
    }
  }
}
