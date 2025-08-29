import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class UserService {
  final DatabaseHelper _db = DatabaseHelper();
  static const _uuid = Uuid();

  Future<User?> getCurrentUser() async {
    final database = await _db.database;
    final result = await database.query('users', limit: 1);
    
    if (result.isEmpty) return null;
    return User.fromJson(result.first);
  }

  Future<String> createUser({
    required double weightKg,
    List<String>? containerPresets,
  }) async {
    final database = await _db.database;
    final userId = _uuid.v4();
    
    const defaultContainers = [
      'Water Bottle (500ml)',
      'Glass (250ml)',
      'Large Bottle (750ml)',
    ];

    final user = User(
      id: userId,
      weightKg: weightKg,
      dailyGoalMl: weightKg * 35, // 35ml per kg
      containerPresets: containerPresets ?? defaultContainers,
      createdAt: DateTime.now(),
    );

    await database.insert('users', user.toJson());
    return userId;
  }

  Future<void> updateWeight(String userId, double weightKg) async {
    final database = await _db.database;
    await database.update(
      'users',
      {
        'weight_kg': weightKg,
        'daily_goal_ml': weightKg * 35,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateContainerPresets(String userId, List<String> presets) async {
    final database = await _db.database;
    await database.update(
      'users',
      {'container_presets': presets.join(',')},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}