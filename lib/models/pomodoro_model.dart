class PomodoroModel {
  String id;
  int minutes;
  bool completed;
  String date;

  PomodoroModel({
    required this.id,
    required this.minutes,
    required this.completed,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'minutes': minutes,
      'completed': completed,
      'date': date,
    };
  }

  factory PomodoroModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return PomodoroModel(
      id: id,
      minutes: map['minutes'] ?? 25,
      completed: map['completed'] ?? false,
      date: map['date'] ?? '',
    );
  }
}