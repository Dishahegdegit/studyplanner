import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../utils/app_colors.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: isDark ? AppColors.linen : AppColors.lobsterPink,
                  ),
                  onPressed: onEdit,
                ),

                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: isDark ? AppColors.almondSilk : AppColors.winePlum,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              note.content,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [

                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: isDark ? AppColors.linen : AppColors.textMuted,
                ),

                const SizedBox(width: 6),

                Text(
                  note.createdAt,
                  style: TextStyle(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
