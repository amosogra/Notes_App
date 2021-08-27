import 'package:flutter/material.dart';
import 'package:layout/layout.dart';
import 'package:notes_app/app_theme.dart';
import 'package:notes_app/presentation/routes/router.gr.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/values/values.dart';
import 'package:provider/provider.dart';

class HOGHome extends StatelessWidget {
  static String routeName = "/hoghome";
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    return Layout(
      child: MaterialApp.router(
        title: StringConst.APP_NAME,
        theme: config.darkThemeEnabled ? AppTheme.darkThemeData : AppTheme.lightThemeData,
        debugShowCheckedModeBanner: false,
        routerDelegate: _appRouter.delegate(),
        routeInformationParser: _appRouter.defaultRouteParser(),
      ),
    );
  }
}
