import '../constants.dart';
import '../languages.dart';

class LanguageEn extends Languages {
  // Introduction Screens
  @override
  String get labelAppWelcome => "Welcome to";
  @override
  String get labelStart => "Start";
  @override
  String get labelSkip => "Skip";
  @override
  String get labelNext => "Next";
  @override
  String get labelExternalAccessJustification => "Needs Access to your External Storage to save all " + "your activities' data";
  @override
  String get labelAppCustomization => "Customization";
  @override
  String get labelSelectPreferred => "Select your Preferred";
  @override
  String get labelConfigReady => "Config Ready";
  @override
  String get labelIntroductionIsOver => "Introduction is over";
  @override
  String get labelEnjoy => "Enjoy";
  @override
  String get labelGoHome => "Go Home";

  // Home Screen
  @override
  String get labelQuickSearch => "Quick Search...";

  // Video Options Menu
  @override
  String get labelCopyLink => "Copy Link";
  @override
  String get labelAddToFavorites => "Add to Favorites";

  // Navigate Screen
  @override
  String get labelSearchYoutube => "Search Music Sources...";

  // More Screen
  @override
  String get labelSettings => "Settings";
  @override
  String get labelLicenses => "Licenses";
  @override
  String get labelChooseColor => "Choose Color";
  @override
  String get labelTheme => "Theme";
  @override
  String get labelUseSystemTheme => "Use System Theme";
  @override
  String get labelUseSystemThemeJustification => "Enable/Disable automatic Theme";
  @override
  String get labelEnableDarkTheme => "Enable Dark Theme";
  @override
  String get labelEnableDarkThemeJustification => "Use Dark Theme by default";
  @override
  String get labelEnableBlackTheme => "Enable Black Theme";
  @override
  String get labelEnableBlackThemeJustification => "Enable Pure Black Theme";
  @override
  String get labelAccentColor => "Accent Color";
  @override
  String get labelAccentColorJustification => "Customize accent color";
  @override
  String get labelDeleteCache => "Delete Cache";
  @override
  String get labelDeleteCacheJustification => "Clear ${Constants.appName}'s Cache";
  @override
  String get labelAndroid11Fix => "Android 11 Fix";
  @override
  String get labelAndroid11FixJustification => "Fixes Download issues on " + "Android 10 & 11";
  @override
  String get labelCacheIsEmpty => "Cache is Empty";
  @override
  String get labelYouAreAboutToClear => "You're about to clear";

  // Android 10 or 11 Detected Dialog
  @override
  String get labelAndroid11Detected => "Android 10 or 11 Detected";
  @override
  String get labelAndroid11DetectedJustification =>
      "To ensure the correct " +
      "functioning of this app Downloads, on Android 10 and 11, access to all " +
      "Files permission might be needed, this will be temporal and not required " +
      "on future updates. You can also apply this fix in Settings.";

  // Common Words (One word labels)
  @override
  String get labelExit => "Exit";
  @override
  String get labelSystem => "System";
  @override
  String get labelShare => "Share";
  @override
  String get labelVersion => "Version";
  @override
  String get labelLanguage => "Language";
  @override
  String get labelGrant => "Grant";
  @override
  String get labelAllow => "Allow";
  @override
  String get labelAccess => "Access";
  @override
  String get labelEmpty => "Empty";
  @override
  String get labelCalculating => "Calculating";
  @override
  String get labelCleaning => "Cleaning";
  @override
  String get labelCancel => "Cancel";
  @override
  String get labelGeneral => "General";
  @override
  String get labelRemove => "Remove";
  @override
  String get labelJoin => "Join";
  @override
  String get labelNo => "No";
  @override
  String get labelLibrary => "Library";
  @override
  String get labelCreate => "Create";
  @override
  String get labelPlaylists => "Playlists";
  @override
  String get labelQuality => "Quality";
}
