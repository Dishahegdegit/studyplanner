import 'package:flutter/material.dart';

import '../models/subject_model.dart';
import '../services/subject_service.dart';
import '../widgets/add_subject_dialog.dart';
import '../widgets/subject_card.dart';
import '../utils/app_colors.dart';
import 'subject_notes_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final SubjectService subjectService = SubjectService();
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

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
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.getBackgroundDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Subjects"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () => _addSubject(context),
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search subjects...",
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchQuery = "";
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<SubjectModel>>(
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

                  final filteredSubjects = subjects.where((subject) {
                    return subject.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                  }).toList();

                  if (filteredSubjects.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            searchQuery.isEmpty
                                ? "No Subjects Added"
                                : "No Results Found",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            searchQuery.isEmpty
                                ? "Tap the + button to add your first subject."
                                : "Try refining your search query.",
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = filteredSubjects[index];

                      return SubjectCard(
                        subject: subject,
                        onNotes: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubjectNotesScreen(
                                subjectId: subject.id,
                                subjectName: subject.name,
                              ),
                            ),
                          );
                        },
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
                                    backgroundColor: AppColors.winePlum,
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
            ),
          ],
        ),
      ),
    );
  }
}
