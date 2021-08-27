// Dart
import 'dart:async';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';

// Key identifiers for variables saved in SharedPreferences.
String accentKey = "app_accent_color";
String systemThemeKey = "use_system_theme";
String darkThemeKey = "use_dark_theme";
String blackThemeKey = "use_black_theme";
String appColor = "app_color";
String showIntroduction = "show_introduction";

// Search History
String searchHistory = "search_history";

class LegacyPreferences {
  late SharedPreferences prefs;

  Future<void> initPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (Platform.isAndroid) {
      AndroidDeviceInfo deviceInfo = await DeviceInfoPlugin().androidInfo;
      sdkInt = deviceInfo.version.sdkInt;
      if (sdkInt >= 28) {
        isSystemThemeAvailable = true;
      } else {
        isSystemThemeAvailable = false;
      }
    } else {
      isSystemThemeAvailable = true;
    }
  }

  late int sdkInt;

  bool? isSystemThemeAvailable;

  Color getAccentColor() {
    return Color(prefs.getInt(accentKey) ?? Colors.orange.value);
  }

  void saveAccentColor(Color color) {
    prefs.setInt(accentKey, color.value);
  }

  bool getSystemThemeEnabled() {
    return prefs.getBool(systemThemeKey) ?? true;
  }

  void saveSystemThemeEnabled(bool value) {
    prefs.setBool(systemThemeKey, value);
  }

  bool getDarkThemeEnabled() {
    return prefs.getBool(darkThemeKey) ?? false;
  }

  void saveDarkThemeEnabled(bool value) {
    prefs.setBool(darkThemeKey, value);
  }

  bool getBlackThemeEnabled() {
    return prefs.getBool(blackThemeKey) ?? false;
  }

  void saveBlackThemeEnabled(bool value) {
    prefs.setBool(blackThemeKey, value);
  }

  bool showIntroductionPages() {
    return prefs.getBool(showIntroduction) ?? true;
  }

  void saveShowIntroductionPages(bool value) {
    prefs.setBool(showIntroduction, value);
  }

  // Search History
  String getSearchHistory() {
    return prefs.getString(searchHistory) ?? "[]";
  }

  void saveSearchHistory(String history) {
    prefs.setString(searchHistory, history);
  }
}
