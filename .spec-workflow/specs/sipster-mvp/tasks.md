# Tasks Document

- [x] 1. Create platform detection utilities in lib/utils/platform_utils.dart
  - File: lib/utils/platform_utils.dart
  - Implement platform detection methods (isMobile, isDesktop, isTablet)
  - Add responsive breakpoint constants and helper methods
  - Purpose: Enable platform-specific UI adaptations across the app
  - _Leverage: Flutter Platform class, MediaQuery_
  - _Requirements: 5.1, 5.2_

- [x] 2. Extend HydrationCalculator with enhanced safety monitoring in lib/services/hydration_calculator.dart
  - File: lib/services/hydration_calculator.dart (modify existing)
  - Add calculateKidneyLoad method for hourly intake tracking
  - Implement SafetyWarning evaluation with visual indicators
  - Add getWarningColor method using DesignConstants
  - Purpose: Provide enhanced safety monitoring with visual feedback
  - _Leverage: existing HydrationCalculator methods, lib/theme/design_constants.dart_
  - _Requirements: 2.1, 2.2_

- [x] 3. Create SafetyWarning model in lib/models/safety_warning.dart
  - File: lib/models/safety_warning.dart
  - Define SafetyWarning class with level, message, title, color properties
  - Add SafetyLevel enum (info, warning, danger)
  - Include JSON serialization methods for consistency
  - Purpose: Standardize safety warning data structure
  - _Leverage: existing model patterns from lib/models/_
  - _Requirements: 2.2_

- [x] 4. Extend SessionService with timeout and container memory in lib/services/session_service.dart
  - File: lib/services/session_service.dart (modify existing)
  - Add handleSessionTimeout method for platform-appropriate reminders
  - Implement getLearnedContainers method to track user patterns
  - Add session timeout detection based on 45-minute threshold
  - Purpose: Enhance session management with smart reminders and learning
  - _Leverage: existing SessionService CRUD operations, DatabaseHelper_
  - _Requirements: 1.1, 1.3_

- [x] 5. Create multi-platform notification service in lib/services/notification_service.dart
  - File: lib/services/notification_service.dart
  - Implement platform-specific notification scheduling
  - Add requestNotificationPermissions method
  - Handle notification cancellation and session-specific reminders
  - Purpose: Provide platform-appropriate notification system
  - _Leverage: flutter_local_notifications package, platform detection_
  - _Requirements: 6.1, 6.2_

- [x] 6. Create platform preferences model in lib/models/platform_preferences.dart
  - File: lib/models/platform_preferences.dart
  - Define PlatformPreferences class with platform-specific settings
  - Add JSON serialization and default value methods
  - Include preferred character count and layout mode settings
  - Purpose: Store platform-specific user preferences
  - _Leverage: existing model serialization patterns_
  - _Requirements: 5.1_

- [x] 7. Enhance CharacterService with improved unlock logic in lib/services/character_service.dart
  - File: lib/services/character_service.dart (modify existing)
  - Improve character unlock algorithm based on consistency patterns
  - Add army status evaluation (happy, waterlogged, sad) based on hydration timing
  - Implement bubble synergy effects for perfect hydration
  - Purpose: Create more engaging character progression system
  - _Leverage: existing CharacterService methods, DatabaseHelper_
  - _Requirements: 3.1, 3.2_

- [x] 8. Create responsive character grid widget in lib/widgets/character_grid.dart
  - File: lib/widgets/character_grid.dart (modify existing)
  - Add platform-adaptive character count (mobile: 3-5, desktop: 8-12, tablet: 6-10)
  - Implement responsive grid sizing based on screen dimensions
  - Add character tap interactions with catchphrase display
  - Purpose: Optimize character display for different screen sizes
  - _Leverage: existing CharacterGrid widget, lib/utils/platform_utils.dart, lib/theme/design_constants.dart_
  - _Requirements: 3.3, 5.1_

- [-] 9. Enhance progress bar with kidney load indicator in lib/widgets/progress_bar.dart
  - File: lib/widgets/progress_bar.dart (modify existing)
  - Add kidney load gauge visualization alongside hydration progress
  - Implement safety warning color integration
  - Add animated transitions for safety level changes
  - Purpose: Provide comprehensive hydration status visualization
  - _Leverage: existing ProgressBar widget, lib/theme/design_constants.dart_
  - _Requirements: 2.3, 5.3_

- [ ] 10. Create platform-adaptive session controls in lib/widgets/session_controls.dart
  - File: lib/widgets/session_controls.dart (modify existing)
  - Implement platform-specific button sizing and layouts
  - Add keyboard shortcut support for desktop platform
  - Create responsive container selection UI
  - Purpose: Optimize session controls for different interaction patterns
  - _Leverage: existing SessionControls widget, lib/utils/platform_utils.dart_
  - _Requirements: 1.2, 5.2_

- [ ] 11. Enhance HomeScreen with multi-platform layout adaptation in lib/screens/home_screen.dart
  - File: lib/screens/home_screen.dart (modify existing)
  - Implement responsive layout switching based on screen size
  - Add platform-specific navigation patterns
  - Integrate enhanced safety warnings and kidney load display
  - Purpose: Create platform-optimized main interface
  - _Leverage: existing HomeScreen implementation, all enhanced widgets_
  - _Requirements: 5.1, 5.2, 5.3_

- [ ] 12. Add flutter_local_notifications dependency in pubspec.yaml
  - File: pubspec.yaml (modify existing)
  - Add flutter_local_notifications package for cross-platform notifications
  - Update dependency versions and ensure compatibility
  - Purpose: Enable notification functionality across platforms
  - _Leverage: existing pubspec.yaml dependency management_
  - _Requirements: 6.1_

- [ ] 13. Create safety warning dialog widget in lib/widgets/safety_warning_dialog.dart
  - File: lib/widgets/safety_warning_dialog.dart
  - Implement platform-appropriate warning dialog design
  - Add safety level color coding and clear messaging
  - Include suggested delay recommendations
  - Purpose: Provide clear safety feedback to users
  - _Leverage: lib/models/safety_warning.dart, lib/theme/design_constants.dart_
  - _Requirements: 2.3_

- [ ] 14. Update database schema for enhanced features in lib/database/database_helper.dart
  - File: lib/database/database_helper.dart (modify existing)
  - Add database migration for new platform preferences table
  - Update session table to include platform context and reminder delays
  - Add indexes for performance optimization
  - Purpose: Support enhanced data storage requirements
  - _Leverage: existing DatabaseHelper schema and migration patterns_
  - _Requirements: 4.2, 4.3_

- [ ] 15. Create comprehensive unit tests in test/services/enhanced_services_test.dart
  - File: test/services/enhanced_services_test.dart
  - Write tests for enhanced HydrationCalculator safety methods
  - Test SessionService timeout and learning functionality
  - Test NotificationService platform-specific behavior
  - Purpose: Ensure reliability of enhanced service functionality
  - _Leverage: existing test patterns, test/widget_test.dart structure_
  - _Requirements: All enhanced service requirements_

- [ ] 16. Create widget tests for responsive components in test/widgets/responsive_widgets_test.dart
  - File: test/widgets/responsive_widgets_test.dart
  - Test CharacterGrid responsiveness across different screen sizes
  - Test ProgressBar kidney load indicator functionality
  - Test SessionControls platform adaptation
  - Purpose: Verify UI components adapt correctly across platforms
  - _Leverage: Flutter widget testing framework, platform mocking_
  - _Requirements: 5.1, 5.2, 5.3_

- [ ] 17. Integration testing for complete hydration flow in test/integration/hydration_flow_test.dart
  - File: test/integration/hydration_flow_test.dart
  - Test complete session flow with safety monitoring
  - Test character unlocking with enhanced logic
  - Test notification scheduling and platform adaptation
  - Purpose: Verify end-to-end functionality works correctly
  - _Leverage: Flutter integration testing framework_
  - _Requirements: All requirements integration_

- [ ] 18. Update app theme for multi-platform consistency in lib/main.dart
  - File: lib/main.dart (modify existing)
  - Add platform-specific theme adaptations while maintaining brand consistency
  - Configure Material 3 design for optimal cross-platform experience
  - Integrate enhanced DesignConstants usage
  - Purpose: Ensure consistent visual experience across platforms
  - _Leverage: existing theme configuration, lib/theme/design_constants.dart_
  - _Requirements: 5.1, 5.2_