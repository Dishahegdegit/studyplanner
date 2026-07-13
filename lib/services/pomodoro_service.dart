import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/pomodoro_model.dart';

class PomodoroService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  CollectionReference get _collection {
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('pomodoro_sessions');
  }

  Future<void> saveSession(
      PomodoroModel session) async {
    await _collection.add(session.toMap());
  }

  Stream<List<PomodoroModel>> getSessions() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PomodoroModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  Future<int> totalMinutesToday() async {
    QuerySnapshot snapshot =
    await _collection.get();

    int total = 0;

    for (var doc in snapshot.docs) {
      total +=
      (doc['minutes'] ?? 0) as int;
    }

    return total;
  }

  Future<int> completedSessions() async {
    QuerySnapshot snapshot =
    await _collection.get();

    return snapshot.docs.length;
  }
}