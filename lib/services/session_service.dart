import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/hydration_session.dart';

class SessionService {
  final DatabaseHelper _db = DatabaseHelper();
  static const _uuid = Uuid();

  Future<String> startSession(String containerType, double targetMl) async {
    final database = await _db.database;
    final sessionId = _uuid.v4();

    final session = HydrationSession(
      id: sessionId,
      startTime: DateTime.now(),
      targetMl: targetMl,
      containerType: containerType,
      isActive: true,
    );

    await database.insert('hydration_sessions', session.toJson());
    return sessionId;
  }

  Future<String> startNewSession(String containerType, double targetMl) async {
    // Explicitly end any existing session and start a new one
    await _endActiveSession();
    return await startSession(containerType, targetMl);
  }

  Future<void> endSession(String sessionId, double actualMl) async {
    final database = await _db.database;

    await database.update(
      'hydration_sessions',
      {
        'end_time': DateTime.now().toIso8601String(),
        'actual_ml': actualMl,
        'is_active': 0,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<HydrationSession?> getCurrentSession() async {
    final database = await _db.database;
    final result = await database.query(
      'hydration_sessions',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'start_time DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;
    return HydrationSession.fromJson(result.first);
  }

  Future<List<HydrationSession>> getTodaySessions() async {
    final database = await _db.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await database.query(
      'hydration_sessions',
      where: 'start_time >= ? AND start_time < ?',
      whereArgs: [
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
      orderBy: 'start_time ASC',
    );

    return result.map((json) => HydrationSession.fromJson(json)).toList();
  }

  Future<List<HydrationSession>> getSessionsInRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final database = await _db.database;
    final result = await database.query(
      'hydration_sessions',
      where: 'start_time >= ? AND start_time <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'start_time ASC',
    );

    return result.map((json) => HydrationSession.fromJson(json)).toList();
  }

  Future<void> _endActiveSession() async {
    final activeSession = await getCurrentSession();
    if (activeSession != null) {
      await endSession(activeSession.id, activeSession.targetMl);
    }
  }

  Future<void> cancelCurrentSession() async {
    final database = await _db.database;
    await database.delete(
      'hydration_sessions',
      where: 'is_active = ?',
      whereArgs: [1],
    );
  }

  List<String> getDefaultContainers() => [
        'Water Bottle (500ml)',
        'Glass (250ml)',
        'Large Bottle (750ml)',
        'Cup (200ml)',
        'Tumbler (400ml)',
      ];

  double parseContainerSize(String containerType) {
    final regex = RegExp(r'\((\d+)ml\)');
    final match = regex.firstMatch(containerType);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 500.0;
    }
    return 500.0;
  }

  /// Handle session timeout with platform-appropriate reminders
  Future<bool> handleSessionTimeout(String sessionId) async {
    final session = await _getSessionById(sessionId);
    if (session == null || !session.isActive) {
      return false; // Session doesn't exist or is already completed
    }

    final now = DateTime.now();
    final sessionDuration = now.difference(session.startTime);
    
    // Check if session has exceeded 45-minute threshold
    if (sessionDuration.inMinutes < 45) {
      return false; // Not yet timed out
    }

    // Calculate estimated completion based on typical drinking patterns
    final estimatedCompletion = _estimateSessionCompletion(session);
    
    // Auto-complete session with estimated amount if timeout is severe (over 2 hours)
    if (sessionDuration.inHours >= 2) {
      await endSession(sessionId, estimatedCompletion);
      return true;
    }

    // For timeouts between 45 minutes and 2 hours, just flag for reminder
    return true;
  }

  /// Get learned containers based on user's historical usage patterns
  Future<List<String>> getLearnedContainers() async {
    final database = await _db.database;
    
    // Get container usage frequency from completed sessions
    final result = await database.rawQuery('''
      SELECT container_type, COUNT(*) as usage_count, AVG(actual_ml) as avg_amount
      FROM hydration_sessions 
      WHERE actual_ml IS NOT NULL 
        AND end_time IS NOT NULL
        AND start_time >= datetime('now', '-30 days')
      GROUP BY container_type 
      ORDER BY usage_count DESC, avg_amount DESC
    ''');

    final learnedContainers = <String>[];
    final defaultContainers = getDefaultContainers();
    
    // Add frequently used containers first
    for (final row in result) {
      final containerType = row['container_type'] as String;
      final usageCount = row['usage_count'] as int;
      final avgAmount = row['avg_amount'] as double;
      
      if (usageCount >= 3) { // Only include containers used at least 3 times
        // Update container name with learned average if significantly different
        final defaultSize = parseContainerSize(containerType);
        if ((avgAmount - defaultSize).abs() > 50) {
          final updatedContainer = _updateContainerWithAverage(containerType, avgAmount);
          learnedContainers.add(updatedContainer);
        } else {
          learnedContainers.add(containerType);
        }
      }
    }

    // Add default containers that haven't been overridden
    for (final defaultContainer in defaultContainers) {
      if (!learnedContainers.any((learned) => 
          _getBaseContainerName(learned) == _getBaseContainerName(defaultContainer))) {
        learnedContainers.add(defaultContainer);
      }
    }

    // Limit to top 8 containers for UI purposes
    return learnedContainers.take(8).toList();
  }

  /// Check if current session has timed out (45+ minutes)
  Future<bool> isCurrentSessionTimedOut() async {
    final currentSession = await getCurrentSession();
    if (currentSession == null) return false;

    final duration = DateTime.now().difference(currentSession.startTime);
    return duration.inMinutes >= 45;
  }

  /// Get session timeout status and suggested action
  Future<Map<String, dynamic>?> getSessionTimeoutStatus() async {
    final currentSession = await getCurrentSession();
    if (currentSession == null) return null;

    final now = DateTime.now();
    final duration = now.difference(currentSession.startTime);
    
    if (duration.inMinutes < 45) {
      return null; // Not timed out
    }

    final estimatedAmount = _estimateSessionCompletion(currentSession);
    
    return {
      'sessionId': currentSession.id,
      'containerType': currentSession.containerType,
      'targetMl': currentSession.targetMl,
      'estimatedMl': estimatedAmount,
      'durationMinutes': duration.inMinutes,
      'isLongTimeout': duration.inHours >= 2,
      'suggestedAction': duration.inHours >= 2 
          ? 'auto_complete' 
          : 'remind_user',
      'timeoutMessage': _getTimeoutMessage(duration),
    };
  }

  /// Get user's typical container completion patterns
  Future<Map<String, double>> getContainerCompletionPatterns() async {
    final database = await _db.database;
    
    final result = await database.rawQuery('''
      SELECT container_type, 
             AVG(CAST(actual_ml AS REAL) / CAST(target_ml AS REAL)) as avg_completion_rate,
             COUNT(*) as session_count
      FROM hydration_sessions 
      WHERE actual_ml IS NOT NULL 
        AND target_ml > 0
        AND end_time IS NOT NULL
        AND start_time >= datetime('now', '-60 days')
      GROUP BY container_type 
      HAVING session_count >= 3
    ''');

    final patterns = <String, double>{};
    for (final row in result) {
      final containerType = row['container_type'] as String;
      final completionRate = row['avg_completion_rate'] as double;
      patterns[containerType] = completionRate.clamp(0.0, 1.0);
    }

    return patterns;
  }

  /// Private helper to get session by ID
  Future<HydrationSession?> _getSessionById(String sessionId) async {
    final database = await _db.database;
    final result = await database.query(
      'hydration_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return HydrationSession.fromJson(result.first);
  }

  /// Estimate completion amount based on historical patterns
  double _estimateSessionCompletion(HydrationSession session) {
    // Default to 80% of target if no historical data
    double estimatedCompletion = session.targetMl * 0.8;
    
    // This could be enhanced with machine learning or more sophisticated patterns
    // For now, use simple heuristics based on container type
    final containerSize = parseContainerSize(session.containerType);
    
    if (containerSize <= 250) {
      // Small containers - usually finished completely
      estimatedCompletion = session.targetMl * 0.95;
    } else if (containerSize >= 750) {
      // Large containers - often not finished completely
      estimatedCompletion = session.targetMl * 0.75;
    }

    return estimatedCompletion;
  }

  /// Update container name with learned average amount
  String _updateContainerWithAverage(String originalContainer, double avgAmount) {
    final baseName = _getBaseContainerName(originalContainer);
    return '$baseName (${avgAmount.round()}ml avg)';
  }

  /// Extract base container name without amount
  String _getBaseContainerName(String containerType) {
    return containerType.replaceAll(RegExp(r'\s*\([^)]*\)'), '');
  }

  /// Get appropriate timeout message based on duration
  String _getTimeoutMessage(Duration duration) {
    if (duration.inHours >= 2) {
      return 'Your drinking session started ${duration.inHours} hours ago. We\'ll estimate your intake and complete it for you.';
    } else if (duration.inMinutes >= 60) {
      return 'Your session has been active for over an hour. How much have you had so far?';
    } else {
      return 'Don\'t forget about your ${duration.inMinutes}-minute session! Time to finish up?';
    }
  }
}