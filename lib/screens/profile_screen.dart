import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import './admin/admin_dashbord_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.appUser;
    final isAdmin = auth.isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Mon Profil',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar & Name
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'Utilisateur',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? auth.user?.email ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAdmin
                          ? Colors.deepPurpleAccent.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAdmin
                            ? Colors.deepPurpleAccent
                            : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAdmin ? Icons.verified_user : Icons.person_outline,
                          size: 14,
                          color: isAdmin
                              ? Colors.deepPurpleAccent
                              : Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAdmin ? 'Administrateur' : 'Client',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isAdmin
                                ? Colors.deepPurpleAccent
                                : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Account Info Card
            _buildInfoCard(context, user, auth),
            const SizedBox(height: 24),
            // Admin Access Button
            if (isAdmin) _buildAdminButton(context),
            const SizedBox(height: 16),
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Se déconnecter',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: Colors.redAccent.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, user, AuthProvider auth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(
            Icons.email_outlined,
            'Email',
            user?.email ?? auth.user?.email ?? 'Non disponible',
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoTile(
            Icons.verified_user_outlined,
            'Statut du compte',
            auth.user?.emailVerified ?? false ? 'Vérifié' : 'Non vérifié',
            trailing: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: auth.user?.emailVerified ?? false
                    ? Colors.green
                    : Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoTile(
            Icons.calendar_today_outlined,
            'Membre depuis',
            user?.createdAt != null
                ? '${user.createdAt.day.toString().padLeft(2, '0')}/${user.createdAt.month.toString().padLeft(2, '0')}/${user.createdAt.year}'
                : 'Non disponible',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF1A1A2E)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildAdminButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        },
        icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
        label: Text(
          'Panneau d\'administration',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: Colors.deepPurple.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
