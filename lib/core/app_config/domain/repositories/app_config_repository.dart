import 'package:cashify/core/app_config/data/models/app_config_model.dart';
import 'package:cashify/core/app_config/domain/entities/app_config_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppConfigRepository {
  final FirebaseFirestore _firestore;

  AppConfigRepository(this._firestore);

  DocumentReference? get _appConfigRef {
    return _firestore.collection('app_config').doc('about');
  }

  Future<AppConfigEntity> getAppConfig() async {
    final ref = _appConfigRef;

    if (ref == null) throw Exception("ref is null");

    final doc = await ref.get();

    if (doc.exists && doc.data() != null) {
      return AppConfigModel.fromFirestore(doc.data() as Map<String, dynamic>);
    }
    return AppConfigEntity.empty();
  }
}
