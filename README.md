# 📚 AI Study Planner

A full-featured, AI-powered study planning mobile app built with **Flutter** and **Firebase**. Helps students organize their academic life — manage subjects, schedule tasks, track progress, take notes, and stay focused with a built-in Pomodoro timer.

---

## ✨ Features

**🏠 Dashboard**
- Overview of today's tasks, study hours, and completion rate
- Quick stats: total subjects, active tasks, completed tasks

**📅 Schedule**
- Create, edit, delete tasks with date, time, and priority
- 7-day horizontal calendar strip to filter tasks by day
- Search, filter by priority, sort by date/priority/subject
- Active and Done tabs with task reminder notifications

**📖 Subjects & Notes**
- Color-coded subjects with weekly study goal tracking
- Per-subject notes with full CRUD support

**⏱️ Pomodoro Timer**
- Customizable work/break durations with audio cue
- Focus sessions saved to Firestore
- Animated circular progress timer

**📊 Statistics**
- Task completion pie chart
- Weekly bar chart (Mon–Sun study hours)
- Activity heatmap (past 10 weeks, GitHub-style)
- Study hours breakdown by subject

**🤖 AI Assistant**
- Powered by Groq API (LLaMA 3)
- Chat interface for study help, explanations, and planning

**👤 Profile**
- Edit personal details, dark/light mode toggle, secure logout

---

## 🛠️ Tech Stack

| | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| Authentication | Firebase Auth (Email & Password) |
| Database | Cloud Firestore |
| AI | Groq API (LLaMA 3) |
| Notifications | flutter_local_notifications |
| Charts | fl_chart + CustomPainter |
| State Management | setState + ValueListenable |
| Environment Config | flutter_dotenv |

---

## 📦 Dependencies

```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
fl_chart: ^0.68.0
flutter_local_notifications: ^17.2.4
audioplayers: ^6.8.1
http: ^1.6.0
flutter_dotenv: ^6.0.1
intl: ^0.19.0
provider: ^6.1.2
```

---

## 📁 Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
│
├── models/
│   ├── task_model.dart
│   ├── subject_model.dart
│   ├── note_model.dart
│   ├── pomodoro_model.dart
│   └── chat_message_model.dart
│
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── bottom_nav_screen.dart
│   ├── home_screen.dart
│   ├── schedule_screen.dart
│   ├── subjects_screen.dart
│   ├── subject_notes_screen.dart
│   ├── pomodoro_screen.dart
│   ├── statistics_screen.dart
│   ├── ai_assistant_screen.dart
│   └── profile_screen.dart
│
├── services/
│   ├── auth_service.dart
│   ├── task_service.dart
│   ├── subject_service.dart
│   ├── note_service.dart
│   ├── pomodoro_service.dart
│   ├── profile_service.dart
│   ├── dashboard_service.dart
│   ├── statistics_service.dart
│   ├── notification_service.dart
│   └── ai_service.dart
│
├── widgets/
│   ├── task_card.dart
│   ├── subject_card.dart
│   ├── note_card.dart
│   ├── dashboard_card.dart
│   ├── progress_pie_chart.dart
│   ├── timer_circle.dart
│   ├── timer_controls.dart
│   ├── add_task_dialog.dart
│   ├── add_subject_dialog.dart
│   └── add_note_dialog.dart
│
└── utils/
    ├── app_colors.dart
    ├── app_styles.dart
    └── app_theme.dart
```

---

## 🔐 Auth Flow

```
App Launch
    ↓
Firebase.initializeApp() completes in main()
    ↓
FirebaseAuth.currentUser checked synchronously
    ↓
Logged in? → Home Screen
Not logged in? → Splash → Login Screen
```

Session persists automatically — user only sees login after explicit logout.

---

## 🔒 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

All data is stored under `users/{uid}/...` — only the authenticated owner can access their own data.
