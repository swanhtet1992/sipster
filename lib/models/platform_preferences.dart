/// Platform-specific user preferences for UI adaptation
class PlatformPreferences {
  final String platform;
  final int preferredCharacterCount;
  final bool enableNotifications;
  final Duration defaultReminderDelay;
  final String layoutMode;
  final bool compactMode;
  final double preferredFontScale;
  final bool enableHapticFeedback;
  final bool showAdvancedStats;

  const PlatformPreferences({
    required this.platform,
    required this.preferredCharacterCount,
    required this.enableNotifications,
    required this.defaultReminderDelay,
    required this.layoutMode,
    this.compactMode = false,
    this.preferredFontScale = 1.0,
    this.enableHapticFeedback = true,
    this.showAdvancedStats = false,
  });

  /// Create default preferences for mobile platform
  factory PlatformPreferences.mobile() {
    return const PlatformPreferences(
      platform: 'mobile',
      preferredCharacterCount: 5,
      enableNotifications: true,
      defaultReminderDelay: Duration(minutes: 45),
      layoutMode: 'compact',
      compactMode: true,
      preferredFontScale: 1.0,
      enableHapticFeedback: true,
      showAdvancedStats: false,
    );
  }

  /// Create default preferences for tablet platform
  factory PlatformPreferences.tablet() {
    return const PlatformPreferences(
      platform: 'tablet',
      preferredCharacterCount: 8,
      enableNotifications: true,
      defaultReminderDelay: Duration(minutes: 45),
      layoutMode: 'expanded',
      compactMode: false,
      preferredFontScale: 1.1,
      enableHapticFeedback: true,
      showAdvancedStats: true,
    );
  }

  /// Create default preferences for desktop platform
  factory PlatformPreferences.desktop() {
    return const PlatformPreferences(
      platform: 'desktop',
      preferredCharacterCount: 12,
      enableNotifications: false, // Desktop users prefer in-app notifications
      defaultReminderDelay: Duration(minutes: 60), // Longer delay for desktop work
      layoutMode: 'expanded',
      compactMode: false,
      preferredFontScale: 1.2,
      enableHapticFeedback: false, // No haptic feedback on desktop
      showAdvancedStats: true,
    );
  }

  /// Create default preferences based on platform name
  factory PlatformPreferences.forPlatform(String platformName) {
    switch (platformName.toLowerCase()) {
      case 'mobile':
      case 'android':
      case 'ios':
        return PlatformPreferences.mobile();
      case 'tablet':
        return PlatformPreferences.tablet();
      case 'desktop':
      case 'macos':
      case 'windows':
      case 'linux':
      case 'web':
        return PlatformPreferences.desktop();
      default:
        return PlatformPreferences.mobile(); // Fallback to mobile
    }
  }

  /// Check if this is a mobile platform preference
  bool get isMobile => platform == 'mobile' || platform == 'android' || platform == 'ios';

  /// Check if this is a tablet platform preference
  bool get isTablet => platform == 'tablet';

  /// Check if this is a desktop platform preference
  bool get isDesktop => platform == 'desktop' || platform == 'macos' || 
                        platform == 'windows' || platform == 'linux' || platform == 'web';

  /// Get reminder delay in minutes for convenience
  int get reminderDelayMinutes => defaultReminderDelay.inMinutes;

  /// Check if expanded layout should be used
  bool get useExpandedLayout => layoutMode == 'expanded';

  /// Check if notifications should be enabled for this platform
  bool get shouldShowNotificationSettings => platform != 'web';

  /// Copy with method for immutable updates
  PlatformPreferences copyWith({
    String? platform,
    int? preferredCharacterCount,
    bool? enableNotifications,
    Duration? defaultReminderDelay,
    String? layoutMode,
    bool? compactMode,
    double? preferredFontScale,
    bool? enableHapticFeedback,
    bool? showAdvancedStats,
  }) {
    return PlatformPreferences(
      platform: platform ?? this.platform,
      preferredCharacterCount: preferredCharacterCount ?? this.preferredCharacterCount,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      defaultReminderDelay: defaultReminderDelay ?? this.defaultReminderDelay,
      layoutMode: layoutMode ?? this.layoutMode,
      compactMode: compactMode ?? this.compactMode,
      preferredFontScale: preferredFontScale ?? this.preferredFontScale,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      showAdvancedStats: showAdvancedStats ?? this.showAdvancedStats,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'preferredCharacterCount': preferredCharacterCount,
      'enableNotifications': enableNotifications,
      'defaultReminderDelayMinutes': defaultReminderDelay.inMinutes,
      'layoutMode': layoutMode,
      'compactMode': compactMode,
      'preferredFontScale': preferredFontScale,
      'enableHapticFeedback': enableHapticFeedback,
      'showAdvancedStats': showAdvancedStats,
    };
  }

  /// Create from JSON for deserialization
  factory PlatformPreferences.fromJson(Map<String, dynamic> json) {
    return PlatformPreferences(
      platform: json['platform'] as String,
      preferredCharacterCount: json['preferredCharacterCount'] as int,
      enableNotifications: json['enableNotifications'] as bool,
      defaultReminderDelay: Duration(
        minutes: json['defaultReminderDelayMinutes'] as int,
      ),
      layoutMode: json['layoutMode'] as String,
      compactMode: json['compactMode'] as bool? ?? false,
      preferredFontScale: (json['preferredFontScale'] as num?)?.toDouble() ?? 1.0,
      enableHapticFeedback: json['enableHapticFeedback'] as bool? ?? true,
      showAdvancedStats: json['showAdvancedStats'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatformPreferences &&
          runtimeType == other.runtimeType &&
          platform == other.platform &&
          preferredCharacterCount == other.preferredCharacterCount &&
          enableNotifications == other.enableNotifications &&
          defaultReminderDelay == other.defaultReminderDelay &&
          layoutMode == other.layoutMode &&
          compactMode == other.compactMode &&
          preferredFontScale == other.preferredFontScale &&
          enableHapticFeedback == other.enableHapticFeedback &&
          showAdvancedStats == other.showAdvancedStats;

  @override
  int get hashCode =>
      platform.hashCode ^
      preferredCharacterCount.hashCode ^
      enableNotifications.hashCode ^
      defaultReminderDelay.hashCode ^
      layoutMode.hashCode ^
      compactMode.hashCode ^
      preferredFontScale.hashCode ^
      enableHapticFeedback.hashCode ^
      showAdvancedStats.hashCode;

  @override
  String toString() {
    return 'PlatformPreferences{'
        'platform: $platform, '
        'preferredCharacterCount: $preferredCharacterCount, '
        'enableNotifications: $enableNotifications, '
        'defaultReminderDelay: $defaultReminderDelay, '
        'layoutMode: $layoutMode, '
        'compactMode: $compactMode, '
        'preferredFontScale: $preferredFontScale, '
        'enableHapticFeedback: $enableHapticFeedback, '
        'showAdvancedStats: $showAdvancedStats'
        '}';
  }
}

/// Layout mode constants for type safety
class LayoutMode {
  static const String compact = 'compact';
  static const String expanded = 'expanded';
  static const String adaptive = 'adaptive';
  
  static const List<String> all = [compact, expanded, adaptive];
  
  static bool isValid(String mode) => all.contains(mode);
}