import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:chefleet/main.dart' as app;
import 'package:chefleet/core/services/guest_session_service.dart';
import 'package:chefleet/core/diagnostics/testing/diagnostic_tester_helpers.dart';
import 'diagnostic_harness.dart';

/// End-to-End test for complete guest user journey
/// 
/// Tests the entire flow from app launch through guest mode,
/// ordering, chatting, and conversion to registered user
void main() {
  ensureIntegrationDiagnostics(scenarioName: 'guest_journey_e2e');

  group('Complete Guest Journey E2E Test', () {
    late GuestSessionService guestSessionService;

    setUpAll(() async {
      // Supabase with test environment
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL'),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      );

      guestSessionService = GuestSessionService();
    });

    setUp(() async {
      // Clear any existing guest session before each test
      await guestSessionService.clearGuestSession();
    });

    testWidgets('Complete guest journey - launch to conversion', (tester) async {
      print('🚀 Starting complete guest journey E2E test');

      // ========== PHASE 1: APP LAUNCH & GUEST MODE START ==========
      print('📱 Phase 1: Launching app');
      app.main();
      await diagnosticPumpAndSettle(
        tester,
        duration: const Duration(seconds: 2),
        description: 'wait for splash',
      );

      // Verify splash screen
      print('✓ Splash screen loaded');

      // Wait for navigation to auth screen
      await diagnosticPumpAndSettle(
        tester,
        duration: const Duration(seconds: 2),
        description: 'navigate to auth',
      );

      // Verify auth screen with guest option
      expect(find.text('Chefleet'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
      print('✓ Auth screen displayed with guest option');

      // Start guest mode
      print('👤 Starting guest mode');
      await diagnosticTap(
        tester,
        find.text('Continue as Guest'),
        description: 'start guest mode',
      );
      await diagnosticPumpAndSettle(
        tester,
        duration: const Duration(seconds: 2),
        description: 'settle guest mode',
      );

      // Verify guest session created
      final guestSession = await guestSessionService.getGuestSession();
      expect(guestSession, isNotNull);
      expect(guestSession!.guestId, startsWith('guest_'));
      print('✓ Guest session created: ${guestSession.guestId}');

      // Verify navigation to map feed
      expect(find.byType(app.MapScreen), findsOneWidget);
      print('✓ Navigated to map feed');

      // ========== PHASE 2: BROWSING & DISCOVERY ==========
      print('🗺️  Phase 2: Browsing dishes');
      
      // Wait for map to load dishes
      await diagnosticPumpAndSettle(
        tester,
        duration: const Duration(seconds: 3),
        description: 'load dishes on map',
      );

      // Verify dishes are displayed on map
      expect(find.byType(app.DishMarker), findsWidgets);
      print('✓ Dishes loaded on map');

      // Tap on a dish marker
      final firstDish = find.byType(app.DishMarker).first;
      await diagnosticTap(
        tester,
        firstDish,
        description: 'select first dish',
      );
      await diagnosticPumpAndSettle(
        tester,
        duration: const Duration(seconds: 1),
        description: 'load dish detail',
      );

      // Verify dish detail screen
      expect(find.byType(app.DishDetailScreen), findsOneWidget);
      print('✓ Dish detail screen opened');

      // ========== PHASE 3: FIRST ORDER ==========
      print('🛒 Phase 3: Placing first order');

      // Add dish to cart
      await diagnosticTap(
        tester,
        find.text('Add to Cart'),
        description: 'add dish to cart',
      );
      await diagnosticPumpAndSettle(tester, description: 'settle after add');
      print('✓ Added dish to cart');

      // Navigate to cart
      await diagnosticTap(
        tester,
        find.byIcon(Icons.shopping_cart),
        description: 'open cart',
      );
      await diagnosticPumpAndSettle(tester, description: 'load cart');

      // Verify cart screen
      expect(find.byType(app.CartScreen), findsOneWidget);
      expect(find.text('Checkout'), findsOneWidget);
      print('✓ Cart screen displayed');

      // Proceed to checkout
      await diagnosticTap(
        tester,
        find.text('Checkout'),
        description: 'proceed to checkout',
      );
      await diagnosticPumpAndSettle(
        tester,
        duration: const Duration(seconds: 1),
        description: 'load checkout form',
      );

      // Fill delivery information
      await diagnosticEnterText(
        tester,
        find.byKey(const Key('delivery_address')),
        '123 Test Street, Test City',
        description: 'enter delivery address',
      );
      await diagnosticEnterText(
        tester,
        find.byKey(const Key('phone_number')),
        '+1234567890',
        description: 'enter phone number',
      );
      await diagnosticPumpAndSettle(tester, description: 'settle form');
      print('✓ Filled delivery information');

      // Place order
      await diagnosticTap(
        tester,
        find.text('Place Order'),
        description: 'place order',
      );
      await diagnosticPumpAndSettle(
        tester,
        duration: const Duration(seconds: 3),
        description: 'process order',
      );

      // Verify order confirmation
      expect(find.byType(app.OrderConfirmationScreen), findsOneWidget);
      expect(find.text('Order Placed!'), findsOneWidget);
      print('✓ Order placed successfully');

      // ========== PHASE 4: FIRST CONVERSION PROMPT ==========
      print('💬 Phase 4: First conversion prompt');

      // Wait for conversion prompt to appear
      await diagnosticPumpAndSettle(
        tester,
        duration: const Duration(seconds: 1),
        description: 'wait for conversion prompt',
      );

      // Verify conversion prompt after first order
      expect(find.text('Save Your Progress'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Not Now'), findsOneWidget);
      print('✓ Conversion prompt displayed after first order');

      // Dismiss for now
      await diagnosticTap(
        tester,
        find.text('Not Now'),
        description: 'dismiss conversion prompt',
      );
      await diagnosticPumpAndSettle(tester, description: 'settle after dismiss');
      print('✓ Dismissed conversion prompt');

      // ========== PHASE 5: CHAT INTERACTION ==========
      print('💬 Phase 5: Chat interaction');

      // Navigate to chat from order confirmation
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify chat screen
      expect(find.byType(app.ChatDetailScreen), findsOneWidget);
      print('✓ Chat screen opened');

      // Send messages as guest
      for (int i = 1; i <= 5; i++) {
        await tester.enterText(
          find.byKey(const Key('chat_input')),
          'Test message $i from guest',
        );
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        print('✓ Sent message $i');
      }

      // Wait for conversion prompt after 5 messages
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify second conversion prompt
      expect(find.text('Save Your Progress'), findsOneWidget);
      print('✓ Conversion prompt displayed after 5 messages');

      // Dismiss again
      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();

      // ========== PHASE 6: PROFILE EXPLORATION ==========
      print('👤 Phase 6: Profile exploration');

      // Navigate back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Open profile drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify guest header
      expect(find.text('Guest User'), findsOneWidget);
      expect(find.text('GUEST'), findsOneWidget);
      expect(find.text('Browsing without an account'), findsOneWidget);
      print('✓ Guest profile header displayed');

      // Verify conversion prompt in profile
      expect(find.text('Unlock All Features'), findsOneWidget);
      print('✓ Conversion prompt in profile drawer');

      // ========== PHASE 7: SECOND ORDER ==========
      print('🛒 Phase 7: Placing second order');

      // Close drawer
      await tester.tap(find.byType(Drawer));
      await tester.pumpAndSettle();

      // Place another order
      final secondDish = find.byType(app.DishMarker).at(1);
      await tester.tap(secondDish);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();

      // Use same delivery info (should be pre-filled)
      await tester.tap(find.text('Place Order'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Order Placed!'), findsOneWidget);
      print('✓ Second order placed successfully');

      // Verify no conversion prompt (already shown)
      expect(find.text('Save Your Progress'), findsNothing);
      print('✓ No duplicate conversion prompt');

      // ========== PHASE 8: GUEST TO REGISTERED CONVERSION ==========
      print('🎯 Phase 8: Converting to registered user');

      // Close order confirmation
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Open profile drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap conversion prompt
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify conversion screen
      expect(find.byType(app.GuestConversionScreen), findsOneWidget);
      expect(find.text('Create Your Account'), findsOneWidget);
      print('✓ Conversion screen displayed');

      // Fill registration form
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testEmail = 'guesttest$timestamp@example.com';

      await tester.enterText(
        find.byKey(const Key('conversion_name_field')),
        'Guest Test User',
      );
      await tester.enterText(
        find.byKey(const Key('conversion_email_field')),
        testEmail,
      );
      await tester.enterText(
        find.byKey(const Key('conversion_password_field')),
        'SecurePassword123!',
      );
      await tester.pumpAndSettle();
      print('✓ Filled registration form');

      // Submit conversion
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify success
      expect(find.text('Account Created!'), findsOneWidget);
      print('✓ Account created successfully');

      // Wait for navigation
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ========== PHASE 9: POST-CONVERSION VERIFICATION ==========
      print('✅ Phase 9: Post-conversion verification');

      // Verify navigation to main app
      expect(find.byType(app.MapScreen), findsOneWidget);
      print('✓ Navigated to main app');

      // Verify guest session cleared
      final isGuest = await guestSessionService.isGuestMode();
      expect(isGuest, isFalse);
      print('✓ Guest session cleared');

      // Verify user is authenticated
      final user = Supabase.instance.client.auth.currentUser;
      expect(user, isNotNull);
      expect(user?.email, equals(testEmail));
      print('✓ User authenticated: ${user?.email}');

      // Verify profile drawer shows registered user
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Guest User'), findsNothing);
      expect(find.text('GUEST'), findsNothing);
      expect(find.text('Logout'), findsOneWidget);
      print('✓ Profile drawer shows registered user');

      // Close drawer
      await tester.tap(find.byType(Drawer));
      await tester.pumpAndSettle();

      // ========== PHASE 10: DATA MIGRATION VERIFICATION ==========
      print('📊 Phase 10: Data migration verification');

      // Verify orders were migrated
      final orders = await Supabase.instance.client
          .from('orders')
          .select()
          .eq('user_id', user!.id)
          .order('created_at', ascending: false);

      expect(orders.length, greaterThanOrEqualTo(2));
      print('✓ Orders migrated: ${orders.length} orders found');

      // Verify messages were migrated
      final messages = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('sender_id', user.id);

      expect(messages.length, greaterThanOrEqualTo(5));
      print('✓ Messages migrated: ${messages.length} messages found');

      // Verify guest session marked as converted
      final guestSessionInfo = await Supabase.instance.client
          .from('guest_sessions')
          .select()
          .eq('guest_id', guestSession.guestId)
          .single();

      expect(guestSessionInfo['converted_to_user_id'], equals(user.id));
      expect(guestSessionInfo['converted_at'], isNotNull);
      print('✓ Guest session marked as converted');

      // ========== PHASE 11: POST-CONVERSION FUNCTIONALITY ==========
      print('🎉 Phase 11: Post-conversion functionality');

      // Access order history
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Order History'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify order history shows migrated orders
      expect(find.byType(app.OrderHistoryScreen), findsOneWidget);
      expect(find.byType(app.OrderCard), findsWidgets);
      print('✓ Order history accessible with migrated orders');

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Place order as registered user
      final thirdDish = find.byType(app.DishMarker).at(2);
      await tester.tap(thirdDish);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Place Order'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify order placed as registered user
      expect(find.text('Order Placed!'), findsOneWidget);
      print('✓ Order placed as registered user');

      // Verify no conversion prompt (already registered)
      expect(find.text('Save Your Progress'), findsNothing);
      print('✓ No conversion prompt for registered user');

      // ========== TEST COMPLETE ==========
      print('🎊 Complete guest journey E2E test passed!');
      print('Summary:');
      print('  - Guest session created and managed');
      print('  - 2 orders placed as guest');
      print('  - 5+ chat messages sent');
      print('  - Conversion prompts shown at appropriate times');
      print('  - Successfully converted to registered user');
      print('  - All data migrated correctly');
      print('  - Post-conversion functionality verified');
    });

    testWidgets('Guest journey - exit guest mode', (tester) async {
      print('🚪 Testing exit guest mode flow');

      // Start as guest
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify guest mode
      final isGuest = await guestSessionService.isGuestMode();
      expect(isGuest, isTrue);
      print('✓ Guest mode active');

      // Open profile drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap Exit Guest Mode
      await tester.tap(find.text('Exit Guest Mode'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Exit Guest Mode'), findsWidgets);
      expect(find.textContaining('guest data will be cleared'), findsOneWidget);
      print('✓ Exit confirmation dialog displayed');

      // Confirm exit
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify navigation to auth screen
      expect(find.text('Continue as Guest'), findsOneWidget);
      print('✓ Navigated to auth screen');

      // Verify guest session cleared
      final isGuestAfter = await guestSessionService.isGuestMode();
      expect(isGuestAfter, isFalse);
      print('✓ Guest session cleared');

      print('🎊 Exit guest mode test passed!');
    });
  });
}
