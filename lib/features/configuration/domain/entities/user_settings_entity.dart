import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class UserSettingsEntity extends Equatable {
  final String billingPeriodType; /* 'month_to_month' o 'custom_range' */
  final int startDay;
  final int endDay;

  const UserSettingsEntity({
    required this.billingPeriodType,
    required this.startDay,
    required this.endDay,
  });

  DateTimeRange getDateTimeRangeFromBillingPeriod(String billingPeriodId) {
    final parts = billingPeriodId.split('_');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    if (billingPeriodType == 'month_to_month') {
      return DateTimeRange(
        start: DateTime(year, month, 1),
        end: DateTime(year, month + 1, 0, 23, 59, 59),
      );
    } else {
      final startDate = DateTime(year, month - 1, startDay);
      final endDate = DateTime(year, month, endDay, 23, 59, 59);
      return DateTimeRange(start: startDate, end: endDate);
    }
  }

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
