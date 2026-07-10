# Chronicle of Life

A cross-platform application to help you record and manage the little moments of life. Built with Flutter, supporting Android, iOS, Web, and Windows platforms.

## Features

### 📸 Moment
Capture beautiful moments in life anytime, preserving precious memories.

### 👥 Bond
Manage relationships with friends and family, and record important interpersonal connections.

### 🍽️ Food
Track your dietary habits and gain insights into your health.

### 🎯 Goal
Set and track your life goals, witnessing your personal growth.

### 📅 Home Schedule
Manage daily routines and work schedules to improve time efficiency.

### ✈️ Travel
Record your travel足迹 and cherish every journey.

### 🤖 AI Historian
Leverage AI capabilities to intelligently analyze your life records and provide insights and recommendations.

## Technical Architecture

### Core Framework
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language

### Data Storage
- **Drift** - Lightweight SQLite database
- **DAO Pattern** - Data Access Object design pattern

### State Management
- **Provider/Riverpod** - State management solution

### Supported Platforms
- Android
- iOS
- Web
- Windows

## Project Structure

```
life_chronicle/
├── lib/
│   ├── app/                    # Core application configuration
│   │   ├── app.dart           # Application entry point
│   │   ├── app_shell.dart     # Application shell
│   │   └── app_theme.dart     # Theme configuration
│   ├── core/                   # Core functionality layer
│   │   └── database/          # Database layer
│   │       ├── app_database.dart
│   │       ├── daos/          # Data Access Objects
│   │       └── migration_steps.dart
│   ├── features/              # Feature modules
│   │   ├── ai_historian/     # AI Historian
│   │   ├── bond/             # Bond (Relationships)
│   │   ├── food/             # Food logging
│   │   ├── goal/             # Goal management
│   │   ├── home_schedule/    # Home schedule
│   │   ├── moment/           # Moment recording
│   │   ├── profile/          # Profile
│   │   └── travel/           # Travel logging
│   └── main.dart             # Program entry point
├── android/                   # Android platform configuration
├── web/                      # Web platform configuration
└── windows_bak/             # Windows platform configuration
```

## Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code

### Installation Steps

1. **Clone the project**
```bash
git clone https://gitee.com/suliu-here/chronicle-of-life.git
cd chronicle-of-life/life_chronicle
```

2. **Fetch dependencies**
```bash
flutter pub get
```

3. **Run the project**
```bash
flutter run
```

### Build APK (Android)
```bash
flutter build apk --release
```

## Contribution Guidelines

Contributions via Issues and Pull Requests are welcome to help improve this project.

## License

This project is licensed under the [MIT License](LICENSE).