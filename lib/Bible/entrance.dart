import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

import 'package:notes_app/Bible/core.dart';
import 'package:notes_app/Bible/idea/scope.dart';
import 'package:notes_app/Bible/view/common.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/utils/log.dart';
import 'package:provider/provider.dart';

class Entrance extends StatelessWidget {
  static String routeName = "/Entrance";
  const Entrance({
    Key? key,
    this.initialRoute,
    this.isTesting: false,
  }) : super(key: key);

  final String? initialRoute;
  final bool isTesting;

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    return WillPopScope(
      onWillPop: () {
        xshowDialog(context, "Do you want to exit the bible?");
        log("Heyy.. Entrance");
        return Future.value(false);
      },
      child: ApplyModelBinding(
        initialModel: ApplyThemeOption(
          themeMode: config.darkThemeEnabled ? ThemeMode.dark : ThemeMode.light,
          textScaleFactor: systemTextScaleFactorOption,
          customTextDirection: CustomTextDirection.localeBased,
          locale: null,
          timeDilation: timeDilation,
          platform: defaultTargetPlatform,
          isTesting: isTesting,
        ),
        child: Builder(
          builder: (context) => /* SplashPage() */ MaterialApp(
            title: Core.instance.appName,
            debugShowCheckedModeBanner: false,
            themeMode: ApplyThemeOption.of(context)?.themeMode,
            theme: ApplyThemeData.lightThemeData.copyWith(
              platform: ApplyThemeOption.of(context)?.platform,
            ),
            darkTheme: ApplyThemeData.darkThemeData.copyWith(
              platform: ApplyThemeOption.of(context)?.platform,
            ),
            // localizationsDelegates: const [
            //   ...GalleryLocalizations.localizationsDelegates,
            //   LocaleNamesLocalizationsDelegate()
            // ],
            // supportedLocales: GalleryLocalizations.supportedLocales,
            locale: ApplyThemeOption.of(context)?.locale,
            localeResolutionCallback: (locale, supportedLocales) {
              deviceLocale = locale;
              // log(locale);
              return locale;
            },
            initialRoute: initialRoute,
            onGenerateRoute: RouteConfiguration.onGenerateRoute,
            // onUnknownRoute: RouteConfiguration.onUnknownRoute,
          ),
        ),
      ),
    );
  }
}
