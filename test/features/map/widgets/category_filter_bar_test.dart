import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chefleet/features/map/widgets/category_filter_bar.dart';
import 'package:chefleet/core/theme/app_theme.dart';

void main() {
  group('CategoryFilterBar Widget Tests', () {
    Widget createTestWidget({
      required String selectedCategory,
      required Function(String) onCategorySelected,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: CategoryFilterBar(
            selectedCategory: selectedCategory,
            onCategorySelected: onCategorySelected,
          ),
        ),
      );
    }

    testWidgets('displays all category chips', (WidgetTester tester) async {
      String? selectedCategory;
      
      await tester.pumpWidget(
        createTestWidget(
          selectedCategory: 'All',
          onCategorySelected: (category) {
            selectedCategory = category;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Should display all categories
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Sushi'), findsOneWidget);
      expect(find.text('Burger'), findsOneWidget);
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text('Healthy'), findsOneWidget);
      expect(find.text('Dessert'), findsOneWidget);
    });

    testWidgets('highlights selected category', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedCategory: 'Pizza',
          onCategorySelected: (category) {},
        ),
      );
      await tester.pumpAndSettle();

      // Find the Pizza chip container
      final pizzaChip = find.ancestor(
        of: find.text('Pizza'),
        matching: find.byType(AnimatedContainer),
      );

      expect(pizzaChip, findsOneWidget);

      // Get the AnimatedContainer widget
      final containerWidget = tester.widget<AnimatedContainer>(pizzaChip);
      final decoration = containerWidget.decoration as BoxDecoration;

      // Verify it has dark background (selected state)
      expect(decoration.color, isNotNull);
    });

    testWidgets('calls onCategorySelected when chip is tapped',
        (WidgetTester tester) async {
      String? selectedCategory;

      await tester.pumpWidget(
        createTestWidget(
          selectedCategory: 'All',
          onCategorySelected: (category) {
            selectedCategory = category;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Sushi category
      await tester.tap(find.text('Sushi'));
      await tester.pumpAndSettle();

      expect(selectedCategory, 'Sushi');
    });

    testWidgets('allows tapping different categories',
        (WidgetTester tester) async {
      String? lastSelected;

      await tester.pumpWidget(
        createTestWidget(
          selectedCategory: 'All',
          onCategorySelected: (category) {
            lastSelected = category;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap multiple categories
      await tester.tap(find.text('Burger'));
      await tester.pumpAndSettle();
      expect(lastSelected, 'Burger');

      await tester.tap(find.text('Healthy'));
      await tester.pumpAndSettle();
      expect(lastSelected, 'Healthy');

      await tester.tap(find.text('Dessert'));
      await tester.pumpAndSettle();
      expect(lastSelected, 'Dessert');
    });

    testWidgets('scrolls horizontally', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedCategory: 'All',
          onCategorySelected: (category) {},
        ),
      );
      await tester.pumpAndSettle();

      // Find the ListView
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // Verify it's horizontal
      final listViewWidget = tester.widget<ListView>(listView);
      expect(listViewWidget.scrollDirection, Axis.horizontal);
    });

    testWidgets('has proper spacing between chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedCategory: 'All',
          onCategorySelected: (category) {},
        ),
      );
      await tester.pumpAndSettle();

      // Find SizedBox widgets (separators)
      final separators = find.byType(SizedBox);
      expect(separators, findsWidgets);
    });

    testWidgets('animates category selection', (WidgetTester tester) async {
      String selectedCategory = 'All';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return createTestWidget(
              selectedCategory: selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  selectedCategory = category;
                });
              },
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap Pizza
      await tester.tap(find.text('Pizza'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 150)); // Mid animation
      
      // Should be animating
      expect(find.text('Pizza'), findsOneWidget);
      
      await tester.pumpAndSettle(); // Complete animation
    });

    testWidgets('uses correct text styles for selected chip',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedCategory: 'Sushi',
          onCategorySelected: (category) {},
        ),
      );
      await tester.pumpAndSettle();

      // Find the Sushi text widget
      final sushiText = tester.widget<Text>(find.text('Sushi'));
      
      // Selected chip should have white text
      expect(sushiText.style?.color, Colors.white);
      expect(sushiText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('uses correct text styles for unselected chip',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedCategory: 'All',
          onCategorySelected: (category) {},
        ),
      );
      await tester.pumpAndSettle();

      // Find the Pizza text widget (unselected)
      final pizzaText = tester.widget<Text>(find.text('Pizza'));
      
      // Unselected chip should have grey text
      expect(pizzaText.style?.color, isNot(Colors.white));
      expect(pizzaText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('has proper height constraint', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedCategory: 'All',
          onCategorySelected: (category) {},
        ),
      );
      await tester.pumpAndSettle();

      // Find the Container with height constraint
      final container = find.ancestor(
        of: find.byType(ListView),
        matching: find.byType(Container),
      );

      expect(container, findsOneWidget);
      final containerWidget = tester.widget<Container>(container);
      expect(containerWidget.constraints?.maxHeight, 50);
    });

    testWidgets('maintains state across rebuilds', (WidgetTester tester) async {
      String selectedCategory = 'Burger';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return createTestWidget(
              selectedCategory: selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  selectedCategory = category;
                });
              },
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Verify Burger is selected
      final burgerChip = find.ancestor(
        of: find.text('Burger'),
        matching: find.byType(AnimatedContainer),
      );
      expect(burgerChip, findsOneWidget);

      // Tap Pizza
      await tester.tap(find.text('Pizza'));
      await tester.pumpAndSettle();

      // Verify Pizza is now selected
      final pizzaChip = find.ancestor(
        of: find.text('Pizza'),
        matching: find.byType(AnimatedContainer),
      );
      expect(pizzaChip, findsOneWidget);
    });

    testWidgets('handles rapid taps correctly', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        createTestWidget(
          selectedCategory: 'All',
          onCategorySelected: (category) {
            tapCount++;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Rapidly tap different categories
      await tester.tap(find.text('Sushi'));
      await tester.tap(find.text('Burger'));
      await tester.tap(find.text('Pizza'));
      await tester.pumpAndSettle();

      // Should have registered all taps
      expect(tapCount, 3);
    });
  });
}
