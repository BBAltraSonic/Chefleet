import 'dart:collection';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

/// Request to perform navigation with priority and metadata.
class NavigationRequest {
  final String route;
  final Object? extra;
  final Map<String, String>? pathParameters;
  final Map<String, dynamic>? queryParameters;
  final NavigationPriority priority;
  final String? requestSource;

  const NavigationRequest({
    required this.route,
    this.extra,
    this.pathParameters,
    this.queryParameters,
    this.priority = NavigationPriority.normal,
    this.requestSource,
  });

  @override
  String toString() => 'NavigationRequest(route: $route, source: $requestSource, priority: $priority)';
}

/// Priority levels for navigation requests.
enum NavigationPriority {
  high,    // Deep links, critical errors
  normal,  // User interactions
  low,     // Background updates
}

/// Coordinates navigation requests to prevent competing authorities.
/// 
/// This service ensures that only one navigation happens at a time,
/// preventing race conditions when multiple systems (BLoC listeners,
/// router redirects, manual navigation) try to navigate simultaneously.
/// 
/// Phase 1 Implementation: Basic queueing to prevent competing authorities.
/// Future phases will add coordination with BLoC state changes and timing.
class NavigationCoordinator {
  final GoRouter _router;
  final Queue<NavigationRequest> _pending = Queue();
  bool _isProcessing = false;

  NavigationCoordinator(this._router);

  /// Request navigation to a route.
  /// 
  /// Navigation requests are queued and processed sequentially to prevent
  /// race conditions. Higher priority requests are processed first.
  void request(NavigationRequest req) {
    print('🧭 Navigation request queued: ${req.route} (source: ${req.requestSource ?? "unknown"}, priority: ${req.priority})');
    
    // Insert by priority
    if (req.priority == NavigationPriority.high) {
      // Add high priority requests to front of queue
      final highPriorityCount = _pending.where((r) => r.priority == NavigationPriority.high).length;
      if (highPriorityCount == 0) {
        _pending.addFirst(req);
      } else {
        // Insert after other high priority requests
        final list = _pending.toList();
        list.insert(highPriorityCount, req);
        _pending.clear();
        _pending.addAll(list);
      }
    } else {
      _pending.add(req);
    }
    
    _processQueue();
  }

  /// Process queued navigation requests sequentially.
  ///
  /// Waits for the next frame after each navigation to ensure the router
  /// completes its processing before executing the next request. This prevents
  /// navigation race conditions when multiple requests are queued.
  Future<void> _processQueue() async {
    if (_isProcessing || _pending.isEmpty) return;
    
    _isProcessing = true;
    
    while (_pending.isNotEmpty) {
      final request = _pending.removeFirst();
      await _executeNavigation(request);
      
      // Wait for the next frame to ensure router has processed this navigation
      // before executing the next request from the queue
      await SchedulerBinding.instance.endOfFrame;
    }
    
    _isProcessing = false;
  }

  /// Execute a single navigation request.
  Future<void> _executeNavigation(NavigationRequest request) async {
    try {
      print('🧭 Executing navigation: ${request.route}');
      
      if (request.pathParameters != null || request.queryParameters != null) {
        _router.goNamed(
          request.route,
          pathParameters: request.pathParameters ?? {},
          queryParameters: request.queryParameters ?? {},
          extra: request.extra,
        );
      } else {
        _router.go(request.route, extra: request.extra);
      }
      
      print('🧭 Navigation completed: ${request.route}');
    } catch (e) {
      print('🧭 Navigation failed: ${request.route}, error: $e');
      // Don't rethrow - continue processing queue
    }
  }

  /// Clear all pending navigation requests.
  /// 
  /// Useful when user logs out or needs to cancel pending navigations.
  void clearQueue() {
    print('🧭 Clearing ${_pending.length} pending navigation requests');
    _pending.clear();
  }

  /// Check if navigation is currently being processed.
  bool get isProcessing => _isProcessing;

  /// Get count of pending navigation requests.
  int get pendingCount => _pending.length;
}
