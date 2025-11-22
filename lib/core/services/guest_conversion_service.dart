import 'package:supabase_flutter/supabase_flutter.dart';
import 'guest_session_service.dart';

/// Service for converting guest accounts to registered user accounts
/// 
/// Handles the complete conversion flow including:
/// - Account creation
/// - Data migration (orders, messages)
/// - Session cleanup
class GuestConversionService {
  GuestConversionService({
    SupabaseClient? supabaseClient,
    GuestSessionService? guestSessionService,
  })  : _supabaseClient = supabaseClient ?? Supabase.instance.client,
        _guestSessionService = guestSessionService ?? GuestSessionService();

  final SupabaseClient _supabaseClient;
  final GuestSessionService _guestSessionService;

  /// Convert a guest session to a registered user account
  /// 
  /// This performs the following steps:
  /// 1. Creates a new auth.users account
  /// 2. Migrates guest data (orders, messages) to the new user
  /// 3. Clears the local guest session
  /// 
  /// Returns a [ConversionResult] with success status and details
  Future<ConversionResult> convertGuestToRegistered({
    required String guestId,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Step 1: Validate guest session exists and is not already converted
      final isValid = await _validateGuestSession(guestId);
      if (!isValid) {
        return ConversionResult(
          success: false,
          errorMessage: 'Invalid or already converted guest session',
        );
      }

      // Step 2: Create auth.users account
      final authResponse = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (authResponse.user == null) {
        return ConversionResult(
          success: false,
          errorMessage: 'Failed to create user account',
        );
      }

      final newUserId = authResponse.user!.id;

      // Step 3: Migrate guest data using edge function
      final migrationResult = await _migrateGuestData(
        guestId: guestId,
        newUserId: newUserId,
      );

      if (!migrationResult.success) {
        // Account was created but migration failed
        // Log the error but don't fail the conversion
        print('Warning: Data migration failed: ${migrationResult.errorMessage}');
      }

      // Step 4: Clear local guest session
      await _guestSessionService.clearGuestSession();

      return ConversionResult(
        success: true,
        userId: newUserId,
        ordersMigrated: migrationResult.ordersMigrated,
        messagesMigrated: migrationResult.messagesMigrated,
      );
    } on AuthException catch (e) {
      return ConversionResult(
        success: false,
        errorMessage: _formatAuthError(e),
      );
    } catch (e) {
      return ConversionResult(
        success: false,
        errorMessage: 'Conversion failed: ${e.toString()}',
      );
    }
  }

  /// Validate that a guest session exists and can be converted
  Future<bool> _validateGuestSession(String guestId) async {
    try {
      final session = await _supabaseClient
          .from('guest_sessions')
          .select('id, converted_to_user_id')
          .eq('guest_id', guestId)
          .maybeSingle();

      if (session == null) {
        return false;
      }

      // Check if already converted
      if (session['converted_to_user_id'] != null) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating guest session: $e');
      return false;
    }
  }

  /// Migrate guest data using the edge function
  Future<MigrationResult> _migrateGuestData({
    required String guestId,
    required String newUserId,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'migrate_guest_data',
        body: {
          'guest_id': guestId,
          'new_user_id': newUserId,
        },
      );

      final data = response.data as Map<String, dynamic>?;

      if (data == null) {
        return MigrationResult(
          success: false,
          errorMessage: 'No response from migration function',
        );
      }

      return MigrationResult(
        success: data['success'] == true,
        errorMessage: data['message'] as String?,
        ordersMigrated: data['orders_migrated'] as int? ?? 0,
        messagesMigrated: data['messages_migrated'] as int? ?? 0,
      );
    } catch (e) {
      return MigrationResult(
        success: false,
        errorMessage: 'Migration error: ${e.toString()}',
      );
    }
  }

  /// Get guest session statistics for conversion prompt
  Future<GuestSessionStats> getGuestSessionStats(String guestId) async {
    try {
      // Get order count
      final ordersResponse = await _supabaseClient
          .from('orders')
          .select('id')
          .eq('guest_user_id', guestId);

      final orderCount = (ordersResponse as List).length;

      // Get message count
      final messagesResponse = await _supabaseClient
          .from('messages')
          .select('id')
          .eq('guest_sender_id', guestId);

      final messageCount = (messagesResponse as List).length;

      // Get session info
      final sessionInfo = await _guestSessionService.getGuestSessionInfo(guestId);
      final createdAt = sessionInfo?['created_at'] != null
          ? DateTime.parse(sessionInfo!['created_at'] as String)
          : DateTime.now();

      return GuestSessionStats(
        orderCount: orderCount,
        messageCount: messageCount,
        sessionAge: DateTime.now().difference(createdAt),
      );
    } catch (e) {
      print('Error getting guest session stats: $e');
      return GuestSessionStats(
        orderCount: 0,
        messageCount: 0,
        sessionAge: Duration.zero,
      );
    }
  }

  /// Check if guest should be prompted to convert
  /// 
  /// Prompts are shown based on:
  /// - Number of orders placed
  /// - Time since first order
  /// - Number of messages sent
  bool shouldPromptConversion(GuestSessionStats stats) {
    // Prompt after first order
    if (stats.orderCount >= 1) {
      return true;
    }

    // Prompt after 5+ messages
    if (stats.messageCount >= 5) {
      return true;
    }

    // Prompt after 7 days of activity
    if (stats.sessionAge.inDays >= 7) {
      return true;
    }

    return false;
  }

  /// Format auth errors into user-friendly messages
  String _formatAuthError(AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.contains('already registered')) {
          return 'This email is already registered. Please sign in instead.';
        }
        return 'Invalid email or password format.';
      case '422':
        return 'Email is already in use. Please use a different email.';
      case '429':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Registration failed: ${e.message}';
    }
  }
}

/// Result of a guest-to-registered conversion
class ConversionResult {
  const ConversionResult({
    required this.success,
    this.userId,
    this.ordersMigrated = 0,
    this.messagesMigrated = 0,
    this.errorMessage,
  });

  final bool success;
  final String? userId;
  final int ordersMigrated;
  final int messagesMigrated;
  final String? errorMessage;

  bool get hasData => ordersMigrated > 0 || messagesMigrated > 0;
}

/// Result of data migration operation
class MigrationResult {
  const MigrationResult({
    required this.success,
    this.ordersMigrated = 0,
    this.messagesMigrated = 0,
    this.errorMessage,
  });

  final bool success;
  final int ordersMigrated;
  final int messagesMigrated;
  final String? errorMessage;
}

/// Statistics about a guest session
class GuestSessionStats {
  const GuestSessionStats({
    required this.orderCount,
    required this.messageCount,
    required this.sessionAge,
  });

  final int orderCount;
  final int messageCount;
  final Duration sessionAge;

  bool get hasActivity => orderCount > 0 || messageCount > 0;
}

/// Exception thrown when conversion operations fail
class ConversionException implements Exception {
  const ConversionException(this.message);

  final String message;

  @override
  String toString() => 'ConversionException: $message';
}
