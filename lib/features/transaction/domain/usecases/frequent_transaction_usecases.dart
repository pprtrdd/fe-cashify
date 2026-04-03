import 'package:cashify/features/transaction/domain/entities/frequent_transaction_entity.dart';
import 'package:cashify/features/transaction/domain/repositories/frequent_transaction_repository.dart';

class FrequentTransactionUsecases {
  final FrequentTransactionRepository repository;

  FrequentTransactionUsecases({required this.repository});

  Future<void> save(FrequentTransactionEntity f) => repository.save(f);
  Future<void> update(FrequentTransactionEntity f) => repository.update(f);
  Future<void> archive(String id) => repository.archive(id);
  Future<List<FrequentTransactionEntity>> fetchAll() => repository.fetchAll();
}
