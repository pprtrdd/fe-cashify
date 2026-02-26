import 'package:cashify/features/transaction/domain/entities/frequent_movement_entity.dart';
import 'package:cashify/features/transaction/domain/repositories/frequent_movement_repository.dart';

class FrequentMovementUsecases {
  final FrequentMovementRepository repository;

  FrequentMovementUsecases({required this.repository});

  Future<void> save(FrequentMovementEntity f) => repository.save(f);
  Future<void> update(FrequentMovementEntity f) => repository.update(f);
  Future<void> archive(String id) => repository.archive(id);
  Future<List<FrequentMovementEntity>> fetchAll() => repository.fetchAll();
}
