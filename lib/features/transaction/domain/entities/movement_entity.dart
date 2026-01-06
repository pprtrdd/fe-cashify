class MovementEntity {
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
}
