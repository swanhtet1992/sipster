import '../database/database_helper.dart';
import '../models/boba_character.dart';
import '../models/hydration_session.dart';

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
    List<HydrationSession>? recentSessions,
    Map<String, dynamic>? hydrationPatterns,
  }) async {
    final characters = await getAllCharacters();

    for (final character in characters.where((c) => !c.isUnlocked)) {
      if (await _meetsEnhancedUnlockCriteria(
        character, 
        totalIntake, 
        streak, 
        goalReached,
        recentSessions: recentSessions,
        hydrationPatterns: hydrationPatterns,
      )) {
        await unlockCharacter(character.id);
        return character.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }
    }
    return null;
  }

  Future<bool> _meetsEnhancedUnlockCriteria(
    BobaCharacter character,
    double totalIntake,
    int streak,
    bool goalReached, {
    List<HydrationSession>? recentSessions,
    Map<String, dynamic>? hydrationPatterns,
  }) async {
    // Get consistency metrics
    final consistency = await _calculateHydrationConsistency();
    final timing = _calculateHydrationTiming(recentSessions ?? []);
    
    switch (character.id) {
      case 'matcha_wizard':
        // Unlocks with consistent goal achievement and good timing
        return goalReached && streak >= 3 && timing['isConsistent'] == true;
        
      case 'fruit_archer':
        // Unlocks with high intake but also requires variety in sessions
        final sessionVariety = _calculateSessionVariety(recentSessions ?? []);
        return totalIntake >= 2000 && sessionVariety >= 3;
        
      case 'milk_knight':
        // Unlocks with dedicated consistency - requires longer streaks and perfect timing
        return goalReached && streak >= 7 && consistency >= 0.8 && timing['perfectDays'] >= 2;
        
      case 'classic_rebel':
        // Master level - requires excellence across all metrics
        return goalReached && streak >= 14 && consistency >= 0.9 && 
               timing['bubbleSynergy'] == true;
               
      default:
        return false;
    }
  }

  /// Calculate hydration consistency over the past week
  Future<double> _calculateHydrationConsistency() async {
    final database = await _db.database;
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    
    final result = await database.rawQuery('''
      SELECT DATE(start_time) as day, 
             COUNT(*) as session_count,
             SUM(actual_ml) as daily_total
      FROM hydration_sessions 
      WHERE start_time >= ? 
        AND actual_ml IS NOT NULL
        AND end_time IS NOT NULL
      GROUP BY DATE(start_time)
      ORDER BY day DESC
    ''', [oneWeekAgo.toIso8601String()]);
    
    if (result.length < 3) return 0.0; // Need at least 3 days of data
    
    // Calculate consistency based on regularity of sessions and achieving goals
    double totalConsistency = 0.0;
    for (final day in result) {
      final sessionCount = day['session_count'] as int;
      final dailyTotal = day['daily_total'] as double;
      
      // Ideal session pattern: 3-6 sessions per day with reasonable amounts
      final sessionScore = (sessionCount >= 3 && sessionCount <= 8) ? 1.0 : 0.5;
      final amountScore = (dailyTotal >= 1500 && dailyTotal <= 3500) ? 1.0 : 0.7;
      
      totalConsistency += (sessionScore * amountScore);
    }
    
    return totalConsistency / result.length;
  }

  /// Calculate hydration timing patterns for bubble synergy detection
  Map<String, dynamic> _calculateHydrationTiming(List<HydrationSession> sessions) {
    if (sessions.length < 5) {
      return {
        'isConsistent': false,
        'perfectDays': 0,
        'bubbleSynergy': false,
        'averageSessionLength': 0.0,
      };
    }
    
    final completedSessions = sessions.where((s) => 
      s.endTime != null && s.actualMl != null).toList();
    
    if (completedSessions.isEmpty) {
      return {
        'isConsistent': false,
        'perfectDays': 0,
        'bubbleSynergy': false,
        'averageSessionLength': 0.0,
      };
    }
    
    // Calculate session durations
    final sessionDurations = completedSessions.map((s) => 
      s.endTime!.difference(s.startTime).inMinutes).toList();
    
    final avgSessionLength = sessionDurations.reduce((a, b) => a + b) / sessionDurations.length;
    
    // Good timing: sessions between 15-90 minutes
    final goodTimingSessions = sessionDurations.where((d) => d >= 15 && d <= 90).length;
    final isConsistent = goodTimingSessions / sessionDurations.length >= 0.7;
    
    // Perfect days: days with 3+ sessions, good timing, and proper spacing
    int perfectDays = 0;
    final sessionsByDay = <String, List<HydrationSession>>{};
    
    for (final session in completedSessions) {
      final dayKey = session.startTime.toIso8601String().split('T')[0];
      sessionsByDay[dayKey] ??= [];
      sessionsByDay[dayKey]!.add(session);
    }
    
    for (final daySessions in sessionsByDay.values) {
      if (daySessions.length >= 3) {
        // Check if sessions are well-spaced (at least 2 hours apart)
        final sortedSessions = daySessions..sort((a, b) => a.startTime.compareTo(b.startTime));
        bool wellSpaced = true;
        
        for (int i = 1; i < sortedSessions.length; i++) {
          final gap = sortedSessions[i].startTime.difference(sortedSessions[i-1].startTime);
          if (gap.inHours < 2) {
            wellSpaced = false;
            break;
          }
        }
        
        if (wellSpaced) perfectDays++;
      }
    }
    
    // Bubble synergy: perfect timing with consistent patterns
    final bubbleSynergy = isConsistent && perfectDays >= 2 && avgSessionLength >= 30 && avgSessionLength <= 60;
    
    return {
      'isConsistent': isConsistent,
      'perfectDays': perfectDays,
      'bubbleSynergy': bubbleSynergy,
      'averageSessionLength': avgSessionLength,
    };
  }

  /// Calculate variety in session containers and amounts
  int _calculateSessionVariety(List<HydrationSession> sessions) {
    final containerTypes = sessions.map((s) => s.containerType).toSet();
    return containerTypes.length;
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

  /// Enhanced army status evaluation with detailed mood analysis
  Map<String, dynamic> getEnhancedArmyStatus({
    required List<BobaCharacter> unlockedCharacters,
    required double hourlyRate,
    required double dailyProgress,
    required List<HydrationSession> recentSessions,
    required Map<String, dynamic> hydrationTiming,
  }) {
    if (unlockedCharacters.isEmpty) {
      return {
        'status': 'recruitment',
        'mood': 'waiting',
        'message': 'Your boba army awaits recruitment!',
        'description': 'Complete hydration goals to unlock your first boba soldier.',
        'color': 'grey',
        'animationState': 'idle',
      };
    }

    // Determine overall army mood based on multiple factors
    final armyMood = _calculateArmyMood(hourlyRate, dailyProgress, hydrationTiming);
    
    return {
      'status': armyMood['status'],
      'mood': armyMood['mood'],
      'message': armyMood['message'],
      'description': armyMood['description'],
      'color': armyMood['color'],
      'animationState': armyMood['animationState'],
      'characterCount': unlockedCharacters.length,
      'bubbleSynergy': hydrationTiming['bubbleSynergy'] ?? false,
      'effects': _getArmyEffects(armyMood['mood'], unlockedCharacters),
    };
  }

  Map<String, dynamic> _calculateArmyMood(
    double hourlyRate, 
    double dailyProgress,
    Map<String, dynamic> hydrationTiming,
  ) {
    final bubbleSynergy = hydrationTiming['bubbleSynergy'] ?? false;
    final isConsistent = hydrationTiming['isConsistent'] ?? false;
    final perfectDays = hydrationTiming['perfectDays'] ?? 0;

    // Bubble Synergy - Perfect hydration timing
    if (bubbleSynergy && dailyProgress >= 0.8 && hourlyRate > 200 && hourlyRate <= 600) {
      return {
        'status': 'synergy',
        'mood': 'euphoric',
        'message': '✨ BUBBLE SYNERGY ACTIVATED! ✨',
        'description': 'Your army is in perfect harmony! Characters combine their powers with flawless hydration timing.',
        'color': 'rainbow',
        'animationState': 'synergy_dance',
      };
    }

    // Over-hydration - Waterlogged army
    if (hourlyRate > 700) {
      return {
        'status': 'waterlogged',
        'mood': 'sluggish',
        'message': 'Your army is waterlogged and moving slowly...',
        'description': 'Too much too fast! Your boba soldiers are struggling to keep up. Slow down the intake rate.',
        'color': 'blue',
        'animationState': 'sluggish_wobble',
      };
    }

    // Under-hydration - Sad and deflated
    if (hourlyRate < 100 && dailyProgress < 0.5) {
      return {
        'status': 'dehydrated',
        'mood': 'sad',
        'message': 'Your boba soldiers look deflated and concerned...',
        'description': 'Your army needs more hydration! They\'re worried about your wellbeing.',
        'color': 'orange',
        'animationState': 'sad_droop',
      };
    }

    // Excellent consistency - Happy army
    if (isConsistent && dailyProgress >= 0.8 && perfectDays >= 1) {
      return {
        'status': 'excellent',
        'mood': 'happy',
        'message': 'Your boba army is thriving and battle-ready! 🎉',
        'description': 'Consistent hydration has your soldiers in top fighting form. They\'re proud of your dedication!',
        'color': 'green',
        'animationState': 'happy_bounce',
      };
    }

    // Good progress - Content army
    if (dailyProgress >= 0.6 && hourlyRate >= 200 && hourlyRate <= 600) {
      return {
        'status': 'good',
        'mood': 'content',
        'message': 'Your boba army is ready for action!',
        'description': 'Steady progress keeps your soldiers motivated and ready to fight the Bland Water Empire.',
        'color': 'green',
        'animationState': 'steady_march',
      };
    }

    // Moderate progress - Neutral army
    if (dailyProgress >= 0.3) {
      return {
        'status': 'neutral',
        'mood': 'neutral',
        'message': 'Your army is standing by...',
        'description': 'Your soldiers are waiting for more consistent hydration to reach their full potential.',
        'color': 'yellow',
        'animationState': 'idle_sway',
      };
    }

    // Poor progress - Concerned army
    return {
      'status': 'concerned',
      'mood': 'worried',
      'message': 'Your army is concerned about your hydration...',
      'description': 'Your boba soldiers are worried! They need to see more regular hydration to stay motivated.',
      'color': 'red',
      'animationState': 'worried_fidget',
    };
  }

  List<Map<String, dynamic>> _getArmyEffects(String mood, List<BobaCharacter> characters) {
    final effects = <Map<String, dynamic>>[];
    
    switch (mood) {
      case 'euphoric':
        effects.addAll([
          {'type': 'sparkles', 'intensity': 'high', 'color': 'rainbow'},
          {'type': 'power_aura', 'intensity': 'max', 'color': 'gold'},
          {'type': 'character_glow', 'intensity': 'bright', 'color': 'white'},
        ]);
        break;
        
      case 'happy':
        effects.addAll([
          {'type': 'bounce', 'intensity': 'medium', 'color': 'green'},
          {'type': 'smile_particles', 'intensity': 'medium', 'color': 'yellow'},
        ]);
        break;
        
      case 'sluggish':
        effects.addAll([
          {'type': 'water_drops', 'intensity': 'high', 'color': 'blue'},
          {'type': 'slow_motion', 'intensity': 'strong', 'color': 'blue'},
        ]);
        break;
        
      case 'sad':
        effects.addAll([
          {'type': 'tear_drops', 'intensity': 'medium', 'color': 'blue'},
          {'type': 'droop', 'intensity': 'medium', 'color': 'grey'},
        ]);
        break;
        
      case 'worried':
        effects.addAll([
          {'type': 'question_marks', 'intensity': 'low', 'color': 'orange'},
          {'type': 'fidget', 'intensity': 'medium', 'color': 'yellow'},
        ]);
        break;
    }
    
    return effects;
  }

  /// Get character-specific encouragement with personality
  String getPersonalizedEncouragement(List<BobaCharacter> characters, String armyMood) {
    if (characters.isEmpty) return 'Stay hydrated and recruit your first boba soldier!';

    final characterPhrases = <String>[];
    
    for (final character in characters) {
      switch (character.type) {
        case BobaType.taro:
          characterPhrases.add(_getTaroPhrase(armyMood));
          break;
        case BobaType.matcha:
          characterPhrases.add(_getMatchaPhrase(armyMood));
          break;
        case BobaType.fruit:
          characterPhrases.add(_getFruitPhrase(armyMood));
          break;
        case BobaType.milkTea:
          characterPhrases.add(_getMilkTeaPhrase(armyMood));
          break;
        case BobaType.classic:
          characterPhrases.add(_getClassicPhrase(armyMood));
          break;
      }
    }
    
    characterPhrases.shuffle();
    return characterPhrases.first;
  }

  String _getTaroPhrase(String mood) {
    switch (mood) {
      case 'euphoric': return '🟣 TARO POWER ACTIVATED! Purple rain of hydration! 🟣';
      case 'happy': return 'Stay purple, stay powerful! 💜';
      case 'sluggish': return 'Even taro moves slowly when waterlogged... 😵';
      case 'sad': return 'Purple tears for better hydration habits... 💧';
      default: return 'Stay purple, stay hydrated! 🟣';
    }
  }

  String _getMatchaPhrase(String mood) {
    switch (mood) {
      case 'euphoric': return '🍃 ZEN MASTER MODE! Perfect balance achieved! 🍃';
      case 'happy': return 'Green tea wisdom: consistency is key! 🌿';
      case 'sluggish': return 'Even zen masters need balance... 🍃💧';
      case 'sad': return 'Meditate on better hydration practices... 🧘‍♂️';
      default: return 'Green tea, green dreams! 🍃';
    }
  }

  String _getFruitPhrase(String mood) {
    switch (mood) {
      case 'euphoric': return '🏹 BULLSEYE! Perfect aim on hydration goals! 🎯';
      case 'happy': return 'Aim high, drink well! 🏹✨';
      case 'sluggish': return 'My arrows move too slowly when you overhydrate... 🏹💧';
      case 'sad': return 'Missing the target on hydration... 🎯💧';
      default: return 'Aim high, drink well! 🏹';
    }
  }

  String _getMilkTeaPhrase(String mood) {
    switch (mood) {
      case 'euphoric': return '⚔️ LEGENDARY HYDRATION KNIGHT STATUS ACHIEVED! ⚔️';
      case 'happy': return 'Honor through hydration, warrior! ⚔️';
      case 'sluggish': return 'Even knights stumble when armor is waterlogged... 🛡️💧';
      case 'sad': return 'A knight\'s duty is proper hydration... ⚔️💧';
      default: return 'Honor through hydration! ⚔️';
    }
  }

  String _getClassicPhrase(String mood) {
    switch (mood) {
      case 'euphoric': return '⭐ REBELLION LEADER! You\'ve mastered the art! ⭐';
      case 'happy': return 'Keep it simple, keep it flowing! 💫';
      case 'sluggish': return 'Simple is best, but not too much at once... 💧';
      case 'sad': return 'Back to basics: steady, simple hydration... 💧';
      default: return 'Keep it simple, keep it flowing! 💫';
    }
  }

  // Legacy method for backwards compatibility
  String getArmyStatus(List<BobaCharacter> unlockedCharacters, double hourlyRate) {
    final enhancedStatus = getEnhancedArmyStatus(
      unlockedCharacters: unlockedCharacters,
      hourlyRate: hourlyRate,
      dailyProgress: 0.5, // Default value
      recentSessions: [],
      hydrationTiming: {},
    );
    return enhancedStatus['message'] as String;
  }

  // Legacy method for backwards compatibility
  String getRandomEncouragement(List<BobaCharacter> characters) {
    return getPersonalizedEncouragement(characters, 'neutral');
  }
}