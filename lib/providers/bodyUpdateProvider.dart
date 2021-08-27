import 'package:flutter/material.dart';

class BodyUpdateProvider extends ChangeNotifier {
  Widget? _body;
  Widget body() =>
      _body ??
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );

  BodyUpdateProvider() {
    init();
  }

  init() {
    //updateBody(Center(child: CircularProgressIndicator()));
  }

  updateBody(Widget? widget) {
    this._body = widget;
    notifyListeners();
  }
}
