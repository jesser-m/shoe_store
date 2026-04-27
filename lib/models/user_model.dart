import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String role; // 'client', 'admin'
  final String? displayName;
  final DateTime createdAt;
  final bool isActive;

  AppUser({
    required this.id,
    required this.email,
    this.role = 'client',
    this.displayName,
    required this.createdAt,
    this.isActive = true,
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      role: data['role'] ?? 'client',
      displayName: data['displayName'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? role,
    String? displayName,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
