import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/pomodoro_model.dart';
import '../services/notification_service.dart';
import '../services/pomodoro_service.dart';
import '../utils/app_colors.dart';
import '../widgets/timer_circle.dart';
import '../widgets/timer_controls.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final PomodoroService pomodoroService = PomodoroService();
  final TextEditingController customController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? timer;
  bool isRunning = false;
  bool isPaused = false;
  bool isBreak = false;

  int selectedMinutes = 25;
  int breakMinutes = 5;
  int totalSeconds = 25 * 60;
  int secondsLeft = 25 * 60;

  int completedToday = 0;
  int minutesToday = 0;

  final List<int> focusPresets = [15, 25, 40, 50, 60];
  final List<int> breakPresets = [3, 5, 10, 15, 20];

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    completedToday = await pomodoroService.completedSessions();
    minutesToday = await pomodoroService.totalMinutesToday();
    if (mounted) setState(() {});
  }

  void switchMode(bool breakMode) {
    if (isRunning) return;
    setState(() {
      isBreak = breakMode;
      final mins = isBreak ? breakMinutes : selectedMinutes;
      totalSeconds = mins * 60;
      secondsLeft = totalSeconds;
    });
  }

  void selectMinutes(int minutes) {
    if (isRunning) return;
    setState(() {
      if (isBreak) {
        breakMinutes = minutes;
      } else {
        selectedMinutes = minutes;
      }
      totalSeconds = minutes * 60;
      secondsLeft = totalSeconds;
    });
  }

  void applyCustomMinutes() {
    if (customController.text.trim().isEmpty) return;
    int? value = int.tryParse(customController.text.trim());
    if (value == null || value <= 0) return;
    customController.clear();
    selectMinutes(value);
    FocusScope.of(context).unfocus();
  }

  void startTimer() {
    if (isRunning) return;
    isRunning = true;
    isPaused = false;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft > 0) {
        setState(() {
          secondsLeft--;
        });
      } else {
        timer.cancel();
        isRunning = false;
        sessionCompleted();
      }
    });

    setState(() {});
  }

  void pauseTimer() {
    timer?.cancel();
    isRunning = false;
    isPaused = true;
    setState(() {});
  }

  void resumeTimer() {
    if (!isPaused) return;
    startTimer();
  }

  void resetTimer() {
    timer?.cancel();
    isRunning = false;
    isPaused = false;
    secondsLeft = totalSeconds;
    setState(() {});
  }

  Future<void> sessionCompleted() async {
    // 1. Fire alarm notification
    _fireSessionCompleteNotification();

    // 2. Strong triple haptic vibration alert
    _triggerVibrationAlert();

    if (!isBreak) {
      await pomodoroService.saveSession(
        PomodoroModel(
          id: "",
          minutes: selectedMinutes,
          completed: true,
          date: DateFormat("dd MMM yyyy").format(DateTime.now()),
        ),
      );
      completedToday++;
      minutesToday += selectedMinutes;
    }

    if (!mounted) return;

    if (!isBreak) {
      _showFocusCompleteDialog();
    } else {
      _showBreakCompleteDialog();
    }
  }

  void _triggerVibrationAlert() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 300), () {
      HapticFeedback.heavyImpact();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      HapticFeedback.vibrate();
    });
  }

  void _showFocusCompleteDialog() {
    int chosenBreakMins = breakMinutes;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text("Session Complete!"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Great work completing $selectedMinutes minutes of focus! Take a break before your next session.",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Choose Break Duration:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: breakPresets.map((mins) {
                      final bool sel = chosenBreakMins == mins;
                      return ChoiceChip(
                        label: Text("$mins min"),
                        selected: sel,
                        selectedColor: AppColors.lobsterPink,
                        labelStyle: TextStyle(
                          color: sel ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) {
                          setDialogState(() {
                            chosenBreakMins = mins;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    setState(() {
                      isBreak = false;
                      totalSeconds = selectedMinutes * 60;
                      secondsLeft = totalSeconds;
                    });
                  },
                  child: const Text("Skip Break"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lobsterPink,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.free_breakfast, size: 18),
                  label: Text("Start $chosenBreakMins Min Break"),
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    setState(() {
                      isBreak = true;
                      breakMinutes = chosenBreakMins;
                      totalSeconds = breakMinutes * 60;
                      secondsLeft = totalSeconds;
                    });
                    startTimer();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBreakCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Break Over!"),
        content: const Text(
          "Hope you feel refreshed! Ready to start another focus session?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              setState(() {
                isBreak = false;
                totalSeconds = selectedMinutes * 60;
                secondsLeft = totalSeconds;
              });
            },
            child: const Text("Later"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lobsterPink,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.play_arrow, size: 18),
            label: Text("Start $selectedMinutes Min Focus"),
            onPressed: () {
              Navigator.pop(dialogCtx);
              setState(() {
                isBreak = false;
                totalSeconds = selectedMinutes * 60;
                secondsLeft = totalSeconds;
              });
              startTimer();
            },
          ),
        ],
      ),
    );
  }

  void _playBuzzerSound() async {
    try {
      await _audioPlayer.stop();
      // Digital alarm clock beep sound
      await _audioPlayer.play(
        UrlSource('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'),
      );
    } catch (_) {}
  }

  void _fireSessionCompleteNotification() {
    final bool wasBreak = isBreak;

    SystemSound.play(SystemSoundType.click);
    _playBuzzerSound();

    NotificationService.flutterLocalNotificationsPlugin.show(
      99999,
      wasBreak ? 'Break Over!' : 'Pomodoro Complete!',
      wasBreak
          ? 'Break finished. Ready to focus again?'
          : 'Great work! You completed a $selectedMinutes-minute focus session.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro_alarm_channel_v4',
          'Pomodoro Alarm Timer',
          channelDescription:
              'Alarm buzzer sound when pomodoro focus or break timer finishes',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    customController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<int> currentPresets = isBreak ? breakPresets : focusPresets;
    final int currentSelectedMins = isBreak ? breakMinutes : selectedMinutes;

    return Container(
      decoration: AppColors.getBackgroundDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text("Pomodoro Timer"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Focus vs Break Mode Selector Switcher
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => switchMode(false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isBreak
                                ? AppColors.lobsterPink
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 18,
                                color: !isBreak ? Colors.white : AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Focus Mode",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !isBreak
                                      ? Colors.white
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => switchMode(true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isBreak
                                ? AppColors.lobsterPink
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.free_breakfast,
                                size: 18,
                                color: isBreak ? Colors.white : AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Break Mode",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isBreak
                                      ? Colors.white
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title showing mode
              Text(
                isBreak ? "Choose Break Duration" : "Choose Focus Time",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              // Presets chips
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: currentPresets.map((minutes) {
                  bool selected = currentSelectedMins == minutes;
                  return ChoiceChip(
                    label: Text("$minutes min"),
                    selected: selected,
                    selectedColor: AppColors.lobsterPink,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) {
                      selectMinutes(minutes);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Custom Minutes Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: customController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: isBreak
                            ? "Custom Break Minutes"
                            : "Custom Focus Minutes",
                        hintText: isBreak ? "e.g. 7" : "e.g. 30",
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lobsterPink,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: applyCustomMinutes,
                    child: const Text("Set"),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Timer Circle
              Center(
                child: TimerCircle(
                  secondsLeft: secondsLeft,
                  totalSeconds: totalSeconds,
                ),
              ),

              const SizedBox(height: 30),

              // Timer Controls
              TimerControls(
                isRunning: isRunning,
                isPaused: isPaused,
                onStart: startTimer,
                onPause: pauseTimer,
                onResume: resumeTimer,
                onReset: resetTimer,
              ),

              const SizedBox(height: 30),

              // Today's Progress Card
              Card(
                elevation: 3,
                color: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Text(
                        "Today's Progress",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: AppColors.lobsterPink,
                                size: 35,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "$completedToday",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text("Sessions"),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(
                                Icons.timer,
                                color: AppColors.textSecondary,
                                size: 35,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "$minutesToday",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text("Minutes"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}