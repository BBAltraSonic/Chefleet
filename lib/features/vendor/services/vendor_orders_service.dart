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
}

abstract class VendorOrdersQueryRunner {
  Future<List<Map<String, dynamic>>> run({
    required String vendorId,
    required int limit,
    required bool includeBuyer,
  });
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
}
