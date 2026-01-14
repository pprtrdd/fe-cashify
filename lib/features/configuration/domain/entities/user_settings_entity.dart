import 'package:equatable/equatable.dart';

class UserSettingsEntity extends Equatable {
  final String billingPeriodType; /* 'month_to_month' o 'custom_range' */
  final int startDay;
  final int endDay;

  const UserSettingsEntity({
    required this.billingPeriodType,
    required this.startDay,
    required this.endDay,
  });

  @override
  List<Object?> get props => [billingPeriodType, startDay, endDay];

  factory UserSettingsEntity.empty() {
    return const UserSettingsEntity(
      billingPeriodType: 'month_to_month',
      startDay: 1,
      endDay: 31,
    );
  }

  UserSettingsEntity copyWith({
    String? billingPeriodType,
    int? startDay,
    int? endDay,
  }) {
    return UserSettingsEntity(
      billingPeriodType: billingPeriodType ?? this.billingPeriodType,
      startDay: startDay ?? this.startDay,
      endDay: endDay ?? this.endDay,
    );
  }
}
