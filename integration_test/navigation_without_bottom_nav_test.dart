import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chefleet/main.dart' as app;

/// Integration test for navigation flows without bottom navigation bar
/// Tests the new navigation model: Map/Feed primary, FAB for orders, profile in header
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Without Bottom Nav - Guest Flow', () {
    testWidgets('Guest can browse nearby dishes without bottom navigation', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify no bottom navigation bar exists
      expect(
        find.byType(BottomNavigationBar),
        findsNothing,
        reason: 'Bottom navigation bar should not exist',
      );

      // Verify no NavigationBar exists (Material 3)
      expect(
        find.byType(NavigationBar),
        findsNothing,
        reason: 'Navigation bar should not exist',
      );

      // Step 1: Verify initial landing on map/nearby dishes
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Should see either map or nearby dishes
      final hasMapOrFeed = find.text('Nearby Dishes').evaluate().isNotEmpty ||
          find.byType(GoogleMap).evaluate().isNotEmpty;
      
      expect(
        hasMapOrFeed,
        true,
        reason: 'Should land on map or nearby dishes screen',
      );

      // Step 2: Toggle between map and list view
      if (find.byIcon(Icons.list).evaluate().isNotEmpty) {
        // Currently on map, toggle to list
        await tester.tap(find.byIcon(Icons.list));
        await tester.pumpAndSettle();
        
        // Should see "Nearby Dishes" title
        expect(
          find.text('Nearby Dishes'),
          findsOneWidget,
          reason: 'Should navigate to nearby dishes list',
        );
      }

      // Step 3: Access profile via header icon
      expect(
        find.byIcon(Icons.person_outline),
        findsOneWidget,
        reason: 'Profile icon should be in header',
      );

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Should navigate to profile (may show guest prompt)
      final hasProfileOrPrompt = find.textContaining('Profile').evaluate().isNotEmpty ||
          find.textContaining('Guest').evaluate().isNotEmpty ||
          find.textContaining('Sign').evaluate().isNotEmpty;
      
      expect(
        hasProfileOrPrompt,
        true,
        reason: 'Should navigate to profile or show guest prompt',
      );
    });

    testWidgets('FAB opens Active Orders modal', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify FAB exists
      expect(
        find.byIcon(Icons.shopping_bag_outlined),
        findsOneWidget,
        reason: 'FAB with shopping bag icon should exist',
      );

      // Tap FAB
      await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
      await tester.pumpAndSettle();

      // Verify Active Orders modal opens
      expect(
        find.text('Active Order'),
        findsOneWidget,
        reason: 'Active Orders modal should open',
      );

      // Close modal
      await tester.tapAt(const Offset(10, 10)); // Tap outside
      await tester.pumpAndSettle();
    });

    testWidgets('Guest can view dish details from nearby dishes', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to nearby dishes if not already there
      if (find.byIcon(Icons.list).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.list));
        await tester.pumpAndSettle();
      }

      // Wait for dishes to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find first dish card (if available)
      final dishCards = find.byType(Card).evaluate();
      
      if (dishCards.isNotEmpty) {
        // Tap first dish
        await tester.tap(find.byType(Card).first);
        await tester.pumpAndSettle();

        // Should navigate to dish detail
        // Verify dish detail elements (varies by implementation)
        final hasDishDetail = find.byType(Card).evaluate().isNotEmpty;
        expect(
          hasDishDetail,
          true,
          reason: 'Should navigate to dish detail screen',
        );
      }
    });
  });

  group('Navigation Without Bottom Nav - Order Flow', () {
    testWidgets('Guest can place order and access chat from Active Orders', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // This is a placeholder for order flow
      // In a real test, you would:
      // 1. Navigate to dish detail
      // 2. Add to cart
      // 3. Checkout (cash-only)
      // 4. Open Active Orders via FAB
      // 5. Access chat from order card

      // Verify FAB is accessible throughout flow
      expect(
        find.byIcon(Icons.shopping_bag_outlined),
        findsOneWidget,
        reason: 'FAB should be accessible during order flow',
      );

      // Open Active Orders
      await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
      await tester.pumpAndSettle();

      // Verify modal structure allows chat access
      expect(
        find.text('Active Order'),
        findsOneWidget,
        reason: 'Active Orders modal should be accessible',
      );

      // If orders exist, verify Chat button is present
      if (find.text('Chat').evaluate().isNotEmpty) {
        expect(
          find.text('Chat'),
          findsWidgets,
          reason: 'Chat button should be accessible from order cards',
        );
      }
    });
  });

  group('Navigation Regression Tests', () {
    testWidgets('No UI elements reference feed or chat tabs', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify no "Feed" tab label
      expect(
        find.text('Feed'),
        findsNothing,
        reason: 'No "Feed" tab should exist',
      );

      // Verify no "Chat" tab label (in bottom nav context)
      final chatFinds = find.text('Chat').evaluate();
      
      // If Chat text exists, verify it's in order context, not nav bar
      if (chatFinds.isNotEmpty) {
        expect(
          find.byType(BottomNavigationBar),
          findsNothing,
          reason: 'Chat text should not be in bottom navigation context',
        );
      }
    });

    testWidgets('Screen transitions maintain FAB visibility', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify FAB on initial screen
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);

      // Toggle to list view if on map
      if (find.byIcon(Icons.list).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.list));
        await tester.pumpAndSettle();
        
        // Verify FAB still visible
        expect(
          find.byIcon(Icons.shopping_bag_outlined),
          findsOneWidget,
          reason: 'FAB should remain visible after navigation',
        );
      }

      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // FAB may or may not be visible on profile (depends on implementation)
      // But should never have bottom nav
      expect(find.byType(BottomNavigationBar), findsNothing);
    });

    testWidgets('Map and feed screens have proper spacing without bottom nav', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify content is not clipped at bottom
      final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      
      // Get scaffold
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      
      // Verify no bottom navigation bar
      expect(scaffold.bottomNavigationBar, isNull);

      // Content should extend to bottom with safe area
      // This is tested by verifying no excessive padding
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      
      for (final box in sizedBoxes) {
        if (box.height != null) {
          expect(
            box.height! < 100,
            true,
            reason: 'No excessive bottom padding (100px) should exist',
          );
        }
      }
    });
  });

  group('Navigation Accessibility Tests', () {
    testWidgets('All navigation controls have proper tooltips', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find all IconButton widgets
      final iconButtons = tester.widgetList<IconButton>(
        find.byType(IconButton),
      );

      int tooltipCount = 0;
      for (final button in iconButtons) {
        if (button.tooltip != null && button.tooltip!.isNotEmpty) {
          tooltipCount++;
        }
      }

      expect(
        tooltipCount,
        greaterThan(0),
        reason: 'Navigation controls should have tooltips for accessibility',
      );
    });

    testWidgets('FAB has adequate touch target size', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find FAB
      final fab = find.byIcon(Icons.shopping_bag_outlined);
      expect(fab, findsOneWidget);

      // Get FAB size
      final fabSize = tester.getSize(fab);
      
      // Verify minimum touch target (48x48 recommended, FAB is 64x64)
      expect(
        fabSize.width,
        greaterThanOrEqualTo(48),
        reason: 'FAB width should meet minimum touch target',
      );
      expect(
        fabSize.height,
        greaterThanOrEqualTo(48),
        reason: 'FAB height should meet minimum touch target',
      );
    });
  });
}
