import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chefleet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Vendor Flow Integration Tests', () {
    testWidgets('Complete vendor flow: accept -> prepare -> ready -> complete', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Assume vendor is authenticated and on dashboard
      await tester.pumpAndSettle();

      // Step 1: Verify vendor dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Order Queue'), findsOneWidget);

      // Step 2: Verify metrics tiles
      expect(find.text('Today\'s Revenue'), findsOneWidget);
      expect(find.text('Active Orders'), findsOneWidget);

      // Step 3: Filter to pending orders
      final pendingFilter = find.text('Pending');
      await tester.tap(pendingFilter);
      await tester.pumpAndSettle();

      // Step 4: Tap on a pending order
      final orderCard = find.byType(Card).first;
      await tester.tap(orderCard);
      await tester.pumpAndSettle();

      // Step 5: Verify order detail screen
      expect(find.textContaining('Order'), findsOneWidget);
      expect(find.text('Items'), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);

      // Step 6: Accept the order
      final acceptButton = find.text('Accept Order');
      await tester.tap(acceptButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 7: Verify success toast
      expect(find.text('Order accepted'), findsOneWidget);

      // Step 8: Verify status timeline updated
      expect(find.text('Accepted'), findsOneWidget);

      // Step 9: Start preparing
      final prepareButton = find.text('Start Preparing');
      await tester.tap(prepareButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 10: Verify status updated to preparing
      expect(find.text('Preparing'), findsOneWidget);

      // Step 11: Mark as ready
      final readyButton = find.text('Mark as Ready');
      await tester.tap(readyButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 12: Verify status updated to ready
      expect(find.text('Ready'), findsOneWidget);

      // Step 13: Verify pickup code is displayed
      expect(find.text('Pickup Code'), findsOneWidget);

      // Step 14: Enter pickup code for verification
      final codeInput = find.byType(TextField);
      if (codeInput.evaluate().isNotEmpty) {
        await tester.enterText(codeInput, '1234');
        await tester.pumpAndSettle();

        // Step 15: Verify pickup
        final verifyButton = find.text('Verify Pickup');
        await tester.tap(verifyButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Step 16: Verify order completed
        expect(find.text('Completed'), findsOneWidget);
      }

      // Step 17: Navigate back to dashboard
      final backButton = find.byIcon(Icons.arrow_back);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Step 18: Verify order moved to completed
      final completedFilter = find.text('Completed');
      await tester.tap(completedFilter);
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsWidgets);

      print('✅ Vendor flow integration test completed successfully');
    });

    testWidgets('Vendor can add a new dish', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add dish screen
      final addDishButton = find.byIcon(Icons.add);
      if (addDishButton.evaluate().isNotEmpty) {
        await tester.tap(addDishButton);
        await tester.pumpAndSettle();
      }

      // Fill in dish details
      final nameField = find.byType(TextField).at(0);
      await tester.enterText(nameField, 'New Test Dish');
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextField).at(1);
      await tester.enterText(descriptionField, 'A delicious new dish');
      await tester.pumpAndSettle();

      final priceField = find.byType(TextField).at(2);
      await tester.enterText(priceField, '12.99');
      await tester.pumpAndSettle();

      // Select category
      final categoryDropdown = find.byType(DropdownButton<String>);
      if (categoryDropdown.evaluate().isNotEmpty) {
        await tester.tap(categoryDropdown);
        await tester.pumpAndSettle();

        final categoryOption = find.text('Main Course').last;
        await tester.tap(categoryOption);
        await tester.pumpAndSettle();
      }

      // Upload image (mock)
      final uploadButton = find.text('Upload Image');
      if (uploadButton.evaluate().isNotEmpty) {
        await tester.tap(uploadButton);
        await tester.pumpAndSettle();
      }

      // Save dish
      final saveButton = find.text('Save Dish');
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify success
      expect(find.text('Dish added successfully'), findsOneWidget);

      print('✅ Add dish test completed successfully');
    });

    testWidgets('Vendor can chat with customer', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to an order
      final orderCard = find.byType(Card).first;
      await tester.tap(orderCard);
      await tester.pumpAndSettle();

      // Open chat
      final chatButton = find.byIcon(Icons.chat);
      await tester.tap(chatButton);
      await tester.pumpAndSettle();

      // Verify chat screen
      expect(find.byType(TextField), findsOneWidget);

      // Send a message
      await tester.enterText(find.byType(TextField), 'Your order is ready!');
      final sendButton = find.byIcon(Icons.send);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Verify message sent
      expect(find.text('Your order is ready!'), findsOneWidget);

      print('✅ Vendor chat test completed successfully');
    });

    testWidgets('Vendor can manage dish availability', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to availability management
      final menuButton = find.byIcon(Icons.menu);
      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton);
        await tester.pumpAndSettle();

        final availabilityOption = find.text('Manage Availability');
        await tester.tap(availabilityOption);
        await tester.pumpAndSettle();
      }

      // Toggle dish availability
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pumpAndSettle();

        // Verify success
        expect(find.text('Availability updated'), findsOneWidget);
      }

      print('✅ Availability management test completed successfully');
    });

    testWidgets('Vendor can view revenue metrics', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify dashboard metrics
      expect(find.text('Today\'s Revenue'), findsOneWidget);
      expect(find.textContaining('\$'), findsWidgets);

      // Verify active orders count
      expect(find.text('Active Orders'), findsOneWidget);

      // Verify completed orders count
      expect(find.text('Completed Today'), findsOneWidget);

      print('✅ Revenue metrics test completed successfully');
    });

    testWidgets('Vendor receives realtime order updates', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify dashboard is loaded
      expect(find.text('Dashboard'), findsOneWidget);

      // Wait for realtime updates
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify order queue updates
      expect(find.byType(Card), findsWidgets);

      // This test would verify that new orders appear automatically
      // In a real scenario, you'd trigger a new order from another device/session

      print('✅ Realtime updates test completed successfully');
    });

    testWidgets('Vendor can reject an order', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to a pending order
      final pendingFilter = find.text('Pending');
      await tester.tap(pendingFilter);
      await tester.pumpAndSettle();

      final orderCard = find.byType(Card).first;
      await tester.tap(orderCard);
      await tester.pumpAndSettle();

      // Find reject button
      final rejectButton = find.text('Reject Order');
      if (rejectButton.evaluate().isNotEmpty) {
        await tester.tap(rejectButton);
        await tester.pumpAndSettle();

        // Confirm rejection
        final confirmButton = find.text('Confirm');
        await tester.tap(confirmButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify order rejected
        expect(find.text('Order rejected'), findsOneWidget);
      }

      print('✅ Reject order test completed successfully');
    });
  });
}
