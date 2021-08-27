import 'package:flutter/material.dart';

class NotifierProvider extends ChangeNotifier {
  bool _notify = true;
  bool get notify => _notify;

  NotifierProvider();

  set updateNotifier(bool notify) {
    this._notify = notify;
    notifyListeners();
  }
}
