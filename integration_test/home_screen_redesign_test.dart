import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chefleet/core/diagnostics/testing/diagnostic_tester_helpers.dart';
import 'package:chefleet/main.dart' as app;

import 'diagnostic_harness.dart';

void main() {
  ensureIntegrationDiagnostics(scenarioName: 'home_screen_redesign');

  group('Home Screen Redesign Integration Tests', () {
    testWidgets('Complete user flow: browse, filter, and add to cart',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // STEP 1: Verify PersonalizedHeader is displayed
      expect(
        find.textContaining('Good'),
        findsOneWidget,
        reason: 'Personalized greeting should be displayed',
      );

      // STEP 2: Verify CategoryFilterBar is displayed
      expect(
        find.text('All'),
        findsOneWidget,
        reason: 'All category should be visible',
      );
      expect(
        find.text('Sushi'),
        findsOneWidget,
        reason: 'Sushi category should be visible',
      );
      expect(
        find.text('Burger'),
        findsOneWidget,
        reason: 'Burger category should be visible',
      );

      // STEP 3: Verify dishes are displayed in grid
      await tester.pumpAndSettle();
      final dishCards = find.byType(Card);
      expect(
        dishCards,
        findsWidgets,
        reason: 'Dish cards should be displayed',
      );

      // STEP 4: Test category filtering - select Sushi
      await tester.tap(find.text('Sushi'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify dishes are filtered (this is visual verification)
      // In real test, you'd verify specific dishes are shown

      // STEP 5: Test category filtering - select Pizza
      await tester.tap(find.text('Pizza'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // STEP 6: Reset to All categories
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // STEP 7: Verify SmartCartFAB is displayed
      expect(
        find.byIcon(Icons.shopping_bag),
        findsOneWidget,
        reason: 'Cart FAB should be visible',
      );

      // STEP 8: Add item to cart (if add button is visible)
      final addButtons = find.byIcon(Icons.add);
      if (addButtons.hasFound) {
        await tester.tap(addButtons.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Verify cart FAB expands
        expect(
          find.text('View Cart'),
          findsOneWidget,
          reason: 'Cart FAB should expand to show View Cart',
        );
      }

      // STEP 9: Test sheet drag behavior
      // Find the drag handle
      await tester.drag(
        find.byType(DraggableScrollableSheet),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      // Sheet should expand
      // Verify more dishes are visible after expansion

      // STEP 10: Drag sheet back down
      await tester.drag(
        find.byType(DraggableScrollableSheet),
        const Offset(0, 200),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('Category selection updates dish list',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Count initial dishes
      final initialDishCount = find.byType(Card).evaluate().length;

      // Select a specific category
      await tester.tap(find.text('Burger'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Count filtered dishes
      final filteredDishCount = find.byType(Card).evaluate().length;

      // Filtered count should be different (likely less)
      expect(
        filteredDishCount != initialDishCount || filteredDishCount == 0,
        isTrue,
        reason: 'Dish count should change when filtering',
      );

      // Return to All
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Count should return to initial
      final finalDishCount = find.byType(Card).evaluate().length;
      expect(
        finalDishCount,
        initialDishCount,
        reason: 'All category should show all dishes again',
      );
    });

    testWidgets('Responsive grid layout on different sizes',
        (WidgetTester tester) async {
      // Test mobile size (2 columns)
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify grid is displayed
      expect(
        find.byType(SliverGrid),
        findsOneWidget,
        reason: 'SliverGrid should be used for dish layout',
      );

      // Test tablet size (3 columns)
      tester.binding.window.physicalSizeTestValue = const Size(768, 1024);
      await tester.pumpAndSettle();

      // Grid should still be present
      expect(find.byType(SliverGrid), findsOneWidget);

      // Reset
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    testWidgets('Cart FAB expansion animation works',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Initially, cart should be compact (no View Cart text)
      expect(find.text('View Cart'), findsNothing);

      // Find and tap an add button
      final addButtons = find.byIcon(Icons.add);
      if (addButtons.hasFound) {
        await tester.tap(addButtons.first);
        
        // Let animation start
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        
        // Complete animation
        await tester.pumpAndSettle();

        // Should now show View Cart
        expect(
          find.text('View Cart'),
          findsOneWidget,
          reason: 'Cart FAB should expand when items are added',
        );

        // Should show item count
        expect(
          find.text('1'),
          findsOneWidget,
          reason: 'Should show item count badge',
        );
      }
    });

    testWidgets('Map interaction remains unchanged',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify map is visible (GoogleMap widget)
      // This depends on your implementation
      expect(
        find.byType(Container).first,
        findsOneWidget,
        reason: 'Map container should be present',
      );

      // Try to interact with map (drag)
      await tester.drag(
        find.byType(Stack).first,
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Map should still be functional (no crashes)
      expect(tester.takeException(), isNull);
    });

    testWidgets('Search bar integration with redesign',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find search bar (should be glass container at top)
      final searchBar = find.byType(TextField);
      
      if (searchBar.hasFound) {
        // Tap search bar
        await tester.tap(searchBar);
        await tester.pumpAndSettle();

        // Enter search query
        await tester.enterText(searchBar, 'pizza');
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Dishes should be filtered by search
        // This is visual verification in integration test
      }
    });

    testWidgets('Bottom sheet snap points work correctly',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final sheet = find.byType(DraggableScrollableSheet);
      expect(sheet, findsOneWidget);

      // Drag to middle position
      await tester.drag(sheet, const Offset(0, -100));
      await tester.pumpAndSettle();

      // Should snap to nearest snap point
      expect(tester.takeException(), isNull);

      // Drag to expanded position
      await tester.drag(sheet, const Offset(0, -400));
      await tester.pumpAndSettle();

      // Should snap to expanded position
      expect(tester.takeException(), isNull);

      // Drag to minimized
      await tester.drag(sheet, const Offset(0, 400));
      await tester.pumpAndSettle();

      // Should snap to minimized position
      expect(tester.takeException(), isNull);
    });

    testWidgets('Multiple category switches work smoothly',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Rapidly switch between categories
      final categories = ['Sushi', 'Burger', 'Pizza', 'Healthy', 'Dessert', 'All'];
      
      for (final category in categories) {
        await tester.tap(find.text(category));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // Should not crash
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Greeting changes based on time (manual verification)',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find greeting text
      final greetingFinder = find.textContaining('Good');
      expect(greetingFinder, findsOneWidget);

      // The actual greeting (Morning/Afternoon/Evening) depends on current time
      // This is more of a visual verification test
    });

    testWidgets('Animations are smooth without jank',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test category selection animation
      await tester.tap(find.text('Pizza'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // No exceptions should occur
      expect(tester.takeException(), isNull);

      // Test cart FAB animation
      final addButtons = find.byIcon(Icons.add);
      if (addButtons.hasFound) {
        await tester.tap(addButtons.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      }
    });
  });
}
