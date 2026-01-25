import 'package:cashify/firebase_options.dart';
import 'package:cashify/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "env/prod.env");
  await startApp(
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
    envFile: "env/prod.env",
  );
}
