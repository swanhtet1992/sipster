import '../database/database_helper.dart';
import '../models/boba_character.dart';

class CharacterService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<List<BobaCharacter>> getAllCharacters() async {
    final database = await _db.database;
    final result = await database.query('boba_characters');
    return result.map((json) => BobaCharacter.fromJson(json)).toList();
  }

  Future<List<BobaCharacter>> getUnlockedCharacters() async {
    final database = await _db.database;
    final result = await database.query(
      'boba_characters',
      where: 'is_unlocked = ?',
      whereArgs: [1],
    );
    return result.map((json) => BobaCharacter.fromJson(json)).toList();
  }

  Future<BobaCharacter?> checkForNewUnlock({
    required double totalIntake,
    required int streak,
    required bool goalReached,
  }) async {
    final characters = await getAllCharacters();

    for (final character in characters.where((c) => !c.isUnlocked)) {
      if (_meetsUnlockCriteria(character, totalIntake, streak, goalReached)) {
        await unlockCharacter(character.id);
        return character.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }
    }
    return null;
  }

  bool _meetsUnlockCriteria(
    BobaCharacter character,
    double totalIntake,
    int streak,
    bool goalReached,
  ) {
    switch (character.id) {
      case 'matcha_wizard':
        return goalReached && streak >= 3;
      case 'fruit_archer':
        return totalIntake >= 2000;
      case 'milk_knight':
        return goalReached && streak >= 7;
      case 'classic_rebel':
        return goalReached && streak >= 14;
      default:
        return false;
    }
  }

  Future<void> unlockCharacter(String characterId) async {
    final database = await _db.database;
    await database.update(
      'boba_characters',
      {
        'is_unlocked': 1,
        'unlocked_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [characterId],
    );
  }

  Future<void> increaseLoyalty(String characterId) async {
    final database = await _db.database;
    await database.rawUpdate(
      'UPDATE boba_characters SET loyalty_level = loyalty_level + 1 WHERE id = ?',
      [characterId],
    );
  }

  String getArmyStatus(List<BobaCharacter> unlockedCharacters, double hourlyRate) {
    if (unlockedCharacters.isEmpty) {
      return 'Your boba army awaits recruitment!';
    }

    if (hourlyRate > 700) {
      return 'Your army is waterlogged and sluggish!';
    }

    if (hourlyRate < 100) {
      return 'Your boba soldiers look a bit deflated...';
    }

    return 'Your boba army is ready for battle!';
  }

  String getRandomEncouragement(List<BobaCharacter> characters) {
    if (characters.isEmpty) return 'Stay hydrated!';

    final phrases = characters.map((c) => c.catchphrase).toList();
    phrases.shuffle();
    return phrases.first;
  }
}