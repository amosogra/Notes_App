//import 'package:universal_html/prefer_universal/html.dart' as html;
//import 'package:firebase/firebase.dart' as fb;

import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import 'log.dart';
//import 'package:universal_io/io.dart';

class Tasks {
  static Future<Map<String, dynamic>> uploadImageTask(PickedFile file, Uint8List fileData, String fileName, Color? maskColor, String uploadMessage) async {
    var type = lookupMimeType(file.path) ?? "image/${fileName.substring(fileName.lastIndexOf(".") + 1)}";
    UploadTask task = FirebaseStorage.instance.ref().child(fileName).putData(
          fileData,
          SettableMetadata(
            contentType: type.startsWith("image/") ? type : "image/${fileName.substring(fileName.lastIndexOf(".") + 1)}",
            //cacheControl: 'max-age=60',
            /* customMetadata: <String, String>{
            'userId': 'ABC123',
          }, */
          ),
        );

    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.cubeGrid
      ..loadingStyle = EasyLoadingStyle.dark
      ..userInteractions = true
      ..dismissOnTap = false
      ..toastPosition = EasyLoadingToastPosition.center
      ..maskType = EasyLoadingMaskType.custom
      ..maskColor = maskColor;

    EasyLoading.show(status: 'Uploading...', dismissOnTap: false);

    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      var snapshotProgress = snapshot.bytesTransferred / snapshot.totalBytes;
      var progress = snapshotProgress * 100;
      log('Task state: ${snapshot.state}');
      log('Progress: ${progress.toStringAsFixed(0)}%');
      EasyLoading.showProgress(snapshotProgress, status: '$uploadMessage.. ${progress.toStringAsFixed(0)}%');
      //updateProgress(progress);
    }, onError: (e) {
      // The final snapshot is also available on the task via `.snapshot`,
      // this can include 2 additional states, `TaskState.error` & `TaskState.canceled`
      //log(task.snapshot);

      if (e.code == 'permission-denied') {
        log('User does not have permission to upload to this reference.');
      }
      EasyLoading.dismiss();
      var result = {'uploaded': false, 'url': ""};
      return result;
    });

    // We can still optionally use the Future alongside the stream.
    try {
      await task;
      log('media upload complete.');
      EasyLoading.showSuccess('media upload complete', duration: Duration(seconds: 2), dismissOnTap: true);
      var result = {'uploaded': true, 'url': await task.snapshot.ref.getDownloadURL()};
      return result;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        log('User does not have permission to upload to this reference.');
      }
      EasyLoading.dismiss();
      var result = {'uploaded': false, 'url': ""};
      return result;
    }
  }
}
