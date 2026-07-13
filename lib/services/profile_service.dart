import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  String get email {
    return currentUser?.email ?? "";
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}