import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Service for managing guest user sessions
/// 
/// Guest sessions allow users to browse and order without authentication.
/// Sessions are stored locally and can be converted to registered accounts.
class GuestSessionService {
  GuestSessionService({
    FlutterSecureStorage? secureStorage,
    SupabaseClient? supabaseClient,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _supabaseClient = supabaseClient ?? Supabase.instance.client;

  final FlutterSecureStorage _secureStorage;
  final SupabaseClient _supabaseClient;

  static const String _guestIdKey = 'guest_session_id';
  static const String _guestCreatedAtKey = 'guest_session_created_at';
  static const String _guestPrefix = 'guest_';

  /// Get existing guest ID or create a new one
  /// 
  /// Returns a guest ID in format: guest_[uuid]
  /// The ID is persisted in secure local storage
  Future<String> getOrCreateGuestId() async {
    try {
      // Check for existing guest ID
      String? guestId = await _secureStorage.read(key: _guestIdKey);

      if (guestId != null && guestId.isNotEmpty) {
        // Validate format
        if (guestId.startsWith(_guestPrefix)) {
          return guestId;
        }
      }

      // Create new guest ID
      guestId = '$_guestPrefix${const Uuid().v4()}';
      
      // Store locally
      await _secureStorage.write(key: _guestIdKey, value: guestId);
      await _secureStorage.write(
        key: _guestCreatedAtKey,
        value: DateTime.now().toIso8601String(),
      );

      // Create guest session in database
      await _createGuestSession(guestId);

      return guestId;
    } catch (e) {
      throw GuestSessionException('Failed to get or create guest ID: $e');
    }
  }

  /// Get the current guest session if it exists
  Future<GuestSession?> getGuestSession() async {
    try {
      final guestId = await _secureStorage.read(key: _guestIdKey);
      if (guestId == null || guestId.isEmpty) {
        return null;
      }

      final createdAtStr = await _secureStorage.read(key: _guestCreatedAtKey);
      final createdAt = createdAtStr != null
          ? DateTime.parse(createdAtStr)
          : DateTime.now();

      return GuestSession(
        guestId: guestId,
        createdAt: createdAt,
      );
    } catch (e) {
      throw GuestSessionException('Failed to get guest session: $e');
    }
  }

  /// Check if currently in guest mode
  Future<bool> isGuestMode() async {
    final guestId = await _secureStorage.read(key: _guestIdKey);
    return guestId != null && guestId.isNotEmpty;
  }

  /// Clear the guest session from local storage
  /// 
  /// This should be called after successful conversion to registered account
  Future<void> clearGuestSession() async {
    try {
      await _secureStorage.delete(key: _guestIdKey);
      await _secureStorage.delete(key: _guestCreatedAtKey);
    } catch (e) {
      throw GuestSessionException('Failed to clear guest session: $e');
    }
  }

  /// Validate that a guest session exists in the database
  Future<bool> validateGuestSession(String guestId) async {
    try {
      final response = await _supabaseClient
          .from('guest_sessions')
          .select('id')
          .eq('guest_id', guestId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw GuestSessionException('Failed to validate guest session: $e');
    }
  }

  /// Create a guest session record in the database
  Future<void> _createGuestSession(String guestId) async {
    try {
      // Check if session already exists
      final existing = await _supabaseClient
          .from('guest_sessions')
          .select('id')
          .eq('guest_id', guestId)
          .maybeSingle();

      if (existing != null) {
        // Update last_active_at
        await _supabaseClient
            .from('guest_sessions')
            .update({'last_active_at': DateTime.now().toIso8601String()})
            .eq('guest_id', guestId);
        return;
      }

      // Create new session
      await _supabaseClient.from('guest_sessions').insert({
        'guest_id': guestId,
        'device_info': {
          'platform': 'flutter',
          'created_at': DateTime.now().toIso8601String(),
        },
        'last_active_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Don't throw if database insert fails - guest can still function locally
      print('Warning: Failed to create guest session in database: $e');
    }
  }

  /// Update the last active timestamp for the guest session
  Future<void> updateLastActive(String guestId) async {
    try {
      await _supabaseClient
          .from('guest_sessions')
          .update({'last_active_at': DateTime.now().toIso8601String()})
          .eq('guest_id', guestId);
    } catch (e) {
      // Non-critical error, just log it
      print('Warning: Failed to update guest session activity: $e');
    }
  }

  /// Get guest session info from database
  Future<Map<String, dynamic>?> getGuestSessionInfo(String guestId) async {
    try {
      final response = await _supabaseClient
          .from('guest_sessions')
          .select('*')
          .eq('guest_id', guestId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw GuestSessionException('Failed to get guest session info: $e');
    }
  }
}

/// Represents a guest user session
class GuestSession {
  const GuestSession({
    required this.guestId,
    required this.createdAt,
    this.deviceInfo,
    this.lastActiveAt,
    this.convertedToUserId,
    this.convertedAt,
  });

  final String guestId;
  final DateTime createdAt;
  final Map<String, dynamic>? deviceInfo;
  final DateTime? lastActiveAt;
  final String? convertedToUserId;
  final DateTime? convertedAt;

  bool get isConverted => convertedToUserId != null;

  factory GuestSession.fromJson(Map<String, dynamic> json) {
    return GuestSession(
      guestId: json['guest_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      deviceInfo: json['device_info'] as Map<String, dynamic>?,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      convertedToUserId: json['converted_to_user_id'] as String?,
      convertedAt: json['converted_at'] != null
          ? DateTime.parse(json['converted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guest_id': guestId,
      'created_at': createdAt.toIso8601String(),
      'device_info': deviceInfo,
      'last_active_at': lastActiveAt?.toIso8601String(),
      'converted_to_user_id': convertedToUserId,
      'converted_at': convertedAt?.toIso8601String(),
    };
  }
}

/// Exception thrown when guest session operations fail
class GuestSessionException implements Exception {
  const GuestSessionException(this.message);

  final String message;

  @override
  String toString() => 'GuestSessionException: $message';
}
