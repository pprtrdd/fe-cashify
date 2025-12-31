import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/domain/usecases/movement_usecase.dart';
import 'package:flutter/material.dart';

class MovementProvider extends ChangeNotifier {
  final MovementUseCase _movementUseCase = MovementUseCase();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> createMovement(MovementEntity movement) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _movementUseCase.add(movement);
    } catch (e) {
      /* Handle errors */
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
