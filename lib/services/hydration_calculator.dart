import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/hydration_session.dart';
import '../models/safety_warning.dart';
import '../theme/design_constants.dart';

class HydrationCalculator {
  static const double _mlPerKgGoal = 35.0;
  static const double _dangerousHourlyRate = 700.0;
  static const double _maxDailyIntake = 4000.0;
  static const double _rapidIntakeThreshold = 300.0;

  double calculateDailyGoal(double weightKg) {
    return weightKg * _mlPerKgGoal;
  }

  bool isOverHydrating(List<HydrationSession> recentSessions) {
    final hourlyRate = getCurrentHourlyRate(recentSessions);
    return hourlyRate > _dangerousHourlyRate;
  }

  /// FIXED: Properly calculates hourly rate considering session duration
  /// This accounts for the fact that sessions represent gradual consumption over time
  double getCurrentHourlyRate(List<HydrationSession> sessions) {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    double totalMl = 0.0;

    for (final session in sessions) {
      if (session.endTime == null || session.actualMl == null) continue;
      
      // Calculate the portion of this session that falls within the last hour
      final sessionStart = session.startTime;
      final sessionEnd = session.endTime!;
      
      // Check if session overlaps with our time window
      if (sessionEnd.isAfter(oneHourAgo) && sessionStart.isBefore(now)) {
        // Calculate overlap period
        final overlapStart = sessionStart.isAfter(oneHourAgo) ? sessionStart : oneHourAgo;
        final overlapEnd = sessionEnd.isBefore(now) ? sessionEnd : now;
        final overlapDuration = overlapEnd.difference(overlapStart);
        
        // Calculate total session duration
        final sessionDuration = sessionEnd.difference(sessionStart);
        
        if (sessionDuration.inMinutes > 0) {
          // Calculate the portion of fluid consumed during the overlap period
          final overlapRatio = overlapDuration.inMinutes / sessionDuration.inMinutes;
          final overlapMl = session.actualMl! * overlapRatio;
          totalMl += overlapMl;
        }
      }
    }

    return totalMl;
  }

  double getKidneyLoadPercentage(double hourlyRate) {
    return (hourlyRate / _dangerousHourlyRate * 100).clamp(0, 100);
  }

  bool isRapidIntake(double amount) {
    return amount > _rapidIntakeThreshold;
  }

  bool isDailyLimitExceeded(double totalDaily) {
    return totalDaily > _maxDailyIntake;
  }

  String getSafetyWarning(List<HydrationSession> sessions, double todayTotal) {
    if (isDailyLimitExceeded(todayTotal)) {
      return 'Daily limit exceeded! Consider spacing out your hydration.';
    }

    if (isOverHydrating(sessions)) {
      return 'Slow down! You\'re drinking too much too fast.';
    }

    final lastSession = sessions
        .where((s) => s.actualMl != null)
        .toList()
        ..sort((a, b) => (b.endTime ?? b.startTime)
            .compareTo(a.endTime ?? a.startTime));

    if (lastSession.isNotEmpty && isRapidIntake(lastSession.first.actualMl!)) {
      return 'Take it easy! That\'s a lot of liquid at once.';
    }

    return '';
  }

  Map<String, dynamic> getHydrationStats({
    required List<HydrationSession> todaySessions,
    required double dailyGoal,
  }) {
    final completedSessions = todaySessions
        .where((s) => s.actualMl != null)
        .toList();

    final totalToday = completedSessions
        .fold(0.0, (sum, s) => sum + s.actualMl!);

    final hourlyRate = getCurrentHourlyRate(completedSessions);
    final kidneyLoad = getKidneyLoadPercentage(hourlyRate);
    final progressPercent = dailyGoal > 0 ? (totalToday / dailyGoal * 100).clamp(0, 100) : 0;
    final safetyWarning = getSafetyWarning(completedSessions, totalToday);

    return {
      'totalToday': totalToday,
      'dailyGoal': dailyGoal,
      'progressPercent': progressPercent,
      'hourlyRate': hourlyRate,
      'kidneyLoad': kidneyLoad,
      'safetyWarning': safetyWarning,
      'goalReached': totalToday >= dailyGoal,
    };
  }

  /// FIXED: Calculate kidney load percentage based on recent hourly intake history
  /// This properly accounts for session duration and natural decay over time
  double calculateKidneyLoad(List<HydrationSession> hourlyHistory) {
    final now = DateTime.now();
    
    // Calculate kidney load using a rolling 2-hour window with proper decay
    final twoHoursAgo = now.subtract(const Duration(hours: 2));
    double totalKidneyLoad = 0.0;
    
    for (final session in hourlyHistory) {
      if (session.endTime == null || session.actualMl == null) continue;
      
      final sessionStart = session.startTime;
      final sessionEnd = session.endTime!;
      
      // Only consider sessions that overlap with our 2-hour window
      if (sessionEnd.isAfter(twoHoursAgo) && sessionStart.isBefore(now)) {
        final sessionDuration = sessionEnd.difference(sessionStart);
        if (sessionDuration.inMinutes <= 0) continue;
        
        // Calculate how much of this session's load still affects kidneys
        // Kidney processing follows exponential decay with ~90 minute half-life
        final sessionAgeMinutes = now.difference(sessionEnd).inMinutes;
        final decayFactor = _calculateKidneyDecay(sessionAgeMinutes);
        
        // Calculate effective hourly rate for this session
        final sessionHourlyRate = (session.actualMl! / sessionDuration.inMinutes) * 60;
        
        // Add to total load with decay applied
        totalKidneyLoad += (sessionHourlyRate / _dangerousHourlyRate) * decayFactor;
      }
    }
    
    return (totalKidneyLoad * 100).clamp(0, 100);
  }
  
  /// Calculate kidney processing decay factor
  /// Based on medical literature: kidneys process ~800-1000ml/hour optimally
  /// Load decreases exponentially with ~90 minute half-life
  double _calculateKidneyDecay(int ageInMinutes) {
    if (ageInMinutes < 0) return 1.0; // Future sessions (shouldn't happen)
    if (ageInMinutes > 240) return 0.0; // After 4 hours, minimal impact
    
    // Exponential decay: load(t) = initial * e^(-t/90)
    // Where 90 minutes is approximate half-life of kidney processing
    const halfLife = 90.0; // minutes
    final lambda = 0.693147 / halfLife; // ln(2) / half-life
    return math.pow(math.e, -lambda * ageInMinutes).toDouble();
  }

  /// Evaluate session safety and return appropriate warning
  SafetyWarning? evaluateSessionSafety(double ml, Duration duration) {
    final ratePerHour = (ml / duration.inMinutes.toDouble()) * 60;
    
    // Danger level - immediate health risk
    if (ml > 500 && duration.inMinutes < 10) {
      return SafetyWarning.danger(
        title: 'Dangerous Intake Rate!',
        message: 'Drinking ${ml.toInt()}ml in ${duration.inMinutes} minutes is dangerous. Please slow down and seek medical advice if you feel unwell.',
        suggestedDelay: const Duration(hours: 2),
        color: Colors.red,
      );
    }
    
    // Warning level - concerning but not immediately dangerous
    if (ratePerHour > _dangerousHourlyRate) {
      return SafetyWarning.warning(
        title: 'Slow Down!',
        message: 'You\'re drinking too much too quickly. Your current rate could stress your kidneys.',
        suggestedDelay: const Duration(minutes: 30),
        color: DesignConstants.warning,
      );
    }
    
    // Warning for rapid intake
    if (ml > _rapidIntakeThreshold && duration.inMinutes < 15) {
      return SafetyWarning.warning(
        title: 'Take It Easy',
        message: 'That\'s a lot of liquid at once. Consider sipping more slowly.',
        suggestedDelay: const Duration(minutes: 15),
        color: DesignConstants.warning,
      );
    }
    
    // Info level - good hydration but worth noting
    if (ml > 200 && ratePerHour < _dangerousHourlyRate * 0.7) {
      return SafetyWarning.info(
        title: 'Good Hydration!',
        message: 'Nice steady intake. Keep up the good hydration habits!',
        color: DesignConstants.success,
      );
    }
    
    return null; // No warning needed
  }

  /// Get color for warning based on safety level and kidney load
  Color getWarningColor(SafetyLevel level, {double? kidneyLoadPercent}) {
    switch (level) {
      case SafetyLevel.danger:
        return Colors.red;
      case SafetyLevel.warning:
        // Use kidney load to determine warning color intensity
        if (kidneyLoadPercent != null && kidneyLoadPercent > 80) {
          return Colors.deepOrange;
        }
        return DesignConstants.warning;
      case SafetyLevel.info:
        return DesignConstants.success;
    }
  }

  /// Get comprehensive safety assessment for current hydration state
  Map<String, dynamic> getEnhancedSafetyAssessment({
    required List<HydrationSession> todaySessions,
    required List<HydrationSession> hourlyHistory,
    required double todayTotal,
  }) {
    final kidneyLoad = calculateKidneyLoad(hourlyHistory);
    final hourlyRate = getCurrentHourlyRate(todaySessions);
    
    // Evaluate overall safety status
    SafetyLevel overallLevel = SafetyLevel.info;
    String statusMessage = 'Hydration levels look good!';
    Color statusColor = DesignConstants.success;
    
    if (kidneyLoad > 85 || hourlyRate > _dangerousHourlyRate) {
      overallLevel = SafetyLevel.danger;
      statusMessage = 'Immediate attention needed - drinking too much too fast';
      statusColor = Colors.red;
    } else if (kidneyLoad > 70 || hourlyRate > _dangerousHourlyRate * 0.8) {
      overallLevel = SafetyLevel.warning;
      statusMessage = 'Slow down your intake rate';
      statusColor = DesignConstants.warning;
    } else if (todayTotal > _maxDailyIntake * 0.9) {
      overallLevel = SafetyLevel.warning;
      statusMessage = 'Approaching daily limit - space out remaining intake';
      statusColor = DesignConstants.warning;
    }
    
    return {
      'kidneyLoad': kidneyLoad,
      'hourlyRate': hourlyRate,
      'overallLevel': overallLevel,
      'statusMessage': statusMessage,
      'statusColor': statusColor,
      'isHealthyRate': hourlyRate < _dangerousHourlyRate * 0.6,
      'shouldShowWarning': overallLevel != SafetyLevel.info,
    };
  }
}