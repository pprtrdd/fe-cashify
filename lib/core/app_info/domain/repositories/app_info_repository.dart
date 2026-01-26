import 'package:cashify/core/app_info/data/models/app_info_model.dart';
import 'package:cashify/core/app_info/domain/entities/app_info_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppInfoRepository {
  final FirebaseFirestore _firestore;

  AppInfoRepository(this._firestore);

  DocumentReference? get _appInfoRef {
    return _firestore.collection('app_config').doc('about');
  }

  Future<AppInfoEntity> getAppInfo() async {
    final ref = _appInfoRef;

    if (ref == null) throw Exception("ref is null");

    final doc = await ref.get();

    if (doc.exists && doc.data() != null) {
      return AppInfoModel.fromFirestore(doc.data() as Map<String, dynamic>);
    }
    return AppInfoEntity.empty();
  }
}
