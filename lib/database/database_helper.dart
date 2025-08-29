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
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        weight_kg REAL NOT NULL,
        daily_goal_ml REAL NOT NULL,
        container_presets TEXT NOT NULL,
        created_at TEXT NOT NULL
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
        is_active INTEGER NOT NULL DEFAULT 1
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
        catchphrase TEXT NOT NULL
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

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}