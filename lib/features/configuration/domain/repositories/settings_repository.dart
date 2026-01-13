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

  Future<void> saveSettings(UserSettingsEntity settings) async {
    final ref = _settingsRef;
    if (ref == null) throw Exception("Usuario no autenticado");
    await ref.set(settings.toMap(), SetOptions(merge: true));
  }

  Future<UserSettingsEntity> getSettings() async {
    final ref = _settingsRef;

    if (ref == null) return UserSettingsEntity.empty();
    final doc = await ref.get();

    if (doc.exists && doc.data() != null) {
      return UserSettingsEntity.fromMap(doc.data() as Map<String, dynamic>);
    }

    return UserSettingsEntity.empty();
  }
}