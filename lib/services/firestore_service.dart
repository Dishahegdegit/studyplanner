import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/subject_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  CollectionReference get _subjectCollection {
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('subjects');
  }

  // ---------------- ADD SUBJECT ----------------

  Future<void> addSubject(SubjectModel subject) async {
    await _subjectCollection.add(subject.toMap());
  }

  // ---------------- GET SUBJECTS ----------------

  Stream<List<SubjectModel>> getSubjects() {
    return _subjectCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SubjectModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  // ---------------- UPDATE SUBJECT ----------------

  Future<void> updateSubject(SubjectModel subject) async {
    await _subjectCollection.doc(subject.id).update(subject.toMap());
  }

  // ---------------- DELETE SUBJECT ----------------

  Future<void> deleteSubject(String id) async {
    await _subjectCollection.doc(id).delete();
  }
}