import 'package:cashify/core/utils/billing_period_utils.dart';
import 'package:cashify/features/transaction/domain/entities/frequent_movement_entity.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/domain/usecases/category_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/frequent_movement_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/movement_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/payment_method_usecases.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum FrequentStatus { pending, completed, overdue, none }

class FrequentMovementProvider extends ChangeNotifier {
  final FrequentMovementUsecases usecases;
  final MovementUseCase movementUsecases;
  final CategoryUsecases categoryUsecases;
  final PaymentMethodUsecases paymentMethodUsecases;

  List<FrequentMovementEntity> _frequents = [];
  bool _isLoading = false;

  FrequentMovementProvider({
    required this.usecases,
    required this.movementUsecases,
    required this.categoryUsecases,
    required this.paymentMethodUsecases,
  });

  List<FrequentMovementEntity> get frequents => _frequents;
  bool get isLoading => _isLoading;

  Future<void> loadFrequent() async {
    _isLoading = true;
    notifyListeners();
    try {
      _frequents = await usecases.fetchAll();
    } catch (e) {
      debugPrint("Error loading frequent: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool shouldEnterInBillingPeriod(
    FrequentMovementEntity frequent,
    String billingPeriodId,
  ) {
    if (frequent.isArchived) return false;

    final parts = billingPeriodId.split('_');
    final pYear = int.parse(parts[0]);
    final pMonth = int.parse(parts[1]);

    final startParts = frequent.startPeriodId.split('_');
    final sYear = int.parse(startParts[0]);
    final sMonth = int.parse(startParts[1]);
    final diffMonths = (pYear - sYear) * 12 + (pMonth - sMonth);

    if (diffMonths < 0) return false;

    return diffMonths % frequent.frequency.months == 0;
  }

  FrequentStatus getStatus(
    FrequentMovementEntity frequent,
    String selectedBillingPeriodId,
    int startDay,
    List<MovementEntity> movements,
    String? currentLoadedBillingPeriodId,
  ) {
    if (!shouldEnterInBillingPeriod(frequent, selectedBillingPeriodId)) {
      return FrequentStatus.none;
    }

    final exists = movements.any(
      (m) =>
          m.frequentId == frequent.id &&
          m.billingPeriodId == selectedBillingPeriodId,
    );

    if (exists) {
      return FrequentStatus.completed;
    }

    final currentPeriodId = BillingPeriodUtils.generateId(
      DateTime.now(),
      startDay,
    );
    final parts = selectedBillingPeriodId.split('_');
    final selYear = int.parse(parts[0]);
    final selMonth = int.parse(parts[1]);

    final curParts = currentPeriodId.split('_');
    final curYear = int.parse(curParts[0]);
    final curMonth = int.parse(curParts[1]);

    if (selYear < curYear || (selYear == curYear && selMonth < curMonth)) {
      return FrequentStatus.overdue;
    }

    return FrequentStatus.pending;
  }

  List<FrequentMovementEntity> getPendingForBillingPeriod(
    String billingPeriodId,
    int startDay,
    List<MovementEntity> movements,
    String? currentLoadedBillingPeriodId,
  ) {
    return _frequents
        .where(
          (f) =>
              getStatus(
                    f,
                    billingPeriodId,
                    startDay,
                    movements,
                    currentLoadedBillingPeriodId,
                  ) ==
                  FrequentStatus.pending ||
              getStatus(
                    f,
                    billingPeriodId,
                    startDay,
                    movements,
                    currentLoadedBillingPeriodId,
                  ) ==
                  FrequentStatus.overdue,
        )
        .toList();
  }

  Future<void> enterMovement({
    required FrequentMovementEntity frequent,
    required int amount,
    required String paymentMethodId,
    required String billingPeriodId,
    required int startDay,
  }) async {
    final parts = billingPeriodId.split('_');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final now = DateTime.now();
    final movement = MovementEntity(
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

    await movementUsecases.add(movement);

    final updatedFrequent = frequent.copyWith(updatedAt: now);

    await usecases.update(updatedFrequent);
    await loadFrequent();
  }

  Future<void> saveFrequent(FrequentMovementEntity frequent) async {
    await usecases.save(frequent);
    await loadFrequent();
  }

  Future<void> archiveFrequent(String id) async {
    await usecases.archive(id);
    await loadFrequent();
  }
}
