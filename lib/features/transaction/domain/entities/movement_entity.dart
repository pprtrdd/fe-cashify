import 'package:equatable/equatable.dart';

class MovementEntity extends Equatable {
  final String id;
  final String categoryId;
  final String description;
  final String source;
  final int quantity;
  final int amount;
  final int currentInstallment;
  final int totalInstallments;
  final String paymentMethodId;
  final int billingPeriodYear;
  final int billingPeriodMonth;
  final String? notes;
  final bool isCompleted;

  const MovementEntity({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.source,
    required this.quantity,
    required this.amount,
    required this.currentInstallment,
    required this.totalInstallments,
    required this.paymentMethodId,
    required this.billingPeriodYear,
    required this.billingPeriodMonth,
    this.notes,
    required this.isCompleted,
  });

  int get totalAmount => quantity * amount;
  bool get isInstallment => totalInstallments > 1;

  @override
  List<Object?> get props => [
    id,
    categoryId,
    description,
    source,
    quantity,
    amount,
    currentInstallment,
    totalInstallments,
    paymentMethodId,
    billingPeriodYear,
    billingPeriodMonth,
    notes,
    isCompleted,
  ];

  MovementEntity copyWith({
    String? id,
    String? categoryId,
    String? description,
    String? source,
    int? quantity,
    int? amount,
    int? currentInstallment,
    int? totalInstallments,
    String? paymentMethodId,
    int? billingPeriodYear,
    int? billingPeriodMonth,
    String? notes,
    bool? isCompleted,
  }) {
    return MovementEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      source: source ?? this.source,
      quantity: quantity ?? this.quantity,
      amount: amount ?? this.amount,
      currentInstallment: currentInstallment ?? this.currentInstallment,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      billingPeriodYear: billingPeriodYear ?? this.billingPeriodYear,
      billingPeriodMonth: billingPeriodMonth ?? this.billingPeriodMonth,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
