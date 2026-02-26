import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/domain/repositories/movement_repository.dart';

class MovementUseCase {
  final MovementRepository repository;

  MovementUseCase({required this.repository});

  Future<void> add(MovementEntity movement) async {
    _validate(movement);
    return await repository.save(movement);
  }

  Future<void> addAll(List<MovementEntity> movements) async {
    for (final movement in movements) {
      _validate(movement);
    }
    return await repository.saveMultiple(movements);
  }

  Future<void> update(MovementEntity movement) async {
    return await repository.update(movement);
  }

  Future<void> updateGroup(MovementEntity movement, bool onlyPending) async {
    return await repository.updateGroup(movement, onlyPending);
  }

  Future<void> delete(MovementEntity movement) async {
    return await repository.delete(movement);
  }

  Future<void> deleteGroup(String billingPeriodId, String groupId) async {
    return await repository.deleteGroup(groupId);
  }

  Future<Map<String, String>> fetchLastMovementsPerFrequent() async {
    return await repository.fetchLastMovementsPerFrequent();
  }

  Future<List<MovementEntity>> fetchByBillingPeriod(String periodId) async {
    return await repository.fetchByBillingPeriod(periodId);
  }

  void _validate(MovementEntity movement) {
    if (movement.amount <= 0 ||
        movement.quantity <= 0 ||
        movement.currentInstallment <= 0 ||
        movement.totalInstallments <= 0 ||
        movement.currentInstallment > movement.totalInstallments ||
        movement.billingPeriodMonth < 1 ||
        movement.billingPeriodMonth > 12 ||
        movement.description.trim().isEmpty ||
        movement.categoryId.isEmpty ||
        movement.paymentMethodId.isEmpty) {
      throw Exception("Datos del movimiento inválidos o incompletos");
    }
  }
}
