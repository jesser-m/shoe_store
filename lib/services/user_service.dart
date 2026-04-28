import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  // Get user by ID
  Future<AppUser?> getUser(String userId) async {
    try {
      final response = await ApiService.get('/users/$userId');
      if (response.statusCode == 404) return null;
      final data = ApiService.handleResponse(response);
      return AppUser.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors du chargement de l\'utilisateur: $e');
    }
  }

  // Get all users (admin)
  Future<List<AppUser>> getAllUsers() async {
    try {
      final response = await ApiService.get('/users');
      final data = ApiService.handleResponse(response);
      final List<dynamic> list = data is List ? data : [];
      return list.map((json) => AppUser.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des utilisateurs: $e');
    }
  }

  // Create or update user
  Future<void> saveUser(AppUser user) async {
    try {
      await ApiService.put('/users/${user.id}', body: user.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'utilisateur: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile(
    String userId, {
    String? displayName,
    String? phone,
    String? photoUrl,
    Map<String, dynamic>? address,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (displayName != null) body['displayName'] = displayName;
      if (phone != null) body['phone'] = phone;
      if (photoUrl != null) body['photoUrl'] = photoUrl;
      if (address != null) body['address'] = address;

      final response = await ApiService.put('/auth/profile', body: body);
      ApiService.handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise a jour du profil: $e');
    }
  }

  // Update user role (admin only)
  Future<void> updateUserRole(String userId, String role) async {
    try {
      final response = await ApiService.put(
        '/users/$userId/role',
        body: {'role': role},
      );
      ApiService.handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise a jour du role: $e');
    }
  }

  // Toggle user active status (admin only)
  Future<void> toggleUserActive(String userId, bool isActive) async {
    try {
      final response = await ApiService.put('/users/$userId/toggle');
      ApiService.handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise a jour du statut: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      final response = await ApiService.delete('/users/$userId');
      ApiService.handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'utilisateur: $e');
    }
  }

  // Search users
  Future<List<AppUser>> searchUsers(String query) async {
    try {
      final users = await getAllUsers();
      final lowercaseQuery = query.toLowerCase();
      return users.where((u) {
        return u.email.toLowerCase().contains(lowercaseQuery) ||
            (u.displayName?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            u.name.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche d\'utilisateurs: $e');
    }
  }
}
