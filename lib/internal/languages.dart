import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

// Language Files
import 'languages/languageEn.dart';
/* import 'languages/languageEs.dart';
import 'languages/languageRu.dart';
import 'languages/languageAr.dart';
import 'languages/languagePt-BR.dart';
import 'languages/languageIgbo-NG.dart';
import 'languages/languageId.dart';
import 'languages/languageTr.dart';
import 'languages/languageSo.dart'; */

/// Multi-Language Support for SongTube, for new Languages to be supported
/// a new [File] in this project [internal/languages] folder needs to be
/// created named: [language<Code>.dart], you can then copy the contents
/// of any other already supported Language and adapt/translate it to your
/// new one.
///
/// To finish your new Language implementation you would only need to add
/// a new [LanguageData] to the [_supportedLanguages] list bellow and a new
/// switch case to your Language File in [_loadLocale] also bellow this.
final supportedLanguages = <LanguageData>[
  // English (US)
  LanguageData("🇺🇸", "English", 'en'),
  /* // Spanish (VE)
  LanguageData("ve", "Español", "es"),
  // Portuguese (BR)
  LanguageData("🇧🇷", "Português", "pt"),
  // Igbo (NG)
  LanguageData("ng", "Igbo", "ig"),
  // Indonesia (ID)
  LanguageData("🇮🇩", "Indonesia", "id"),
  // Turkish (TR)
  LanguageData("tr", "Turkey", "tr"),
  // Russian (RU)
  LanguageData("ru", "Russian", "ru"),
  // Somali (SO, ET, DJI, KEN)
  LanguageData("🇸🇴" "🇪🇹" "🇩🇯" "🇰🇪", "Soomaali", "so"),
  // Arabic (AR)
  LanguageData("ar", "Arabic", "ar"), */
];

Future<Languages> _loadLocale(Locale locale) async {
  switch (locale.languageCode) {
    // English (US)
    case 'en':
      return LanguageEn();
    /* // Spanish (VE)
    case 'es':
      return LanguageEs();
    // Portuguese (BR)
    case 'pt':
      return LanguagePtBr();
    // Igbo (NG)
    case 'ig':
      return LanguageIgbo();
    // Indonesia (ID)
    case 'id':
      return LanguageId();
    // Turkish (TR)
    case 'tr':
      return LanguageTr();
    // Russian (RU)
    case 'ru':
      return LanguageRu();
    // Somali (SO, ET, DJI, KEN)
    case 'so':
      return LanguageSo();
    // Arabic (AR)
    case 'ar':
      return LanguageAr(); */
    // Default Language (English)
    default:
      return LanguageEn();
  }
}

// -------------------
// Language Data Class
// -------------------
class LanguageData {
  final String flag;
  final String name;
  final String languageCode;

  LanguageData(this.flag, this.name, this.languageCode);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<Languages> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    List<String> supportedLanguageCodes = [];
    supportedLanguages.forEach((element) => supportedLanguageCodes.add(element.languageCode));
    return supportedLanguageCodes.contains(locale.languageCode);
  }

  @override
  Future<Languages> load(Locale locale) => _loadLocale(locale);

  @override
  bool shouldReload(LocalizationsDelegate<Languages> old) => false;
}

class FallbackLocalizationDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<MaterialLocalizations> load(Locale locale) async => DefaultMaterialLocalizations();
  @override
  bool shouldReload(_) => false;
}

abstract class Languages {
  static Languages? of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }

  // Introduction Screens
  String get labelAppWelcome;
  String get labelStart;
  String get labelSkip;
  String get labelNext;
  String get labelExternalAccessJustification;
  String get labelAppCustomization;
  String get labelSelectPreferred;
  String get labelConfigReady;
  String get labelIntroductionIsOver;
  String get labelEnjoy;
  String get labelGoHome;

  // Home Screen
  String get labelQuickSearch;

  // Navigate Screen
  String get labelSearchYoutube;

  // More Screen
  String get labelSettings;
  String get labelLicenses;
  String get labelChooseColor;
  String get labelTheme;
  String get labelUseSystemTheme;
  String get labelUseSystemThemeJustification;
  String get labelEnableDarkTheme;
  String get labelEnableDarkThemeJustification;
  String get labelEnableBlackTheme;
  String get labelEnableBlackThemeJustification;
  String get labelAccentColor;
  String get labelAccentColorJustification;
  String get labelDeleteCache;
  String get labelDeleteCacheJustification;
  String get labelAndroid11Fix;
  String get labelAndroid11FixJustification;
  String get labelCacheIsEmpty;
  String get labelYouAreAboutToClear;

  // Android 10 or 11 Detected Dialog
  String get labelAndroid11Detected;
  String get labelAndroid11DetectedJustification;

  // Common Words (One word labels)
  String get labelExit;
  String get labelSystem;
  String get labelShare;
  String get labelCopyLink;
  String get labelAddToFavorites;
  String get labelVersion;
  String get labelLanguage;
  String get labelGrant;
  String get labelAllow;
  String get labelAccess;
  String get labelEmpty;
  String get labelCalculating;
  String get labelCleaning;
  String get labelCancel;
  String get labelGeneral;
  String get labelRemove;
  String get labelJoin;
  String get labelNo;
  String get labelLibrary;
  String get labelCreate;
  String get labelPlaylists;
  String get labelQuality;
}

// ----------------------------------------
// Methods To Get, Set an Save App Language
// ----------------------------------------

const String prefSelectedLanguageCode = "SelectedLanguageCode";

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(prefSelectedLanguageCode, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(prefSelectedLanguageCode) ?? "en";
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  return languageCode.isNotEmpty ? Locale(languageCode, '') : Locale('en', '');
}

void changeLanguage(BuildContext context, String selectedLanguageCode) async {
  var _locale = await setLocale(selectedLanguageCode);
  //Main.setLocale(context, _locale);
}
