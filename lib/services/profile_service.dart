import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  String get email {
    return currentUser?.email ?? "";
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  DocumentReference get _userDoc {
    return _firestore.collection('users').doc(currentUser!.uid);
  }

  Stream<DocumentSnapshot> getUserDetails() {
    return _userDoc.snapshots();
  }

  Future<void> saveUserDetails({
    required String name,
    required String age,
    required String college,
    required String course,
  }) async {
    await _userDoc.set({
      'name': name,
      'age': age,
      'college': college,
      'course': course,
    }, SetOptions(merge: true));
  }
}