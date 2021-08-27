import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.pink, width: 2.0),
    ));

class AdMobConstants {
  static const admobAppId = "ca-app-pub-2288924893490965~4319171427";
  static const admobAdUnitId = "ca-app-pub-2288924893490965/5440681403";

  static const admobAdKeywords = [
    "games",
    "electronics",
    "gadgets",
    "banks",
    "financial institutions",
    "insurance",
    "loans",
  ];
}
