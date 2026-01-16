import 'dart:async';
import 'package:flutter/material.dart';
import '../routes/deep_link_handler.dart';

/// Queues deep links received during app bootstrap and processes them after bootstrap completes.
///
/// **Problem Solved (Issue #11):**
/// Deep links received during cold start (before bootstrap completes) were either:
/// - Processed immediately, causing navigation before auth/role ready
/// - Lost entirely, never reaching their destination
///
/// **Solution:**
/// - Queue deep links received before bootstrap
/// - Process queued link immediately after bootstrap completes
/// - Direct process links received after bootstrap
///
/// **Usage:**
/// ```dart
/// final queue = DeepLinkQueue();
/// 
/// // During initialization, listen to platform deep links
/// appLinks.uriLinkStream.listen((uri) => queue.onDeepLink(uri));
/// 
/// // After bootstrap completes
/// queue.onBootstrapComplete(context, handler);
/// ```
class DeepLinkQueue {
  DeepLinkQueue();

  Uri? _pendingLink;
  bool _bootstrapComplete = false;
  DeepLinkHandler? _handler;
  BuildContext? _context;
  
  final _linkProcessedController = StreamController<bool>.broadcast();
  
  /// Stream that emits when a deep link is processed.
  /// Emits true if successful, false if failed.
  Stream<bool> get linkProcessedStream => _linkProcessedController.stream;

  /// Called when a deep link is received from the platform.
  ///
  /// If bootstrap is complete, processes immediately.
  /// Otherwise, queues for processing after bootstrap.
  void onDeepLink(Uri uri) {
    debugPrint('🔗 DeepLinkQueue: Received deep link: $uri');
    
    if (_bootstrapComplete && _handler != null && _context != null) {
      // Bootstrap complete - process immediately
      debugPrint('🔗 DeepLinkQueue: Bootstrap complete, processing immediately');
      _processDeepLink(uri);
    } else {
      // Bootstrap not complete - queue for later
      debugPrint('🔗 DeepLinkQueue: Bootstrap incomplete, queuing link');
      _pendingLink = uri;
    }
  }

  /// Called when bootstrap completes.
  ///
  /// Sets up the handler and processes any pending deep link.
  void onBootstrapComplete(BuildContext context, DeepLinkHandler handler) {
    debugPrint('🔗 DeepLinkQueue: Bootstrap complete');
    _bootstrapComplete = true;
    _handler = handler;
    _context = context;

    // Process any pending deep link
    if (_pendingLink != null) {
      debugPrint('🔗 DeepLinkQueue: Processing queued deep link: $_pendingLink');
      final link = _pendingLink!;
      _pendingLink = null;
      
      // Process on next frame to ensure UI is fully ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processDeepLink(link);
      });
    } else {
      debugPrint('🔗 DeepLinkQueue: No pending deep links');
    }
  }

  /// Processes a deep link using the configured handler.
  Future<void> _processDeepLink(Uri uri) async {
    if (_handler == null || _context == null) {
      debugPrint('❌ DeepLinkQueue: Handler or context not available');
      _linkProcessedController.add(false);
      return;
    }

    try {
      debugPrint('🔗 DeepLinkQueue: Processing deep link: $uri');
      final success = await _handler!.handleDeepLink(uri, context: _context);
      
      if (success) {
        debugPrint('✅ DeepLinkQueue: Deep link processed successfully');
      } else {
        debugPrint('⚠️ DeepLinkQueue: Deep link processing returned false');
      }
      
      _linkProcessedController.add(success);
    } catch (e, stackTrace) {
      debugPrint('❌ DeepLinkQueue: Error processing deep link: $e');
      debugPrint('Stack trace: $stackTrace');
      _linkProcessedController.add(false);
    }
  }

  /// Clears any pending deep link without processing it.
  ///
  /// Useful for testing or error recovery scenarios.
  void clearPending() {
    if (_pendingLink != null) {
      debugPrint('🔗 DeepLinkQueue: Clearing pending deep link: $_pendingLink');
      _pendingLink = null;
    }
  }

  /// Returns whether there is a pending deep link.
  bool get hasPendingLink => _pendingLink != null;

  /// Returns the pending deep link URI if one exists.
  Uri? get pendingLink => _pendingLink;

  /// Returns whether bootstrap has completed.
  bool get isBootstrapComplete => _bootstrapComplete;

  /// Disposes resources.
  void dispose() {
    _linkProcessedController.close();
    _pendingLink = null;
    _handler = null;
    _context = null;
  }
}

/// Exception thrown when deep link queue operations fail.
class DeepLinkQueueException implements Exception {
  DeepLinkQueueException(this.message);

  final String message;

  @override
  String toString() => 'DeepLinkQueueException: $message';
}
