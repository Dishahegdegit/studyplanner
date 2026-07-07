import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'An account already exists with this email.';

        case 'invalid-email':
          return 'Please enter a valid email address.';

        case 'weak-password':
          return 'Password must contain at least 6 characters.';

        default:
          return 'Unable to create account. Please try again.';
      }
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
        case 'invalid-email':
          return 'Incorrect credentials entered.\nPlease check again.';

        default:
          return 'Unable to login. Please try again.';
      }
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}