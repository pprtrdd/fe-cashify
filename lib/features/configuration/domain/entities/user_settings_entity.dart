import 'package:equatable/equatable.dart';

class UserSettingsEntity extends Equatable {
  final String periodType; /* 'month_to_month' o 'custom_range' */
  final int startDay;
  final int endDay;

  const UserSettingsEntity({
    required this.periodType,
    required this.startDay,
    required this.endDay,
  });

  Map<String, dynamic> toMap() {
    return {
      'billing': {
        'periodType': periodType,
        'startDay': startDay,
        'endDay': endDay,
      },
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory UserSettingsEntity.fromMap(Map<String, dynamic> map) {
    final billing = map['billing'] as Map<String, dynamic>? ?? {};
    
    return UserSettingsEntity(
      periodType: billing['periodType'],
      startDay: (billing['startDay'] as num).toInt(),
      endDay: (billing['endDay'] as num).toInt(),
    );
  }

  factory UserSettingsEntity.empty() {
    return const UserSettingsEntity(
      periodType: 'month_to_month',
      startDay: 1,
      endDay: 31,
    );
  }

  @override
  List<Object?> get props => [periodType, startDay, endDay];

  UserSettingsEntity copyWith({
    String? periodType,
    int? startDay,
    int? endDay,
  }) {
    return UserSettingsEntity(
      periodType: periodType ?? this.periodType,
      startDay: startDay ?? this.startDay,
      endDay: endDay ?? this.endDay,
    );
  }
}