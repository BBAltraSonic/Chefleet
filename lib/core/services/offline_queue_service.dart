import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OfflineOperation {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
  final String? correlationId;

  OfflineOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.correlationId,
  });

  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'] as String,
      type: json['type'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
      retryCount: json['retry_count'] as int? ?? 0,
      correlationId: json['correlation_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'retry_count': retryCount,
      'correlation_id': correlationId,
    };
  }
}

class OfflineQueueService {
  final SharedPreferences _prefs;
  final SupabaseClient _client;
  static const String _queueKey = 'offline_queue';
  static const String _isOfflineKey = 'is_offline';
  static const int _maxRetries = 5;
  static const Duration _retryDelay = Duration(seconds: 5);

  bool _isProcessing = false;
  bool _isOffline = false;
  final StreamController<bool> _offlineStatusController = StreamController<bool>.broadcast();
  Timer? _syncTimer;
  Timer? _connectivityCheckTimer;

  OfflineQueueService(this._prefs, this._client) {
    _initializeConnectivityCheck();
  }

  Stream<bool> get offlineStatus => _offlineStatusController.stream;

  bool get isOffline => _isOffline;

  void updateConnectivity(bool isConnected) {
    _isOffline = !isConnected;
    _prefs.setBool(_isOfflineKey, _isOffline);
    _offlineStatusController.add(_isOffline);

    if (isConnected) {
      scheduleSync();
    }
  }

  Future<void> _initializeConnectivityCheck() async {
    _isOffline = _prefs.getBool(_isOfflineKey) ?? false;

    _connectivityCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnectivity(),
    );

    await _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    try {
      await _client.from('profiles').select('id').limit(1).maybeSingle();
      updateConnectivity(true);
    } catch (e) {
      updateConnectivity(false);
    }
  }

  Future<void> enqueueOperation(
    String type,
    Map<String, dynamic> data, {
    String? correlationId,
  }) async {
    final operation = OfflineOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      data: data,
      createdAt: DateTime.now(),
      correlationId: correlationId,
    );

    final queue = await _getQueue();
    queue.add(operation);
    await _saveQueue(queue);
  }

  Future<List<OfflineOperation>> _getQueue() async {
    try {
      final queueJson = _prefs.getString(_queueKey);
      if (queueJson == null) return [];

      final List<dynamic> decoded = jsonDecode(queueJson);
      return decoded
          .map((json) => OfflineOperation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveQueue(List<OfflineOperation> queue) async {
    final queueJson = jsonEncode(queue.map((op) => op.toJson()).toList());
    await _prefs.setString(_queueKey, queueJson);
  }

  Future<void> scheduleSync() async {
    if (_isProcessing) return;

    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 2), () => syncQueue());
  }

  Future<void> syncQueue() async {
    if (_isProcessing || isOffline) return;

    _isProcessing = true;

    try {
      final queue = await _getQueue();
      if (queue.isEmpty) {
        _isProcessing = false;
        return;
      }

      final remaining = <OfflineOperation>[];
      int synced = 0;

      for (final operation in queue) {
        try {
          final success = await _processOperation(operation);
          if (success) {
            synced++;
          } else {
            if (operation.retryCount < _maxRetries) {
              final updatedOp = OfflineOperation(
                id: operation.id,
                type: operation.type,
                data: operation.data,
                createdAt: operation.createdAt,
                retryCount: operation.retryCount + 1,
                correlationId: operation.correlationId,
              );
              remaining.add(updatedOp);
            }
          }
        } catch (e) {
          if (operation.retryCount < _maxRetries) {
            final updatedOp = OfflineOperation(
              id: operation.id,
              type: operation.type,
              data: operation.data,
              createdAt: operation.createdAt,
              retryCount: operation.retryCount + 1,
              correlationId: operation.correlationId,
            );
            remaining.add(updatedOp);
          }
        }

        await Future.delayed(_retryDelay);
      }

      await _saveQueue(remaining);
    } finally {
      _isProcessing = false;
    }
  }

  Future<bool> _processOperation(OfflineOperation operation) async {
    switch (operation.type) {
      case 'create_order':
        return await _createOrder(operation.data);
      case 'change_order_status':
        return await _changeOrderStatus(operation.data);
      case 'update_profile':
        return await _updateProfile(operation.data);
      case 'send_message':
        return await _sendMessage(operation.data);
      default:
        return false;
    }
  }

  Future<bool> _createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _client.functions.invoke(
        'create_order',
        body: data,
      );

      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _changeOrderStatus(Map<String, dynamic> data) async {
    try {
      final response = await _client.functions.invoke(
        'change_order_status',
        body: data,
      );

      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateProfile(Map<String, dynamic> data) async {
    try {
      final userId = data['user_id'] as String;
      final profileData = Map<String, dynamic>.from(data);
      profileData.remove('user_id');

      await _client
          .from('profiles')
          .update(profileData)
          .eq('id', userId);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _sendMessage(Map<String, dynamic> data) async {
    try {
      await _client.from('messages').insert(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getQueueLength() async {
    final queue = await _getQueue();
    return queue.length;
  }

  Future<void> clearQueue() async {
    await _saveQueue([]);
  }

  void dispose() {
    _syncTimer?.cancel();
    _connectivityCheckTimer?.cancel();
    _offlineStatusController.close();
  }
}

class OfflineQueueServiceSingleton {
  static OfflineQueueService? _instance;

  static Future<OfflineQueueService> getInstance() async {
    _instance ??= OfflineQueueService(
      await SharedPreferences.getInstance(),
      Supabase.instance.client,
    );
    return _instance!;
  }

  static OfflineQueueService get instance {
    if (_instance == null) {
      throw StateError('OfflineQueueService not initialized. Call getInstance() first.');
    }
    return _instance!;
  }
}
