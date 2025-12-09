import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chefleet/core/diagnostics/testing/diagnostic_tester_helpers.dart';
import 'package:chefleet/main.dart' as app;

import 'diagnostic_harness.dart';

void main() {
  ensureIntegrationDiagnostics(scenarioName: 'vendor_flow');

  group('Vendor Flow Integration Tests', () {
    testWidgets('Complete vendor flow: accept -> prepare -> ready -> complete', (WidgetTester tester) async {
      // Start the app
      app.main();
      await diagnosticPumpAndSettle(tester, description: 'settle vendor dashboard');

      // Assume vendor is authenticated and on dashboard
      await diagnosticPumpAndSettle(tester, description: 'wait for vendor data');

      // Step 1: Verify vendor dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Order Queue'), findsOneWidget);

      // Step 2: Verify metrics tiles
      expect(find.text('Today\'s Revenue'), findsOneWidget);
      expect(find.text('Active Orders'), findsOneWidget);

      // Step 3: Filter to pending orders
      final pendingFilter = find.text('Pending');
      await diagnosticTap(tester, pendingFilter, description: 'filter pending orders');
      await diagnosticPumpAndSettle(tester, description: 'settle pending filter');

      // Step 4: Tap on a pending order
      final orderCard = find.byType(Card).first;
      await diagnosticTap(tester, orderCard, description: 'open pending order');
      await diagnosticPumpAndSettle(tester, description: 'settle order detail');

      // Step 5: Verify order detail screen
      expect(find.textContaining('Order'), findsOneWidget);
      expect(find.text('Items'), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);

      // Step 6: Accept the order
      final acceptButton = find.text('Accept Order');
      await diagnosticTap(tester, acceptButton, description: 'accept order');
      await diagnosticPumpAndSettle(
        tester,
        duration: const Duration(seconds: 2),
        description: 'wait for accept order response',
      );

      // Step 7: Verify success toast
      expect(find.text('Order accepted'), findsOneWidget);

      // Step 8: Verify status timeline updated
      expect(find.text('Accepted'), findsOneWidget);

      // Step 9: Start preparing
      final prepareButton = find.text('Start Preparing');
      await diagnosticTap(tester, prepareButton, description: 'start preparing');
      await diagnosticPumpAndSettle(
        tester,
        duration: const Duration(seconds: 2),
        description: 'wait for preparing state',
      );

      // Step 10: Verify status updated to preparing
      expect(find.text('Preparing'), findsOneWidget);

      // Step 11: Mark as ready
      final readyButton = find.text('Mark as Ready');
      await diagnosticTap(tester, readyButton, description: 'mark as ready');
      await diagnosticPumpAndSettle(
        tester,
        duration: const Duration(seconds: 2),
        description: 'wait for ready state',
      );

      // Step 12: Verify status updated to ready
      expect(find.text('Ready'), findsOneWidget);

      // Step 13: Verify pickup code is displayed
      expect(find.text('Pickup Code'), findsOneWidget);

      // Step 14: Enter pickup code for verification
      final codeInput = find.byType(TextField);
      if (codeInput.evaluate().isNotEmpty) {
        await diagnosticEnterText(tester, codeInput, '1234', description: 'enter pickup code');
        await diagnosticPumpAndSettle(tester, description: 'settle pickup code entry');

        // Step 15: Verify pickup
        final verifyButton = find.text('Verify Pickup');
        await diagnosticTap(tester, verifyButton, description: 'verify pickup');
        await diagnosticPumpAndSettle(
          tester,
          duration: const Duration(seconds: 2),
          description: 'wait for pickup verification',
        );

        // Step 16: Verify order completed
        expect(find.text('Completed'), findsOneWidget);
      }

      // Step 17: Navigate back to dashboard
      final backButton = find.byIcon(Icons.arrow_back);
      await diagnosticTap(tester, backButton, description: 'return to dashboard');
      await diagnosticPumpAndSettle(tester, description: 'settle dashboard return');

      // Step 18: Verify order moved to completed
      final completedFilter = find.text('Completed');
      await diagnosticTap(tester, completedFilter, description: 'filter completed orders');
      await diagnosticPumpAndSettle(tester, description: 'settle completed filter');

      expect(find.byType(Card), findsWidgets);

      print('✅ Vendor flow integration test completed successfully');
    });

    testWidgets('Vendor can add a new dish', (WidgetTester tester) async {
      await _launchVendorApp(tester, description: 'vendor add dish');

      // Navigate to add dish screen
      final addDishButton = find.byIcon(Icons.add);
      if (addDishButton.evaluate().isNotEmpty) {
        await _tapFinder(tester, addDishButton, 'open add dish');
        await _pumpSettle(tester, 'settle add dish screen');
      }

      // Fill in dish details
      final nameField = find.byType(TextField).at(0);
      await _enterTextField(tester, nameField, 'New Test Dish', 'enter dish name');
      await _pumpSettle(tester, 'settle name entry');

      final descriptionField = find.byType(TextField).at(1);
      await _enterTextField(tester, descriptionField, 'A delicious new dish', 'enter dish description');
      await _pumpSettle(tester, 'settle description entry');

      final priceField = find.byType(TextField).at(2);
      await _enterTextField(tester, priceField, '12.99', 'enter dish price');
      await _pumpSettle(tester, 'settle price entry');

      // Select category
      final categoryDropdown = find.byType(DropdownButton<String>);
      if (categoryDropdown.evaluate().isNotEmpty) {
        await _tapFinder(tester, categoryDropdown, 'open category dropdown');
        await _pumpSettle(tester, 'settle category dropdown');

        final categoryOption = find.text('Main Course').last;
        await _tapFinder(tester, categoryOption, 'select main course category');
        await _pumpSettle(tester, 'settle category selection');
      }

      // Upload image (mock)
      final uploadButton = find.text('Upload Image');
      if (uploadButton.evaluate().isNotEmpty) {
        await _tapFinder(tester, uploadButton, 'open upload dialog');
        await _pumpSettle(tester, 'settle upload action');
      }

      // Save dish
      final saveButton = find.text('Save Dish');
      await _tapFinder(tester, saveButton, 'save dish');
      await _pumpSettle(
        tester,
        'wait for dish save',
        duration: const Duration(seconds: 2),
      );

      // Verify success
      expect(find.text('Dish added successfully'), findsOneWidget);

      print('✅ Add dish test completed successfully');
    });

    testWidgets('Vendor can chat with customer', (WidgetTester tester) async {
      await _launchVendorApp(tester, description: 'vendor chat flow');

      // Navigate to an order
      final orderCard = find.byType(Card).first;
      await _tapFinder(tester, orderCard, 'open order for chat');
      await _pumpSettle(tester, 'settle order modal');

      // Open chat
      final chatButton = find.byIcon(Icons.chat);
      await _tapFinder(tester, chatButton, 'open vendor chat');
      await _pumpSettle(tester, 'settle chat screen');

      // Verify chat screen
      expect(find.byType(TextField), findsOneWidget);

      // Send a message
      await _enterTextField(
        tester,
        find.byType(TextField),
        'Your order is ready!',
        'enter vendor chat message',
      );
      final sendButton = find.byIcon(Icons.send);
      await _tapFinder(tester, sendButton, 'send vendor chat message');
      await _pumpSettle(tester, 'settle chat send');

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

Future<void> _launchVendorApp(WidgetTester tester, {String description = 'app launch'}) async {
  app.main();
  await _pumpSettle(tester, 'settle after $description');
}

Future<void> _pumpSettle(
  WidgetTester tester,
  String description, {
  Duration? duration,
}) {
  return diagnosticPumpAndSettle(
    tester,
    duration: duration,
    description: description,
  );
}

Future<void> _tapFinder(WidgetTester tester, Finder finder, String description) {
  return diagnosticTap(tester, finder, description: description);
}

Future<void> _tapIcon(WidgetTester tester, IconData icon, String description) {
  return _tapFinder(tester, find.byIcon(icon), description);
}

Future<void> _tapText(WidgetTester tester, String text, String description) {
  return _tapFinder(tester, find.text(text), description);
}

Future<void> _enterTextField(
  WidgetTester tester,
  Finder finder,
  String text,
  String description,
) {
  return diagnosticEnterText(tester, finder, text, description: description);
}
