import 'package:flutter/material.dart';

class SelectedItemProvider extends ChangeNotifier {

  int? _selected;
  int? selected() => _selected ?? 0;

  SelectedItemProvider();

  updateSelected(int? x) {
    this._selected = x;
    notifyListeners();
  }
}
