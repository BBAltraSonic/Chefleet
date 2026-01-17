import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chefleet/shared/widgets/smart_cart_fab.dart';
import 'package:chefleet/core/theme/app_theme.dart';

void main() {
  group('SmartCartFAB Widget Tests', () {
    Widget createTestWidget({
      required int itemCount,
      required double total,
      required VoidCallback onTap,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SmartCartFAB(
            itemCount: itemCount,
            total: total,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('displays compact icon when cart is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 0,
          total: 0.0,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Should show just the shopping bag icon
      final icon = find.byIcon(Icons.shopping_bag);
      expect(icon, findsOneWidget);

      // Should not show text
      expect(find.text('View Cart'), findsNothing);
    });

    testWidgets('expands when items are added', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 3,
          total: 42.50,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Should show expanded view with text
      expect(find.text('View Cart'), findsOneWidget);
      expect(find.text('R42.50'), findsOneWidget);
    });

    testWidgets('displays correct item count badge',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 5,
          total: 89.99,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Should show badge with count
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('displays formatted total price', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 2,
          total: 123.45,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Should show formatted price
      expect(find.text('R123.45'), findsOneWidget);
    });

    testWidgets('calls onTap when pressed', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          itemCount: 1,
          total: 15.99,
          onTap: () {
            wasTapped = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap the FAB
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });

    testWidgets('animates expansion when items change',
        (WidgetTester tester) async {
      int itemCount = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return createTestWidget(
              itemCount: itemCount,
              total: itemCount * 10.0,
              onTap: () {},
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Initially compact
      expect(find.text('View Cart'), findsNothing);

      // Update with items
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 3,
          total: 30.0,
          onTap: () {},
        ),
      );

      // Start animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Complete animation
      await tester.pumpAndSettle();

      // Should now be expanded
      expect(find.text('View Cart'), findsOneWidget);
    });

    testWidgets('has proper shadow/elevation', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 2,
          total: 25.0,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Find AnimatedContainer with shadow
      final container = find.byType(AnimatedContainer);
      expect(container, findsOneWidget);

      final containerWidget = tester.widget<AnimatedContainer>(container);
      final decoration = containerWidget.decoration as BoxDecoration;
      
      // Should have shadow
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, greaterThan(0));
    });

    testWidgets('displays shopping bag icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 2,
          total: 25.0,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Should always show shopping bag icon
      expect(find.byIcon(Icons.shopping_bag), findsOneWidget);
    });

    testWidgets('badge has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 7,
          total: 50.0,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Find the badge text
      final badgeText = tester.widget<Text>(find.text('7'));
      
      // Verify styling
      expect(badgeText.style?.fontSize, 10);
      expect(badgeText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('handles large item counts', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 99,
          total: 999.99,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Should display large numbers correctly
      expect(find.text('99'), findsOneWidget);
      expect(find.text('R999.99'), findsOneWidget);
    });

    testWidgets('handles zero price', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 1,
          total: 0.0,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Should show R0.00
      expect(find.textContaining('R0'), findsOneWidget);
    });

    testWidgets('uses correct colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 3,
          total: 45.0,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Find container
      final container = find.byType(AnimatedContainer);
      final containerWidget = tester.widget<AnimatedContainer>(container);
      final decoration = containerWidget.decoration as BoxDecoration;

      // Should have dark background
      expect(decoration.color, isNotNull);
    });

    testWidgets('maintains rounded shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 2,
          total: 30.0,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Find container
      final container = find.byType(AnimatedContainer);
      final containerWidget = tester.widget<AnimatedContainer>(container);
      final decoration = containerWidget.decoration as BoxDecoration;

      // Should have border radius
      expect(decoration.borderRadius, isNotNull);
    });

    testWidgets('shows View Cart text only when expanded',
        (WidgetTester tester) async {
      // Empty cart
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 0,
          total: 0.0,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('View Cart'), findsNothing);

      // With items
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 1,
          total: 10.0,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('View Cart'), findsOneWidget);
    });

    testWidgets('handles decimal prices correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 2,
          total: 19.99,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Should format with 2 decimal places
      expect(find.text('R19.99'), findsOneWidget);
    });

    testWidgets('animation duration is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 0,
          total: 0.0,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Change to expanded
      await tester.pumpWidget(
        createTestWidget(
          itemCount: 1,
          total: 10.0,
          onTap: () {},
        ),
      );

      // Get AnimatedContainer
      final container = find.byType(AnimatedContainer);
      final containerWidget = tester.widget<AnimatedContainer>(container);

      // Verify animation duration
      expect(containerWidget.duration, const Duration(milliseconds: 300));
      expect(containerWidget.curve, Curves.easeInOut);
    });
  });
}
