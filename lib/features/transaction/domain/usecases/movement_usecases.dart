import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/domain/repositories/movement_repository.dart';

class MovementUseCase {
  final MovementRepository movementRepository;

  MovementUseCase({required this.movementRepository});

  Future<void> add(MovementEntity movement) async {
    if (movement.amount <= 0 ||
        movement.quantity <= 0 ||
        movement.currentInstallment < 0 ||
        movement.totalInstallments < 0 ||
        movement.currentInstallment > movement.totalInstallments ||
        movement.billingPeriodMonth < 1 ||
        movement.billingPeriodMonth > 12 ||
        movement.billingPeriodYear < 0 ||
        movement.description.isEmpty ||
        movement.source.isEmpty ||
        movement.categoryId.isEmpty ||
        movement.paymentMethodId.isEmpty) {
      throw Exception("Movimiento inválido");
    }

    return await movementRepository.save(movement);
  }

  Future<void> update(MovementEntity movement) async {
    return await movementRepository.update(movement);
  }

  Future<void> delete(String id) async {
    return await movementRepository.delete(id);
  }

  Future<List<MovementEntity>> fetchByMonth(int year, int month) async {
    return await movementRepository.fetchByMonth(year, month);
  }
}
