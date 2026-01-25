import 'package:cashify/features/transaction/domain/repositories/billing_period_repository.dart';

class BillingPeriodUsecases {
  final BillingPeriodRepository repository;

  BillingPeriodUsecases({required this.repository});

  Future<List<String>> fetchAll() async {
    return await repository.getAllPeriodIds();
  }
}
