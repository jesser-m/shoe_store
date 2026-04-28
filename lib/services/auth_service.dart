import 'dart:convert';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  // Sign up with email and password
  Future<AppUser?> signUp(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/register',
        body: {
          'name': displayName ?? email.split('@')[0],
          'email': email,
          'password': password,
          'displayName': displayName ?? email.split('@')[0],
        },
        auth: false,
      );

      final data = ApiService.handleResponse(response);
      if (data['token'] != null) {
        await ApiService.saveToken(data['token']);
      }
      return AppUser.fromJson(data);
    } catch (e) {
      if (e.toString().contains('deja')) {
        throw 'Un compte existe deja avec cet email.';
      }
      throw 'Erreur lors de l\'inscription: $e';
    }
  }

  // Sign in with email and password
  Future<AppUser?> signIn(String email, String password) async {
    try {
      final response = await ApiService.post(
        '/auth/login',
        body: {'email': email, 'password': password},
        auth: false,
      );

      final data = ApiService.handleResponse(response);
      if (data['token'] != null) {
        await ApiService.saveToken(data['token']);
      }
      return AppUser.fromJson(data);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('utilisateur')) {
        throw 'Aucun utilisateur trouve avec cet email.';
      } else if (msg.contains('mot de passe')) {
        throw 'Mot de passe incorrect.';
      } else if (msg.contains('desactive')) {
        throw 'Ce compte utilisateur a ete desactive.';
      }
      throw 'Erreur lors de la connexion: $e';
    }
  }

  // Get current user data from profile endpoint
  Future<AppUser?> getCurrentUser() async {
    try {
      final response = await ApiService.get('/auth/profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AppUser.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get user data by ID (alias for compatibility)
  Future<AppUser?> getUserData(String uid) async {
    return getCurrentUser();
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      final response = await ApiService.put('/auth/profile', body: data);
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise a jour du profil');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise a jour du profil: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await ApiService.deleteToken();
  }

  // Reset password (mock - backend can be extended)
  Future<void> resetPassword(String email) async {
    // In a full implementation, call backend endpoint
    throw UnimplementedError('Reset password requires backend implementation');
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = await getCurrentUser();
      if (user != null) {
        final response = await ApiService.delete('/users/${user.id}');
        ApiService.handleResponse(response);
      }
      await signOut();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du compte: $e');
    }
  }
}
