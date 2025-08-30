import 'package:flutter/material.dart';
import '../models/hydration_session.dart';
import '../models/boba_character.dart';
import '../models/safety_warning.dart';
import '../services/session_service.dart';
import '../services/character_service.dart';
import '../services/user_service.dart';
import '../services/hydration_calculator.dart';
import '../widgets/progress_bar.dart';
import '../widgets/character_grid.dart';
import '../widgets/session_controls.dart';
import '../widgets/safety_warning_dialog.dart';
import '../theme/design_constants.dart';
import '../utils/platform_utils.dart';

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

  HydrationSession? _currentSession;
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
        _currentSession = currentSession;
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
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _loadData();
                }
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

    final isDesktop = PlatformUtils.isDesktop(context);
    final isTablet = PlatformUtils.isTablet(context);
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          isDesktop ? DesignConstants.headerHeight + 20 : DesignConstants.headerHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: DesignConstants.headerGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? DesignConstants.spacingXXL : DesignConstants.spacingL,
                vertical: DesignConstants.spacingS,
              ),
              child: _buildAppBarContent(context, isDesktop),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: isDesktop
            ? _buildDesktopLayout(context)
            : isTablet
                ? _buildTabletLayout(context)
                : _buildMobileLayout(context),
      ),
    );
  }

  Future<void> _startSession(String containerType) async {
    try {
      final targetMl = _sessionService.parseContainerSize(containerType);
      
      // Only start new session if none exists
      if (_currentSession == null) {
        await _sessionService.startSession(containerType, targetMl);
      }
      
      _loadData();
    } catch (e) {
      _showError('Failed to start session: $e');
    }
  }

  Future<void> _switchContainer(String containerType) async {
    try {
      final targetMl = _sessionService.parseContainerSize(containerType);
      await _sessionService.startNewSession(containerType, targetMl);
      _loadData();
    } catch (e) {
      _showError('Failed to switch container: $e');
    }
  }

  Future<void> _endSession(double actualMl) async {
    if (_currentSession == null) return;

    try {
      // Calculate session duration for safety evaluation
      final sessionDuration = DateTime.now().difference(_currentSession!.startTime);
      
      // Evaluate session safety before ending
      final safetyWarning = _calculator.evaluateSessionSafety(actualMl, sessionDuration);
      
      // End the session first
      await _sessionService.endSession(_currentSession!.id, actualMl);
      
      // Check for character unlock
      final newCharacter = await _characterService.checkForNewUnlock(
        totalIntake: _hydrationStats?['totalToday'] ?? 0,
        streak: 1, // TODO: Calculate actual streak
        goalReached: _hydrationStats?['goalReached'] ?? false,
      );

      // Reload data to get updated stats
      await _loadData();

      // Show safety warning if present (after data reload)
      if (safetyWarning != null && mounted) {
        await _showSafetyWarning(safetyWarning);
      }

      // Show character unlock after safety warning (if any)
      if (newCharacter != null && mounted) {
        _showCharacterUnlocked(newCharacter);
      }
      
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

  Widget _buildAppBarContent(BuildContext context, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Army Counter Badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? DesignConstants.spacingXL : DesignConstants.spacingL,
            vertical: DesignConstants.spacingS,
          ),
          decoration: BoxDecoration(
            color: DesignConstants.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(DesignConstants.radiusXL),
          ),
          child: Row(
            children: [
              Text('🧋', style: TextStyle(fontSize: isDesktop ? 20 : 16)),
              const SizedBox(width: DesignConstants.spacingXS),
              Text(
                'Army: ${_unlockedCharacters.length} Bobas',
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: isDesktop ? DesignConstants.fontTitle : DesignConstants.fontSubtitle,
                  fontWeight: FontWeight.w600,
                  color: DesignConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
        // Daily Progress Crown
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: isDesktop ? 80 : 60,
                  height: isDesktop ? 80 : 60,
                  child: CircularProgressIndicator(
                    value: (_hydrationStats?['progressPercent'] ?? 0) / 100,
                    backgroundColor: DesignConstants.cupRim,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      DesignConstants.success,
                    ),
                    strokeWidth: isDesktop ? 6 : 4,
                  ),
                ),
                Column(
                  children: [
                    Text('👑', style: TextStyle(fontSize: isDesktop ? 24 : 16)),
                    Text(
                      '${(_hydrationStats?['progressPercent'] ?? 0).round()}%',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: isDesktop ? DesignConstants.fontSubtitle : DesignConstants.fontCaption,
                        fontWeight: FontWeight.bold,
                        color: DesignConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: DesignConstants.spacingXS),
            Text(
              "Today's Victory",
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: isDesktop ? DesignConstants.fontBody : DesignConstants.fontSmall,
                color: DesignConstants.textSecondary,
              ),
            ),
          ],
        ),
        // Session Status Indicator
        if (_currentSession != null)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? DesignConstants.spacingL : DesignConstants.spacingM,
              vertical: DesignConstants.spacingXS,
            ),
            decoration: BoxDecoration(
              color: DesignConstants.success.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(DesignConstants.radiusM),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_drink,
                  color: DesignConstants.pearlWhite,
                  size: isDesktop ? 18 : 14,
                ),
                const SizedBox(width: DesignConstants.spacingXS),
                Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: isDesktop ? DesignConstants.fontBody : DesignConstants.fontSmall,
                    fontWeight: FontWeight.bold,
                    color: DesignConstants.pearlWhite,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(width: isDesktop ? 120 : 80), // Maintain layout balance
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignConstants.spacingXXL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column - Primary content
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSafetyWarning(),
                  const SizedBox(height: DesignConstants.spacingL),
                  ProgressBar(
                    progress: (_hydrationStats?['progressPercent'] ?? 0).toDouble(),
                    current: (_hydrationStats?['totalToday'] ?? 0).toDouble(),
                    goal: (_hydrationStats?['dailyGoal'] ?? 0).toDouble(),
                    kidneyLoad: (_hydrationStats?['kidneyLoad'] ?? 0).toDouble(),
                  ),
                  const SizedBox(height: DesignConstants.spacingXL),
                  SessionControls(
                    currentSession: _currentSession,
                    containers: _sessionService.getDefaultContainers(),
                    onSessionStart: _startSession,
                    onSessionEnd: _endSession,
                    onSessionCancel: _cancelSession,
                    onSwitchContainer: _switchContainer,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: DesignConstants.spacingXXL),
          // Right Column - Character grid
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Boba Army',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: DesignConstants.fontTitle,
                      fontWeight: FontWeight.bold,
                      color: DesignConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: DesignConstants.spacingL),
                  CharacterGrid(
                    characters: _unlockedCharacters,
                    status: _characterService.getArmyStatus(
                      _unlockedCharacters,
                      _hydrationStats?['hourlyRate'] ?? 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignConstants.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSafetyWarning(),
          const SizedBox(height: DesignConstants.spacingL),
          
          // Two-column layout for tablet
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Progress and controls
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProgressBar(
                        progress: (_hydrationStats?['progressPercent'] ?? 0).toDouble(),
                        current: (_hydrationStats?['totalToday'] ?? 0).toDouble(),
                        goal: (_hydrationStats?['dailyGoal'] ?? 0).toDouble(),
                        kidneyLoad: (_hydrationStats?['kidneyLoad'] ?? 0).toDouble(),
                      ),
                      const SizedBox(height: DesignConstants.spacingXL),
                      SessionControls(
                        currentSession: _currentSession,
                        containers: _sessionService.getDefaultContainers(),
                        onSessionStart: _startSession,
                        onSessionEnd: _endSession,
                        onSessionCancel: _cancelSession,
                        onSwitchContainer: _switchContainer,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: DesignConstants.spacingXL),
              // Right side - Characters
              Expanded(
                flex: 2,
                child: CharacterGrid(
                  characters: _unlockedCharacters,
                  status: _characterService.getArmyStatus(
                    _unlockedCharacters,
                    _hydrationStats?['hourlyRate'] ?? 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSafetyWarning(),
          const SizedBox(height: DesignConstants.spacingL),
          ProgressBar(
            progress: (_hydrationStats?['progressPercent'] ?? 0).toDouble(),
            current: (_hydrationStats?['totalToday'] ?? 0).toDouble(),
            goal: (_hydrationStats?['dailyGoal'] ?? 0).toDouble(),
            kidneyLoad: (_hydrationStats?['kidneyLoad'] ?? 0).toDouble(),
          ),
          const SizedBox(height: DesignConstants.spacingXL),
          CharacterGrid(
            characters: _unlockedCharacters,
            status: _characterService.getArmyStatus(
              _unlockedCharacters,
              _hydrationStats?['hourlyRate'] ?? 0,
            ),
          ),
          const SizedBox(height: DesignConstants.spacingXL),
          SessionControls(
            currentSession: _currentSession,
            containers: _sessionService.getDefaultContainers(),
            onSessionStart: _startSession,
            onSessionEnd: _endSession,
            onSessionCancel: _cancelSession,
            onSwitchContainer: _switchContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyWarning() {
    if (_hydrationStats?['safetyWarning']?.isNotEmpty != true) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignConstants.spacingM),
      margin: const EdgeInsets.only(bottom: DesignConstants.spacingL),
      decoration: BoxDecoration(
        color: DesignConstants.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignConstants.radiusM),
        border: Border.all(
          color: DesignConstants.warning.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: DesignConstants.warning,
            size: 20,
          ),
          const SizedBox(width: DesignConstants.spacingS),
          Expanded(
            child: Text(
              _hydrationStats!['safetyWarning'],
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: DesignConstants.fontBody,
                fontWeight: FontWeight.w500,
                color: DesignConstants.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSafetyWarning(SafetyWarning warning) async {
    return await SafetyWarningDialog.show(
      context: context,
      warning: warning,
      onDismiss: () => Navigator.of(context).pop(),
      onPause: warning.level == SafetyLevel.warning 
          ? () {
              Navigator.of(context).pop();
              // Could add session pause logic here if needed
            }
          : null,
      onContinue: () => Navigator.of(context).pop(),
    );
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