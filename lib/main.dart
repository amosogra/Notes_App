import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:notes_app/Bible/entrance.dart';
import 'package:notes_app/authentication/services/auth.dart';
import 'package:notes_app/authentication/splash.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/internal/languages.dart';
import 'package:notes_app/internal/legacyPreferences.dart';
import 'package:notes_app/intro/introduction.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/providers/bodyTypeWidgetProvider.dart';
import 'package:notes_app/providers/bodyUpdateProvider.dart';
import 'package:notes_app/providers/detailsBodyWidgetProvider.dart';
import 'package:notes_app/providers/notifierProvider.dart';
import 'package:notes_app/providers/selectedItemProvider.dart';
import 'package:notes_app/providers/selectedUserProvider.dart';
import 'package:notes_app/providers/widgetScreenProvider.dart';
import 'package:notes_app/screens/admin/admin_screen.dart';
import 'package:notes_app/screens/admin/prayers/prayer_screen.dart';
import 'package:notes_app/screens/home.dart';
import 'package:notes_app/screens/home/edit_profile_screen.dart';
import 'package:notes_app/screens/home/hog_screen.dart';
import 'package:notes_app/screens/profile/profile_screen.dart';
import 'package:notes_app/size_config.dart';
import 'package:notes_app/ui/internal/navigationService.dart';
import 'package:notes_app/ui/internal/scrollBehavior.dart';
import 'package:notes_app/ui/internal/themeValues.dart';
import 'package:notes_app/utils/SizeConfig.dart';
import 'package:notes_app/utils/log.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'models/user_prefrences.dart';
import 'providers/configurationProvider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UserPrefrences.init();

  if (!kIsWeb) {
    Logger.root.onRecord.listen((record) {
      log('${record.level.name}: ${record.time}: ${record.message}');
      if (record.error != null) {
        log('${record.error}');
      }
      if (record.stackTrace != null) {
        log('${record.stackTrace}');
      }
    });
  }

  await Firebase.initializeApp();

  if (kIsWeb) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };
  } else {
    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
  await Hive.initFlutter();
  await Hive.openBox('settings');

  LegacyPreferences preferences = new LegacyPreferences();
  await preferences.initPreferences();
  // If we run on web, do not use Crashlytics (not supported on web yet)
  if (kIsWeb) {
    runApp(MyApp(preloadedFs: preferences));
  } else {
    // Use dart zone to define Crashlytics as error handler for errors
    // that occur outside runApp
    runZonedGuarded<Future<Null>>(() async {
      runApp(MyApp(preloadedFs: preferences));
    }, FirebaseCrashlytics.instance.recordError);
  }
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  static void validateTheme(BuildContext context) {
    var state = context.findAncestorStateOfType<_MyAppState>()!;
    state.validateTheme();
  }

  final LegacyPreferences preloadedFs;
  const MyApp({Key? key, required this.preloadedFs}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Language
  Locale? _locale;

  ConfigurationProvider? configx;
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void validateTheme() {
    log("OOOHHHHHAY");
    try {
      configx?.darkThemeEnabled = configx?.darkThemeEnabled as bool;
    } catch (e) {
      log("THIS IS NOT GOOD!");
      log("LOG: $e");
    }
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(value: AuthService().stream, initialData: null),
        ChangeNotifierProvider<ConfigurationProvider>(create: (context) => ConfigurationProvider(preferences: widget.preloadedFs)),
        ChangeNotifierProvider<WidgetScreenProvider>(create: (context) => WidgetScreenProvider()),
        ChangeNotifierProvider<BodyUpdateProvider>(create: (context) => BodyUpdateProvider()),
        ChangeNotifierProvider<SelectedItemProvider>(create: (context) => SelectedItemProvider()),
        ChangeNotifierProvider<SelectedUserProvider>(create: (context) => SelectedUserProvider()),
        ChangeNotifierProvider<BodyTypeWidgetProvider>(create: (context) => BodyTypeWidgetProvider()),
        ChangeNotifierProvider<DetailsBodyWidgetProvider>(create: (context) => DetailsBodyWidgetProvider()),
        ChangeNotifierProvider<NotifierProvider>(create: (context) => NotifierProvider()),
      ],
      child: Builder(builder: (context) {
        final config = Provider.of<ConfigurationProvider>(context);
        configx = config;
        ThemeData customTheme;
        ThemeData darkTheme;

        darkTheme = config.blackThemeEnabled
            ? AppTheme.black(config.accentColor).copyWith(
                scaffoldBackgroundColor: bgColorD, //Colors.black,
                canvasColor: secondaryColorD,
                colorScheme: ColorScheme.dark().copyWith(primary: Colors.yellow),
                textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.black, displayColor: bgColorD),
              )
            : AppTheme.dark(config.accentColor).copyWith(
                scaffoldBackgroundColor: bgColorD,
                textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white, displayColor: Colors.white),
                canvasColor: secondaryColorD,
                colorScheme: ColorScheme.dark().copyWith(primary: Colors.yellow));

        customTheme = config.darkThemeEnabled
            ? darkTheme
            : AppTheme.white(config.accentColor).copyWith(
                scaffoldBackgroundColor: bgColor,
                canvasColor: secondaryColor,
                textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.black, displayColor: bgColorD),
              );
        List<Locale> supportedLocales = [];
        supportedLanguages.forEach((element) => supportedLocales.add(Locale(element.languageCode, '')));
        return OverlaySupport.global(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: Constants.appName,
            locale: _locale,
            supportedLocales: supportedLocales,
            localizationsDelegates: [
              FallbackLocalizationDelegate(),
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode && supportedLocale.countryCode == locale?.countryCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            theme: config.systemThemeEnabled ? AppTheme.white(config.accentColor) : customTheme,
            darkTheme: config.systemThemeEnabled ? darkTheme : customTheme,
            builder: EasyLoading.init(
              builder: (context, child) {
                SizeConfig().init(context);
                MySize().init(context);
                return ScrollConfiguration(
                  behavior: CustomScrollBehavior(),
                  child: child!,
                );
              },
            ),
            navigatorKey: NavigationService.instance.navigationKey,
            //initialRoute: config.preferences.showIntroductionPages() && !kIsWeb ? 'intro' : 'main',
            home: Material(child: SplashScreen()),
            routes: {
              'main': (context) => Material(child: SplashScreen()),
              'intro': (context) => IntroScreen(),
              HOGHome.routeName: (context) => HOGHome(),
              Entrance.routeName: (context) => Entrance(),
              //CompleteProfileScreen.routeName: (context) => CompleteProfileScreen(),
              ProfileScreen.routeName: (context) => ProfileScreen(),
              EditProfileScreen.routeName: (context) => EditProfileScreen(),
              AdminScreen.routeName: (context) => AdminScreen(),
              PrayerScreen.routeName: (context) => PrayerScreen(),
              ProfileScreen.routeName: (context) => ProfileScreen(),
            },
          ),
        );
      }),
    );
  }
}
