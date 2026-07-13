import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance; //connects to firebase authentication

  User? get currentUser => _auth.currentUser;

  CollectionReference get _subjects =>
      _firestore
          .collection("users")
          .doc(currentUser!.uid)
          .collection("subjects");

  CollectionReference get _tasks =>
      _firestore
          .collection("users")
          .doc(currentUser!.uid)
          .collection("tasks");

  Future<int> getSubjectCount() async {
    final snapshot = await _subjects.get();
    return snapshot.docs.length;
  }

  Future<int> getTaskCount() async {
    final snapshot = await _tasks.get();
    return snapshot.docs.length;
  }

  Future<int> getCompletedCount() async {
    final snapshot = await _tasks
        .where("completed", isEqualTo: true)
        .get();

    return snapshot.docs.length;
  }

  Future<int> getPendingCount() async {
    final snapshot = await _tasks
        .where("completed", isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }
}