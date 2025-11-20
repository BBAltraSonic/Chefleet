import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[DEBUG] $message');
      if (error != null) {
        // ignore: avoid_print
        print('[ERROR] $error');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        print('[STACK] $stackTrace');
      }
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[INFO] $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[WARN] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    // Always log errors, even in release mode
    // ignore: avoid_print
    print('[ERROR] $message');
    if (error != null) {
      // ignore: avoid_print
      print('[ERROR] $error');
    }
    if (stackTrace != null) {
      // ignore: avoid_print
      print('[STACK] $stackTrace');
    }
  }
}
