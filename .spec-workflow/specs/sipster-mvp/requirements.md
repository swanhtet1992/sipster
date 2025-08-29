# Requirements Document

## Introduction

Sipster is a Flutter-based hydration tracking app that revolutionizes water intake monitoring through session-based tracking and gamified boba character progression. Unlike traditional hydration apps that rely on repetitive notifications and unrealistic sip-by-sip tracking, Sipster matches actual human drinking behavior and uses engaging storytelling to combat notification fatigue.

The core innovation is session-based hydration tracking where users log complete drinking sessions (start drinking → naturally consume → log final amount) rather than forced individual measurements, combined with a revolutionary boba army that responds to hydration patterns.

**Multi-Platform Focus**: Sipster is designed for cross-platform deployment (mobile and desktop) with platform-specific UI adaptations while maintaining core functionality consistency.

## Alignment with Product Vision

This MVP implementation establishes the foundational session-based tracking system that differentiates Sipster from traditional hydration apps. It directly addresses the core problems outlined in the PRD:
- **Notification Fatigue**: Replaced with character-driven engagement that users want to check
- **Unrealistic Tracking**: Session-based approach matches natural human drinking patterns (sip throughout meeting → finish bottle later → measure)

The boba revolution theme creates emotional connection and shareable moments that traditional health apps lack, with platform-appropriate presentation across mobile and desktop environments.

## Requirements

### Requirement 1: Session-Based Hydration Tracking

**User Story:** As a user, I want to track my water intake in realistic drinking sessions so that I don't have to measure individual sips and can log my consumption naturally.

#### Acceptance Criteria

1. WHEN user opens the app THEN system SHALL display current hydration status and available session options
2. WHEN user starts a drinking session THEN system SHALL record start time, container type, and target volume without pressure to immediately finish
3. WHEN user has an active session THEN system SHALL allow natural drinking without forced logging intervals
4. WHEN user completes drinking THEN system SHALL accept actual consumption amount (which may differ from target)
5. IF session exceeds 45 minutes without completion THEN system SHALL provide gentle reminder option
6. WHEN session is completed THEN system SHALL update daily progress and trigger character reactions

### Requirement 2: Science-Based Hydration Calculator

**User Story:** As a user, I want personalized hydration goals and safety monitoring so that I can stay properly hydrated without health risks.

#### Acceptance Criteria

1. WHEN user sets their weight THEN system SHALL calculate daily goal as 35ml per kg body weight
2. IF user attempts to log >300ml in 15 minutes THEN system SHALL display safety warning
3. WHEN hourly intake exceeds 700ml THEN system SHALL show kidney overload warning with visual indicator
4. IF daily intake approaches 4000ml THEN system SHALL alert user to daily maximum limit
5. WHEN calculating progress THEN system SHALL display current intake vs daily goal with visual progress indicator
6. WHEN user views hydration status THEN system SHALL show kidney load percentage as simple gauge

### Requirement 3: Revolutionary Boba Army Character System

**User Story:** As a user, I want to unlock and collect cute boba characters through consistent hydration so that tracking feels like a fun game rather than a health chore.

#### Acceptance Criteria

1. WHEN user achieves hydration milestones THEN system SHALL unlock new boba characters (taro ninjas, matcha wizards, fruit tea archers, milk tea knights)
2. WHEN user maintains perfect hydration timing THEN characters SHALL display "bubble synergy" effects
3. IF user over-hydrates THEN army SHALL appear waterlogged and sluggish with appropriate animations
4. IF user under-hydrates THEN characters SHALL become sad and deflated
5. WHEN user unlocks characters THEN system SHALL allow sharing army screenshots for social media
6. WHEN user taps characters THEN system SHALL display unique catchphrases ("Stay bouncy!", "Hydrate or die-drate!")

### Requirement 4: User Profile and Data Management

**User Story:** As a user, I want to set my personal information and preferences so that the app provides accurate calculations and remembers my habits.

#### Acceptance Criteria

1. WHEN user first opens app THEN system SHALL prompt for weight input for goal calculation
2. WHEN user adds container presets THEN system SHALL remember typical container sizes for quick session setup
3. WHEN user completes sessions THEN system SHALL store session history locally with no cloud dependency
4. IF user wants to modify weight THEN system SHALL recalculate daily goal automatically
5. WHEN user sets preferences THEN system SHALL maintain settings in local SQLite database
6. WHEN app handles data THEN system SHALL ensure all information stays on device for privacy

### Requirement 5: Multi-Platform Adaptive Interface

**User Story:** As a user, I want the app to work seamlessly across my devices (phone, tablet, desktop) with appropriate interface adaptations for each platform.

#### Acceptance Criteria

1. WHEN running on mobile devices THEN system SHALL use compact, thumb-friendly layouts optimized for portrait orientation
2. WHEN running on desktop THEN system SHALL utilize larger screen real estate with expanded character displays and multi-column layouts
3. WHEN running on tablet THEN system SHALL adapt to both portrait and landscape orientations gracefully
4. WHEN displaying characters on mobile THEN system SHALL show 3-5 characters prominently
5. WHEN displaying characters on desktop THEN system SHALL show larger character grid with more visible army members
6. WHEN presenting session controls on mobile THEN system SHALL use full-width buttons and simple navigation
7. WHEN presenting session controls on desktop THEN system SHALL use contextual menus and keyboard shortcuts where appropriate
8. WHEN showing progress indicators THEN system SHALL scale appropriately for screen size and pixel density

### Requirement 6: Platform-Specific Notification Handling

**User Story:** As a user, I want appropriate reminder notifications that work naturally on each platform I use.

#### Acceptance Criteria

1. WHEN running on mobile THEN system SHALL use native push notifications for session reminders
2. WHEN running on desktop THEN system SHALL use system tray notifications or desktop alerts
3. WHEN user has app open on desktop THEN system SHALL prioritize in-app notifications over system notifications
4. WHEN user has app backgrounded on mobile THEN system SHALL use push notifications for session timeouts
5. WHEN multiple platforms are used THEN system SHALL avoid duplicate notifications across devices (if future sync is implemented)

## Non-Functional Requirements

### Code Architecture and Modularity
- **Single Responsibility Principle**: Separate services for session management, hydration calculation, character management, and user profile
- **Modular Design**: Clear separation between UI widgets, business logic services, and database layer
- **Platform Abstraction**: UI components that adapt to platform constraints while sharing business logic
- **Dependency Management**: Services should be loosely coupled with dependency injection where appropriate
- **Clear Interfaces**: Well-defined contracts between session service, hydration calculator, and character manager

### Performance
- App must launch and display home screen within 2 seconds on target devices (mobile and desktop)
- Session start/end actions must complete within 500ms for responsive feel across all platforms
- Character animations should run at 60fps on supported devices
- SQLite queries must complete within 100ms for real-time progress updates
- Desktop version should handle window resizing smoothly without layout breaks

### Security
- All user data (weight, session history, character progress) must be stored locally only
- No network requests required for core functionality
- Graceful handling of incomplete sessions without data loss
- Input validation on all numeric fields (weight, volume amounts)
- Platform-appropriate security measures (keychain on iOS, credential manager on Windows, etc.)

### Reliability
- App must handle incomplete sessions gracefully if user closes app mid-session
- Database operations must be atomic to prevent data corruption
- Session data must persist across app restarts on all platforms
- Automatic database schema migration for future updates
- Consistent behavior across platform differences (file system access, permissions, etc.)

### Usability
- Interface must be optimized for each platform's interaction paradigms
- Mobile: Thumb-friendly with minimum 44pt touch targets, gesture support
- Desktop: Mouse/keyboard friendly with hover states, context menus, keyboard shortcuts
- Tablet: Touch-optimized but with larger information density
- Visual feedback must be immediate for all user actions across platforms
- Safety warnings must be clear and follow platform notification conventions
- Character unlock animations must provide satisfying feedback without being distracting
- Consistent visual branding across platforms while respecting platform design guidelines