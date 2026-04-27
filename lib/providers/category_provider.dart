import 'package:flutter/foundation.dart' hide Category;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => [..._categories];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('categories')
          .orderBy('sortOrder')
          .get();

      _categories = snapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _categories = _getDemoCategories();
      notifyListeners();
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      final docRef = await _firestore
          .collection('categories')
          .add(category.toFirestore());
      _categories.add(category.copyWith(id: docRef.id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding category: $e');
      throw Exception('Erreur lors de l\'ajout de la catégorie');
    }
  }

  Future<void> updateCategory(Category updated) async {
    try {
      await _firestore
          .collection('categories')
          .doc(updated.id)
          .update(updated.toFirestore());
      final idx = _categories.indexWhere((c) => c.id == updated.id);
      if (idx != -1) {
        _categories[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
      throw Exception('Erreur lors de la mise à jour');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting category: $e');
      throw Exception('Erreur lors de la suppression');
    }
  }

  Future<void> toggleActive(Category category) async {
    await updateCategory(category.copyWith(isActive: !category.isActive));
  }

  List<Category> _getDemoCategories() => [
    Category(
      id: '1',
      name: 'Running',
      iconName: 'directions_run',
      sortOrder: 0,
      productCount: 12,
    ),
    Category(
      id: '2',
      name: 'Street',
      iconName: 'style',
      sortOrder: 1,
      productCount: 8,
    ),
    Category(
      id: '3',
      name: 'Basket',
      iconName: 'sports_basketball',
      sortOrder: 2,
      productCount: 5,
    ),
    Category(
      id: '4',
      name: 'Training',
      iconName: 'fitness_center',
      sortOrder: 3,
      productCount: 7,
    ),
  ];
}
