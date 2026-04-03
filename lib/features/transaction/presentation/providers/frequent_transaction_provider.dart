import 'package:cashify/core/utils/billing_period_utils.dart';
import 'package:cashify/features/transaction/domain/entities/frequent_transaction_entity.dart';
import 'package:cashify/features/transaction/domain/entities/transaction_entity.dart';
import 'package:cashify/features/transaction/domain/usecases/category_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/frequent_transaction_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/transaction_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/payment_method_usecases.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum FrequentStatus { pending, completed, overdue, none }

class FrequentTransactionProvider extends ChangeNotifier {
  final FrequentTransactionUsecases usecases;
  final TransactionUseCase transactionUsecases;
  final CategoryUsecases categoryUsecases;
  final PaymentMethodUsecases paymentMethodUsecases;

  List<FrequentTransactionEntity> _frequents = [];
  Map<String, String> _lastMovePeriodByFrequent = {};
  bool _isLoading = false;

  FrequentTransactionProvider({
    required this.usecases,
    required this.transactionUsecases,
    required this.categoryUsecases,
    required this.paymentMethodUsecases,
  });

  List<FrequentTransactionEntity> get frequents => _frequents;
  Map<String, String> get lastMovePeriodByFrequent => _lastMovePeriodByFrequent;
  bool get isLoading => _isLoading;

  Future<void> loadFrequent() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        usecases.fetchAll(),
        transactionUsecases.fetchLastTransactionsPerFrequent(),
      ]);
      _frequents = results[0] as List<FrequentTransactionEntity>;
      _lastMovePeriodByFrequent = results[1] as Map<String, String>;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool shouldEnterInBillingPeriod(
    FrequentTransactionEntity frequent,
    String billingPeriodId,
  ) {
    if (frequent.isArchived) return false;

    final lastBillingPeriodId = _lastMovePeriodByFrequent[frequent.id];
    if (lastBillingPeriodId == null) return false;

    final parts = billingPeriodId.split('_');
    final pYear = int.parse(parts[0]);
    final pMonth = int.parse(parts[1]);

    final lastParts = lastBillingPeriodId.split('_');
    final lYear = int.parse(lastParts[0]);
    final lMonth = int.parse(lastParts[1]);
    final diffMonths = (pYear - lYear) * 12 + (pMonth - lMonth);
    if (diffMonths == 0) return true;

    return diffMonths % frequent.frequency.months == 0;
  }

  int? getBillingPeriodsAway(
    FrequentTransactionEntity frequent,
    String currentBillingPeriodId,
  ) {
    if (frequent.isArchived) return null;

    final lastBillingPeriodId = _lastMovePeriodByFrequent[frequent.id];
    if (lastBillingPeriodId == null) return null;

    final parts = currentBillingPeriodId.split('_');
    final pYear = int.parse(parts[0]);
    final pMonth = int.parse(parts[1]);

    final lastParts = lastBillingPeriodId.split('_');
    final lYear = int.parse(lastParts[0]);
    final lMonth = int.parse(lastParts[1]);

    final diffMonths = (pYear - lYear) * 12 + (pMonth - lMonth);

    final freq = frequent.frequency.months;
    int k;
    if (diffMonths < 0) {
      k = 1;
    } else {
      k = (diffMonths ~/ freq) + 1;
    }
    return k * freq - diffMonths;
  }

  FrequentStatus getStatus(
    FrequentTransactionEntity frequent,
    String selectedBillingPeriodId,
    int startDay,
    List<TransactionEntity> transactions,
  ) {
    final selParts = selectedBillingPeriodId.split('_');
    final selYear = int.parse(selParts[0]);
    final selMonth = int.parse(selParts[1]);
    final normalizedSelectedId = "${selYear}_$selMonth";

    final exists = transactions.any((m) {
      final mParts = m.billingPeriodId.split('_');
      final mYear = int.parse(mParts[0]);
      final mMonth = int.parse(mParts[1]);
      final normalizedMId = "${mYear}_$mMonth";

      return m.frequentId == frequent.id &&
          normalizedMId == normalizedSelectedId;
    });

    if (exists) {
      return FrequentStatus.completed;
    }

    if (!shouldEnterInBillingPeriod(frequent, selectedBillingPeriodId)) {
      return FrequentStatus.none;
    }

    final currentPeriodId = BillingPeriodUtils.generateId(
      DateTime.now(),
      startDay,
    );
    final curParts = currentPeriodId.split('_');
    final curYear = int.parse(curParts[0]);
    final curMonth = int.parse(curParts[1]);

    if (selYear < curYear || (selYear == curYear && selMonth < curMonth)) {
      return FrequentStatus.overdue;
    }

    return FrequentStatus.pending;
  }

  List<FrequentTransactionEntity> getPendingForBillingPeriod(
    String billingPeriodId,
    int startDay,
    List<TransactionEntity> transactions,
  ) {
    return _frequents
        .where(
          (f) =>
              getStatus(f, billingPeriodId, startDay, transactions) ==
                  FrequentStatus.pending ||
              getStatus(f, billingPeriodId, startDay, transactions) ==
                  FrequentStatus.overdue,
        )
        .toList();
  }

  Future<void> enterTransaction({
    required FrequentTransactionEntity frequent,
    required int amount,
    required String paymentMethodId,
    required String billingPeriodId,
    required int startDay,
  }) async {
    final parts = billingPeriodId.split('_');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final now = DateTime.now();
    final transaction = TransactionEntity(
      id: '',
      userId: '',
      groupId: const Uuid().v4(),
      categoryId: frequent.categoryId,
      description: frequent.description,
      source: frequent.source,
      quantity: 1,
      amount: amount,
      currentInstallment: 1,
      totalInstallments: 1,
      paymentMethodId: paymentMethodId,
      billingPeriodYear: year,
      billingPeriodMonth: month,
      billingPeriodId: billingPeriodId,
      isCompleted: true,
      createdAt: now,
      updatedAt: now,
      frequentId: frequent.id,
    );

    await transactionUsecases.add(transaction);

    final updatedFrequent = frequent.copyWith(updatedAt: now);

    await usecases.update(updatedFrequent);
    await loadFrequent();
  }

  Future<void> saveFrequent(FrequentTransactionEntity frequent) async {
    await usecases.save(frequent);
    await loadFrequent();
  }

  Future<void> archiveFrequent(String id) async {
    await usecases.archive(id);
    await loadFrequent();
  }
}
