import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

 static FirebaseOptions get web => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
    authDomain: '${dotenv.env['FIREBASE_PROJECT_ID']}.firebaseapp.com',
    projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
    storageBucket: '${dotenv.env['FIREBASE_PROJECT_ID']}.firebasestorage.app',
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
    appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
    measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? '',
  );
}