class TaskModel {
  String id;
  String title;
  String subjectId;
  String subjectName;
  String date;
  String startTime;
  String endTime;
  String priority;
  bool completed;

  TaskModel({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.subjectName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.priority,
    required this.completed,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'priority': priority,
      'completed': completed,
    };
  }

  factory TaskModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      date: map['date'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      priority: map['priority'] ?? 'Medium',
      completed: map['completed'] ?? false,
    );
  }
}