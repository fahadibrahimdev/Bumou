import 'dart:developer';

import 'package:flutter/foundation.dart';

class Logger {
  Logger(String s);

  static void success(String message, {bool isLog = true, bool isDebug = kDebugMode}) {
    if (isDebug) {
      String logMessage = '🟩 $message';
      if (isLog) {
        log(logMessage);
      } else {
        debugPrint(logMessage);
      }
    }
  }

  static void error(String message, {bool isLog = true, bool isDebug = kDebugMode}) {
    if (isDebug) {
      String logMessage = '🟥 $message';
      if (isLog) {
        log(logMessage);
      } else {
        debugPrint(logMessage);
      }
    }
  }

  static void warning(String message, {bool isLog = true, bool isDebug = kDebugMode}) {
    if (isDebug) {
      String logMessage = '🟨 $message';
      if (isLog) {
        log(logMessage);
      } else {
        debugPrint(logMessage);
      }
    }
  }

  static void message(String message, {bool isLog = true, bool isDebug = kDebugMode}) {
    if (isDebug) {
      String logMessage = '🚀 $message';
      if (isLog) {
        log(logMessage);
      } else {
        debugPrint(logMessage);
      }
    }
  }
}
