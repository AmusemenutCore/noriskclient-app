import 'package:flutter/material.dart';
import 'package:noriskclient/utils/NotificationService.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Owns the "push notifications" toggle in Settings. See
/// `NotificationService` for why this delivers local, not remote, push.
class NotificationsProvider extends ChangeNotifier {
  bool _enabled = false;
  bool get enabled => _enabled;

  void load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('notificationsEnabled') ?? false;
    notifyListeners();
  }

  void toggle() async {
    final next = !_enabled;
    if (next) {
      final granted = await NotificationService().requestPermission();
      if (!granted) {
        // Permission denied at the OS level: keep the toggle off so it
        // doesn't silently claim to be on while nothing can be delivered.
        return;
      }
    }
    _enabled = next;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', next);
  }
}
