import 'package:cashify/core/app_config/domain/repositories/app_config_repository.dart';
import 'package:cashify/features/transaction/presentation/providers/category_provider.dart';
import 'package:cashify/core/app_config/domain/usecases/app_config_usecases.dart';
import 'package:cashify/core/app_config/presentation/providers/app_config_provider.dart';
import 'package:cashify/core/auth/auth_service.dart';
import 'package:cashify/features/settings/domain/repositories/settings_repository.dart';
import 'package:cashify/features/settings/domain/usecases/settings_usecases.dart';
import 'package:cashify/features/settings/presentation/providers/settings_provider.dart';
import 'package:cashify/features/transaction/domain/repositories/billing_period_repository.dart';
import 'package:cashify/features/transaction/domain/repositories/category_repository.dart';
import 'package:cashify/features/transaction/domain/repositories/movement_repository.dart';
import 'package:cashify/features/transaction/domain/repositories/payment_method_repository.dart';
import 'package:cashify/features/transaction/domain/usecases/billing_period_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/category_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/movement_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/payment_method_usecases.dart';
import 'package:cashify/features/transaction/presentation/providers/billing_period_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/user_config/domain/repositories/user_config_repository.dart';
import 'package:cashify/features/user_config/domain/usecases/user_config_usecases.dart';
import 'package:cashify/features/user_config/presentation/providers/user_config_provider.dart';
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
  sl.registerFactory(() => BillingPeriodProvider(usecases: sl()));
  sl.registerFactory(() => SettingsProvider(settingsUsecases: sl()));
  sl.registerFactory(() => AppConfigProvider(appConfigUsecases: sl()));
  sl.registerFactory(
    () => UserConfigProvider(userConfigUsecases: sl(), authService: sl()),
  );
  sl.registerFactory(() => CategoryProvider(categoryUsecases: sl()));

  /* --------------------------------------------------------------------------- */
  /* USE CASES (Lazy Singletons)                                                 */
  /* --------------------------------------------------------------------------- */
  sl.registerLazySingleton(() => MovementUseCase(repository: sl()));
  sl.registerLazySingleton(() => CategoryUsecases(repository: sl()));
  sl.registerLazySingleton(() => PaymentMethodUsecases(repository: sl()));
  sl.registerLazySingleton(() => SettingsUsecases(repository: sl()));
  sl.registerLazySingleton(() => BillingPeriodUsecases(repository: sl()));
  sl.registerLazySingleton(() => AppConfigUsecases(repository: sl()));
  sl.registerLazySingleton(() => UserConfigUsecases(repository: sl()));

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
  sl.registerLazySingleton(
    () => BillingPeriodRepository(sl<FirebaseFirestore>(), sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton(() => AppConfigRepository(sl<FirebaseFirestore>()));
  sl.registerLazySingleton(
    () => UserConfigRepository(sl<FirebaseFirestore>(), sl<FirebaseAuth>()),
  );

  /* --------------------------------------------------------------------------- */
  /* SERVICES (Lazy Singletons)                                                  */
  /* --------------------------------------------------------------------------- */
  sl.registerLazySingleton(() => AuthService());

  /* --------------------------------------------------------------------------- */
  /* EXTERNAL (Firebase)                                                         */
  /* --------------------------------------------------------------------------- */
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
}
