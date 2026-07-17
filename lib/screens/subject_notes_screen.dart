import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note_model.dart';
import '../services/note_service.dart';
import '../utils/app_colors.dart';
import '../widgets/add_note_dialog.dart';
import '../widgets/note_card.dart';

class SubjectNotesScreen extends StatelessWidget {
  final String subjectId;
  final String subjectName;

  SubjectNotesScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  final NoteService noteService = NoteService();

  Future<void> _addNote(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const AddNoteDialog(),
    );

    if (result == null) return;

    final note = NoteModel(
      id: '',
      subjectId: subjectId,
      title: result['title'],
      content: result['content'],
      createdAt: DateFormat("dd MMM yyyy").format(DateTime.now()),
    );

    await noteService.addNote(note);
  }

  Future<void> _editNote(
      BuildContext context,
      NoteModel note,
      ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddNoteDialog(note: note),
    );

    if (result == null) return;

    final updatedNote = NoteModel(
      id: note.id,
      subjectId: subjectId,
      title: result['title'],
      content: result['content'],
      createdAt: note.createdAt,
    );

    await noteService.updateNote(updatedNote);
  }

  Future<void> _deleteNote(NoteModel note) async {
    await noteService.deleteNote(
      subjectId,
      note.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: AppColors.getBackgroundDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("$subjectName Notes"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: StreamBuilder<List<NoteModel>>(
          stream: noteService.getNotes(subjectId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            final notes = snapshot.data ?? [];

            if (notes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        size: 90,
                        color: isDark ? AppColors.linen : AppColors.vividPink,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "No Notes Yet",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap + to create your first note.",
                        style: TextStyle(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];

                return NoteCard(
                  note: note,
                  onEdit: () {
                    _editNote(
                      context,
                      note,
                    );
                  },
                  onDelete: () async {
                    final delete = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Delete Note"),
                        content: Text(
                          "Delete '${note.title}'?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                                false,
                              );
                            },
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.winePlum,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(
                                context,
                                true,
                              );
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );

                    if (delete == true) {
                      _deleteNote(note);
                    }
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.lobsterPink,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
          onPressed: () {
            _addNote(context);
          },
        ),
      ),
    );
  }
}
