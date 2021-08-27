// Flutter
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/internal/legacyPreferences.dart';

import 'package:package_info/package_info.dart';

class ConfigurationProvider extends ChangeNotifier {
  LegacyPreferences preferences;
  ConfigurationProvider({required this.preferences}) {
    preferences = this.preferences;
    initProvider();
  }

  void initProvider() {
    loadSavedData();
    if (!kIsWeb) {
      PackageInfo.fromPlatform().then((value) {
        appName = value.appName;
        packageName = value.packageName;
        appVersion = value.version;
        buildNumber = value.buildNumber;
      });
    }
    accentColor = preferences.getAccentColor();
    showIntroduction = preferences.showIntroductionPages();
  }

  // App Introduction
  bool? showIntroduction;
  bool? _decending;
  bool get sortDescending => _decending ?? false;

  // Platform Info
  String? appName;
  String? packageName;
  String? appVersion;
  String? buildNumber;

  late Color _accentColor;
  bool _systemThemeAvailable = false;
  bool _systemThemeEnabled = false;
  bool _darkThemeEnabled = false;
  bool _blackThemeEnabled = false;
  String? _upliner;

  // Search History
  List<String>? _searchHistory;
  Color get accentColor => _accentColor;
  bool get systemThemeAvailable => _systemThemeAvailable;
  bool get systemThemeEnabled => _systemThemeEnabled;
  bool get darkThemeEnabled => _darkThemeEnabled;
  bool get blackThemeEnabled => _blackThemeEnabled;
  String? get upliner => _upliner;

  set upliner(String? value) {
    _upliner = value;
    notifyListeners();
  }

  set updateSortByDate(bool decending) {
    this._decending = decending;
    notifyListeners();
  }

  set systemThemeAvailable(bool value) {
    _systemThemeAvailable = value;
    if (value)
      _systemThemeEnabled = preferences.getSystemThemeEnabled();
    else
      _systemThemeEnabled = false;
    notifyListeners();
  }

  set accentColor(Color value) {
    _accentColor = value;
    preferences.saveAccentColor(value);
    notifyListeners();
  }

  set systemThemeEnabled(bool value) {
    _systemThemeEnabled = value;
    preferences.saveSystemThemeEnabled(value);
    notifyListeners();
  }

  set darkThemeEnabled(bool value) {
    _darkThemeEnabled = value;
    preferences.saveDarkThemeEnabled(value);
    notifyListeners();
  }

  set blackThemeEnabled(bool value) {
    _blackThemeEnabled = value;
    preferences.saveBlackThemeEnabled(value);
    notifyListeners();
  }

  void loadSavedData() {
    systemThemeAvailable = preferences.isSystemThemeAvailable ?? false;
    accentColor = preferences.getAccentColor();
    darkThemeEnabled = preferences.getDarkThemeEnabled();
    blackThemeEnabled = preferences.getBlackThemeEnabled();
    _searchHistory = (jsonDecode(preferences.getSearchHistory()) as List<dynamic>).cast<String>();
  }

  // Search History
  List<String>? getSearchHistory() => _searchHistory;
  void addStringtoSearchHistory(String searchQuery) {
    if (_searchHistory!.contains(searchQuery)) {
      _searchHistory!.removeWhere((element) => element == searchQuery);
      _searchHistory!.insert(0, searchQuery);
    } else {
      _searchHistory!.insert(0, searchQuery);
    }
    preferences.saveSearchHistory(jsonEncode(_searchHistory));
  }

  void removeStringfromSearchHistory(int index) {
    _searchHistory!.removeAt(index);
    preferences.saveSearchHistory(jsonEncode(_searchHistory));
    notifyListeners();
  }
}
