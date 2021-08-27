import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:notes_app/authentication/splash.dart';
import 'package:notes_app/internal/languages.dart';
import 'package:notes_app/internal/legacyPreferences.dart';
import 'package:notes_app/screens/home.dart';
import 'package:notes_app/utils/log.dart';
import 'models/user_prefrences.dart';
import 'providers/configurationProvider.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await UserPrefrences.init();

  /* Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      debugPrint('${record.error}');
    }
    if (record.stackTrace != null) {
      debugPrint('${record.stackTrace}');
    }
  }); */

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

  ConfigurationProvider? config;
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void validateTheme() {
    log("OOOHHHHHAY");
    try {
      config?.darkThemeEnabled = config?.darkThemeEnabled as bool;
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 37, 37, 37),
        primarySwatch: Colors.blue,
      ),
      home: Material(child: SplashScreen()),
    );
  }
}