import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_repository.dart';

class OrderRepository extends SupabaseRepository<Map<String, dynamic>> {
  OrderRepository(SupabaseClient client) : super(client) {
    tableName = 'orders';
  }

  @override
  Map<String, dynamic> fromMap(Map<String, dynamic> map) {
    return map;
  }

  @override
  Map<String, dynamic> toMap(Map<String, dynamic> item) {
    return item;
  }

  /// Calls an Edge Function with the given function name and data
  Future<Map<String, dynamic>> callEdgeFunction(
    String functionName,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client.functions.invoke(
        functionName,
        body: data,
      );

      if (response.data == null) {
        throw Exception('No response from Edge Function');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Exception _handleException(dynamic error) {
    // Custom exception handling for order operations
    if (error is FunctionException) {
      return Exception('Edge Function error: ${error.toString()}');
    } else if (error is PostgrestException) {
      return Exception('Database error: ${error.message}');
    } else if (error is AuthException) {
      return error;
    } else {
      return Exception('Order operation failed: ${error.toString()}');
    }
  }
}