import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Thin wrapper around `flutter_local_notifications`. This is *device-local*
/// notification delivery: it can surface a notification the instant the app
/// (foreground or backgrounded-but-alive) notices new content, but it
/// cannot wake the app up from fully killed/terminated state the way a real
/// push service (e.g. Firebase Cloud Messaging) can - that would need a
/// Firebase project + server-side trigger, which is out of scope here since
/// there's no Firebase/OneSignal connector in this environment and it would
/// require the user's own Firebase console setup.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  Future<bool> requestPermission() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    await initialize();
    const androidDetails = AndroidNotificationDetails(
      'noriskclient_default',
      'NoRisk Client',
      channelDescription: 'News and chat updates',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
