import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:chefleet/core/models/order_model.dart';
import 'package:chefleet/core/models/message_model.dart';
import 'package:chefleet/core/models/dish_model.dart';
import 'package:chefleet/core/models/vendor_model.dart';
import 'package:chefleet/core/services/guest_session_service.dart';

/// Integration tests to validate schema alignment between:
/// - Flutter models
/// - Edge functions
/// - Database schema
/// 
/// These tests verify that all schema mismatches from Phase 1-4 are fixed
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Schema Validation Tests', () {
    late SupabaseClient supabase;
    late GuestSessionService guestSessionService;
    String? testGuestId;
    String? testVendorId;
    String? testDishId;

    setUpAll(() async {
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL'),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      );

      supabase = Supabase.instance.client;
      guestSessionService = GuestSessionService();

      // Get test data IDs
      final vendors = await supabase
          .from('vendors')
          .select('id')
          .eq('is_active', true)
          .limit(1);
      
      if (vendors.isNotEmpty) {
        testVendorId = vendors.first['id'];
        
        final dishes = await supabase
            .from('dishes')
            .select('id')
            .eq('vendor_id', testVendorId!)
            .eq('is_available', true)
            .limit(1);
        
        if (dishes.isNotEmpty) {
          testDishId = dishes.first['id'];
        }
      }
    });

    setUp(() async {
      // Create fresh guest session for each test
      await guestSessionService.clearGuestSession();
      testGuestId = await guestSessionService.getOrCreateGuestId();
    });

    tearDown(() async {
      // Clean up test data
      if (testGuestId != null) {
        await guestSessionService.clearGuestSession();
      }
    });

    test('Order model matches database schema', () async {
      print('🧪 Testing Order model schema alignment');

      // Skip if no test data available
      if (testVendorId == null || testDishId == null) {
        print('⚠️  Skipping: No test vendor/dish data available');
        return;
      }

      // Create order via edge function
      final response = await supabase.functions.invoke(
        'create_order',
        body: {
          'guest_user_id': testGuestId,
          'vendor_id': testVendorId,
          'items': [
            {
              'dish_id': testDishId,
              'quantity': 1,
              'price_at_purchase': 10.00,
            }
          ],
          'estimated_fulfillment_time': DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),
          'pickup_address': 'Test Address',
          'idempotency_key': 'test_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      expect(response.status, equals(200));
      final orderData = response.data['order'];
      expect(orderData, isNotNull);

      print('✓ Order created via edge function');

      // Fetch order from database
      final dbOrder = await supabase
          .from('orders')
          .select()
          .eq('id', orderData['id'])
          .single();

      expect(dbOrder, isNotNull);
      print('✓ Order fetched from database');

      // Parse into Order model
      final order = Order.fromJson(dbOrder);

      // Verify all critical fields are present and correctly mapped
      expect(order.id, equals(orderData['id']));
      expect(order.vendorId, equals(testVendorId));
      expect(order.guestUserId, equals(testGuestId));
      expect(order.buyerId, isNull); // Guest order
      expect(order.status, isNotNull);
      expect(order.totalAmount, isNotNull);
      expect(order.totalCents, isNotNull);
      expect(order.subtotalCents, isNotNull,
          reason: 'subtotal_cents should be stored for auditing and totals');
      final subtotalCents = order.subtotalCents ?? 0;
      expect(order.taxCents, equals(0));
      expect(order.deliveryFeeCents, equals(0));
      expect(order.serviceFeeCents, equals(0));
      expect(order.tipCents, equals(0));
      expect(
        order.totalCents,
        equals(
          subtotalCents +
              order.taxCents +
              order.deliveryFeeCents +
              order.serviceFeeCents +
              order.tipCents,
        ),
        reason: 'total_cents should be generated from component fields',
      );
      expect(order.estimatedFulfillmentTime, isNotNull);
      expect(order.pickupAddress, equals('Test Address'));
      expect(order.createdAt, isNotNull);
      expect(order.updatedAt, isNotNull);

      print('✓ Order model correctly maps all database fields');

      // Test toJson() produces correct column names
      final json = order.toJson();
      expect(json.containsKey('vendor_id'), isTrue);
      expect(json.containsKey('guest_user_id'), isTrue);
      expect(json.containsKey('total_amount'), isTrue);
      expect(json.containsKey('total_cents'), isTrue);
      expect(json.containsKey('subtotal_cents'), isTrue);
      expect(json.containsKey('estimated_fulfillment_time'), isTrue);
      expect(json.containsKey('pickup_address'), isTrue);
      
      // Verify no incorrect column names
      expect(json.containsKey('pickup_time'), isFalse); // Old incorrect name
      expect(json.containsKey('delivery_address'), isFalse); // Old incorrect name

      print('✓ Order.toJson() produces correct column names');
    });

    test('OrderItem model matches database schema', () async {
      print('🧪 Testing OrderItem model schema alignment');

      if (testVendorId == null || testDishId == null) {
        print('⚠️  Skipping: No test vendor/dish data available');
        return;
      }

      // Create order with items
      final response = await supabase.functions.invoke(
        'create_order',
        body: {
          'guest_user_id': testGuestId,
          'vendor_id': testVendorId,
          'items': [
            {
              'dish_id': testDishId,
              'quantity': 2,
              'price_at_purchase': 15.50,
              'customization_note': 'Extra spicy',
            }
          ],
          'estimated_fulfillment_time': DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),
          'pickup_address': 'Test Address',
          'idempotency_key': 'test_items_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      expect(response.status, equals(200));
      final orderId = response.data['order']['id'];

      // Fetch order items from database
      final dbItems = await supabase
          .from('order_items')
          .select()
          .eq('order_id', orderId);

      expect(dbItems, isNotEmpty);
      print('✓ Order items fetched from database');

      // Parse into OrderItem models
      final items = dbItems.map((json) => OrderItem.fromJson(json)).toList();
      final item = items.first;

      // Verify all fields
      expect(item.id, isNotNull);
      expect(item.orderId, equals(orderId));
      expect(item.dishId, equals(testDishId));
      expect(item.quantity, equals(2));
      expect(item.unitPrice, equals(15.50));
      expect(item.specialInstructions, equals('Extra spicy'));
      expect(item.createdAt, isNotNull);

      print('✓ OrderItem model correctly maps all database fields');

      // Test toJson()
      final json = item.toJson();
      expect(json.containsKey('order_id'), isTrue);
      expect(json.containsKey('dish_id'), isTrue);
      expect(json.containsKey('unit_price'), isTrue);
      expect(json.containsKey('special_instructions'), isTrue);

      print('✓ OrderItem.toJson() produces correct column names');
    });

    test('Message model matches database schema with guest support', () async {
      print('🧪 Testing Message model schema alignment');

      if (testVendorId == null || testDishId == null) {
        print('⚠️  Skipping: No test vendor/dish data available');
        return;
      }

      // Create an order to satisfy NOT NULL order_id constraint
      final orderResponse = await supabase.functions.invoke(
        'create_order',
        body: {
          'guest_user_id': testGuestId,
          'vendor_id': testVendorId,
          'items': [
            {
              'dish_id': testDishId,
              'quantity': 1,
              'price_at_purchase': 12.5,
            }
          ],
          'estimated_fulfillment_time': DateTime.now()
              .add(const Duration(minutes: 30))
              .toIso8601String(),
          'pickup_address': 'Message Test Address',
          'idempotency_key': 'test_message_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      expect(orderResponse.status, equals(200));
      final testOrderId = orderResponse.data['order']['id'] as String;

      // Create a message as guest user
      final messageData = {
        'order_id': testOrderId,
        'sender_id': null,
        'guest_sender_id': testGuestId,
        'sender_type': 'buyer',
        'message_type': 'text',
        'content': 'Test message from guest',
        'is_read': false,
      };

      final dbMessage = await supabase
          .from('messages')
          .insert(messageData)
          .select()
          .single();

      expect(dbMessage, isNotNull);
      print('✓ Message created in database');

      // Parse into Message model
      final message = Message.fromJson(dbMessage);

      // Verify all fields including guest support
      expect(message.id, isNotNull);
      expect(message.orderId, equals(testOrderId));
      expect(message.senderId, isNull); // Guest message
      expect(message.guestSenderId, equals(testGuestId));
      expect(message.senderType, equals('buyer'));
      expect(message.messageType, equals('text'));
      expect(message.content, equals('Test message from guest'));
      expect(message.isRead, isFalse);
      expect(message.createdAt, isNotNull);

      print('✓ Message model correctly maps all database fields');

      // Test toJson()
      final json = message.toJson();
      expect(json.containsKey('order_id'), isTrue);
      expect(json.containsKey('guest_sender_id'), isTrue);
      expect(json.containsKey('sender_type'), isTrue);
      expect(json.containsKey('message_type'), isTrue);
      expect(json.containsKey('content'), isTrue);
      expect(json.containsKey('is_read'), isTrue);
      
      // Verify no incorrect column names
      expect(json.containsKey('sender_role'), isFalse); // Old incorrect name

      print('✓ Message.toJson() produces correct column names');
    });

    test('Guest session creation includes all required fields', () async {
      print('🧪 Testing guest session schema');

      final session = await guestSessionService.getGuestSession();
      expect(session, isNotNull);

      // Verify session in database
      final dbSession = await supabase
          .from('guest_sessions')
          .select()
          .eq('guest_id', session!.guestId)
          .single();

      expect(dbSession, isNotNull);
      expect(dbSession['guest_id'], startsWith('guest_'));
      expect(dbSession['created_at'], isNotNull);
      expect(dbSession['last_active_at'], isNotNull);
      expect(dbSession['expires_at'], isNotNull);

      print('✓ Guest session has all required fields');
    });

    test('Dish model matches database schema', () async {
      print('🧪 Testing Dish model schema alignment');

      if (testDishId == null) {
        print('⚠️  Skipping: No test dish data available');
        return;
      }

      // Fetch dish from database
      final dbDish = await supabase
          .from('dishes')
          .select()
          .eq('id', testDishId!)
          .single();

      expect(dbDish, isNotNull);

      // Parse into Dish model
      final dish = Dish.fromJson(dbDish);

      // Verify all fields
      expect(dish.id, equals(testDishId));
      expect(dish.vendorId, isNotNull);
      expect(dish.name, isNotNull);
      expect(dish.price, isNotNull);
      expect(dish.priceCents, isNotNull);
      expect(dish.isAvailable, isNotNull);
      expect(dish.createdAt, isNotNull);

      print('✓ Dish model correctly maps all database fields');

      // Test toJson()
      final json = dish.toJson();
      expect(json.containsKey('vendor_id'), isTrue);
      expect(json.containsKey('price_cents'), isTrue);
      expect(json.containsKey('is_available'), isTrue);

      print('✓ Dish.toJson() produces correct column names');
    });

    test('Vendor model matches database schema', () async {
      print('🧪 Testing Vendor model schema alignment');

      if (testVendorId == null) {
        print('⚠️  Skipping: No test vendor data available');
        return;
      }

      // Fetch vendor from database
      final dbVendor = await supabase
          .from('vendors')
          .select()
          .eq('id', testVendorId!)
          .single();

      expect(dbVendor, isNotNull);

      // Parse into Vendor model
      final vendor = Vendor.fromJson(dbVendor);

      // Verify all fields
      expect(vendor.id, equals(testVendorId));
      expect(vendor.ownerId, isNotNull);
      expect(vendor.businessName, isNotNull);
      expect(vendor.isActive, isNotNull);
      expect(vendor.createdAt, isNotNull);

      print('✓ Vendor model correctly maps all database fields');

      // Test toJson()
      final json = vendor.toJson();
      expect(json.containsKey('owner_id'), isTrue);
      expect(json.containsKey('business_name'), isTrue);
      expect(json.containsKey('is_active'), isTrue);

      print('✓ Vendor.toJson() produces correct column names');
    });

    test('Order status transitions work correctly', () async {
      print('🧪 Testing order status transitions');

      if (testVendorId == null || testDishId == null) {
        print('⚠️  Skipping: No test vendor/dish data available');
        return;
      }

      // Create order
      final createResponse = await supabase.functions.invoke(
        'create_order',
        body: {
          'guest_user_id': testGuestId,
          'vendor_id': testVendorId,
          'items': [
            {
              'dish_id': testDishId,
              'quantity': 1,
              'price_at_purchase': 10.00,
            }
          ],
          'estimated_fulfillment_time': DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),
          'pickup_address': 'Test Address',
          'idempotency_key': 'test_status_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      expect(createResponse.status, equals(200));
      final orderId = createResponse.data['order']['id'];

      print('✓ Order created');

      // Verify order_status_history entry was created
      final historyEntries = await supabase
          .from('order_status_history')
          .select()
          .eq('order_id', orderId);

      expect(historyEntries, isNotEmpty);
      expect(historyEntries.first['new_status'], equals('pending'));

      print('✓ Order status history tracks status changes');
    });

    test('All NOT NULL constraints are satisfied', () async {
      print('🧪 Testing NOT NULL constraint compliance');

      if (testVendorId == null || testDishId == null) {
        print('⚠️  Skipping: No test vendor/dish data available');
        return;
      }

      // Create order with all required fields
      final response = await supabase.functions.invoke(
        'create_order',
        body: {
          'guest_user_id': testGuestId,
          'vendor_id': testVendorId,
          'items': [
            {
              'dish_id': testDishId,
              'quantity': 1,
              'price_at_purchase': 10.00,
            }
          ],
          'estimated_fulfillment_time': DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),
          'pickup_address': 'Test Address',
          'idempotency_key': 'test_notnull_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      expect(response.status, equals(200));
      final orderId = response.data['order']['id'];

      // Fetch order and verify all NOT NULL fields are present
      final order = await supabase
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();

      // Critical NOT NULL fields from schema
      expect(order['id'], isNotNull);
      expect(order['vendor_id'], isNotNull);
      expect(order['status'], isNotNull);
      expect(order['total_amount'], isNotNull); // This was missing before!
      expect(order['total_cents'], isNotNull);
      expect(order['estimated_fulfillment_time'], isNotNull);
      expect(order['created_at'], isNotNull);
      expect(order['updated_at'], isNotNull);

      print('✓ All NOT NULL constraints satisfied');
    });
  });
}
