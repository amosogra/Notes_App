import 'package:flutter/foundation.dart';

const klog = true;

void log(Object? message, {int? wrapWidth}) {
  if (klog) {
    debugPrint(message.toString(), wrapWidth: wrapWidth);
  }
}
