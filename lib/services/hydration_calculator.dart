import '../models/hydration_session.dart';

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

  double getCurrentHourlyRate(List<HydrationSession> sessions) {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    return sessions
        .where((session) =>
            session.endTime != null &&
            session.endTime!.isAfter(oneHourAgo) &&
            session.actualMl != null)
        .fold(0.0, (sum, session) => sum + session.actualMl!);
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
}