import 'package:cashify/core/auth/auth_wrapper.dart';
import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/settings/presentation/providers/settings_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/billing_period_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/injection_container.dart' as di;
import 'package:cashify/injection_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> startApp({
  required FirebaseOptions firebaseOptions,
  required String envFile,
}) async {
  if (!dotenv.isInitialized) {
    await dotenv.load(fileName: envFile);
  }

  await Firebase.initializeApp(options: firebaseOptions);
  await di.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<MovementProvider>()),
        ChangeNotifierProvider(
          create: (_) => sl<SettingsProvider>()..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<BillingPeriodProvider>()..loadPeriods(),
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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const AuthWrapper(),
    );
  }
}
