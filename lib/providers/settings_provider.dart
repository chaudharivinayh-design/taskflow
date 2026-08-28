import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/styles.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyStyle = 'app_style';
  static const _keyThemeMode = 'theme_mode';
  static const _keyUserName = 'user_name';

  AppStyle _style = AppStyle.fusion;
  ThemeMode _themeMode = ThemeMode.system;
  String _userName = '';
  bool _loaded = false;

  AppStyle get style => _style;
  ThemeMode get themeMode => _themeMode;
  String get userName => _userName;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final styleName = prefs.getString(_keyStyle);
    if (styleName != null) {
      _style = AppStyle.values.firstWhere(
        (e) => e.name == styleName,
        orElse: () => AppStyle.fusion,
      );
    }
    final modeName = prefs.getString(_keyThemeMode);
    if (modeName != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == modeName,
        orElse: () => ThemeMode.system,
      );
    }
    _userName = prefs.getString(_keyUserName) ?? '';
    _loaded = true;
    notifyListeners();
  }

  Future<void> setStyle(AppStyle style) async {
    _style = style;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStyle, style.name);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }
}
