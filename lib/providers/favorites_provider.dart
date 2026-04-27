import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Product> _favorites = [];
  List<String> _favoriteIds = [];
  static const String _favoritesKey = 'favorites';

  List<Product> get favorites => [..._favorites];

  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  Future<void> toggleFavorite(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final isCurrentlyFavorite = isFavorite(product.id);

    if (isCurrentlyFavorite) {
      _favorites.removeWhere((p) => p.id == product.id);
      _favoriteIds.remove(product.id);
    } else {
      _favorites.add(product);
      _favoriteIds.add(product.id);
    }

    // Save to persistent storage
    await prefs.setStringList(_favoritesKey, _favoriteIds);

    notifyListeners();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
    notifyListeners();
  }

  void updateFavoritesFromProducts(List<Product> allProducts) {
    _favorites.clear();

    for (final product in allProducts) {
      if (_favoriteIds.contains(product.id)) {
        _favorites.add(product);
      }
    }

    notifyListeners();
  }

  Future<void> clearFavorites() async {
    _favorites.clear();
    _favoriteIds.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
    notifyListeners();
  }
}
