import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth? _auth;
  User? _user;
  AppUser? _appUser;
  bool _isLoading = false;
  bool _isRoleLoading = false;

  bool _isDemoAuthenticated = false;

  User? get user => _user;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isRoleLoading => _isRoleLoading;
  bool get isAuthenticated => _user != null || _isDemoAuthenticated;

  /// Secure admin check: only verified Firebase users with role='admin' in Firestore
  bool get isAdmin {
    if (_user == null) return false;
    return _appUser?.isAdmin ?? false;
  }

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
        if (user != null) {
          await loadUserRole();
        } else {
          _appUser = null;
        }
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      _user = null;
      _appUser = null;
    }
  }

  /// Load user role from Firestore. Creates default 'client' role if missing.
  Future<void> loadUserRole() async {
    if (_user == null) return;
    _isRoleLoading = true;
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (doc.exists) {
        _appUser = AppUser.fromFirestore(doc);
      } else {
        // Create default user document if it doesn't exist
        _appUser = AppUser(
          id: _user!.uid,
          email: _user!.email ?? '',
          role: 'client',
          displayName: _user!.displayName,
          createdAt: DateTime.now(),
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .set(_appUser!.toFirestore());
      }
    } catch (e) {
      debugPrint('Error loading user role: $e');
      _appUser = null;
    } finally {
      _isRoleLoading = false;
      notifyListeners();
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

      final cred = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document with 'client' role
      if (cred.user != null) {
        final newUser = AppUser(
          id: cred.user!.uid,
          email: email,
          role: 'client',
          displayName: cred.user!.displayName,
          createdAt: DateTime.now(),
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .set(newUser.toFirestore());
        _appUser = newUser;
      }

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

      // loadUserRole will be triggered by authStateChanges listener
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
        _appUser = null;
        notifyListeners();
        return;
      }
      if (_auth != null) {
        await _auth!.signOut();
      }
      _appUser = null;
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
