import 'package:flutter/material.dart';
import '../models/hydration_session.dart';
import '../models/boba_character.dart';
import '../models/user.dart';
import '../services/session_service.dart';
import '../services/character_service.dart';
import '../services/user_service.dart';
import '../services/hydration_calculator.dart';
import '../widgets/progress_bar.dart';
import '../widgets/character_grid.dart';
import '../widgets/session_controls.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionService _sessionService = SessionService();
  final CharacterService _characterService = CharacterService();
  final UserService _userService = UserService();
  final HydrationCalculator _calculator = HydrationCalculator();

  User? _user;
  HydrationSession? _currentSession;
  List<HydrationSession> _todaySessions = [];
  List<BobaCharacter> _unlockedCharacters = [];
  Map<String, dynamic>? _hydrationStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = await _userService.getCurrentUser();
      if (user == null) {
        await _showSetupDialog();
        return;
      }

      final currentSession = await _sessionService.getCurrentSession();
      final todaySessions = await _sessionService.getTodaySessions();
      final unlockedCharacters = await _characterService.getUnlockedCharacters();

      final stats = _calculator.getHydrationStats(
        todaySessions: todaySessions,
        dailyGoal: user.dailyGoalMl,
      );

      setState(() {
        _user = user;
        _currentSession = currentSession;
        _todaySessions = todaySessions;
        _unlockedCharacters = unlockedCharacters;
        _hydrationStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load data: $e');
    }
  }

  Future<void> _showSetupDialog() async {
    double? weight;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Welcome to Sipster!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your weight to calculate your daily hydration goal:'),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => weight = double.tryParse(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (weight != null && weight! > 0) {
                await _userService.createUser(weightKg: weight!);
                Navigator.of(context).pop();
                _loadData();
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sipster'),
        backgroundColor: Colors.purple.shade100,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_hydrationStats?['safetyWarning']?.isNotEmpty == true)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    _hydrationStats!['safetyWarning'],
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              
              ProgressBar(
                progress: _hydrationStats?['progressPercent'] ?? 0,
                current: _hydrationStats?['totalToday'] ?? 0,
                goal: _hydrationStats?['dailyGoal'] ?? 0,
                kidneyLoad: _hydrationStats?['kidneyLoad'] ?? 0,
              ),
              
              const SizedBox(height: 24),
              
              CharacterGrid(
                characters: _unlockedCharacters,
                status: _characterService.getArmyStatus(
                  _unlockedCharacters,
                  _hydrationStats?['hourlyRate'] ?? 0,
                ),
              ),
              
              const SizedBox(height: 24),
              
              SessionControls(
                currentSession: _currentSession,
                containers: _sessionService.getDefaultContainers(),
                onSessionStart: _startSession,
                onSessionEnd: _endSession,
                onSessionCancel: _cancelSession,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startSession(String containerType) async {
    try {
      final targetMl = _sessionService.parseContainerSize(containerType);
      await _sessionService.startSession(containerType, targetMl);
      _loadData();
    } catch (e) {
      _showError('Failed to start session: $e');
    }
  }

  Future<void> _endSession(double actualMl) async {
    if (_currentSession == null) return;

    try {
      await _sessionService.endSession(_currentSession!.id, actualMl);
      
      final newCharacter = await _characterService.checkForNewUnlock(
        totalIntake: _hydrationStats?['totalToday'] ?? 0,
        streak: 1, // TODO: Calculate actual streak
        goalReached: _hydrationStats?['goalReached'] ?? false,
      );

      if (newCharacter != null) {
        _showCharacterUnlocked(newCharacter);
      }
      
      _loadData();
    } catch (e) {
      _showError('Failed to end session: $e');
    }
  }

  Future<void> _cancelSession() async {
    try {
      await _sessionService.cancelCurrentSession();
      _loadData();
    } catch (e) {
      _showError('Failed to cancel session: $e');
    }
  }

  void _showCharacterUnlocked(BobaCharacter character) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 New Character Unlocked!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              character.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(character.catchphrase),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }
}