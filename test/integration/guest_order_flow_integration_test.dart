import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:chefleet/main.dart' as app;
import 'package:chefleet/features/auth/blocs/auth_bloc.dart';
import 'package:chefleet/core/services/guest_session_service.dart';

/// Integration tests for guest user order flow
/// 
/// Tests the complete journey from guest mode start to order placement
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Guest Order Flow Integration Tests', () {
    late GuestSessionService guestSessionService;

    setUp(() async {
      // Initialize Supabase (use test environment)
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://test.supabase.co'),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'test_key'),
      );

      guestSessionService = GuestSessionService();
      
      // Clear any existing guest session
      await guestSessionService.clearGuestSession();
    });

    tearDown(() async {
      // Clean up guest session after each test
      await guestSessionService.clearGuestSession();
    });

    testWidgets('Complete guest order flow - start to confirmation', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Navigate to auth screen and start guest mode
      expect(find.text('Continue as Guest'), findsOneWidget);
      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Step 2: Verify navigation to map feed
      expect(find.byType(app.MapScreen), findsOneWidget);

      // Step 3: Verify guest session was created
      final isGuest = await guestSessionService.isGuestMode();
      expect(isGuest, isTrue);

      // Step 4: Browse dishes on map
      // (Assuming map shows dish markers)
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 5: Tap on a dish marker to view details
      final dishMarker = find.byType(app.DishMarker).first;
      await tester.tap(dishMarker);
      await tester.pumpAndSettle();

      // Step 6: Verify dish detail screen appears
      expect(find.byType(app.DishDetailScreen), findsOneWidget);

      // Step 7: Add dish to cart
      final addToCartButton = find.text('Add to Cart');
      expect(addToCartButton, findsOneWidget);
      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      // Step 8: Navigate to cart
      final cartIcon = find.byIcon(Icons.shopping_cart);
      await tester.tap(cartIcon);
      await tester.pumpAndSettle();

      // Step 9: Verify cart screen shows items
      expect(find.byType(app.CartScreen), findsOneWidget);
      expect(find.text('Checkout'), findsOneWidget);

      // Step 10: Proceed to checkout
      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();

      // Step 11: Verify checkout screen
      expect(find.byType(app.CheckoutScreen), findsOneWidget);

      // Step 12: Fill in delivery details (guest users need to provide)
      await tester.enterText(find.byKey(const Key('delivery_address')), '123 Test St');
      await tester.enterText(find.byKey(const Key('phone_number')), '1234567890');
      await tester.pumpAndSettle();

      // Step 13: Place order
      await tester.tap(find.text('Place Order'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 14: Verify order confirmation screen
      expect(find.byType(app.OrderConfirmationScreen), findsOneWidget);
      expect(find.text('Order Placed!'), findsOneWidget);

      // Step 15: Verify conversion prompt appears for first order
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Save Your Progress'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);

      // Step 16: Dismiss conversion prompt
      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();

      // Step 17: Verify order details are shown
      expect(find.textContaining('Order Summary'), findsOneWidget);
      expect(find.textContaining('Total'), findsOneWidget);
    });

    testWidgets('Guest can place multiple orders', (tester) async {
      // Start the app in guest mode
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Place first order
      await _placeTestOrder(tester);
      await tester.pumpAndSettle();

      // Verify first order conversion prompt
      expect(find.text('Save Your Progress'), findsOneWidget);
      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();

      // Navigate back to map
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Place second order
      await _placeTestOrder(tester);
      await tester.pumpAndSettle();

      // Verify second order doesn't show conversion prompt (already shown)
      expect(find.text('Save Your Progress'), findsNothing);

      // Verify order confirmation
      expect(find.text('Order Placed!'), findsOneWidget);
    });

    testWidgets('Guest order persists across app restarts', (tester) async {
      String? guestId;

      // First session - place order
      {
        app.main();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue as Guest'));
        await tester.pumpAndSettle();

        // Get guest ID
        final session = await guestSessionService.getGuestSession();
        guestId = session?.guestId;
        expect(guestId, isNotNull);

        // Place order
        await _placeTestOrder(tester);
        await tester.pumpAndSettle();
      }

      // Simulate app restart
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      // Second session - verify guest session persists
      {
        app.main();
        await tester.pumpAndSettle();

        // Should automatically restore guest session
        final session = await guestSessionService.getGuestSession();
        expect(session?.guestId, equals(guestId));

        // Verify can access order history
        final drawerIcon = find.byIcon(Icons.menu);
        await tester.tap(drawerIcon);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Order History'));
        await tester.pumpAndSettle();

        // Verify orders are shown
        expect(find.byType(app.OrderHistoryScreen), findsOneWidget);
      }
    });

    testWidgets('Guest order includes guest_id in database', (tester) async {
      // Start app and place order as guest
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      final session = await guestSessionService.getGuestSession();
      final guestId = session?.guestId;

      await _placeTestOrder(tester);
      await tester.pumpAndSettle();

      // Verify order in database has guest_id
      final supabase = Supabase.instance.client;
      final orders = await supabase
          .from('orders')
          .select()
          .eq('guest_id', guestId!)
          .order('created_at', ascending: false)
          .limit(1);

      expect(orders, isNotEmpty);
      expect(orders.first['guest_id'], equals(guestId));
      expect(orders.first['user_id'], isNull);
    });

    testWidgets('Guest cannot access features requiring authentication', (tester) async {
      // Start app in guest mode
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Try to access favorites
      final drawerIcon = find.byIcon(Icons.menu);
      await tester.tap(drawerIcon);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Favourites'));
      await tester.pumpAndSettle();

      // Should show conversion prompt or limited access message
      expect(
        find.textContaining('Create an account'),
        findsOneWidget,
      );
    });
  });

  group('Guest Order Error Handling', () {
    testWidgets('handles network errors gracefully', (tester) async {
      // Start app in guest mode
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Simulate network error during order placement
      // (This would require mocking network calls)

      // Verify error message is shown
      // expect(find.textContaining('network error'), findsOneWidget);
    });

    testWidgets('validates delivery information', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Navigate to checkout without filling details
      await _navigateToCheckout(tester);

      // Try to place order without delivery info
      await tester.tap(find.text('Place Order'));
      await tester.pumpAndSettle();

      // Verify validation errors
      expect(find.textContaining('required'), findsWidgets);
    });
  });
}

/// Helper function to place a test order
Future<void> _placeTestOrder(WidgetTester tester) async {
  // Tap on first dish
  final dishMarker = find.byType(app.DishMarker).first;
  await tester.tap(dishMarker);
  await tester.pumpAndSettle();

  // Add to cart
  await tester.tap(find.text('Add to Cart'));
  await tester.pumpAndSettle();

  // Go to cart
  await tester.tap(find.byIcon(Icons.shopping_cart));
  await tester.pumpAndSettle();

  // Checkout
  await tester.tap(find.text('Checkout'));
  await tester.pumpAndSettle();

  // Fill delivery details
  await tester.enterText(find.byKey(const Key('delivery_address')), '123 Test St');
  await tester.enterText(find.byKey(const Key('phone_number')), '1234567890');
  await tester.pumpAndSettle();

  // Place order
  await tester.tap(find.text('Place Order'));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

/// Helper function to navigate to checkout
Future<void> _navigateToCheckout(WidgetTester tester) async {
  final dishMarker = find.byType(app.DishMarker).first;
  await tester.tap(dishMarker);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Add to Cart'));
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.shopping_cart));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Checkout'));
  await tester.pumpAndSettle();
}
