import 'package:flutter/material.dart';
import '../models/subject_model.dart';

class AddSubjectDialog extends StatefulWidget {
  final SubjectModel? subject;

  const AddSubjectDialog({
    super.key,
    this.subject,
  });

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  late TextEditingController nameController;
  late TextEditingController goalController;

  late int selectedColor;

  final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.subject?.name ?? '',
    );

    goalController = TextEditingController(
      text: widget.subject?.weeklyGoal.toString() ?? '',
    );

    selectedColor = widget.subject?.color ?? Colors.blue.value;
  }

  @override
  void dispose() {
    nameController.dispose();
    goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.subject == null ? "Add Subject" : "Edit Subject",
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Subject Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Weekly Goal (Hours)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Choose Color",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color.value;
                    });
                  },
                  child: CircleAvatar(
                    radius: selectedColor == color.value ? 20 : 17,
                    backgroundColor: color,
                    child: selectedColor == color.value
                        ? const Icon(
                      Icons.check,
                      color: Colors.white,
                    )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () {
            if (nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please enter a subject name."),
                ),
              );
              return;
            }

            Navigator.pop(
              context,
              {
                "name": nameController.text.trim(),
                "goal": int.tryParse(goalController.text) ?? 0,
                "color": selectedColor,
              },
            );
          },
          child: Text(
            widget.subject == null ? "Add" : "Update",
          ),
        ),
      ],
    );
  }
}