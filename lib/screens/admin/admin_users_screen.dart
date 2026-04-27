import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'email': data['email'] ?? '',
          'displayName': data['displayName'] ?? 'Utilisateur',
          'photoUrl': data['photoUrl'] ?? '',
          'role': data['role'] ?? 'user',
          'isActive': data['isActive'] ?? true,
          'createdAt': data['createdAt'],
          'orderCount': data['orderCount'] ?? 0,
          'totalSpent': (data['totalSpent'] ?? 0.0).toDouble(),
        };
      }).toList();

      setState(() {
        _users = users;
        _filtered = users;
        _isLoading = false;
      });
    } catch (e) {
      // Demo data fallback
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
        final name = (u['displayName'] as String).toLowerCase();
        final email = (u['email'] as String).toLowerCase();
        return name.contains(query.toLowerCase()) || email.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _toggleRole(Map<String, dynamic> user) async {
    final newRole = user['role'] == 'admin' ? 'user' : 'admin';
    try {
      await FirebaseFirestore.instance.collection('users').doc(user['id']).update({'role': newRole});
    } catch (_) {}
    setState(() {
      user['role'] = newRole;
    });
  }

  Future<void> _toggleActive(Map<String, dynamic> user) async {
    final newActive = !(user['isActive'] as bool);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user['id']).update({'isActive': newActive});
    } catch (_) {}
    setState(() {
      user['isActive'] = newActive;
    });
  }

  List<Map<String, dynamic>> _getDemoUsers() => [
        {'id': 'u1', 'email': 'ahmed.benali@email.com', 'displayName': 'Ahmed Ben Ali', 'photoUrl': '', 'role': 'admin', 'isActive': true, 'orderCount': 5, 'totalSpent': 899.95},
        {'id': 'u2', 'email': 'sana.trabelsi@email.com', 'displayName': 'Sana Trabelsi', 'photoUrl': '', 'role': 'user', 'isActive': true, 'orderCount': 2, 'totalSpent': 379.98},
        {'id': 'u3', 'email': 'med.karray@email.com', 'displayName': 'Mohamed Karray', 'photoUrl': '', 'role': 'user', 'isActive': true, 'orderCount': 1, 'totalSpent': 299.99},
        {'id': 'u4', 'email': 'leila.mansouri@email.com', 'displayName': 'Leila Mansouri', 'photoUrl': '', 'role': 'user', 'isActive': false, 'orderCount': 3, 'totalSpent': 650.00},
        {'id': 'u5', 'email': 'karim.bouzid@email.com', 'displayName': 'Karim Bouzid', 'photoUrl': '', 'role': 'user', 'isActive': true, 'orderCount': 0, 'totalSpent': 0.0},
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: const Text('Utilisateurs', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade200, height: 1)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats row
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _StatPill(label: 'Total', count: _users.length, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      _StatPill(label: 'Actifs', count: _users.where((u) => u['isActive'] == true).length, color: Colors.green),
                      const SizedBox(width: 8),
                      _StatPill(label: 'Admins', count: _users.where((u) => u['role'] == 'admin').length, color: Colors.orange),
                      const SizedBox(width: 8),
                      _StatPill(label: 'Inactifs', count: _users.where((u) => u['isActive'] == false).length, color: Colors.red),
                    ],
                  ),
                ),
                // Search
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: _filter,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un utilisateur...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
  const _StatPill({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text('$label: $count', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onToggleRole;
  final VoidCallback onToggleActive;

  const _UserCard({required this.user, required this.onToggleRole, required this.onToggleActive});

  @override
  Widget build(BuildContext context) {
    final isAdmin = user['role'] == 'admin';
    final isActive = user['isActive'] as bool;
    final name = user['displayName'] as String;
    final initials = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.deepPurple.withOpacity(0.15),
              backgroundImage: (user['photoUrl'] as String).isNotEmpty ? NetworkImage(user['photoUrl']) : null,
              child: (user['photoUrl'] as String).isEmpty
                  ? Text(initials, style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 6),
                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                          child: const Text('Admin', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  Text(user['email'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${user['orderCount']} commandes · ${(user['totalSpent'] as double).toStringAsFixed(2)} €',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'role') onToggleRole();
                if (value == 'active') onToggleActive();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'role',
                  child: Row(children: [
                    Icon(isAdmin ? Icons.person_remove_outlined : Icons.admin_panel_settings_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(isAdmin ? 'Retirer admin' : 'Rendre admin'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'active',
                  child: Row(children: [
                    Icon(isActive ? Icons.block : Icons.check_circle_outline, size: 18, color: isActive ? Colors.red : Colors.green),
                    const SizedBox(width: 8),
                    Text(isActive ? 'Désactiver' : 'Activer', style: TextStyle(color: isActive ? Colors.red : Colors.green)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}