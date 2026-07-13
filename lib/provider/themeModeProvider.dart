import 'package:flutter/material.dart';
import 'package:noriskclient/config/Colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Drives the V2 dark/light toggle. `NoRiskClientColors` holds the actual
/// palette values (mutable static getters, see Colors.dart); this provider
/// owns persistence and calls `notifyListeners()` so the `Consumer` wrapping
/// `MaterialApp` in `main.dart` rebuilds the whole tree with the new colors,
/// mirroring the existing `LocaleProvider` pattern.
class ThemeModeProvider extends ChangeNotifier {
  NoRiskThemeMode _mode = NoRiskThemeMode.dark;
  NoRiskThemeMode get mode => _mode;

  void setMode(NoRiskThemeMode mode) {
    _mode = mode;
    NoRiskClientColors.setMode(mode);
    notifyListeners();
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(
        'themeMode',
        mode == NoRiskThemeMode.dark ? 'dark' : 'light',
      ),
    );
  }

  void loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('themeMode');
    final mode = stored == 'light'
        ? NoRiskThemeMode.light
        : NoRiskThemeMode.dark;
    _mode = mode;
    NoRiskClientColors.setMode(mode);
    notifyListeners();

    if (stored == null) {
      await prefs.setString('themeMode', 'dark');
    }
  }
}
