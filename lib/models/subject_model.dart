class SubjectModel {
  String id;
  String name;
  int color;
  int weeklyGoal;

  SubjectModel({
    required this.id,
    required this.name,
    required this.color,
    required this.weeklyGoal,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
      'weeklyGoal': weeklyGoal,
    };
  }

  factory SubjectModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return SubjectModel(
      id: id,
      name: map['name'] as String? ?? '',
      color: map['color'] as int? ?? 0xFF2196F3,
      weeklyGoal: map['weeklyGoal'] as int? ?? 0,
    );
  }
}