import 'package:cashify/core/auth/auth_wrapper.dart';
import 'package:cashify/features/transaction/domain/repositories/category_repository.dart';
import 'package:cashify/features/transaction/domain/repositories/movement_repository.dart';
import 'package:cashify/features/transaction/domain/repositories/payment_method_repository.dart';
import 'package:cashify/features/transaction/domain/usecases/category_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/movement_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/payment_method_usecases.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MovementProvider(
            movementUseCase: MovementUseCase(
              movementRepository: MovementRepository(),
            ),
            categoryUsecases: CategoryUsecases(
              categoryRepository: CategoryRepository(),
            ),
            paymentMethodUsecases: PaymentMethodUsecases(
              paymentMethodRepository: PaymentMethodRepository(),
            ),
          ),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cashify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}
