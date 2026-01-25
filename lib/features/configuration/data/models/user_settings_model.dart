import 'package:cashify/features/configuration/domain/entities/user_settings_entity.dart';

class UserSettingsModel extends UserSettingsEntity {
  const UserSettingsModel({
    required super.billingPeriodType,
    required super.startDay,
    required super.endDay,
  });

  factory UserSettingsModel.fromFirestore(Map<String, dynamic> json) {
    final billing = json['billing'] as Map<String, dynamic>;

    return UserSettingsModel(
      billingPeriodType: billing['billingPeriodType'].toString(),
      startDay: (billing['startDay'] as num).toInt(),
      endDay: (billing['endDay'] as num).toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'billing': {
        'billingPeriodType': billingPeriodType,
        'startDay': startDay,
        'endDay': endDay,
      },
      'updatedAt': DateTime.now(),
    };
  }

  factory UserSettingsModel.fromEntity(UserSettingsEntity e) {
    return UserSettingsModel(
      billingPeriodType: e.billingPeriodType,
      startDay: e.startDay,
      endDay: e.endDay,
    );
  }
}
