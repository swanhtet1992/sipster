import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sipster.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Users table with enhanced fields
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        weight_kg REAL NOT NULL,
        daily_goal_ml REAL NOT NULL,
        container_presets TEXT NOT NULL,
        created_at TEXT NOT NULL,
        platform_preferences TEXT,
        notification_enabled INTEGER DEFAULT 1,
        last_active TEXT,
        total_sessions INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE hydration_sessions (
        id TEXT PRIMARY KEY,
        start_time TEXT NOT NULL,
        end_time TEXT,
        target_ml REAL NOT NULL,
        actual_ml REAL,
        container_type TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        completion_rate REAL DEFAULT 0,
        session_duration_minutes INTEGER,
        safety_warnings_triggered INTEGER DEFAULT 0,
        platform_used TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE boba_characters (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        is_unlocked INTEGER NOT NULL DEFAULT 0,
        loyalty_level INTEGER NOT NULL DEFAULT 0,
        unlocked_at TEXT,
        catchphrase TEXT NOT NULL,
        unlock_condition TEXT,
        special_ability TEXT,
        mood_state TEXT DEFAULT 'neutral',
        last_interaction TEXT
      )
    ''');

    // Safety warnings log table
    await db.execute('''
      CREATE TABLE safety_warnings (
        id TEXT PRIMARY KEY,
        session_id TEXT,
        warning_type TEXT NOT NULL,
        priority TEXT NOT NULL,
        message TEXT NOT NULL,
        triggered_at TEXT NOT NULL,
        user_response TEXT,
        kidney_load_at_time REAL,
        hourly_rate_at_time REAL,
        FOREIGN KEY (session_id) REFERENCES hydration_sessions (id)
      )
    ''');

    // Daily analytics table
    await db.execute('''
      CREATE TABLE daily_analytics (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        total_intake_ml REAL DEFAULT 0,
        goal_achieved INTEGER DEFAULT 0,
        sessions_count INTEGER DEFAULT 0,
        average_session_duration REAL DEFAULT 0,
        peak_hourly_rate REAL DEFAULT 0,
        safety_warnings_count INTEGER DEFAULT 0,
        characters_unlocked INTEGER DEFAULT 0,
        platform_breakdown TEXT
      )
    ''');

    // Notification schedule table
    await db.execute('''
      CREATE TABLE notification_schedule (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        scheduled_time TEXT NOT NULL,
        notification_type TEXT NOT NULL,
        is_sent INTEGER DEFAULT 0,
        platform_specific_data TEXT,
        FOREIGN KEY (session_id) REFERENCES hydration_sessions (id)
      )
    ''');

    // User preferences table for detailed settings
    await db.execute('''
      CREATE TABLE user_preferences (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        preference_key TEXT NOT NULL,
        preference_value TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        UNIQUE(user_id, preference_key)
      )
    ''');

    await _seedBobaCharacters(db);
  }

  Future<void> _seedBobaCharacters(Database db) async {
    const characters = [
      {
        'id': 'taro_ninja',
        'name': 'Taro Ninja',
        'type': 'taro',
        'is_unlocked': 1,
        'loyalty_level': 0,
        'catchphrase': 'Stay purple, stay hydrated!'
      },
      {
        'id': 'matcha_wizard',
        'name': 'Matcha Wizard',
        'type': 'matcha',
        'is_unlocked': 0,
        'loyalty_level': 0,
        'catchphrase': 'Green tea, green dreams!'
      },
      {
        'id': 'fruit_archer',
        'name': 'Fruit Archer',
        'type': 'fruit',
        'is_unlocked': 0,
        'loyalty_level': 0,
        'catchphrase': 'Aim high, drink well!'
      },
      {
        'id': 'milk_knight',
        'name': 'Milk Knight',
        'type': 'milkTea',
        'is_unlocked': 0,
        'loyalty_level': 0,
        'catchphrase': 'Honor through hydration!'
      },
      {
        'id': 'classic_rebel',
        'name': 'Classic Rebel',
        'type': 'classic',
        'is_unlocked': 0,
        'loyalty_level': 0,
        'catchphrase': 'Keep it simple, keep it flowing!'
      },
    ];

    for (final character in characters) {
      await db.insert('boba_characters', character);
    }
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to existing tables
      await db.execute('''
        ALTER TABLE users ADD COLUMN platform_preferences TEXT
      ''');
      await db.execute('''
        ALTER TABLE users ADD COLUMN notification_enabled INTEGER DEFAULT 1
      ''');
      await db.execute('''
        ALTER TABLE users ADD COLUMN last_active TEXT
      ''');
      await db.execute('''
        ALTER TABLE users ADD COLUMN total_sessions INTEGER DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE users ADD COLUMN longest_streak INTEGER DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE users ADD COLUMN current_streak INTEGER DEFAULT 0
      ''');

      await db.execute('''
        ALTER TABLE hydration_sessions ADD COLUMN completion_rate REAL DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE hydration_sessions ADD COLUMN session_duration_minutes INTEGER
      ''');
      await db.execute('''
        ALTER TABLE hydration_sessions ADD COLUMN safety_warnings_triggered INTEGER DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE hydration_sessions ADD COLUMN platform_used TEXT
      ''');
      await db.execute('''
        ALTER TABLE hydration_sessions ADD COLUMN notes TEXT
      ''');

      await db.execute('''
        ALTER TABLE boba_characters ADD COLUMN unlock_condition TEXT
      ''');
      await db.execute('''
        ALTER TABLE boba_characters ADD COLUMN special_ability TEXT
      ''');
      await db.execute('''
        ALTER TABLE boba_characters ADD COLUMN mood_state TEXT DEFAULT 'neutral'
      ''');
      await db.execute('''
        ALTER TABLE boba_characters ADD COLUMN last_interaction TEXT
      ''');

      // Create new tables
      await db.execute('''
        CREATE TABLE safety_warnings (
          id TEXT PRIMARY KEY,
          session_id TEXT,
          warning_type TEXT NOT NULL,
          priority TEXT NOT NULL,
          message TEXT NOT NULL,
          triggered_at TEXT NOT NULL,
          user_response TEXT,
          kidney_load_at_time REAL,
          hourly_rate_at_time REAL,
          FOREIGN KEY (session_id) REFERENCES hydration_sessions (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE daily_analytics (
          id TEXT PRIMARY KEY,
          date TEXT NOT NULL UNIQUE,
          total_intake_ml REAL DEFAULT 0,
          goal_achieved INTEGER DEFAULT 0,
          sessions_count INTEGER DEFAULT 0,
          average_session_duration REAL DEFAULT 0,
          peak_hourly_rate REAL DEFAULT 0,
          safety_warnings_count INTEGER DEFAULT 0,
          characters_unlocked INTEGER DEFAULT 0,
          platform_breakdown TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE notification_schedule (
          id TEXT PRIMARY KEY,
          session_id TEXT NOT NULL,
          scheduled_time TEXT NOT NULL,
          notification_type TEXT NOT NULL,
          is_sent INTEGER DEFAULT 0,
          platform_specific_data TEXT,
          FOREIGN KEY (session_id) REFERENCES hydration_sessions (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE user_preferences (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          preference_key TEXT NOT NULL,
          preference_value TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id),
          UNIQUE(user_id, preference_key)
        )
      ''');

      // Update existing character data with new fields
      await _updateExistingCharacters(db);
    }
  }

  Future<void> _updateExistingCharacters(Database db) async {
    final characterUpdates = {
      'taro_ninja': {
        'unlock_condition': 'Start your hydration journey',
        'special_ability': 'Stealth hydration detection',
      },
      'matcha_wizard': {
        'unlock_condition': 'Complete 3 sessions in one day',
        'special_ability': 'Antioxidant power boost',
      },
      'fruit_archer': {
        'unlock_condition': 'Achieve 7-day streak',
        'special_ability': 'Vitamin precision targeting',
      },
      'milk_knight': {
        'unlock_condition': 'Reach weekly hydration goals',
        'special_ability': 'Calcium shield protection',
      },
      'classic_rebel': {
        'unlock_condition': 'Complete 50 total sessions',
        'special_ability': 'Pure hydration rebellion',
      },
    };

    for (final entry in characterUpdates.entries) {
      await db.update(
        'boba_characters',
        {
          'unlock_condition': entry.value['unlock_condition'],
          'special_ability': entry.value['special_ability'],
        },
        where: 'id = ?',
        whereArgs: [entry.key],
      );
    }
  }

  // Helper methods for enhanced features
  Future<void> logSafetyWarning({
    required String warningType,
    required String priority,
    required String message,
    String? sessionId,
    String? userResponse,
    double? kidneyLoad,
    double? hourlyRate,
  }) async {
    final db = await database;
    await db.insert('safety_warnings', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'session_id': sessionId,
      'warning_type': warningType,
      'priority': priority,
      'message': message,
      'triggered_at': DateTime.now().toIso8601String(),
      'user_response': userResponse,
      'kidney_load_at_time': kidneyLoad,
      'hourly_rate_at_time': hourlyRate,
    });
  }

  Future<void> updateDailyAnalytics(String date, Map<String, dynamic> analytics) async {
    final db = await database;
    await db.insert(
      'daily_analytics',
      {
        'id': date,
        'date': date,
        ...analytics,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getSafetyWarningsHistory({
    int? limit,
    String? sessionId,
  }) async {
    final db = await database;
    String query = 'SELECT * FROM safety_warnings';
    List<dynamic> args = [];
    
    if (sessionId != null) {
      query += ' WHERE session_id = ?';
      args.add(sessionId);
    }
    
    query += ' ORDER BY triggered_at DESC';
    
    if (limit != null) {
      query += ' LIMIT ?';
      args.add(limit);
    }
    
    return await db.rawQuery(query, args);
  }

  Future<Map<String, dynamic>?> getDailyAnalytics(String date) async {
    final db = await database;
    final results = await db.query(
      'daily_analytics',
      where: 'date = ?',
      whereArgs: [date],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> scheduleNotification({
    required String sessionId,
    required DateTime scheduledTime,
    required String notificationType,
    Map<String, dynamic>? platformSpecificData,
  }) async {
    final db = await database;
    await db.insert('notification_schedule', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'session_id': sessionId,
      'scheduled_time': scheduledTime.toIso8601String(),
      'notification_type': notificationType,
      'is_sent': 0,
      'platform_specific_data': platformSpecificData?.toString(),
    });
  }

  Future<void> setUserPreference(String userId, String key, String value) async {
    final db = await database;
    await db.insert(
      'user_preferences',
      {
        'id': '${userId}_$key',
        'user_id': userId,
        'preference_key': key,
        'preference_value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getUserPreference(String userId, String key) async {
    final db = await database;
    final results = await db.query(
      'user_preferences',
      columns: ['preference_value'],
      where: 'user_id = ? AND preference_key = ?',
      whereArgs: [userId, key],
    );
    return results.isNotEmpty ? results.first['preference_value'] as String : null;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}