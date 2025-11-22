import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chefleet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Buyer Flow Integration Tests', () {
    testWidgets('Complete buyer flow: browse -> order -> pickup', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Verify splash screen appears
      expect(find.text('Chefleet'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 2: Navigate to map screen (if not authenticated, handle auth flow)
      // This assumes user is already authenticated or auth is bypassed in test
      await tester.pumpAndSettle();

      // Step 3: Search for a dish
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'Burger');
        await tester.pumpAndSettle(const Duration(milliseconds: 600)); // Debounce
      }

      // Step 4: Switch to feed view
      final feedTab = find.text('Feed');
      if (feedTab.evaluate().isNotEmpty) {
        await tester.tap(feedTab);
        await tester.pumpAndSettle();
      }

      // Step 5: Tap on a dish card
      final dishCard = find.byType(Card).first;
      await tester.tap(dishCard);
      await tester.pumpAndSettle();

      // Step 6: Verify dish detail screen
      expect(find.text('Dish Details'), findsOneWidget);
      expect(find.text('Quantity'), findsOneWidget);
      expect(find.text('Pickup Time'), findsOneWidget);

      // Step 7: Adjust quantity
      final increaseButton = find.byIcon(Icons.add);
      await tester.tap(increaseButton);
      await tester.pumpAndSettle();

      // Step 8: Select pickup time
      final pickupSlot = find.textContaining('12:00 PM').first;
      await tester.tap(pickupSlot);
      await tester.pumpAndSettle();

      // Step 9: Place order
      final orderButton = find.text('Order for Pickup');
      await tester.tap(orderButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 10: Verify order confirmation screen
      expect(find.text('Order Confirmed'), findsOneWidget);
      expect(find.text('Pickup Code'), findsOneWidget);

      // Step 11: Verify pickup code is displayed
      expect(find.textContaining(RegExp(r'\d{4}')), findsOneWidget);

      // Step 12: Copy pickup code
      final copyButton = find.byIcon(Icons.copy);
      await tester.tap(copyButton);
      await tester.pumpAndSettle();
      expect(find.text('Copied to clipboard'), findsOneWidget);

      // Step 13: Navigate to active orders
      final ordersTab = find.text('Orders');
      await tester.tap(ordersTab);
      await tester.pumpAndSettle();

      // Step 14: Verify order appears in active orders list
      expect(find.byType(Card), findsWidgets);

      // Step 15: Tap on order to view details
      final orderCard = find.byType(Card).first;
      await tester.tap(orderCard);
      await tester.pumpAndSettle();

      // Step 16: Verify active order modal
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Preparing'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);

      // Step 17: Open chat
      final chatButton = find.byIcon(Icons.chat);
      await tester.tap(chatButton);
      await tester.pumpAndSettle();

      // Step 18: Verify chat screen
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('On my way'), findsOneWidget);

      // Step 19: Send a message
      await tester.enterText(find.byType(TextField), 'When will it be ready?');
      final sendButton = find.byIcon(Icons.send);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Step 20: Navigate back to order
      final backButton = find.byIcon(Icons.arrow_back);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      // Navigate to feed
      final feedTab = find.text('Feed');
      if (feedTab.evaluate().isNotEmpty) {
        await tester.tap(feedTab);
        await tester.pumpAndSettle();
      }

      // Find favorite button on a dish card
      final favoriteButton = find.byIcon(Icons.favorite_border).first;
      await tester.tap(favoriteButton);
      await tester.pumpAndSettle();

      // Verify favorite icon changes
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Navigate to favorites screen
      final profileTab = find.text('Profile');
      await tester.tap(profileTab);
      await tester.pumpAndSettle();

      final favoritesOption = find.text('Favourites');
      await tester.tap(favoritesOption);
      await tester.pumpAndSettle();

      // Verify favorited dish appears
      expect(find.byType(Card), findsWidgets);

      print('✅ Favorite dish test completed successfully');
    });

    testWidgets('Buyer can view order history', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to orders tab
      final ordersTab = find.text('Orders');
      await tester.tap(ordersTab);
      await tester.pumpAndSettle();

      // Switch to completed orders
      final completedFilter = find.text('Completed');
      if (completedFilter.evaluate().isNotEmpty) {
        await tester.tap(completedFilter);
        await tester.pumpAndSettle();
      }

      // Verify completed orders are displayed
      expect(find.byType(Card), findsWidgets);

      print('✅ Order history test completed successfully');
    });

    testWidgets('Buyer can update notification preferences', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to profile
      final profileTab = find.text('Profile');
      await tester.tap(profileTab);
      await tester.pumpAndSettle();

      // Open settings
      final settingsOption = find.text('Settings');
      await tester.tap(settingsOption);
      await tester.pumpAndSettle();

      // Open notifications
      final notificationsOption = find.text('Notifications');
      await tester.tap(notificationsOption);
      await tester.pumpAndSettle();

      // Toggle a notification preference
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pumpAndSettle();

        // Verify success message
        expect(find.text('Preferences saved'), findsOneWidget);
      }

      print('✅ Notification preferences test completed successfully');
    });
  });
}
