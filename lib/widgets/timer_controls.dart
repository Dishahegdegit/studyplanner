import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class TimerControls extends StatelessWidget {
  final bool isRunning;
  final bool isPaused;

  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;

  const TimerControls({
    super.key,
    required this.isRunning,
    required this.isPaused,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lobsterPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: isRunning
                ? null
                : (isPaused ? onResume : onStart),
            icon: Icon(
              isPaused ? Icons.play_arrow : Icons.play_arrow,
            ),
            label: Text(
              isPaused ? "Resume" : "Start",
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.winePlum,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: isRunning ? onPause : null,
            icon: const Icon(Icons.pause),
            label: const Text("Pause"),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.almondSilk,
              foregroundColor: AppColors.midnightViolet,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onReset,
            icon: const Icon(Icons.refresh),
            label: const Text("Reset"),
          ),
        ),
      ],
    );
  }
}
