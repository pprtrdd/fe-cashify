import 'package:cashify/features/transaction/data/models/category_model.dart';
import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CategoryRepository(this._firestore, this._auth);

  String get _currentUid =>
      _auth.currentUser?.uid ?? (throw Exception("Usuario no autenticado"));

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _firestore.collection('users').doc(_currentUid).collection('categories');

  Future<List<CategoryEntity>> fetchCategories() async {
    try {
      final snapshot = await _categoriesRef.orderBy('name').get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
          .cast<CategoryEntity>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<CategoryEntity> addCategory({
    required String name,
    required bool isExpense,
    required bool isExtra,
  }) async {
    try {
      final now = DateTime.now();
      final doc = await _categoriesRef.add({
        'name': name,
        'isExpense': isExpense,
        'isExtra': isExtra,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return CategoryModel(
        id: doc.id,
        name: name,
        isExpense: isExpense,
        isExtra: isExtra,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkCategoryHasMovements(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('movements')
          .where('userId', isEqualTo: _currentUid)
          .where('categoryId', isEqualTo: categoryId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoriesRef.doc(categoryId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> migrateMovementsAndDelete({
    required String fromCategoryId,
    required String toCategoryId,
  }) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('movements')
          .where('userId', isEqualTo: _currentUid)
          .where('categoryId', isEqualTo: fromCategoryId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'categoryId': toCategoryId});
      }
      batch.delete(_categoriesRef.doc(fromCategoryId));
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required bool isExpense,
    required bool isExtra,
  }) async {
    try {
      await _categoriesRef.doc(id).update({
        'name': name,
        'isExpense': isExpense,
        'isExtra': isExtra,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
