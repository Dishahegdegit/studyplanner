class NoteModel {
  final String id;
  final String subjectId;
  final String title;
  final String content;
  final String createdAt;

  NoteModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'title': title,
      'content': content,
      'createdAt': createdAt,
    };
  }

  factory NoteModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return NoteModel(
      id: id,
      subjectId: map['subjectId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }
}