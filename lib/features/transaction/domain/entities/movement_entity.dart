class MovementEntity {
  final String categoryId;
  final String description;
  final String source;
  final String quantity;
  final String amount;
  final String currentInstallment;
  final String totalInstallments;
  final String paymentMethodId;
  final String billingPeriod;
  final String? notes;

  MovementEntity({
    required this.categoryId,
    required this.description,
    required this.source,
    required this.quantity,
    required this.amount,
    required this.currentInstallment,
    required this.totalInstallments,
    required this.paymentMethodId,
    required this.billingPeriod,
    this.notes,
  });

  @override
  String toString() {
    return 'MovementEntity(categoryId: $categoryId, description: $description, source: $source, quantity: $quantity, amount: $amount, currentInstallment: $currentInstallment, totalInstallments: $totalInstallments, paymentMethodId: $paymentMethodId, billingPeriod: $billingPeriod, notes: $notes)';
  }
}
