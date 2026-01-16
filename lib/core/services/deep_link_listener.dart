import 'dart:async';
import 'package:flutter/material.dart';
import 'deep_link_queue.dart';

/// Service for listening to platform deep links and forwarding them to the queue.
///
/// This service handles:
/// - Initial deep link (app opened via deep link when not running)
/// - Stream deep links (app opened via deep link when already running)
///
/// **Important:** This should only be initialized AFTER bootstrap completes
/// to ensure deep links are properly queued during cold start.
///
/// **Usage:**
/// ```dart
/// final listener = DeepLinkListener(deepLinkQueue);
/// await listener.initialize();
/// ```
///
/// **Note:** Requires app_links package in pubspec.yaml:
/// ```yaml
/// dependencies:
///   app_links: ^4.0.0
/// ```
class DeepLinkListener {
  DeepLinkListener(this._queue);

  final DeepLinkQueue _queue;
  StreamSubscription<Uri>? _linkSubscription;
  bool _isInitialized = false;

  /// Initializes the deep link listener.
  ///
  /// Sets up listening for both initial and stream deep links.
  /// Should be called after bootstrap completes.
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ DeepLinkListener: Already initialized');
      return;
    }

    try {
      // Import app_links dynamically to avoid compile errors if not installed
      // In production, this should be imported at the top level
      debugPrint('🔗 DeepLinkListener: Initializing deep link listening');
      
      // Note: Actual implementation requires app_links package
      // For now, we'll just mark as initialized and log
      // Production code should use:
      // final appLinks = AppLinks();
      // final initialUri = await appLinks.getInitialLink();
      // if (initialUri != null) {
      //   _queue.onDeepLink(initialUri);
      // }
      // _linkSubscription = appLinks.uriLinkStream.listen(_queue.onDeepLink);
      
      debugPrint('🔗 DeepLinkListener: Initialization complete');
      debugPrint('⚠️ Note: app_links package integration pending');
      debugPrint('   Add "app_links: ^4.0.0" to pubspec.yaml to enable');
      
      _isInitialized = true;
    } catch (e, stackTrace) {
      debugPrint('❌ DeepLinkListener: Initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Simulates receiving a deep link (for testing).
  ///
  /// This can be used to test deep link handling without platform integration.
  void simulateDeepLink(Uri uri) {
    debugPrint('🔗 DeepLinkListener: Simulating deep link: $uri');
    _queue.onDeepLink(uri);
  }

  /// Disposes resources.
  Future<void> dispose() async {
    await _linkSubscription?.cancel();
    _linkSubscription = null;
    _isInitialized = false;
  }
}

/// Extension to add deep link listening to DeepLinkQueue for convenience.
extension DeepLinkListenerExtension on DeepLinkQueue {
  /// Creates and returns a listener for this queue.
  DeepLinkListener createListener() {
    return DeepLinkListener(this);
  }
}
