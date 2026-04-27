import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: const Text(
          'Gestion des catégories',
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
      body: Consumer<CategoryProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = provider.categories;

          if (categories.isEmpty) {
            return const Center(child: Text('Aucune catégorie'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (ctx, i) {
              final cat = categories[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                    child: Icon(
                      _iconFromName(cat.iconName),
                      color: Colors.deepPurple,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    cat.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${cat.productCount} produits'),
                  trailing: Switch(
                    value: cat.isActive,
                    onChanged: (_) => provider.toggleActive(cat),
                    activeColor: Colors.deepPurple,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconFromName(String? name) {
    return switch (name) {
      'directions_run' => Icons.directions_run,
      'style' => Icons.style,
      'sports_basketball' => Icons.sports_basketball,
      'fitness_center' => Icons.fitness_center,
      _ => Icons.category,
    };
  }
}
