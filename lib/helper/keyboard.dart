import 'package:flutter/cupertino.dart';

class KeyboardUtil {
  static void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  static void showKeyboard(BuildContext context, FocusNode focusNode) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    //if (!currentFocus.hasPrimaryFocus) {
      currentFocus.requestFocus(focusNode);
    //}
  }
}
