import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Still loading user role
    if (auth.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.deepPurpleAccent),
              SizedBox(height: 16),
              Text(
                'Vérification des accès...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    // Not authenticated → login
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    // Not admin → access denied
    if (!auth.isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Accès Refusé',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vous n\'avez pas les permissions nécessaires pour accéder à cette section.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Retour'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Admin → allow access
    return child;
  }
}
