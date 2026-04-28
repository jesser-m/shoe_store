import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  // Get all products
  Future<List<Product>> getProducts() async {
    try {
      final response = await ApiService.get('/products');
      final data = ApiService.handleResponse(response);
      final List<dynamic> list = data is List ? data : [];
      return list.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des produits: $e');
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await ApiService.get('/products?category=$category');
      final data = ApiService.handleResponse(response);
      final List<dynamic> list = data is List ? data : [];
      return list.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du filtrage des produits: $e');
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await ApiService.get('/products?search=$query');
      final data = ApiService.handleResponse(response);
      final List<dynamic> list = data is List ? data : [];
      return list.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  // Get single product
  Future<Product?> getProduct(String productId) async {
    try {
      final response = await ApiService.get('/products/$productId');
      if (response.statusCode == 404) return null;
      final data = ApiService.handleResponse(response);
      return Product.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors du chargement du produit: $e');
    }
  }

  // Add product
  Future<Product> addProduct(Product product) async {
    try {
      final response = await ApiService.post(
        '/products',
        body: product.toJson(),
      );
      final data = ApiService.handleResponse(response);
      return Product.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du produit: $e');
    }
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    try {
      final response = await ApiService.put(
        '/products/${product.id}',
        body: product.toJson(),
      );
      ApiService.handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise a jour du produit: $e');
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      final response = await ApiService.delete('/products/$productId');
      ApiService.handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du produit: $e');
    }
  }

  // Update stock
  Future<void> updateStock(String productId, int newQuantity) async {
    try {
      final response = await ApiService.put(
        '/products/$productId',
        body: {'stockQuantity': newQuantity, 'inStock': newQuantity > 0},
      );
      ApiService.handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise a jour du stock: $e');
    }
  }

  // Get unique categories from products
  Future<List<String>> getProductCategories() async {
    try {
      final response = await ApiService.get('/categories');
      final data = ApiService.handleResponse(response);
      final List<dynamic> list = data is List ? data : [];
      return list
          .map<String>((json) => json['name']?.toString() ?? '')
          .where((c) => c.isNotEmpty)
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des categories: $e');
    }
  }
}
