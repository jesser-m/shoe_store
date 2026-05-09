import '../models/user_model.dart';

class MockUserService {
  final List<AppUser> _users;
  bool _shouldThrowError = false;
  String _errorMessage = 'Mock error';

  MockUserService(this._users, {bool shouldThrowError = false, String errorMessage = 'Mock error'}) 
      : _shouldThrowError = shouldThrowError, _errorMessage = errorMessage;

  Future<AppUser?> getUser(String userId) async {
    if (_shouldThrowError) throw Exception(_errorMessage);
    try {
      return _users.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }

  Future<List<AppUser>> getAllUsers() async {
    if (_shouldThrowError) throw Exception(_errorMessage);
    return List.unmodifiable(_users);
  }

  Future<void> saveUser(AppUser user) async {
    if (_shouldThrowError) throw Exception(_errorMessage);
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
    } else {
      _users.add(user);
    }
  }

  Future<void> updateProfile(
    String userId, {
    String? displayName,
    String? phone,
    String? photoUrl,
    Map<String, dynamic>? address,
  }) async {
    if (_shouldThrowError) throw Exception(_errorMessage);
    AppUser? user;
    try {
      user = _users.firstWhere((u) => u.id == userId);
    } catch (_) {
      user = null;
    }
    if (user != null) {
      // Update user properties - simplified for mock
    }
  }

  Future<void> updateUserRole(String userId, String role) async {
    if (_shouldThrowError) throw Exception(_errorMessage);
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(role: role);
    }
  }

  Future<void> toggleUserActive(String userId, bool isActive) async {
    if (_shouldThrowError) throw Exception(_errorMessage);
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isActive: isActive);
    }
  }

  Future<void> deleteUser(String userId) async {
    if (_shouldThrowError) throw Exception(_errorMessage);
    _users.removeWhere((u) => u.id == userId);
  }

  Future<List<AppUser>> searchUsers(String query) async {
    if (_shouldThrowError) throw Exception(_errorMessage);
    final lowercaseQuery = query.toLowerCase();
    return _users.where((u) {
      return u.email.toLowerCase().contains(lowercaseQuery) ||
          (u.displayName?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Helper methods for test setup
  void setShouldThrowError(bool shouldThrow) {
    _shouldThrowError = shouldThrow;
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
  }

  List<AppUser> getUsers() => List.unmodifiable(_users);
}
