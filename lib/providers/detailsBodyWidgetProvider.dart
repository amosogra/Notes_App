import 'package:flutter/material.dart';

class DetailsBodyWidgetProvider extends ChangeNotifier {
  Widget? _detailsBody;
  Widget detailsBodyWidget() =>
      _detailsBody ??
      Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );

  DetailsBodyWidgetProvider();

  updateDetailsBodyWidget(Widget? widget) {
    this._detailsBody = widget;
    notifyListeners();
  }
}
