import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/note_model.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  CollectionReference _notesCollection(String subjectId) {
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('subjects')
        .doc(subjectId)
        .collection('notes');
  }

  Future<void> addNote(NoteModel note) async {
    await _notesCollection(note.subjectId).add(note.toMap());
  }

  Stream<List<NoteModel>> getNotes(String subjectId) {
    return _notesCollection(subjectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NoteModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  Future<void> updateNote(NoteModel note) async {
    await _notesCollection(note.subjectId)
        .doc(note.id)
        .update(note.toMap());
  }

  Future<void> deleteNote(
      String subjectId,
      String noteId,
      ) async {
    await _notesCollection(subjectId)
        .doc(noteId)
        .delete();
  }
}