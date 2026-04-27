import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth? _auth;
  User? _user;
  bool _isLoading = false;
  bool _isDemoAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null || _isDemoAuthenticated;

  bool get isAdmin => false;

  bool get isDemoMode {
    if (_auth == null) return true;
    try {
      final key = _auth!.app.options.apiKey;
      return key.isEmpty ||
          key.contains('DemoFakeApiKey') ||
          key.contains('AIzaSy');
    } catch (e) {
      debugPrint('Error checking demo mode: $e');
      return true;
    }
  }

  AuthProvider() {
    try {
      _auth = FirebaseAuth.instance;
      _auth!.authStateChanges().listen((User? user) async {
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      _user = null;
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (isDemoMode) {
        await Future.delayed(const Duration(seconds: 1));
        _isDemoAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return null;
      }

      await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      switch (e.code) {
        case 'weak-password':
          return 'Le mot de passe est trop faible.';
        case 'email-already-in-use':
          return 'Un compte existe déjà avec cet email.';
        case 'invalid-email':
          return 'L\'email n\'est pas valide.';
        default:
          if (e.message?.contains('API key') == true) {
            return 'Erreur: Le projet utilise des fausses clés Firebase. Veuillez configurer Firebase avec "flutterfire configure".';
          }
          return 'Erreur lors de l\'inscription: ${e.message}';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      final errorStr = e.toString();
      if (errorStr.contains('API key')) {
        return 'Erreur: Le projet utilise des fausses clés Firebase. Veuillez configurer Firebase avec "flutterfire configure".';
      }
      return 'Erreur inattendue: $e';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (isDemoMode) {
        await Future.delayed(const Duration(seconds: 1));
        _isDemoAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return null;
      }

      await _auth!.signInWithEmailAndPassword(email: email, password: password);

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      switch (e.code) {
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet email.';
        case 'wrong-password':
          return 'Mot de passe incorrect.';
        case 'invalid-email':
          return 'L\'email n\'est pas valide.';
        case 'user-disabled':
          return 'Ce compte utilisateur a été désactivé.';
        default:
          if (e.message?.contains('API key') == true) {
            return 'Erreur: Le projet utilise des fausses clés Firebase. Veuillez configurer Firebase avec "flutterfire configure".';
          }
          return 'Erreur lors de la connexion: ${e.message}';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      final errorStr = e.toString();
      if (errorStr.contains('API key')) {
        return 'Erreur: Le projet utilise des fausses clés Firebase. Veuillez configurer Firebase avec "flutterfire configure".';
      }
      return 'Erreur inattendue: $e';
    }
  }

  Future<void> signOut() async {
    try {
      if (_isDemoAuthenticated) {
        _isDemoAuthenticated = false;
        notifyListeners();
        return;
      }
      if (_auth != null) {
        await _auth!.signOut();
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth!.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'L\'email n\'est pas valide.';
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet email.';
        default:
          return 'Erreur lors de la réinitialisation: ${e.message}';
      }
    } catch (e) {
      return 'Erreur inattendue: $e';
    }
  }
}
