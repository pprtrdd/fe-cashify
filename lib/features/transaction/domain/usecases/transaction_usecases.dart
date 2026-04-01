import 'package:cashify/features/transaction/domain/entities/transaction_entity.dart';
import 'package:cashify/features/transaction/domain/repositories/transaction_repository.dart';

class TransactionUseCase {
  final TransactionRepository repository;

  TransactionUseCase({required this.repository});

  Future<void> add(TransactionEntity transaction) async {
    _validate(transaction);
    return await repository.save(transaction);
  }

  Future<void> addAll(List<TransactionEntity> transactions) async {
    for (final transaction in transactions) {
      _validate(transaction);
    }
    return await repository.saveMultiple(transactions);
  }

  Future<void> update(TransactionEntity transaction) async {
    return await repository.update(transaction);
  }

  Future<void> updateGroup(TransactionEntity transaction, bool onlyPending) async {
    return await repository.updateGroup(transaction, onlyPending);
  }

  Future<void> delete(TransactionEntity transaction) async {
    return await repository.delete(transaction);
  }

  Future<void> deleteGroup(String billingPeriodId, String groupId) async {
    return await repository.deleteGroup(groupId);
  }

  Future<Map<String, String>> fetchLastTransactionsPerFrequent() async {
    return await repository.fetchLastTransactionsPerFrequent();
  }

  Future<List<TransactionEntity>> fetchByBillingPeriodId(
    String billingPeriodId,
  ) async {
    return await repository.fetchByBillingPeriodId(billingPeriodId);
  }

  void _validate(TransactionEntity transaction) {
    if (transaction.amount <= 0 ||
        transaction.quantity <= 0 ||
        transaction.currentInstallment <= 0 ||
        transaction.totalInstallments <= 0 ||
        transaction.currentInstallment > transaction.totalInstallments ||
        transaction.billingPeriodMonth < 1 ||
        transaction.billingPeriodMonth > 12 ||
        transaction.description.trim().isEmpty ||
        transaction.categoryId.isEmpty ||
        transaction.paymentMethodId.isEmpty) {
      throw Exception("Datos del movimiento inválidos o incompletos");
    }
  }
}
