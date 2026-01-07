class MovementEntity {
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

  MovementEntity({
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

  @override
  String toString() {
    return 'MovementEntity(categoryId: $categoryId, description: $description, source: $source, quantity: $quantity, amount: $amount, currentInstallment: $currentInstallment, totalInstallments: $totalInstallments, paymentMethodId: $paymentMethodId, billingPeriodYear: $billingPeriodYear, billingPeriodMonth: $billingPeriodMonth, notes: $notes, isCompleted: $isCompleted)';
  }

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
