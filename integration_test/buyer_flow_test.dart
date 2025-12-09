import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chefleet/core/diagnostics/testing/diagnostic_tester_helpers.dart';
import 'package:chefleet/main.dart' as app;

import 'diagnostic_harness.dart';

void main() {
  ensureIntegrationDiagnostics(scenarioName: 'buyer_flow');

  group('Buyer Flow Integration Tests', () {
    testWidgets('Complete buyer flow: browse -> order -> pickup', (WidgetTester tester) async {
      // Start the app
      app.main();
      await diagnosticPumpAndSettle(tester, description: 'settle after app launch');

      // Step 1: Verify splash screen appears
      expect(find.text('Chefleet'), findsOneWidget);
      await diagnosticPumpAndSettle(
        tester,
        duration: const Duration(seconds: 2),
        description: 'wait for splash transition',
      );

      // Step 2: Navigate to map screen (if not authenticated, handle auth flow)
      // This assumes user is already authenticated or auth is bypassed in test
      await diagnosticPumpAndSettle(tester, description: 'settle potential auth/map transition');

      // Step 3: Search for a dish
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await diagnosticEnterText(tester, searchField, 'Burger', description: 'search for burger');
        await diagnosticPumpAndSettle(
          tester,
          duration: const Duration(milliseconds: 600),
          description: 'settle search debounce',
        );
      }

      // Step 4: Switch to feed view
      final feedTab = find.text('Feed');
      if (feedTab.evaluate().isNotEmpty) {
        await diagnosticTap(tester, feedTab, description: 'switch to feed tab');
        await diagnosticPumpAndSettle(tester, description: 'settle feed transition');
      }

      // Step 5: Tap on a dish card
      final dishCard = find.byType(Card).first;
      await diagnosticTap(tester, dishCard, description: 'open dish detail');
      await diagnosticPumpAndSettle(tester, description: 'settle dish detail transition');

      // Step 6: Verify dish detail screen
      expect(find.text('Dish Details'), findsOneWidget);
      expect(find.text('Quantity'), findsOneWidget);
      expect(find.text('Pickup Time'), findsOneWidget);

      // Step 7: Adjust quantity
      final increaseButton = find.byIcon(Icons.add);
      await diagnosticTap(tester, increaseButton, description: 'increase quantity');
      await diagnosticPumpAndSettle(tester, description: 'settle quantity update');

      // Step 8: Select pickup time
      final pickupSlot = find.textContaining('12:00 PM').first;
      await diagnosticTap(tester, pickupSlot, description: 'select pickup slot');
      await diagnosticPumpAndSettle(tester, description: 'settle pickup slot selection');

      // Step 9: Place order
      final orderButton = find.text('Order for Pickup');
      await diagnosticTap(tester, orderButton, description: 'place order');
      await diagnosticPumpAndSettle(
        tester,
        duration: const Duration(seconds: 3),
        description: 'wait for order confirmation',
      );

      // Step 10: Verify order confirmation screen
      expect(find.text('Order Confirmed'), findsOneWidget);
      expect(find.text('Pickup Code'), findsOneWidget);

      // Step 11: Verify pickup code is displayed
      expect(find.textContaining(RegExp(r'\d{4}')), findsOneWidget);

      // Step 12: Copy pickup code
      final copyButton = find.byIcon(Icons.copy);
      await diagnosticTap(tester, copyButton, description: 'copy pickup code');
      await diagnosticPumpAndSettle(tester, description: 'settle snackbar');
      expect(find.text('Copied to clipboard'), findsOneWidget);

      // Step 13: Navigate to active orders
      final ordersTab = find.text('Orders');
      await diagnosticTap(tester, ordersTab, description: 'open orders tab');
      await diagnosticPumpAndSettle(tester, description: 'settle orders tab');

      // Step 14: Verify order appears in active orders list
      expect(find.byType(Card), findsWidgets);

      // Step 15: Tap on order to view details
      final orderCard = find.byType(Card).first;
      await diagnosticTap(tester, orderCard, description: 'open order details');
      await diagnosticPumpAndSettle(tester, description: 'settle order modal');

      // Step 16: Verify active order modal
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Preparing'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);

      // Step 17: Open chat
      final chatButton = find.byIcon(Icons.chat);
      await diagnosticTap(tester, chatButton, description: 'open chat');
      await diagnosticPumpAndSettle(tester, description: 'settle chat transition');

      // Step 18: Verify chat screen
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('On my way'), findsOneWidget);

      // Step 19: Send a message
      await diagnosticEnterText(
        tester,
        find.byType(TextField),
        'When will it be ready?',
        description: 'compose chat message',
      );
      final sendButton = find.byIcon(Icons.send);
      await diagnosticTap(tester, sendButton, description: 'send chat message');
      await diagnosticPumpAndSettle(tester, description: 'settle message send');

      // Step 20: Navigate back to order
      final backButton = find.byIcon(Icons.arrow_back);
      await diagnosticTap(tester, backButton, description: 'return from chat');
      await diagnosticPumpAndSettle(tester, description: 'settle back navigation');

      // Step 21: Simulate order status change to 'ready'
      // This would require backend integration or mocking

      // Step 22: Verify pickup code is visible when ready
      expect(find.text('Pickup Code'), findsOneWidget);

      // Step 23: Complete pickup
      // This would be done by vendor scanning/entering the code
      // For buyer, they just show the code

      print('✅ Buyer flow integration test completed successfully');
    });

    testWidgets('Buyer can favorite a dish', (WidgetTester tester) async {
      app.main();
      await diagnosticPumpAndSettle(tester, description: 'settle after app launch');

      // Navigate to feed
      final feedTab = find.text('Feed');
      if (feedTab.evaluate().isNotEmpty) {
        await diagnosticTap(tester, feedTab, description: 'switch to feed tab');
        await diagnosticPumpAndSettle(tester, description: 'settle feed tab');
      }

      // Find favorite button on a dish card
      final favoriteButton = find.byIcon(Icons.favorite_border).first;
      await diagnosticTap(tester, favoriteButton, description: 'favorite dish');
      await diagnosticPumpAndSettle(tester, description: 'settle favorite animation');

      // Verify favorite icon changes
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Navigate to favorites screen
      final profileTab = find.text('Profile');
      await diagnosticTap(tester, profileTab, description: 'navigate to profile');
      await diagnosticPumpAndSettle(tester, description: 'settle profile transition');

      final favoritesOption = find.text('Favourites');
      await diagnosticTap(tester, favoritesOption, description: 'open favourites');
      await diagnosticPumpAndSettle(tester, description: 'settle favourites');

      // Verify favorited dish appears
      expect(find.byType(Card), findsWidgets);

      print('✅ Favorite dish test completed successfully');
    });

    testWidgets('Buyer can view order history', (WidgetTester tester) async {
      app.main();
      await diagnosticPumpAndSettle(tester, description: 'settle after app launch');

      // Navigate to orders tab
      final ordersTab = find.text('Orders');
      await diagnosticTap(tester, ordersTab, description: 'open orders tab');
      await diagnosticPumpAndSettle(tester, description: 'settle orders tab');

      // Switch to completed orders
      final completedFilter = find.text('Completed');
      if (completedFilter.evaluate().isNotEmpty) {
        await diagnosticTap(tester, completedFilter, description: 'filter completed orders');
        await diagnosticPumpAndSettle(tester, description: 'settle completed filter');
      }

      // Verify completed orders are displayed
      expect(find.byType(Card), findsWidgets);

      print('✅ Order history test completed successfully');
    });

    testWidgets('Buyer can update notification preferences', (WidgetTester tester) async {
      app.main();
      await diagnosticPumpAndSettle(tester, description: 'settle after app launch');

      // Navigate to profile
      final profileTab = find.text('Profile');
      await diagnosticTap(tester, profileTab, description: 'open profile tab');
      await diagnosticPumpAndSettle(tester, description: 'settle profile tab');

      // Open settings
      final settingsOption = find.text('Settings');
      await diagnosticTap(tester, settingsOption, description: 'open settings');
      await diagnosticPumpAndSettle(tester, description: 'settle settings');

      // Open notifications
      final notificationsOption = find.text('Notifications');
      await diagnosticTap(tester, notificationsOption, description: 'open notifications');
      await diagnosticPumpAndSettle(tester, description: 'settle notifications');

      // Toggle a notification preference
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await diagnosticTap(tester, switches.first, description: 'toggle first notification switch');
        await diagnosticPumpAndSettle(tester, description: 'settle toggle state');

        // Verify success message
        expect(find.text('Preferences saved'), findsOneWidget);
      }

      print('✅ Notification preferences test completed successfully');
    });
  });
}
