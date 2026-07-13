import 'package:flutter/material.dart';

import '../models/subject_model.dart';
import '../services/subject_service.dart';
import '../widgets/add_subject_dialog.dart';
import '../widgets/subject_card.dart';
import '../utils/app_colors.dart';

class SubjectsScreen extends StatelessWidget {
  SubjectsScreen({super.key});

  final SubjectService subjectService = SubjectService();
  Future<void> _addSubject(BuildContext context) async {
    final Map<String, dynamic>? result =
    await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddSubjectDialog(),
    );

    if (result == null) return;

    SubjectModel subject = SubjectModel(
      id: '',
      name: result["name"],
      color: result["color"],
      weeklyGoal: result["goal"],
    );

    await subjectService.addSubject(subject);
  }

  Future<void> _editSubject(
      BuildContext context,
      SubjectModel subject,
      ) async {
    final Map<String, dynamic>? result =
    await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddSubjectDialog(
        subject: subject,
      ),
    );

    if (result == null) return;

    SubjectModel updatedSubject = SubjectModel(
      id: subject.id,
      name: result["name"],
      color: result["color"],
      weeklyGoal: result["goal"],
    );

    await subjectService.updateSubject(updatedSubject);
  }

  Future<void> _deleteSubject(String id) async {
    await subjectService.deleteSubject(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Subjects"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _addSubject(context),
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<SubjectModel>>(
        stream: subjectService.getSubjects(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final subjects = snapshot.data ?? [];

          if (subjects.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 80,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 20),

                  Text(
                    "No Subjects Added",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Tap the + button to add your first subject.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];

              return SubjectCard(
                subject: subject,

                onEdit: () {
                  _editSubject(
                    context,
                    subject,
                  );
                },

                onDelete: () async {
                  final delete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Subject"),
                      content: Text(
                        "Are you sure you want to delete ${subject.name}?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text("Cancel"),
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  );

                  if (delete == true) {
                    _deleteSubject(subject.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}