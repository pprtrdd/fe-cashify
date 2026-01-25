import 'package:cashify/features/transaction/domain/entities/payment_method_entity.dart';
import 'package:cashify/features/transaction/domain/repositories/payment_method_repository.dart';

class PaymentMethodUsecases {
  final PaymentMethodRepository repository;

  PaymentMethodUsecases({required this.repository});

  Future<List<PaymentMethodEntity>> fetchAll() async {
    return repository.fetchPaymentMethods();
  }
}
