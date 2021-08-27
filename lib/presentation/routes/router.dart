import 'package:notes_app/Bible/entrance.dart';
import 'package:notes_app/presentation/pages/home/home_page.dart';
import 'package:auto_route/annotations.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    // initial route is named "/"
    MaterialRoute(page: HomePage, initial: true),
    MaterialRoute(page: Entrance, initial: false),
  ],
)
class $AppRouter {}
