/*
* File : App Theme And Battery Notifier (Listener)
* Version : 1.0.0
* */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetScreenProvider extends ChangeNotifier {
  Widget? _screenWidget;
  Widget? screenWidget() => _screenWidget;

  WidgetScreenProvider() {
    init();
  }

  init() async {
    updateScreen(
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
    );
    //handleInitialUri();
    notifyListeners();
  }

  Future<void> updateScreen(Widget screenWidget) async {
    this._screenWidget = screenWidget;
    notifyListeners();
  }
}
