import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  CollectionReference get _taskCollection {
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks');
  }

  Future<void> addTask(TaskModel task) async {
    await _taskCollection.add(task.toMap());
  }

  Stream<List<TaskModel>> getTasks() { //whenever task changes ,receives updated data
    return _taskCollection.snapshots().map((snapshot) { //listen continuously to firestore
      return snapshot.docs.map((doc) { //takes every firestore doc converts it to taskModel
        return TaskModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskCollection.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _taskCollection.doc(id).delete();
  }

  Future<void> toggleTaskCompletion(
      String id,
      bool completed,
      ) async {
    await _taskCollection.doc(id).update({
      'completed': completed,
    });
  }
}