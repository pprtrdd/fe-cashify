import 'package:cashify/features/transaction/data/models/category_model.dart';
import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<CategoryEntity>> fetchCategories() async {
    try {
      final user = _auth.currentUser;

      if (user == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .get();

      return snapshot.docs.map((doc) {
        return CategoryModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
