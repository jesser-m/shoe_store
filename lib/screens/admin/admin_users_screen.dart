import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final UserService _userService = UserService();
  List<AppUser> _users = [];
  List<AppUser> _filtered = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _userService.getAllUsers();
      setState(() {
        _users = users;
        _filtered = users;
        _isLoading = false;
      });
    } catch (e) {
      final demo = _getDemoUsers();
      setState(() {
        _users = demo;
        _filtered = demo;
        _isLoading = false;
      });
    }
  }

  void _filter(String query) {
    setState(() {
      _search = query;
      _filtered = _users.where((u) {
        final name = (u.displayName ?? '').toLowerCase();
        final email = u.email.toLowerCase();
        return name.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _toggleRole(AppUser user) async {
    final newRole = user.isAdmin ? 'user' : 'admin';
    try {
      await _userService.updateUserRole(user.id, newRole);
    } catch (_) {}
    setState(() {
      final idx = _users.indexWhere((u) => u.id == user.id);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(role: newRole);
      }
      _filter(_search);
    });
  }

  Future<void> _toggleActive(AppUser user) async {
    final newActive = !user.isActive;
    try {
      await _userService.toggleUserActive(user.id, newActive);
    } catch (_) {}
    setState(() {
      final idx = _users.indexWhere((u) => u.id == user.id);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(isActive: newActive);
      }
      _filter(_search);
    });
  }

  List<AppUser> _getDemoUsers() => [
    AppUser(
      id: 'u1',
      email: 'ahmed.benali@email.com',
      displayName: 'Ahmed Ben Ali',
      role: 'admin',
      createdAt: DateTime.now(),
      isActive: true,
    ),
    AppUser(
      id: 'u2',
      email: 'sana.trabelsi@email.com',
      displayName: 'Sana Trabelsi',
      role: 'user',
      createdAt: DateTime.now(),
      isActive: true,
    ),
    AppUser(
      id: 'u3',
      email: 'med.karray@email.com',
      displayName: 'Mohamed Karray',
      role: 'user',
      createdAt: DateTime.now(),
      isActive: true,
    ),
    AppUser(
      id: 'u4',
      email: 'leila.mansouri@email.com',
      displayName: 'Leila Mansouri',
      role: 'user',
      createdAt: DateTime.now(),
      isActive: false,
    ),
    AppUser(
      id: 'u5',
      email: 'karim.bouzid@email.com',
      displayName: 'Karim Bouzid',
      role: 'user',
      createdAt: DateTime.now(),
      isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: const Text(
          'Utilisateurs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      _StatPill(
                        label: 'Total',
                        count: _users.length,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        label: 'Actifs',
                        count: _users.where((u) => u.isActive).length,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        label: 'Admins',
                        count: _users.where((u) => u.isAdmin).length,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        label: 'Inactifs',
                        count: _users.where((u) => !u.isActive).length,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: _filter,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un utilisateur...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(child: Text('Aucun utilisateur trouvé'))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _UserCard(
                            user: _filtered[i],
                            onToggleRole: () => _toggleRole(_filtered[i]),
                            onToggleActive: () => _toggleActive(_filtered[i]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatPill({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback onToggleRole;
  final VoidCallback onToggleActive;

  const _UserCard({
    required this.user,
    required this.onToggleRole,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.isAdmin;
    final isActive = user.isActive;
    final name = user.displayName ?? 'Utilisateur';
    final initials = name
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.deepPurple.withValues(alpha: 0.15),
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isActive ? 'Actif' : 'Inactif',
                    style: TextStyle(
                      color: isActive ? Colors.green : Colors.red,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'role') onToggleRole();
                if (value == 'active') onToggleActive();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'role',
                  child: Row(
                    children: [
                      Icon(
                        isAdmin
                            ? Icons.person_remove_outlined
                            : Icons.admin_panel_settings_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(isAdmin ? 'Retirer admin' : 'Rendre admin'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'active',
                  child: Row(
                    children: [
                      Icon(
                        isActive ? Icons.block : Icons.check_circle_outline,
                        size: 18,
                        color: isActive ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isActive ? 'Désactiver' : 'Activer',
                        style: TextStyle(
                          color: isActive ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
