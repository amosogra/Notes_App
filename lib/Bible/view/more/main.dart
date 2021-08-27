import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:notes_app/Bible/core.dart';
import 'package:notes_app/Bible/component.dart';
// import 'package:notes_app/widget.dart';

part 'more_view.dart';

class Main extends StatefulWidget {
  Main({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => MoreView();
}

abstract class _State extends State<Main> with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final core = Core();
  final controller = ScrollController();

  late AnimationController animationController;

  int testCounter = 0;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    animationController.animateTo(1.0);
  }

  @override
  dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }
}
