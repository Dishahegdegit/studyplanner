import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {

  // Key is loaded from .env file via main.dart — do NOT hard-code it here
  static String? apiKey;

  static const String _groqEndpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  static const String _model = 'llama-3.3-70b-versatile';

  /// System prompt — gives Groq context about its role
  static const String _systemPrompt =
      'You are StudyBuddy AI, a friendly, highly encouraging academic tutor, '
      'study coach, and productivity planner inside the StudyPlanner app. '
      'Your goals: '
      '1. Help students break down complex topics into clear, easy-to-understand explanations. '
      '2. Provide structured revision schedules and study timetables when asked. '
      '3. Recommend effective study techniques (Pomodoro, Active Recall, Spaced Repetition, Feynman). '
      '4. Keep responses concise, well-formatted with bullet points and emoji. '
      '5. Provide actionable advice for managing exam stress and time management.';

  /// Sends a query to Groq API or returns intelligent offline fallback
  Future<String> sendMessage({
    required String prompt,
    List<String>? subjectNames,
    int? pendingTaskCount,
  }) async {
    final key = apiKey?.trim();

    if (key != null && key.isNotEmpty) {
      try {
        final contextInfo = subjectNames != null && subjectNames.isNotEmpty
            ? '\n[Student Context — Subjects: ${subjectNames.join(", ")}; Pending Tasks: ${pendingTaskCount ?? 0}]'
            : '';

        final response = await http.post(
          Uri.parse(_groqEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $key',   // Groq uses Bearer token
          },
          body: jsonEncode({
            'model': _model,
            'messages': [
              {'role': 'system', 'content': _systemPrompt},
              {'role': 'user', 'content': '$contextInfo\n$prompt'},
            ],
            'temperature': 0.7,
            'max_tokens': 800,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final String text =
              data['choices']?[0]?['message']?['content'] ?? '';
          if (text.isNotEmpty) return text.trim();
        } else if (response.statusCode == 429) {
          final offlineReply =
              _generateOfflineResponse(prompt, subjectNames: subjectNames);
          return '⏳ *Rate limit reached. Showing offline answer — try again in a moment!*\n\n$offlineReply';
        } else {
          try {
            final errorData = jsonDecode(response.body);
            final errorMsg =
                errorData['error']?['message'] ?? response.body;
            return '❌ Groq API Error (${response.statusCode}): $errorMsg\n\nCheck your API key at console.groq.com';
          } catch (_) {
            return '❌ Groq API Error (${response.statusCode}): ${response.body}';
          }
        }
      } catch (e) {
        return '❌ Network Error: Could not reach Groq API.\n\nCheck your internet connection.\n\nDetails: $e';
      }
    }

    // Intelligent Offline Tutor Engine (works without any API key)
    return _generateOfflineResponse(prompt, subjectNames: subjectNames);
  }

  String _generateOfflineResponse(String prompt,
      {List<String>? subjectNames}) {
    final lower = prompt.toLowerCase();
    final subjectsStr =
        (subjectNames != null && subjectNames.isNotEmpty)
            ? subjectNames.join(', ')
            : 'your active subjects';

    if (lower.contains('revision') ||
        lower.contains('plan') ||
        lower.contains('schedule')) {
      return '''
📅 **Recommended 3-Day Revision Plan**

Here is a structured schedule tailored for **$subjectsStr**:

• **Day 1 (Core Concepts)**:
  - Spend 2x 25-min Pomodoro sessions covering main formulas & key terms.
  - Test yourself using Active Recall after each session.

• **Day 2 (Practice & Problem Solving)**:
  - Solve past paper questions or practice problems.
  - Highlight topics where you felt hesitant.

• **Day 3 (Final Review & Weak Spots)**:
  - Review your error log and summary sheets.
  - Do a light 15-minute quick scan before rest.

💡 *Tip: Remember to take 5-minute breaks between sessions!*
''';
    }

    if (lower.contains('focus') ||
        lower.contains('pomodoro') ||
        lower.contains('distraction')) {
      return '''
⏱️ **Mastering Pomodoro & Focus**

Here are 4 proven tips to double your focus:

1. **25/5 Rule**: Work for 25 mins with zero distractions, then take a full 5-min break.
2. **Clear Single Goal**: Pick ONE specific task before starting the timer.
3. **Brain Dump Note**: Write down random thoughts that pop up so you can ignore them until your break.
4. **Environment**: Clear your desk space to reduce visual clutter.
''';
    }

    if (lower.contains('recall') ||
        lower.contains('memory') ||
        lower.contains('technique')) {
      return '''
🧠 **Top Active Study Techniques**

• **Active Recall**: Test yourself BEFORE re-reading. Use flashcards or blurting.
• **Feynman Technique**: Explain a concept out loud in simple terms as if teaching a 10-year-old.
• **Spaced Repetition**: Review material at increasing intervals (Day 1, Day 3, Day 7, Day 14).
''';
    }

    if (lower.contains('exam') ||
        lower.contains('test') ||
        lower.contains('prep')) {
      return '''
📝 **Exam Preparation Checklist**

• **Prioritize High-Weightage Topics**: Focus 70% of study time on core topics.
• **Time Yourself**: Practice solving questions under realistic timed conditions.
• **Sleep & Nutrition**: Memory consolidation happens during sleep — aim for 7-8 hours before test day!
''';
    }

    return '''
🤖 **StudyBuddy AI Coach**

I'm here to help you study smarter! Here are a few things you can ask me:

• *"Help me make a revision schedule for $subjectsStr"*
• *"How can I improve my focus during Pomodoro?"*
• *"Explain how to use active recall for exams"*
• *"How do I prioritize my pending study tasks?"*

*(Add your GROQ_API_KEY in .env for unlimited AI responses!)*
''';
  }
}
