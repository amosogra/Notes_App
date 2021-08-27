// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i2;

import '../../Bible/entrance.dart' as _i4;
import '../pages/home/home_page.dart' as _i3;

class AppRouter extends _i1.RootStackRouter {
  AppRouter([_i2.GlobalKey<_i2.NavigatorState>? navigatorKey]) : super(navigatorKey);

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    HomePageRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i3.HomePage();
        }),
    EntranceRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<EntranceRouteArgs>(orElse: () => const EntranceRouteArgs());
          return _i4.Entrance(key: args.key, initialRoute: args.initialRoute, isTesting: args.isTesting);
        })
  };

  @override
  List<_i1.RouteConfig> get routes => [_i1.RouteConfig(HomePageRoute.name, path: '/'), _i1.RouteConfig(EntranceRoute.name, path: '/Entrance')];
}

class HomePageRoute extends _i1.PageRouteInfo {
  const HomePageRoute() : super(name, path: '/');

  static const String name = 'HomePageRoute';
}

class EntranceRoute extends _i1.PageRouteInfo<EntranceRouteArgs> {
  EntranceRoute({_i2.Key? key, String? initialRoute, bool? isTesting})
      : super(name, path: '/Entrance', args: EntranceRouteArgs(key: key, initialRoute: initialRoute, isTesting: isTesting ?? false));

  static const String name = 'EntranceRoute';
}

class EntranceRouteArgs {
  const EntranceRouteArgs({this.key, this.initialRoute, this.isTesting = false});

  final _i2.Key? key;

  final String? initialRoute;

  final bool isTesting;
}
