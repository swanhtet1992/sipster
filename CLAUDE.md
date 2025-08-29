# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **Sipster** - a Flutter-based hydration tracking app with a revolutionary boba tea theme. The app uses session-based hydration tracking (not individual sips) to match real human drinking behavior, featuring cute boba characters leading a revolution against the "Bland Water Empire."

**Key Concept**: Solve notification fatigue through engaging, variable storytelling rather than repetitive health reminders.

## Project Status

**MVP Implementation Complete** - Core functionality has been implemented including:
- Session-based hydration tracking
- SQLite database with user profiles, sessions, and boba characters  
- Basic character unlock system (5 initial characters)
- Hydration calculator with safety warnings
- Clean, Material 3 UI with purple boba theme

## Technical Stack & Architecture

- **Framework**: Flutter (cross-platform)
- **Database**: Local SQLite (no external dependencies)
- **Architecture**: Modular with clear separation of concerns

### Core Modules (Implemented)
1. **Session Management** (`lib/services/session_service.dart`) - Start/end drinking sessions
2. **Hydration Calculator** (`lib/services/hydration_calculator.dart`) - Science-based calculations and safety limits  
3. **Character System** (`lib/services/character_service.dart`) - Boba army recruitment and progression
4. **User Management** (`lib/services/user_service.dart`) - User profiles and preferences
5. **Database Layer** (`lib/database/database_helper.dart`) - SQLite storage with automatic migrations
6. **UI Components** (`lib/widgets/`) - Reusable UI widgets for progress, characters, sessions

## Key Data Models (From PRD)

```dart
// User Profile
class User {
  String id;
  double weightKg;
  double dailyGoalMl;
  List<String> containerPresets;
  DateTime createdAt;
}

// Hydration Session  
class HydrationSession {
  String id;
  DateTime startTime;
  DateTime? endTime;
  double targetMl;
  double? actualMl;
  String containerType;
  bool isActive;
}

// Boba Character
class BobaCharacter {
  String id;
  String name;
  String type; // milk_tea, taro, matcha, fruit, classic
  bool isUnlocked;
  int loyaltyLevel;
  DateTime? unlockedAt;
}
```

## Development Commands

**Setup:**
- `flutter pub get` - Install dependencies
- `flutter config --enable-macos-desktop` - Enable macOS desktop support

**Development:**
- `flutter run -d macos` - Run the macOS desktop app
- `flutter run -d chrome` - Run web version (if needed)
- `flutter test` - Run unit tests
- `flutter analyze` - Check for code issues

**Building:**
- `flutter build macos` - Build macOS desktop app
- `flutter build apk` - Build Android APK  
- `flutter build ios` - Build iOS app
- `flutter build web` - Build web version

**Dependencies:**
- `sqflite: ^2.3.0` - SQLite database
- `path: ^1.8.3` - Path manipulation
- `uuid: ^4.1.0` - UUID generation

## Core Business Logic

### Hydration Calculator Rules
- **Daily Goal**: 35ml per kg body weight
- **Safety Warning**: >700ml in 1 hour triggers kidney overload warning
- **Max Daily**: 4000ml limit for average adult
- **Session Safety**: Warning if >300ml in 15 minutes

### Session-Based Tracking Philosophy
- Users track drinking sessions, not individual sips
- Realistic pattern: sip-sip-sip → finish container → log amount
- No pressure to log during active sessions
- Smart estimation and container memory

### Character Unlock System
- Characters unlock based on hydration consistency, not just volume
- Army effects change based on hydration timing
- Over-hydration = waterlogged army, under-hydration = sad characters

## Safety Features
- All data stored locally (privacy-first)
- No internet required for core functionality
- Graceful handling of incomplete sessions
- Built-in hydration safety warnings

## UI Guidelines
- **Color Palette**: Soft pastels (bubble tea inspired)
- **Characters**: Taro ninjas, matcha wizards, fruit tea archers, milk tea knights
- **Animations**: Simple, subtle, not distracting
- **Layout**: Clean, minimal, thumb-friendly

## Development Priorities
1. **MVP Features**: Session tracking, basic character system, hydration calculator
2. **Phase 2**: Enhanced characters, revolutionary story system, smart notifications

When implementing, focus on the core session-based tracking behavior that differentiates this from traditional hydration apps.