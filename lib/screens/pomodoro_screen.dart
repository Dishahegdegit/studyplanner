import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/pomodoro_model.dart';
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

final TextEditingController customController =
TextEditingController();

Timer? timer;

bool isRunning = false;

bool isPaused = false;

bool isBreak = false;

int selectedMinutes = 25;

int totalSeconds = 25 * 60;

int secondsLeft = 25 * 60;

int completedToday = 0;

int minutesToday = 0;

final List<int> presets = [
15,
25,
40,
50,
60,
];

@override
void initState() {
super.initState();
loadStatistics();
}

Future<void> loadStatistics() async {

completedToday =
await pomodoroService.completedSessions();

minutesToday =
await pomodoroService.totalMinutesToday();

setState(() {});
}

void selectMinutes(int minutes) {

if (isRunning) return;

setState(() {

selectedMinutes = minutes;

totalSeconds = minutes * 60;

secondsLeft = totalSeconds;
});
}

void applyCustomMinutes() {

if (customController.text.trim().isEmpty) {
return;
}

int? value =
int.tryParse(customController.text);

if (value == null) {
return;
}

if (value <= 0) {
return;
}

selectMinutes(value);
}

void startTimer() {

if (isRunning) return;

isRunning = true;

isPaused = false;

timer = Timer.periodic(

const Duration(seconds: 1),

(timer) {

if (secondsLeft > 0) {

setState(() {

secondsLeft--;

});

} else {

timer.cancel();

isRunning = false;

sessionCompleted();
}

},

);

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

if (!isBreak) {

await pomodoroService.saveSession(

PomodoroModel(

id: "",

minutes: selectedMinutes,

completed: true,

date: DateFormat(
"dd MMM yyyy",
).format(DateTime.now()),
),

);

completedToday++;

minutesToday += selectedMinutes;

}

if (!mounted) return;

showDialog(

context: context,

builder: (_) {

return AlertDialog(

title: const Text(
"🎉 Session Complete",
),

content: Text(

isBreak
? "Break finished.\nReady to study?"
: "Excellent!\nTime for a short break.",

),
  actions: [

    ElevatedButton(

      onPressed: () {

        Navigator.pop(context);

        setState(() {

          isBreak = !isBreak;

          if (isBreak) {

            selectedMinutes = 5;

          }

          totalSeconds = selectedMinutes * 60;

          secondsLeft = totalSeconds;

        });

      },

      child: Text(
        isBreak
            ? "Start Focus"
            : "Start Break",
      ),
    ),
  ],
);
},
);
}

@override
void dispose() {

  timer?.cancel();

  customController.dispose();

  super.dispose();
}

@override
Widget build(BuildContext context) {

  return Scaffold(

    backgroundColor: AppColors.background,

    appBar: AppBar(

      backgroundColor: AppColors.primary,

      foregroundColor: Colors.white,

      centerTitle: true,

      title: const Text(
        "Pomodoro Timer",
      ),
    ),

    body: SingleChildScrollView(

      padding: const EdgeInsets.all(20),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          const Text(
            "Choose Focus Time",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Wrap(

            spacing: 10,

            runSpacing: 10,

            children: presets.map((minutes) {

              bool selected =
                  selectedMinutes == minutes;

              return ChoiceChip(

                label: Text("$minutes min"),

                selected: selected,

                selectedColor: AppColors.nightBordeaux,

                onSelected: (_) {

                  selectMinutes(minutes);

                },
              );

            }).toList(),
          ),

          const SizedBox(height: 25),

          TextField(

            controller: customController,

            keyboardType: TextInputType.number,

            decoration: InputDecoration(

              labelText: "Custom Minutes",

              hintText: "Example: 30",

              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(12),
              ),

              suffixIcon: IconButton(

                icon: const Icon(Icons.check),

                onPressed: applyCustomMinutes,

              ),
            ),
          ),

          const SizedBox(height: 35),

          Center(

            child: TimerCircle(

              secondsLeft: secondsLeft,

              totalSeconds: totalSeconds,

            ),
          ),

          const SizedBox(height: 35),

          TimerControls(

            isRunning: isRunning,

            isPaused: isPaused,

            onStart: startTimer,

            onPause: pauseTimer,

            onResume: resumeTimer,

            onReset: resetTimer,

          ),

          const SizedBox(height: 40),

          Card(

            elevation: 3,

            shape: RoundedRectangleBorder(

              borderRadius:
              BorderRadius.circular(15),

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

                    mainAxisAlignment:
                    MainAxisAlignment.spaceAround,

                    children: [

                      Column(

                        children: [

                          const Icon(
                            Icons.local_fire_department,
                            color: AppColors.nightBordeaux,
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

                          const Icon(
                            Icons.timer,
                            color: AppColors.rosyGranite,
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
  );
}
}