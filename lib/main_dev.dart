import 'package:cashify/firebase_options_dev.dart';
import 'package:cashify/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "env/dev.env");
  await startApp(
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
    envFile: "env/dev.env",
  );
}
