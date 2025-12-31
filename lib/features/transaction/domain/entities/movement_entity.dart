class MovementEntity {
  /* TODO: Add category field */
  final String description;
  final String source;
  final String quantity;
  final String amount;
  final String currentInstallment;
  final String totalInstallments;
  final String paymentMethod;
  final String billingPeriod;
  final String? notes;

  MovementEntity({
    required this.description,
    required this.source,
    required this.quantity,
    required this.amount,
    required this.currentInstallment,
    required this.totalInstallments,
    required this.paymentMethod,
    required this.billingPeriod,
    this.notes,
  });
}
