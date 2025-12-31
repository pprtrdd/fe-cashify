import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';

class MovementUseCase {
  Future<void> add(MovementEntity movement) async {
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> update(MovementEntity movement) async {
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> delete(String id) async {
    await Future.delayed(Duration(seconds: 1));
  }

  Future<List<MovementEntity>> getAll() async {
    return [];
  }
}
