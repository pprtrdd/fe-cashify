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

  @override
  List<Object?> get props => [periodType, startDay, endDay];

  factory UserSettingsEntity.empty() {
    return const UserSettingsEntity(
      periodType: 'month_to_month',
      startDay: 1,
      endDay: 31,
    );
  }

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
