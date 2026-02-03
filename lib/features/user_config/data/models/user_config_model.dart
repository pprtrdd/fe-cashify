import 'package:cashify/features/user_config/domain/entities/user_config_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserConfigModel extends UserConfigEntity {
  const UserConfigModel({
    required super.setupCompleted,
    required super.uid,
    required super.createdAt,
  });

  factory UserConfigModel.fromFirestore(Map<String, dynamic> json, String id) {
    return UserConfigModel(
      setupCompleted: json['setupCompleted'],
      uid: json['uid'].toString(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'setupCompleted': setupCompleted, 'uid': uid, 'createdAt': createdAt};
  }

  factory UserConfigModel.fromEntity(UserConfigEntity e) {
    return UserConfigModel(
      setupCompleted: e.setupCompleted,
      uid: e.uid,
      createdAt: e.createdAt,
    );
  }
}
