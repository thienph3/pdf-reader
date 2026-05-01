import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _boxName = 'settings';

class SettingsService extends ChangeNotifier {
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  // --- Theme ---

  ThemeMode get themeMode {
    final v = _box.get('themeMode', defaultValue: 'system') as String;
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final v = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await _box.put('themeMode', v);
    notifyListeners();
  }

  // --- Locale ---

  Locale get locale {
    final v = _box.get('locale', defaultValue: 'vi') as String;
    return Locale(v);
  }

  Future<void> setLocale(Locale locale) async {
    await _box.put('locale', locale.languageCode);
    notifyListeners();
  }

  // --- Reading Goals ---

  int get dailyGoalMinutes => _box.get('dailyGoalMinutes', defaultValue: 30) as int;

  Future<void> setDailyGoalMinutes(int minutes) async {
    await _box.put('dailyGoalMinutes', minutes);
    notifyListeners();
  }

  int get monthlyGoalBooks => _box.get('monthlyGoalBooks', defaultValue: 2) as int;

  Future<void> setMonthlyGoalBooks(int books) async {
    await _box.put('monthlyGoalBooks', books);
    notifyListeners();
  }

  // --- PDF Scroll Direction ---

  bool get isHorizontalScroll =>
      _box.get('scrollHorizontal', defaultValue: false) as bool;

  Future<void> setHorizontalScroll(bool horizontal) async {
    await _box.put('scrollHorizontal', horizontal);
    notifyListeners();
  }
}
