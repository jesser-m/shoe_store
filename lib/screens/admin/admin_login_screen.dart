import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import 'admin_dashbord_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final error = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    // Wait for role to be loaded
    await auth.loadUserRole();

    if (!mounted) return;

    if (!auth.isAdmin) {
      setState(() => _errorMessage = 'Accès réservé aux administrateurs.');
      await auth.signOut();
      return;
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.deepPurple, Colors.purpleAccent],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Espace Admin',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connexion sécurisée au panneau d\'administration',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withValues(
                                    alpha: 0.08,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.deepPurpleAccent,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorStyle: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre email';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Email invalide';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Password
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.white),
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withValues(
                                    alpha: 0.08,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.deepPurpleAccent,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorStyle: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre mot de passe';
                                  }
                                  if (value.length < 6) {
                                    return 'Au moins 6 caractères';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.deepPurple
                                  .withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              shadowColor: Colors.deepPurple.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Se connecter',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Back to client
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Retour au site client'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
