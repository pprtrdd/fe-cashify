import 'package:cashify/features/transaction/data/models/category_model.dart';
import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CategoryRepository(this._firestore, this._auth);

  CollectionReference? get _categoriesRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Usuario no autenticado");

    return _firestore.collection('users').doc(uid).collection('categories');
  }

  Future<List<CategoryEntity>> fetchCategories() async {
    try {
      final ref = _categoriesRef;
      if (ref == null) throw Exception('ref is null');
      final snapshot = await ref.orderBy('name').get();

      return snapshot.docs.map((doc) {
        return CategoryModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      rethrow;
    }
  }
}
