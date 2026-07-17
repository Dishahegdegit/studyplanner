import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../utils/app_colors.dart';

class AddNoteDialog extends StatefulWidget {
  final NoteModel? note;

  const AddNoteDialog({
    super.key,
    this.note,
  });

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final TextEditingController titleController =
  TextEditingController();

  final TextEditingController contentController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      title: Text(
        widget.note == null
            ? "Add Note"
            : "Edit Note",
      ),

      content: SizedBox(
        width: 450,

        child: SingleChildScrollView(
          child: Column(
            children: [

              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Note Title",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: contentController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: "Write your notes...",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 48,

      child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lobsterPink,
                    foregroundColor: Colors.white,
                  ),

                  onPressed: () {

                    if (titleController.text.trim().isEmpty ||
                        contentController.text.trim().isEmpty) {

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please fill all fields.",
                          ),
                        ),
                      );

                      return;
                    }

                    Navigator.pop(
                      context,
                      {
                        "title": titleController.text.trim(),
                        "content": contentController.text.trim(),
                      },
                    );
                  },

                  child: Text(
                    widget.note == null
                        ? "Add Note"
                        : "Update Note",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
