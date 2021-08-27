import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:notes_app/Bible/core.dart';
import 'package:notes_app/Bible/component.dart';
import 'package:notes_app/Bible/widget.dart';
import 'package:notes_app/Bible/icon.dart';

part 'note_view.dart';

class MainNote extends StatefulWidget {
  MainNote({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => NoteView();
}

abstract class _State extends State<MainNote> with TickerProviderStateMixin {
  // final scaffoldKey = GlobalKey<ScaffoldState>();
  final core = Core();
  final controller = ScrollController();
  // final sliverAnimatedListKey = GlobalKey<SliverAnimatedListState>();
  AnimationController? animatedController;

  // Collection get collection => core.collection;
  List<CollectionBookmark>? get bookmarks => core.collectionBookmarkList;

  // bool get isNotReady => core.userBible == null && core.userBibleList.length == 0;
  // bool get isNotReady => core.scripturePrimary.hasLoaded;
  bool get isNotReady => core.scripturePrimary!.notReady();

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
    // controller.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }
}
