import 'api_service.dart';

class FavoritesService {
  // Get user's favorites
  Future<List<String>> getFavorites(String userId) async {
    try {
      final response = await ApiService.get('/favorites');
      final data = ApiService.handleResponse(response);
      return List<String>.from(data['productIds'] ?? []);
    } catch (e) {
      throw Exception('Erreur lors du chargement des favoris: $e');
    }
  }

  // Toggle favorite (add/remove)
  Future<bool> toggleFavorite(String userId, String productId) async {
    try {
      final current = await getFavorites(userId);
      if (current.contains(productId)) {
        await removeFavorite(userId, productId);
        return false;
      } else {
        await addFavorite(userId, productId);
        return true;
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise a jour des favoris: $e');
    }
  }

  // Add to favorites
  Future<void> addFavorite(String userId, String productId) async {
    try {
      final response = await ApiService.post(
        '/favorites/add',
        body: {'productId': productId},
      );
      ApiService.handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout aux favoris: $e');
    }
  }

  // Remove from favorites
  Future<void> removeFavorite(String userId, String productId) async {
    try {
      final response = await ApiService.delete(
        '/favorites/remove',
        body: {'productId': productId},
      );
      ApiService.handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la suppression des favoris: $e');
    }
  }

  // Check if product is favorite
  Future<bool> isFavorite(String userId, String productId) async {
    try {
      final favorites = await getFavorites(userId);
      return favorites.contains(productId);
    } catch (e) {
      return false;
    }
  }

  // Clear all favorites
  Future<void> clearFavorites(String userId) async {
    try {
      await ApiService.delete('/favorites');
    } catch (e) {
      throw Exception('Erreur lors du vidage des favoris: $e');
    }
  }
}
