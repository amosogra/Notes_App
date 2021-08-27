import 'package:flutter/material.dart';

class BodyTypeWidgetProvider extends ChangeNotifier {
  Widget? _bodyType;
  Widget bodyTypeWidget() =>
      _bodyType ??
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );

  BodyTypeWidgetProvider() {
    init();
  }

  init() {
    //updateBody(Center(child: CircularProgressIndicator()));
  }

  updateBodyTypeWidget(Widget? widget) {
    this._bodyType = widget;
    notifyListeners();
  }
}
