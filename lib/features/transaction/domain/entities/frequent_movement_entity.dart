import 'package:equatable/equatable.dart';

enum FrequentFrequency {
  monthly(1, 'Mensual (cada un mes)'),
  bimonthly(2, 'Bimestral (cada dos meses)'),
  trimestral(3, 'Trimestral (cada tres meses)'),
  cuatrimestral(4, 'Cuatrimestral (cada cuatro meses)'),
  semestral(6, 'Semestral (cada seis meses)'),
  anual(12, 'Anual (cada doce meses)');

  final int months;
  final String label;
  const FrequentFrequency(this.months, this.label);

  static FrequentFrequency fromMonths(int months) {
    return FrequentFrequency.values.firstWhere(
      (f) => f.months == months,
      orElse: () => FrequentFrequency.monthly,
    );
  }
}

class FrequentMovementEntity extends Equatable {
  final String id;
  final String categoryId;
  final String description;
  final String source;
  final int amount;
  final FrequentFrequency frequency;
  final int paymentDay;
  final bool isArchived;
  final String startPeriodId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FrequentMovementEntity({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.source,
    required this.amount,
    required this.frequency,
    required this.paymentDay,
    required this.isArchived,
    required this.startPeriodId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    categoryId,
    description,
    source,
    amount,
    frequency,
    paymentDay,
    isArchived,
    startPeriodId,
    createdAt,
    updatedAt,
  ];

  FrequentMovementEntity copyWith({
    String? id,
    String? categoryId,
    String? description,
    String? source,
    int? amount,
    FrequentFrequency? frequency,
    int? paymentDay,
    bool? isArchived,
    String? startPeriodId,
    DateTime? updatedAt,
  }) {
    return FrequentMovementEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      paymentDay: paymentDay ?? this.paymentDay,
      isArchived: isArchived ?? this.isArchived,
      startPeriodId: startPeriodId ?? this.startPeriodId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
