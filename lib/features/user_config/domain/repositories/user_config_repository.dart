import 'package:cashify/core/utils/billing_period_utils.dart';
import 'package:cashify/features/settings/data/models/user_settings_model.dart'; // Tu modelo
import 'package:cashify/features/user_config/data/models/user_config_model.dart';
import 'package:cashify/features/user_config/domain/entities/user_config_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserConfigRepository {
  final FirebaseFirestore _firestore;

  UserConfigRepository(this._firestore, FirebaseAuth _);

  CollectionReference get _categoriesTemplateRef => _firestore
      .collection('app_defaults')
      .doc('categories_v1')
      .collection('items');

  DocumentReference<Map<String, dynamic>> get _configTemplateRef => _firestore
      .collection('app_defaults')
      .doc('config_v1')
      .collection('config')
      .doc('settings');

  Future<void> initializeUserData(String uid) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    final catTemplate = await _categoriesTemplateRef.get();
    final configSnapshot = await _configTemplateRef.get();

    int startDay = 1;

    if (configSnapshot.exists && configSnapshot.data() != null) {
      final defaultSettings = UserSettingsModel.fromFirestore(
        configSnapshot.data()!,
      );
      startDay = defaultSettings.startDay;

      batch.set(
        _firestore
            .collection('users')
            .doc(uid)
            .collection('config')
            .doc('settings'),
        defaultSettings.toFirestore(),
      );
    }

    for (var doc in catTemplate.docs) {
      batch.set(
        _firestore
            .collection('users')
            .doc(uid)
            .collection('categories')
            .doc(doc.id),
        doc.data(),
      );
    }

    final String currentPeriodId = BillingPeriodUtils.generateId(now, startDay);

    batch.set(
      _firestore
          .collection('users')
          .doc(uid)
          .collection('billing_periods')
          .doc(currentPeriodId),
      {'id': currentPeriodId, 'createdAt': FieldValue.serverTimestamp()},
    );

    final configUserEntity = UserConfigEntity(
      setupCompleted: true,
      uid: uid,
      createdAt: now,
    );

    batch.set(
      _firestore.collection('users').doc(uid),
      UserConfigModel.fromEntity(configUserEntity).toFirestore(),
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<bool> isUserInitialized(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists && (doc.data()?['setupCompleted'] ?? false);
  }
}
