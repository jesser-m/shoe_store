import '../models/category.dart';
import 'api_service.dart';

class CategoryService {
  // Get all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await ApiService.get('/categories');
      final data = ApiService.handleResponse(response);
      final List<dynamic> list = data is List ? data : [];
      return list.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des categories: $e');
    }
  }

  // Get active categories only
  Future<List<Category>> getActiveCategories() async {
    try {
      final response = await ApiService.get('/categories/active');
      final data = ApiService.handleResponse(response);
      final List<dynamic> list = data is List ? data : [];
      return list.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des categories actives: $e');
    }
  }

  // Add category
  Future<Category> addCategory(Category category) async {
    try {
      final response = await ApiService.post(
        '/categories',
        body: category.toJson(),
      );
      final data = ApiService.handleResponse(response);
      return Category.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la categorie: $e');
    }
  }

  // Update category
  Future<void> updateCategory(Category category) async {
    try {
      final response = await ApiService.put(
        '/categories/${category.id}',
        body: category.toJson(),
      );
      ApiService.handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise a jour de la categorie: $e');
    }
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      final response = await ApiService.delete('/categories/$categoryId');
      ApiService.handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la categorie: $e');
    }
  }

  // Toggle active status
  Future<void> toggleActive(String categoryId, bool isActive) async {
    try {
      final response = await ApiService.put('/categories/$categoryId/toggle');
      ApiService.handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors du changement de statut: $e');
    }
  }
}
