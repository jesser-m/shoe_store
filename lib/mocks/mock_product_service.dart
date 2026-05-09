import '../models/product.dart';

class MockProductService {
  final List<Product> _products;
  bool _shouldThrowError = false;
  String _errorMessage = 'Mock error';

  MockProductService(this._products, {bool shouldThrowError = false, String errorMessage = 'Mock error'}) 
      : _shouldThrowError = shouldThrowError, _errorMessage = errorMessage;

  Future<List<Product>> getAllProducts() async {
    if (_shouldThrowError) throw Exception(_errorMessage);
    return List.unmodifiable(_products);
  }

  Future<Product?> getProductById(String productId) async {
    if (_shouldThrowError) throw Exception(_errorMessage);
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProduct(Product product) async {
    if (_shouldThrowError) throw Exception(_errorMessage);
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    } else {
      _products.add(product);
    }
  }

  Future<void> updateProductStock(String productId, int quantity) async {
    if (_shouldThrowError) throw Exception(_errorMessage);
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(stockQuantity: quantity);
    }
  }

  Future<void> deleteProduct(String productId) async {
    if (_shouldThrowError) throw Exception(_errorMessage);
    _products.removeWhere((p) => p.id == productId);
  }

  Future<List<Product>> searchProducts(String query) async {
    if (_shouldThrowError) throw Exception(_errorMessage);
    final lowercaseQuery = query.toLowerCase();
    return _products.where((p) {
      return p.name.toLowerCase().contains(lowercaseQuery) ||
          p.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Helper methods for test setup
  void setShouldThrowError(bool shouldThrow) {
    _shouldThrowError = shouldThrow;
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
  }

  List<Product> getProducts() => List.unmodifiable(_products);
}
