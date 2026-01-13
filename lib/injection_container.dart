import 'package:cashify/features/configuration/domain/repositories/settings_repository.dart';
import 'package:cashify/features/configuration/domain/usecases/settings_usecases.dart';
import 'package:cashify/features/configuration/presentation/providers/settings_provider.dart';
import 'package:cashify/features/transaction/domain/repositories/category_repository.dart';
import 'package:cashify/features/transaction/domain/repositories/movement_repository.dart';
import 'package:cashify/features/transaction/domain/repositories/payment_method_repository.dart';
import 'package:cashify/features/transaction/domain/usecases/category_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/movement_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/payment_method_usecases.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

/* Service Locator */
final sl = GetIt.instance;

Future<void> init() async {
  /* --------------------------------------------------------------------------- */
  /* PROVIDERS (Factories)                                                       */
  /* --------------------------------------------------------------------------- */
  sl.registerFactory(
    () => MovementProvider(
      movementUseCase: sl(),
      categoryUsecases: sl(),
      paymentMethodUsecases: sl(),
    ),
  );
  sl.registerFactory(() => SettingsProvider(settingsUsecases: sl()));

  /* --------------------------------------------------------------------------- */
  /* USE CASES (Lazy Singletons)                                                 */
  /* --------------------------------------------------------------------------- */
  sl.registerLazySingleton(() => MovementUseCase(movementRepository: sl()));
  sl.registerLazySingleton(() => CategoryUsecases(categoryRepository: sl()));
  sl.registerLazySingleton(
    () => PaymentMethodUsecases(paymentMethodRepository: sl()),
  );
  sl.registerLazySingleton(() => SettingsUsecases(repository: sl()));

  /* --------------------------------------------------------------------------- */
  /* REPOSITORIES (Lazy Singletons)                                              */
  /* --------------------------------------------------------------------------- */
  sl.registerLazySingleton(
    () => MovementRepository(sl<FirebaseFirestore>(), sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton(
    () => CategoryRepository(sl<FirebaseFirestore>(), sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton(
    () => PaymentMethodRepository(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton(
    () => SettingsRepository(sl<FirebaseFirestore>(), sl<FirebaseAuth>()),
  );

  /* --------------------------------------------------------------------------- */
  /* EXTERNAL (Firebase)                                                         */
  /* --------------------------------------------------------------------------- */
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
}
