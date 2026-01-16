import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashReportingService {
  static CrashReportingService? _instance;
  static CrashReportingService get instance => _instance ??= CrashReportingService._();

  CrashReportingService._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();

      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordError(
          fatal: true,
          errorDetails.exception,
          errorDetails.stack,
          information: [
            'Context: ${errorDetails.context}',
          ],
        );
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

      _initialized = true;
      log('Crash reporting service initialized');
    } catch (e, stack) {
      log('Failed to initialize crash reporting: $e');
      debugPrint('Failed to initialize crash reporting: $e');
      debugPrint(stack.toString());
    }
  }

  void recordError(dynamic exception, StackTrace? stack, {bool fatal = false, Map<String, dynamic>? context}) {
    if (!_initialized) {
      log('Crash reporting not initialized, skipping error recording');
      return;
    }

    if (exception != null) {
      FirebaseCrashlytics.instance.recordError(
        exception,
        stack,
        fatal: fatal,
        information: context != null
            ? context.entries.map((e) => '${e.key}: ${e.value}')
            : <String>[],
      );
    } else {
      log('Exception was null, skipping error recording');
    }
  }

  void recordFlutterError(FlutterErrorDetails errorDetails, {bool fatal = false}) {
    if (!_initialized) {
      log('Crash reporting not initialized, skipping error recording');
      return;
    }

    FirebaseCrashlytics.instance.recordError(
      fatal: fatal,
      errorDetails.exception,
      errorDetails.stack,
      information: [
        'Context: ${errorDetails.context}',
        'Library: ${errorDetails.library}',
      ],
    );
  }

  void log(String message) {
    if (!_initialized) return;

    FirebaseCrashlytics.instance.log(message);
  }

  void setUserId(String? userId) {
    if (!_initialized) return;

    FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
  }

  void setCustomKey(String key, String value) {
    if (!_initialized) return;

    FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  void setUser(Map<String, dynamic> user) {
    if (!_initialized) return;

    for (final entry in user.entries) {
      setCustomKey(entry.key, entry.value.toString());
    }
  }

  Future<void> recordErrorWithMessage(
    String message,
    dynamic exception,
    StackTrace? stack, {
    bool fatal = false,
    Map<String, dynamic>? context,
  }) async {
    log(message);

    if (exception != null || stack != null) {
      recordError(exception, stack, fatal: fatal, context: context);
    }
  }

  Future<void> testCrash() async {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.crash();
    } else {
      debugPrint('Test crash skipped - not in release mode');
    }
  }
}
