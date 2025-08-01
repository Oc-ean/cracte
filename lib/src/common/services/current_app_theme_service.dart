import 'package:cracte/src/common/common.dart';

import 'package:hive/hive.dart';

class CurrentAppThemeService {
  final Box<String> _themeBox;
  static const String themeNameKey = 'current_theme';

  CurrentAppThemeService() : _themeBox = Hive.box<String>('app_theme');

  Future<void> setCurrentAppTheme(String themeName) async {
    try {
      await _themeBox.put(themeNameKey, themeName);
    } catch (e) {
      logman.error('Failed to set app theme: $e');
    }
  }

  Future<CurrentAppTheme> getCurrentAppTheme() async {
    try {
      final themeName = _themeBox.get(themeNameKey, defaultValue: 'system');

      if (themeName == 'darkMode') {
        return CurrentAppTheme.dark;
      }

      if (themeName == 'lightMode') {
        return CurrentAppTheme.light;
      }

      return CurrentAppTheme.system;
    } catch (e) {
      logman.error('Failed to get app theme: $e');
      return CurrentAppTheme.system;
    }
  }
}
