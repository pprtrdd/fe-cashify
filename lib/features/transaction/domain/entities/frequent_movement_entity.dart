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
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FrequentMovementEntity({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.source,
    required this.amount,
    required this.frequency,
    required this.isArchived,
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
    isArchived,
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
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return FrequentMovementEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
