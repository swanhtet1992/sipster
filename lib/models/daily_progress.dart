import 'hydration_session.dart';

class DailyProgress {
  final DateTime date;
  final double totalMl;
  final double goalMl;
  final List<HydrationSession> sessions;
  final double maxHourlyRate;

  const DailyProgress({
    required this.date,
    required this.totalMl,
    required this.goalMl,
    required this.sessions,
    required this.maxHourlyRate,
  });

  double get progressPercentage => 
      goalMl > 0 ? (totalMl / goalMl * 100).clamp(0, 100) : 0;

  bool get goalReached => totalMl >= goalMl;

  factory DailyProgress.fromSessions({
    required DateTime date,
    required double goalMl,
    required List<HydrationSession> sessions,
  }) {
    final completedSessions = sessions
        .where((s) => s.actualMl != null)
        .toList();
        
    final totalMl = completedSessions
        .fold(0.0, (sum, session) => sum + (session.actualMl ?? 0));

    final maxHourlyRate = _calculateMaxHourlyRate(completedSessions);

    return DailyProgress(
      date: date,
      totalMl: totalMl,
      goalMl: goalMl,
      sessions: sessions,
      maxHourlyRate: maxHourlyRate,
    );
  }

  static double _calculateMaxHourlyRate(List<HydrationSession> sessions) {
    if (sessions.isEmpty) return 0.0;

    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    final recentSessions = sessions.where((s) => 
        s.endTime != null && 
        s.endTime!.isAfter(oneHourAgo) && 
        s.actualMl != null
    ).toList();

    return recentSessions.fold(0.0, (sum, s) => sum + s.actualMl!);
  }
}