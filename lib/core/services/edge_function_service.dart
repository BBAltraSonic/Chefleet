import 'package:supabase_flutter/supabase_flutter.dart';

/// Result type for edge function calls
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;
  
  const Result.success(this.data) : error = null, isSuccess = true;
  const Result.failure(this.error) : data = null, isSuccess = false;
  
  void when({
    required Function(T data) success,
    required Function(String error) failure,
  }) {
    if (isSuccess && data != null) {
      success(data!);
    } else if (error != null) {
      failure(error!);
    }
  }
}

/// Centralized service for calling Supabase edge functions with proper error handling
class EdgeFunctionService {
  final SupabaseClient _client;
  
  EdgeFunctionService(this._client);
  
  /// Generic method to invoke edge functions with type-safe parsing
  Future<Result<T>> invoke<T>({
    required String functionName,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    try {
      final response = await _client.functions.invoke(
        functionName,
        body: body,
      );
      
      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] == true) {
        return Result.success(parser(data));
      } else {
        return Result.failure(data['error'] ?? 'Unknown error');
      }
    } on FunctionException catch (e) {
      return Result.failure('Function error: ${e.details}');
    } catch (e) {
      return Result.failure('Network error: $e');
    }
  }
  
  /// Create a new order
  Future<Result<Map<String, dynamic>>> createOrder({
    required String vendorId,
    required List<Map<String, dynamic>> items,
    required String pickupTime,
    String? specialInstructions,
    String? guestUserId,
  }) {
    return invoke(
      functionName: 'create_order',
      body: {
        'vendor_id': vendorId,
        'items': items,
        'pickup_time': pickupTime,
        if (specialInstructions != null) 'special_instructions': specialInstructions,
        if (guestUserId != null) 'guest_user_id': guestUserId,
        'idempotency_key': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      parser: (data) => data,
    );
  }
  
  /// Change order status
  Future<Result<Map<String, dynamic>>> changeOrderStatus({
    required String orderId,
    required String newStatus,
    String? reason,
    String? pickupCode,
  }) {
    return invoke(
      functionName: 'change_order_status',
      body: {
        'order_id': orderId,
        'new_status': newStatus,
        if (reason != null) 'reason': reason,
        if (pickupCode != null) 'pickup_code': pickupCode,
      },
      parser: (data) => data,
    );
  }
  
  /// Generate pickup code for an order
  Future<Result<Map<String, dynamic>>> generatePickupCode({
    required String orderId,
  }) {
    return invoke(
      functionName: 'generate_pickup_code',
      body: {
        'order_id': orderId,
      },
      parser: (data) => data,
    );
  }
  
  /// Migrate guest data to registered user
  Future<Result<Map<String, dynamic>>> migrateGuestData({
    required String guestId,
    required String newUserId,
  }) {
    return invoke(
      functionName: 'migrate_guest_data',
      body: {
        'guest_id': guestId,
        'new_user_id': newUserId,
      },
      parser: (data) => data,
    );
  }
  
  /// Report a user
  Future<Result<Map<String, dynamic>>> reportUser({
    required String reportedUserId,
    required String reason,
    String? details,
  }) {
    return invoke(
      functionName: 'report_user',
      body: {
        'reported_user_id': reportedUserId,
        'reason': reason,
        if (details != null) 'details': details,
      },
      parser: (data) => data,
    );
  }
  
  /// Send push notification
  Future<Result<Map<String, dynamic>>> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return invoke(
      functionName: 'send_push',
      body: {
        'user_id': userId,
        'title': title,
        'body': body,
        if (data != null) 'data': data,
      },
      parser: (data) => data,
    );
  }
  
  /// Get signed URL for image upload
  Future<Result<Map<String, dynamic>>> getUploadSignedUrl({
    required String bucket,
    required String path,
  }) {
    return invoke(
      functionName: 'upload_image_signed_url',
      body: {
        'bucket': bucket,
        'path': path,
      },
      parser: (data) => data,
    );
  }
}
