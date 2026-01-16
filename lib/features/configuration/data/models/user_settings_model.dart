import 'package:cashify/features/configuration/domain/entities/user_settings_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettingsModel extends UserSettingsEntity {
  const UserSettingsModel({
    required super.periodType,
    required super.startDay,
    required super.endDay,
  });

  factory UserSettingsModel.fromFirestore(Map<String, dynamic> json) {
    final billing = json['billing'] as Map<String, dynamic>;

    return UserSettingsModel(
      periodType: billing['periodType'].toString(),
      startDay: (billing['startDay'] as num).toInt(),
      endDay: (billing['endDay'] as num).toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'billing': {
        'periodType': periodType,
        'startDay': startDay,
        'endDay': endDay,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserSettingsModel.fromEntity(UserSettingsEntity e) {
    return UserSettingsModel(
      periodType: e.periodType,
      startDay: e.startDay,
      endDay: e.endDay,
    );
  }
}
