import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/hydration_session.dart';

class SessionService {
  final DatabaseHelper _db = DatabaseHelper();
  static const _uuid = Uuid();

  Future<String> startSession(String containerType, double targetMl) async {
    final database = await _db.database;
    final sessionId = _uuid.v4();

    await _endActiveSession();

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
}