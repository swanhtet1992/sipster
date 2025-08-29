import 'package:flutter/material.dart';

/// Severity levels for safety warnings
enum SafetyLevel { 
  info, 
  warning, 
  danger 
}

/// Represents a safety warning for hydration monitoring
class SafetyWarning {
  final SafetyLevel level;
  final String title;
  final String message;
  final Duration? suggestedDelay;
  final Color? warningColor;

  const SafetyWarning({
    required this.level,
    required this.title,
    required this.message,
    this.suggestedDelay,
    this.warningColor,
  });

  /// Create an info-level safety warning
  factory SafetyWarning.info({
    required String title,
    required String message,
    Duration? suggestedDelay,
    Color? color,
  }) {
    return SafetyWarning(
      level: SafetyLevel.info,
      title: title,
      message: message,
      suggestedDelay: suggestedDelay,
      warningColor: color ?? Colors.blue,
    );
  }

  /// Create a warning-level safety warning
  factory SafetyWarning.warning({
    required String title,
    required String message,
    Duration? suggestedDelay,
    Color? color,
  }) {
    return SafetyWarning(
      level: SafetyLevel.warning,
      title: title,
      message: message,
      suggestedDelay: suggestedDelay,
      warningColor: color ?? Colors.orange,
    );
  }

  /// Create a danger-level safety warning
  factory SafetyWarning.danger({
    required String title,
    required String message,
    Duration? suggestedDelay,
    Color? color,
  }) {
    return SafetyWarning(
      level: SafetyLevel.danger,
      title: title,
      message: message,
      suggestedDelay: suggestedDelay,
      warningColor: color ?? Colors.red,
    );
  }

  /// Check if this warning should block user action
  bool get isBlocking => level == SafetyLevel.danger;

  /// Check if this is a high-priority warning
  bool get isHighPriority => level == SafetyLevel.warning || level == SafetyLevel.danger;

  /// Get a user-friendly string representation of the safety level
  String get levelName {
    switch (level) {
      case SafetyLevel.info:
        return 'Info';
      case SafetyLevel.warning:
        return 'Warning';
      case SafetyLevel.danger:
        return 'Danger';
    }
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'level': level.toString().split('.').last,
      'title': title,
      'message': message,
      'suggestedDelayMinutes': suggestedDelay?.inMinutes,
      'warningColorValue': warningColor?.toARGB32(),
    };
  }

  /// Create from JSON for deserialization
  factory SafetyWarning.fromJson(Map<String, dynamic> json) {
    SafetyLevel level;
    switch (json['level'] as String) {
      case 'warning':
        level = SafetyLevel.warning;
        break;
      case 'danger':
        level = SafetyLevel.danger;
        break;
      default:
        level = SafetyLevel.info;
    }

    Duration? delay;
    if (json['suggestedDelayMinutes'] != null) {
      delay = Duration(minutes: json['suggestedDelayMinutes'] as int);
    }

    Color? color;
    if (json['warningColorValue'] != null) {
      color = Color(json['warningColorValue'] as int);
    }

    return SafetyWarning(
      level: level,
      title: json['title'] as String,
      message: json['message'] as String,
      suggestedDelay: delay,
      warningColor: color,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafetyWarning &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          title == other.title &&
          message == other.message &&
          suggestedDelay == other.suggestedDelay &&
          warningColor == other.warningColor;

  @override
  int get hashCode =>
      level.hashCode ^
      title.hashCode ^
      message.hashCode ^
      suggestedDelay.hashCode ^
      warningColor.hashCode;

  @override
  String toString() {
    return 'SafetyWarning{level: $level, title: $title, message: $message}';
  }
}