import 'package:cashify/core/app_config/presentation/providers/app_info_provider.dart';
import 'package:cashify/core/auth/auth_wrapper.dart';
import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/settings/presentation/providers/settings_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/billing_period_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/user_config/presentation/providers/user_config_provider.dart';
import 'package:cashify/firebase_options.dart';
import 'package:cashify/injection_container.dart' as di;
import 'package:cashify/injection_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Cargamos desde la raíz directamente
    await dotenv.load(fileName: ".env");
    print("Project ID: ${dotenv.env['FIREBASE_PROJECT_ID']}");
  } catch (e) {
    print("Error crítico: $e");
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        ChangeNotifierProvider(
          create: (_) => sl<AppConfigProvider>()..loadAppConfig(),
        ),
        ChangeNotifierProvider(create: (_) => sl<UserConfigProvider>()),
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
