import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';
// import 'dart:math';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/utils/log.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_tts/flutter_tts.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:notes_app/Bible/model.dart';
import 'package:collection/collection.dart' show IterableExtension;

part 'configuration.dart';
part 'scripture.dart';
part 'engine.dart';
part 'collection.dart';
part 'bible.dart';
part 'bookmark.dart';
part 'mock.dart';
part 'utility.dart';
part 'speech.dart';

class Core extends _Collection with _Bible, _Bookmark, _Speech, _Mock {
  // Creates instance through `_internal` constructor
  static Core _instance = new Core.internal();
  Core.internal();

  factory Core() => _instance;

  // retrieve the instance through the app
  static Core get instance => _instance;

  Future<void> init() async {
    if (!kIsWeb) {
      await appInfo.then(
        (PackageInfo packageInfo) {
          this.appName = packageInfo.appName;
          this.packageName = packageInfo.packageName;
          this.version = packageInfo.version;
          this.buildNumber = packageInfo.buildNumber;
        },
      );
    }

    await readCollection();
    switchIdentifyPrimary();
    await getBiblePrimary.catchError((e) {
      log('error Primary $e');
    });

    switchIdentifyParallel();
    await getBibleParallel.catchError((e) {
      log('error Parallel $e');
    });

    await initSpeech().catchError((e) {
      log('error speech $e');
    });

    /* await loadDefinitionBible(identify).catchError((e){
      // log('init loadDefinitionBible $e');
    }); */
    // await Future.delayed(Duration(milliseconds: 300), (){});
  }

  // NOTE: used on read: when [bible] is switch
  Future<void> analyticsBible() async {
    CollectionBible e = collectionPrimary;
    // log('analyticsBible ${e.name} ${e.shortname} book:$bookName');
    this.analyticsContent('${e.name} (${e.shortname})', this.bookName);
  }

  // NOTE: used on read: when [book,chapter] are change
  Future<void> analyticsReading() async {
    CollectionBible e = collectionPrimary;
    // log('analyticsReading ${e.name} ${e.shortname} book:$bookName chapter: $chapterName');
    this.analyticsBook('${e.name} (${e.shortname})', this.bookName, this.chapterName);
  }
}
