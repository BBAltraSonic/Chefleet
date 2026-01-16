import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AnalyticsEvent {
  orderCreated,
  orderCancelled,
  orderCompleted,
  orderRetried,
  userSignedUp,
  userLoggedIn,
  userLoggedOut,
  guestModeActivated,
  guestModeConverted,
  featureFlagChecked,
  offlineModeActivated,
  offlineQueueSynced,
  screenViewed,
  vendorRegistered,
  vendorStatusChanged,
  dishCreated,
  dishUpdated,
  dishDeleted,
}

class AnalyticsService {
  final SharedPreferences _prefs;
  final SupabaseClient _client;
  static const String _eventsKey = 'analytics_events_queue';
  static const String _userIdKey = 'analytics_user_id';
  static const String _deviceIdKey = 'analytics_device_id';
  static const int _maxQueueSize = 100;

  AnalyticsService(this._prefs, this._client) {
    _initializeDeviceId();
  }

  String? get _userId => _prefs.getString(_userIdKey);
  String get _deviceId => _prefs.getString(_deviceIdKey) ?? '';

  void _initializeDeviceId() {
    if (!_prefs.containsKey(_deviceIdKey)) {
      final deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      _prefs.setString(_deviceIdKey, deviceId);
    }
  }

  void setUserId(String userId) {
    _prefs.setString(_userIdKey, userId);
  }

  void clearUserId() {
    _prefs.remove(_userIdKey);
  }

  Future<void> trackEvent(
    AnalyticsEvent event, {
    Map<String, dynamic>? properties,
    String? itemId,
    String? category,
  }) async {
    final eventData = {
      'event': event.name,
      'user_id': _userId,
      'device_id': _deviceId,
      'item_id': itemId,
      'category': category,
      'properties': properties ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };

    final queue = await _getEventQueue();
    queue.add(eventData);

    if (queue.length >= _maxQueueSize) {
      await flushEvents();
    } else {
      await _saveEventQueue(queue);
    }
  }

  Future<void> trackScreenView(String screenName) async {
    await trackEvent(
      AnalyticsEvent.screenViewed,
      properties: {'screen_name': screenName},
    );
  }

  Future<void> trackOrderCreated(String orderId, double totalAmount) async {
    await trackEvent(
      AnalyticsEvent.orderCreated,
      itemId: orderId,
      category: 'order',
      properties: {'total_amount': totalAmount},
    );
  }

  Future<void> trackVendorAction(
    String vendorId,
    String action,
    Map<String, dynamic>? details,
  ) async {
    await trackEvent(
      AnalyticsEvent.vendorStatusChanged,
      itemId: vendorId,
      category: 'vendor',
      properties: {'action': action, ...?details},
    );
  }

  Future<void> flushEvents() async {
    try {
      final queue = await _getEventQueue();
      if (queue.isEmpty) return;

      await _client.from('analytics_events').insert(queue);
      await _saveEventQueue([]);
    } catch (e) {
      print('Failed to flush analytics events: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getEventQueue() async {
    try {
      final eventsJson = _prefs.getString(_eventsKey);
      if (eventsJson == null) return [];

      final List<dynamic> decoded = jsonDecode(eventsJson);
      final result = decoded.map((e) => e as Map<String, dynamic>).toList();
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveEventQueue(List<Map<String, dynamic>> queue) async {
    try {
      final eventsJson = jsonEncode(queue);
      await _prefs.setString(_eventsKey, eventsJson);
    } catch (e) {
      print('Failed to save analytics queue: $e');
    }
  }

  Future<Map<String, dynamic>> getTodayMetrics() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final response = await _client
          .from('analytics_events')
          .select('*')
          .gte('timestamp', startOfDay.toIso8601String());

      final events = List<Map<String, dynamic>>.from(response);
      final metrics = <String, dynamic>{};

      for (final event in events) {
        final eventName = event['event'] as String;
        metrics[eventName] = (metrics[eventName] ?? 0) + 1;
      }

      return metrics;
    } catch (e) {
      print('Failed to fetch metrics: $e');
      return {};
    }
  }

  Future<void> clearQueue() async {
    await _saveEventQueue([]);
  }
}

class AnalyticsServiceSingleton {
  static AnalyticsService? _instance;

  static Future<AnalyticsService> getInstance() async {
    _instance ??= AnalyticsService(
      await SharedPreferences.getInstance(),
      Supabase.instance.client,
    );
    return _instance!;
  }

  static AnalyticsService get instance {
    if (_instance == null) {
      throw StateError('AnalyticsService not initialized. Call getInstance() first.');
    }
    return _instance!;
  }
}
