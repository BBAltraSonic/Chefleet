import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data service responsible for fetching vendor orders with buyer + item details.
class VendorOrdersService {
  VendorOrdersService(
    SupabaseClient supabaseClient, {
    VendorOrdersQueryRunner? queryRunner,
  }) : _ordersQueryRunner = queryRunner ?? SupabaseVendorOrdersQueryRunner(supabaseClient);

  final VendorOrdersQueryRunner _ordersQueryRunner;

  Future<List<Map<String, dynamic>>> fetchRecentOrders({
    required String vendorId,
    int limit = 50,
  }) async {
    try {
      return await _ordersQueryRunner.run(
        vendorId: vendorId,
        limit: limit,
        includeBuyer: true,
      );
    } on PostgrestException catch (e) {
      if (_isMissingBuyerRelationship(e)) {
        return _ordersQueryRunner.run(
          vendorId: vendorId,
          limit: limit,
          includeBuyer: false,
        );
      }
      rethrow;
    }
  }

  @visibleForTesting
  static bool _isMissingBuyerRelationship(PostgrestException exception) {
    final message = exception.message.toLowerCase();
    final details = exception.details?.toString().toLowerCase() ?? '';
    final hint = exception.hint?.toLowerCase() ?? '';

    return message.contains("could not find a relationship between 'orders' and 'users_public'") ||
        details.contains('orders_buyer_id_fkey') ||
        hint.contains("perhaps you meant 'users' instead of 'users_public'");
  }

  Future<Map<String, dynamic>> fetchDetailedAnalytics(String vendorId) {
    return _ordersQueryRunner.fetchDetailedAnalytics(vendorId);
  }

  Future<Map<String, dynamic>> fetchPerformanceMetrics(String vendorId) {
    return _ordersQueryRunner.fetchPerformanceMetrics(vendorId);
  }

  Future<List<Map<String, dynamic>>> fetchPopularItems(String vendorId) {
    return _ordersQueryRunner.fetchPopularItems(vendorId);
  }
}

abstract class VendorOrdersQueryRunner {
  Future<List<Map<String, dynamic>>> run({
    required String vendorId,
    required int limit,
    required bool includeBuyer,
  });

  Future<Map<String, dynamic>> fetchDetailedAnalytics(String vendorId);
  Future<Map<String, dynamic>> fetchPerformanceMetrics(String vendorId);
  Future<List<Map<String, dynamic>>> fetchPopularItems(String vendorId);
}

class SupabaseVendorOrdersQueryRunner implements VendorOrdersQueryRunner {
  SupabaseVendorOrdersQueryRunner(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  static const _withBuyerSelect = '''
          id,
          status,
          total_amount,
          pickup_code,
          created_at,
          updated_at,
          special_instructions,
          buyer:users_public!orders_buyer_id_fkey (
            id,
            full_name,
            phone
          ),
          items:order_items(
            id,
            quantity,
            unit_price,
            dishes(
              id,
              name,
              description
            )
          )
        ''';

  static const _fallbackSelect = '''
          id,
          status,
          total_amount,
          pickup_code,
          created_at,
          updated_at,
          special_instructions,
          items:order_items(
            id,
            quantity,
            unit_price,
            dishes(
              id,
              name,
              description
            )
          )
        ''';

  @override
  Future<List<Map<String, dynamic>>> run({
    required String vendorId,
    required int limit,
    required bool includeBuyer,
  }) async {
    final selectClause = includeBuyer ? _withBuyerSelect : _fallbackSelect;

    final response = await _supabaseClient
        .from('orders')
        .select(selectClause)
        .eq('vendor_id', vendorId)
        .order('created_at', ascending: false)
        .limit(limit);

    final data = List<Map<String, dynamic>>.from(response);

    if (!includeBuyer) {
      for (final order in data) {
        order.putIfAbsent('buyer', () => null);
      }
    }

    return data;
  }

  Future<Map<String, dynamic>> fetchDetailedAnalytics(String vendorId) async {
    // TODO: Replace with actual analytics query
    return {
      'total_orders': 150,
      'total_revenue': 15000, // in cents
      'completed_orders': 140,
      'cancelled_orders': 10,
      'status_counts': {
        'completed': 140,
        'cancelled': 8,
        'rejected': 2,
      },
      'daily_revenue': [
        {'date': '2024-01-01', 'revenue': 1200},
        {'date': '2024-01-02', 'revenue': 1500},
        {'date': '2024-01-03', 'revenue': 900},
        // ... more days
      ],
      'peak_hours': [
        {'hour': 12, 'order_count': 25},
        {'hour': 13, 'order_count': 30},
        {'hour': 18, 'order_count': 35},
        {'hour': 19, 'order_count': 28},
      ],
    };
  }

  Future<Map<String, dynamic>> fetchPerformanceMetrics(String vendorId) async {
    // TODO: Replace with actual performance query
    return {
      'avg_prep_time': 15,
      'on_time_rate': 95.5,
      'daily_average': 12.5,
    };
  }

  Future<List<Map<String, dynamic>>> fetchPopularItems(String vendorId) async {
    // TODO: Replace with actual popular items query
    return [
      {'dish_name': 'Burger', 'order_count': 45, 'total_revenue': 4500, 'category': 'Main Course'},
      {'dish_name': 'Pizza', 'order_count': 38, 'total_revenue': 3800, 'category': 'Main Course'},
      {'dish_name': 'Salad', 'order_count': 25, 'total_revenue': 1250, 'category': 'Salads'},
    ];
  }
}
