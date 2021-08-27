import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/screens/home/hog_screen.dart';
import 'package:notes_app/ui/AppTheme.dart';

xshowDialog(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        content: Container(
          margin: EdgeInsets.only(top: 16),
          child: Text(message),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(
              'Exit',
              style: AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle1, color: Theme.of(context).colorScheme.primary, fontWeight: 600, letterSpacing: 0.3),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                new MaterialPageRoute<Null>(
                  builder: (BuildContext context) {
                    return HOGHome();
                  },
                ),
              );
            },
          ),
          CupertinoDialogAction(
            child: Text(
              'Stay',
              style: AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle1, color: Theme.of(context).colorScheme.primary, fontWeight: 600, letterSpacing: 0.3),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
