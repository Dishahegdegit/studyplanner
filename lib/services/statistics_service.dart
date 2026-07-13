import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticsService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

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

  Future<int> subjectCount() async {
    return (await _subjects.get()).docs.length;
  }

  Future<int> taskCount() async {
    return (await _tasks.get()).docs.length;
  }

  Future<int> completedCount() async {
    return (await _tasks
        .where("completed", isEqualTo: true)
        .get())
        .docs
        .length;
  }

  Future<int> pendingCount() async {
    return (await _tasks
        .where("completed", isEqualTo: false)
        .get())
        .docs
        .length;
  }
}