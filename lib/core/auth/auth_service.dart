import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userStatus => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      return await _auth.signInWithPopup(googleProvider);
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async => await _auth.signOut();
}
