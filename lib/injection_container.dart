import 'package:get_it/get_it.dart';
import 'package:cashify/features/transaction/domain/repositories/category_repository.dart';
import 'package:cashify/features/transaction/domain/repositories/movement_repository.dart';
import 'package:cashify/features/transaction/domain/repositories/payment_method_repository.dart';
import 'package:cashify/features/transaction/domain/usecases/category_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/movement_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/payment_method_usecases.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';

/* Service Locator */
final sl = GetIt.instance;

Future<void> init() async {
  // ---------------------------------------------------------------------------
  // 1. PROVIDERS (Factories)
  // ---------------------------------------------------------------------------
  sl.registerFactory(
    () => MovementProvider(
      movementUseCase: sl(),
      categoryUsecases: sl(),
      paymentMethodUsecases: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // USE CASES (Lazy Singletons)
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => MovementUseCase(movementRepository: sl()));
  sl.registerLazySingleton(() => CategoryUsecases(categoryRepository: sl()));
  sl.registerLazySingleton(
    () => PaymentMethodUsecases(paymentMethodRepository: sl()),
  );

  // ---------------------------------------------------------------------------
  // REPOSITORIES (Lazy Singletons)
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => MovementRepository());
  sl.registerLazySingleton(() => CategoryRepository());
  sl.registerLazySingleton(() => PaymentMethodRepository());
}
