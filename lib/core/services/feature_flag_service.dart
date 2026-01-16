import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeatureFlag {
  final String name;
  final String description;
  final bool enabled;
  final String environment;
  final String? userSegment;
  final int? rolloutPercentage;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeatureFlag({
    required this.name,
    required this.description,
    required this.enabled,
    required this.environment,
    this.userSegment,
    this.rolloutPercentage,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeatureFlag.fromJson(Map<String, dynamic> json) {
    return FeatureFlag(
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      enabled: json['enabled'] as bool,
      environment: json['environment'] as String,
      userSegment: json['user_segment'] as String?,
      rolloutPercentage: json['rollout_percentage'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'enabled': enabled,
      'environment': environment,
      'user_segment': userSegment,
      'rollout_percentage': rolloutPercentage,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class FeatureFlagService {
  final SupabaseClient _client;
  SharedPreferences? _prefs;
  static const String _cacheKey = 'feature_flags_cache';
  static const String _cacheTimestampKey = 'feature_flags_cache_timestamp';
  static const Duration _cacheValidity = Duration(minutes: 5);

  FeatureFlagService(this._client);

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw StateError('FeatureFlagService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  Future<List<FeatureFlag>> fetchAllFlags({bool forceRefresh = false}) async {
    try {
      final cacheTimestamp = _preferences.getInt(_cacheTimestampKey);
      final now = DateTime.now().millisecondsSinceEpoch;

      if (!forceRefresh &&
          cacheTimestamp != null &&
          (now - cacheTimestamp) < _cacheValidity.inMilliseconds) {
        final cachedFlags = _getCachedFlags();
        if (cachedFlags.isNotEmpty) {
          return cachedFlags;
        }
      }

      final response = await _client
          .from('feature_flags')
          .select()
          .eq('environment', 'production')
          .order('name');

      final flags = (response as List)
          .map((json) => FeatureFlag.fromJson(json as Map<String, dynamic>))
          .toList();

      await _cacheFlags(flags);

      return flags;
    } catch (e) {
      print('Error fetching feature flags: $e');
      return _getCachedFlags();
    }
  }

  Future<FeatureFlag?> fetchFlag(String name, {bool forceRefresh = false}) async {
    final flags = await fetchAllFlags(forceRefresh: forceRefresh);
    try {
      return flags.firstWhere((flag) => flag.name == name);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isEnabled(String name, {bool forceRefresh = false}) async {
    final flag = await fetchFlag(name, forceRefresh: forceRefresh);
    if (flag == null || !flag.enabled) {
      return false;
    }

    final userId = _client.auth.currentSession?.user?.id;
    final userSegments = _preferences != null ? _getUserSegments() : null;

    if (flag.userSegment != null) {
      if (userSegments == null || !userSegments.contains(flag.userSegment)) {
        return false;
      }
    }

    final rolloutPercentage = flag.rolloutPercentage;
    if (rolloutPercentage != null &&
        rolloutPercentage < 100 &&
        rolloutPercentage > 0) {
      if (userId == null) {
        return false;
      }

      final userHash = _hashUserId(userId);
      return userHash < rolloutPercentage;
    }

    return true;
  }

  Future<void> refreshCache() async {
    await fetchAllFlags(forceRefresh: true);
  }

  Future<void> clearCache() async {
    await _preferences.remove(_cacheKey);
    await _preferences.remove(_cacheTimestampKey);
  }

  Future<Map<String, bool>> getAllEnabledStatuses() async {
    final flags = await fetchAllFlags();
    final statuses = <String, bool>{};

    for (final flag in flags) {
      statuses[flag.name] = await isEnabled(flag.name);
    }

    return statuses;
  }

  Future<bool> isAnyEnabled(List<String> names) async {
    for (final name in names) {
      if (await isEnabled(name)) {
        return true;
      }
    }
    return false;
  }

  Future<bool> areAllEnabled(List<String> names) async {
    for (final name in names) {
      if (!await isEnabled(name)) {
        return false;
      }
    }
    return true;
  }

  List<FeatureFlag> _getCachedFlags() {
    try {
      final flagsJson = _preferences.getString(_cacheKey);
      if (flagsJson == null) return [];

      final List<dynamic> decoded = jsonDecode(flagsJson);
      return decoded
          .map((json) => FeatureFlag.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error reading cached flags: $e');
      return [];
    }
  }

  Future<void> _cacheFlags(List<FeatureFlag> flags) async {
    try {
      final flagsJson =
          jsonEncode(flags.map((flag) => flag.toJson()).toList());
      await _preferences.setString(_cacheKey, flagsJson);
      await _preferences.setInt(
          _cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching flags: $e');
    }
  }

  int _hashUserId(String userId) {
    final bytes = userId.codeUnits;
    var hash = 0;
    for (var i = 0; i < bytes.length; i++) {
      hash = ((hash << 5) - hash) + bytes[i];
      hash = hash & 0xffffffff;
    }
    return hash.abs() % 100;
  }

  List<String>? _getUserSegments() {
    try {
      final segmentsJson = _preferences.getString('user_segments');
      if (segmentsJson == null) return null;

      final List<dynamic> decoded = jsonDecode(segmentsJson);
      return decoded.map((s) => s as String).toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> setUserSegments(List<String> segments) async {
    try {
      await _preferences.setString('user_segments', jsonEncode(segments));
    } catch (e) {
      print('Error setting user segments: $e');
    }
  }
}

class FeatureFlagServiceSingleton {
  static FeatureFlagService? _instance;

  static Future<FeatureFlagService> getInstance() async {
    _instance ??= FeatureFlagService(Supabase.instance.client);
    await _instance!.initialize();
    return _instance!;
  }

  static FeatureFlagService get instance {
    if (_instance == null) {
      throw StateError('FeatureFlagService not initialized. Call getInstance() first.');
    }
    return _instance!;
  }
}
