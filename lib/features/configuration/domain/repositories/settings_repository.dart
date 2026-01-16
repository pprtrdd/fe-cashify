import 'package:cashify/features/configuration/data/models/user_settings_model.dart';
import 'package:cashify/features/configuration/domain/entities/user_settings_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SettingsRepository(this._firestore, this._auth);

  DocumentReference? get _settingsRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('config')
        .doc('settings');
  }

  Future<void> saveSettings(UserSettingsEntity e) async {
    final ref = _settingsRef;
    if (ref == null) throw Exception("Usuario no autenticado");

    final model = UserSettingsModel.fromEntity(e);
    await ref.set(model.toFirestore(), SetOptions(merge: true));
  }

  Future<UserSettingsEntity> getSettings() async {
    final ref = _settingsRef;
    if (ref == null) throw Exception("Usuario no autenticado");

    final doc = await ref.get();
    if (doc.exists && doc.data() != null) {
      return UserSettingsModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
      );
    }
    return UserSettingsEntity.empty();
  }
}
