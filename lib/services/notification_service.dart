import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import '../utils/platform_utils.dart';

/// Multi-platform notification service for session reminders and hydration prompts
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;
  
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  bool _hasPermission = false;

  /// Initialize the notification service
  Future<bool> initialize() async {
    if (_isInitialized) return _hasPermission;

    try {
      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // macOS initialization settings
      const DarwinInitializationSettings initializationSettingsMacOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Note: Windows notifications require additional setup
      // For now, we'll handle Windows through other platforms or skip

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsMacOS,
      );

      final bool? initialized = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _isInitialized = true;
      _hasPermission = initialized ?? false;

      if (_hasPermission) {
        await _requestPermissions();
      }

      return _hasPermission;
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
      _isInitialized = true;
      _hasPermission = false;
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> requestNotificationPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!PlatformUtils.supportsNativeNotifications()) {
      return false; // Platform doesn't support notifications
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        final bool? granted = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        _hasPermission = granted ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();
        
        final bool? granted = await androidImplementation?.requestNotificationsPermission();
        _hasPermission = granted ?? false;
      } else {
        // For other platforms, assume permission is granted
        _hasPermission = true;
      }

      return _hasPermission;
    } catch (e) {
      debugPrint('Failed to request notification permissions: $e');
      return false;
    }
  }

  /// Schedule a session reminder notification
  Future<void> scheduleSessionReminder(
    String sessionId,
    Duration delay, {
    String? containerType,
    int? targetMl,
  }) async {
    if (!_hasPermission || !_isInitialized) {
      await initialize();
      if (!_hasPermission) return;
    }

    try {
      final int notificationId = sessionId.hashCode;
      
      final String title = _getSessionReminderTitle();
      final String body = _getSessionReminderBody(containerType, targetMl);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        _getScheduledTZDateTime(delay),
        _getNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'session_reminder:$sessionId',
      );

      debugPrint('Scheduled session reminder for $sessionId in ${delay.inMinutes} minutes');
    } catch (e) {
      debugPrint('Failed to schedule session reminder: $e');
    }
  }

  /// Cancel session reminders for a specific session
  Future<void> cancelSessionReminders(String sessionId) async {
    if (!_isInitialized) return;

    try {
      final int notificationId = sessionId.hashCode;
      await _flutterLocalNotificationsPlugin.cancel(notificationId);
      debugPrint('Cancelled session reminder for $sessionId');
    } catch (e) {
      debugPrint('Failed to cancel session reminder: $e');
    }
  }

  /// Cancel all pending notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;

    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('Cancelled all notifications');
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }

  /// Show immediate notification (for testing or urgent alerts)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_hasPermission || !_isInitialized) return;

    try {
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        _getNotificationDetails(),
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to show immediate notification: $e');
    }
  }

  /// Check if notifications are enabled
  bool get hasPermission => _hasPermission;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Private methods

  Future<void> _requestPermissions() async {
    await requestNotificationPermissions();
  }

  void _onNotificationTap(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    debugPrint('Notification tapped with payload: $payload');
    
    // Handle different notification types
    if (payload?.startsWith('session_reminder:') == true) {
      final sessionId = payload!.split(':')[1];
      _handleSessionReminderTap(sessionId);
    }
  }

  void _handleSessionReminderTap(String sessionId) {
    // TODO: Navigate to session or show session status
    // This would typically use a navigation service or app router
    debugPrint('Handling session reminder tap for session: $sessionId');
  }

  tz.TZDateTime _getScheduledTZDateTime(Duration delay) {
    final now = tz.TZDateTime.now(tz.local);
    return now.add(delay);
  }

  NotificationDetails _getNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'session_reminders',
        'Session Reminders',
        channelDescription: 'Gentle reminders for your hydration sessions',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      ),
      // Windows notifications not currently implemented
    );
  }

  String _getSessionReminderTitle() {
    final List<String> titles = [
      'Gentle hydration reminder 💧',
      'How\'s your session going? 🥤',
      'Just checking in on you! 💙',
      'Your boba army is curious... 🧋',
      'No pressure, just care 💚',
    ];
    
    // Use current time to get a "random" title that's consistent for testing
    final index = DateTime.now().hour % titles.length;
    return titles[index];
  }

  String _getSessionReminderBody(String? containerType, int? targetMl) {
    if (containerType != null) {
      final List<String> messages = [
        'Still working on that $containerType? Take your time! 😊',
        'Your $containerType session is going strong. No rush! 🌟',
        'Sipping naturally from your $containerType? Perfect! 💫',
        'How\'s your $containerType treating you? 🥰',
        'Your hydration journey continues! 🚀',
      ];
      
      final index = (containerType.hashCode % messages.length).abs();
      return messages[index];
    } else {
      return 'Your hydration session is still active. Drink at your natural pace! 😊';
    }
  }
}

/// Extension for easier access to notification service
extension NotificationServiceExtension on NotificationService {
  /// Quick method to schedule a gentle session reminder
  Future<void> scheduleGentleReminder(String sessionId, {
    String? containerType,
    int? targetMl,
  }) async {
    // Schedule reminder for 45 minutes (as per requirements)
    await scheduleSessionReminder(
      sessionId,
      const Duration(minutes: 45),
      containerType: containerType,
      targetMl: targetMl,
    );
  }

  /// Quick method to schedule long session reminder
  Future<void> scheduleLongSessionReminder(String sessionId, {
    String? containerType,
    int? targetMl,
  }) async {
    // Schedule reminder for 2 hours for very long sessions
    await scheduleSessionReminder(
      sessionId,
      const Duration(hours: 2),
      containerType: containerType,
      targetMl: targetMl,
    );
  }
}