import 'package:flutter/material.dart';

import '../models/chat_message_model.dart';
import '../services/ai_service.dart';
import '../services/subject_service.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final AIService _aiService = AIService();
  final SubjectService _subjectService = SubjectService();
  final TaskService _taskService = TaskService();

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessageModel> _messages = [];
  bool _isTyping = false;

  List<String> _subjects = [];
  int _pendingTaskCount = 0;

  final List<String> _quickPrompts = [
    '📅 Create a 3-day revision plan',
    '⏱️ How to stay focused in Pomodoro?',
    '🧠 Best memory & recall techniques',
    '📝 Tips to prepare for exams',
  ];

  @override
  void initState() {
    super.initState();
    _loadContextData();
    _addInitialGreeting();
  }

  void _loadContextData() async {
    try {
      final subjects = await _subjectService.getSubjects().first;
      final tasks = await _taskService.getTasks().first;

      if (mounted) {
        setState(() {
          _subjects = subjects.map((s) => s.name).toList();
          _pendingTaskCount = tasks.where((t) => !t.completed).length;
        });
      }
    } catch (_) {}
  }

  void _addInitialGreeting() {
    _messages.add(
      ChatMessageModel(
        id: DateTime.now().toIso8601String(),
        text: 'Hello! I am StudyBuddy AI, your study coach.\nHow can I help you excel today?',
        isUser: false,
        timestamp: DateTime.now(),
        quickPrompts: _quickPrompts,
      ),
    );
  }

  void _handleSend([String? customText]) async {
    final text = (customText ?? _inputController.text).trim();
    if (text.isEmpty) return;

    _inputController.clear();

    final userMsg = ChatMessageModel(
      id: DateTime.now().toIso8601String(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });

    _scrollToBottom();

    // Call AI Service
    final aiResponse = await _aiService.sendMessage(
      prompt: text,
      subjectNames: _subjects,
      pendingTaskCount: _pendingTaskCount,
    );

    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(
        ChatMessageModel(
          id: DateTime.now().toIso8601String(),
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }



  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: AppColors.getBackgroundDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: isDark ? AppColors.linen : AppColors.lobsterPink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text('StudyBuddy AI'),
            ],
          ),
          actions: [],
        ),
        body: Column(
          children: [
            // Chat message list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildChatBubble(msg, isDark);
                },
              ),
            ),

            // Typing indicator
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'StudyBuddy is thinking...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            // Quick suggestion chips bar above input
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: _quickPrompts.map((prompt) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: AppColors.card,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      label: Text(
                        prompt,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      onPressed: () => _handleSend(prompt),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.midnightViolet.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSend(),
                        decoration: InputDecoration(
                          hintText: 'Ask StudyBuddy anything...',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: AppColors.card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: _handleSend,
                      ),
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

  Widget _buildChatBubble(ChatMessageModel msg, bool isDark) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 40),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Text(
              msg.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    // AI Bubble
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: isDark ? AppColors.linen : AppColors.lobsterPink,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
