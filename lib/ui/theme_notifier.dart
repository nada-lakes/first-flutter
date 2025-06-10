import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  static const String _boxName = 'settingsBox';
  static const String _key = 'isDarkMode';

  ThemeNotifier() : super(ThemeMode.light) {
    final box = Hive.box(_boxName);
    bool isDark = box.get(_key, defaultValue: false);
    value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme(bool isDark) {
    value = isDark ? ThemeMode.dark : ThemeMode.light;
    final box = Hive.box(_boxName);
    box.put(_key, isDark);
  }

  bool get isDarkMode => value == ThemeMode.dark;
}
