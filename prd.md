### Core Problem Being Solved
**Notification Fatigue**: Traditional hydration apps fail because users develop "notification blindness" - they ignore repetitive, predictable reminders and eventually delete the app. Our solution uses variable, story-driven engagement that makes users WANT to check the app rather than feeling nagged by it.

**Unrealistic Tracking**: Most apps assume people drink measured amounts on command. Reality is: sip throughout meeting → finish bottle later → then measure. Our session-based tracking matches actual human drinking behavior.# Boba Revolution Hydration App - Product Requirements Document

## Core Concept
Session-based hydration tracking with cute boba characters leading a revolution against the "Bland Water Empire." Users track drinking sessions (not individual sips) to build their boba army and progress through the revolutionary storyline. Designed to solve notification fatigue through engaging, variable storytelling.

## Technical Stack
- Flutter (cross-platform)
- Local SQLite database
- No external dependencies for core functionality
- Modular architecture with clear separation of concerns

## App Architecture

### Core Modules
1. **Session Management** - Start/end drinking sessions
2. **Hydration Calculator** - Science-based calculations and safety limits
3. **Character System** - Boba army recruitment and progression
4. **Story Engine** - Simple narrative progression
5. **Notification Service** - Smart reminders
6. **Data Layer** - Local storage and user preferences

## User Stories

### Primary Flow
**As a user, I want to track my water intake in sessions so I don't have to measure individual sips.**

1. User opens app, sees boba army and current hydration status
2. User starts drinking session: "I'm drinking from my 500ml bottle"
3. User drinks naturally (sips, gulps, whatever)
4. User ends session: "I finished 400ml" or "I finished the whole bottle"
5. Boba characters react and new characters may be recruited

### Secondary Flows
**As a user, I want personalized hydration goals based on my weight.**
**As a user, I want reminders that don't annoy me.**
**As a user, I want to see my progress in a fun, gamified way.**

## Feature Requirements

### MVP Features (Phase 1)

#### Session Behavior System
- **Realistic Drinking Patterns**: Accounts for sip-sip-sip → finish container behavior
- **Session States**: 
  - Active (drinking in progress, no pressure)
  - Paused (remind after 45+ minutes)
  - Completed (celebrate and recruit characters)
- **Smart Estimation**: "Looks like you're about halfway done with that bottle?"
- **No Pressure Logging**: Users log when they naturally finish, not forced intervals
- **Container Memory**: App learns user's typical consumption patterns per container type

#### Hydration Engine
- **Daily Goal Calculator**: 35ml per kg body weight
- **Safety Monitor**: Warning if >700ml in 1 hour
- **Progress Tracking**: Current intake vs daily goal
- **Kidney Load Indicator**: Simple visual gauge

#### Revolutionary Boba Army System
- **Character Types**: Taro ninjas, matcha wizards, fruit tea archers, milk tea knights
- **Personalities**: Each character has unique catchphrases ("Stay bouncy!", "Hydrate or die-drate!")
- **Army Effects**: 
  - Perfect hydration timing = "bubble synergy" (characters combine powers)
  - Over-hydration = army becomes "waterlogged" and sluggish
  - Under-hydration = characters become sad and deflated
- **Revolutionary Ranks**: Characters gain military ranks through consistency
- **Social Sharing**: Screenshot your boba army for TikTok/Instagram

#### Data Storage
- **User Profile**: Weight, daily goal, preferences
- **Session History**: Date, amount, duration
- **Character Progress**: Unlocked characters, current army

### Phase 2 Features

#### Enhanced Characters
- **Character Interactions**: Tap for animations and quotes
- **Evolution System**: Characters upgrade with consistent habits
- **Personality Traits**: Each character has unique sayings

#### Revolutionary Story System
- **The Great Bubble Tea Revolution**: Fight against the "Bland Water Empire"
- **3 Chapters**: "The Flavoring" → "The Uprising" → "The Final Steep"
- **Territory Liberation**: Each consistent hydration period liberates new areas from the Empire
- **Character Recruitment**: Proper hydration recruits new boba soldiers with unique abilities
- **Boss Battles**: Face "Lord Espresso" and "Duke Energy Drink" through hydration consistency
- **Viral Moments**: Boba characters perform trending dances, create shareable moments

#### Smart Anti-Fatigue Notifications
- **Variable Timing**: Never predictable patterns to avoid notification blindness
- **Character-Driven**: Each reminder comes from different boba characters with unique personalities
- **Context-Aware**: "Perfect timing for water before your 3pm meeting!" style messages
- **Story-Based**: Notifications tied to revolution progress, not just health nagging
- **Emotional Connection**: Characters express concern, excitement, celebration - not robotic reminders

## Technical Specifications

### Data Models

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

// Daily Progress
class DailyProgress {
  DateTime date;
  double totalMl;
  double goalMl;
  List<HydrationSession> sessions;
  double maxHourlyRate;
}
```

### Core Services

#### Session Service
```dart
class SessionService {
  Future<void> startSession(String containerType, double targetMl);
  Future<void> endSession(String sessionId, double actualMl);
  Future<HydrationSession?> getCurrentSession();
  Future<List<HydrationSession>> getTodaySessions();
}
```

#### Hydration Calculator
```dart
class HydrationCalculator {
  double calculateDailyGoal(double weightKg);
  bool isOverHydrating(List<HydrationSession> recentSessions);
  double getCurrentHourlyRate(List<HydrationSession> sessions);
  double getKidneyLoadPercentage(double hourlyRate);
}
```

#### Character Manager
```dart
class CharacterManager {
  Future<List<BobaCharacter>> getUnlockedCharacters();
  Future<BobaCharacter?> checkForNewUnlock(double totalIntake, int streak);
  Future<void> unlockCharacter(String characterId);
}
```

## UI Requirements

### Home Screen
- **Header**: Current hydration percentage, kidney load gauge
- **Boba Army Display**: 3-5 visible characters with simple animations
- **Quick Actions**: 
  - "Start Drinking" (shows container options)
  - "Finished [Container]" (if session active)
- **Progress Bar**: Visual daily goal progress

### Session Screen
- **Active Session Info**: Container type, target amount, elapsed time
- **End Session Options**: 
  - "Finished it all"
  - "Finished [amount]ml" with slider
  - Quick buttons (25%, 50%, 75%, 100%)

### Character Screen
- **Army Grid**: All unlocked characters
- **Character Details**: Name, unlock condition, simple stats
- **Recruitment Preview**: Silhouettes of locked characters

### Settings Screen
- **Profile**: Weight input, daily goal display
- **Containers**: Add/edit preset containers
- **Notifications**: Enable/disable, frequency settings

## Safety Features

### Hydration Safety
- Warning popup if session intake >300ml in 15 minutes
- Daily maximum limit of 4000ml for average adult
- Visual kidney overload warning at >700ml/hour

### App Safety
- All data stored locally (privacy)
- No internet required for core functionality
- Graceful handling of incomplete sessions

## Success Metrics
- **Primary**: Session completion rate (users who start sessions actually finish logging them)
- **Secondary**: Daily active users after 7 days
- **Engagement**: Average daily sessions per user

## Non-Requirements (Explicitly Excluded)
- Real-time sip tracking
- Complex social features
- Cloud sync (Phase 1)
- Advanced analytics dashboard
- Integration with fitness trackers (Phase 1)
- Elaborate 3D animations
- In-app purchases (Phase 1)
- User accounts/login system

## UI Style Guidelines
- **Color Palette**: Soft pastels (bubble tea inspired)
- **Typography**: Friendly, rounded fonts
- **Animations**: Simple, subtle, not distracting
- **Icons**: Cute but clear, inspired by bubble tea aesthetics
- **Layout**: Clean, minimal, thumb-friendly touch targets

This PRD prioritizes simplicity and focuses on solving the core problem: making hydration tracking match actual human behavior through session-based logging.