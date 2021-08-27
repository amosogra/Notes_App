import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:notes_app/authentication/services/auth.dart';
import 'package:notes_app/authentication/splash.dart';
import 'package:notes_app/internal/languages.dart';
import 'package:notes_app/internal/legacyPreferences.dart';
import 'package:notes_app/intro/introduction.dart';
import 'package:notes_app/providers/bodyTypeWidgetProvider.dart';
import 'package:notes_app/providers/bodyUpdateProvider.dart';
import 'package:notes_app/providers/detailsBodyWidgetProvider.dart';
import 'package:notes_app/providers/notifierProvider.dart';
import 'package:notes_app/providers/selectedItemProvider.dart';
import 'package:notes_app/providers/selectedUserProvider.dart';
import 'package:notes_app/providers/widgetScreenProvider.dart';
import 'package:notes_app/screens/home.dart';
import 'package:notes_app/size_config.dart';
import 'package:notes_app/ui/internal/navigationService.dart';
import 'package:notes_app/ui/internal/scrollBehavior.dart';
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

         List<Locale> supportedLocales = [];
        supportedLanguages.forEach((element) => supportedLocales.add(Locale(element.languageCode, '')));
        return OverlaySupport.global(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
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
            theme: ThemeData(
              scaffoldBackgroundColor: const Color.fromARGB(255, 37, 37, 37),
              primarySwatch: Colors.blue,
            ),
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
            //initialRoute: config!.preferences.showIntroductionPages() && !kIsWeb ? 'intro' : 'main',
            home: Material(child: SplashScreen()),
            routes: {
              'main': (context) => Material(child: SplashScreen()),
              'intro': (context) => IntroScreen(),
            },
          ),
        );
      }),
    );
  }
}
