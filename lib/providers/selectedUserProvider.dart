import 'package:flutter/material.dart';

class SelectedUserProvider extends ChangeNotifier {

  int? _selected;
  int? get selected => _selected ?? 0;

  SelectedUserProvider();

  updateSelectedUser(int? x) {
    this._selected = x;
    notifyListeners();
  }
}
