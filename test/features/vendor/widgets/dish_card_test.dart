import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chefleet/features/vendor/widgets/dish_card.dart';
import 'package:chefleet/features/feed/models/dish_model.dart';

void main() {
  group('DishCard Widget Tests', () {
    late Dish testDish;
    late Dish unavailableDish;
    late Dish featuredDish;

    setUp(() {
      testDish = Dish(
        id: '1',
        vendorId: 'vendor-1',
        name: 'Test Burger',
        description: 'A delicious test burger',
        descriptionLong: 'This is a very detailed description of our test burger with all the ingredients and preparation details.',
        priceCents: 1299,
        category: 'Main Course',
        categoryEnum: 'Main Course',
        imageUrl: 'https://example.com/burger.jpg',
        available: true,
        isFeatured: false,
        ingredients: ['beef patty', 'lettuce', 'tomato', 'bun'],
        allergens: ['gluten', 'dairy'],
        dietaryRestrictions: ['contains gluten'],
        preparationTimeMinutes: 15,
        spiceLevel: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      unavailableDish = testDish.copyWith(available: false);
      featuredDish = testDish.copyWith(isFeatured: true);
    });

    Widget createWidgetUnderTest({required Dish dish, required VoidCallback onEdit, required VoidCallback onDelete, required VoidCallback onToggleAvailability}) {
      return MaterialApp(
        home: Scaffold(
          body: DishCard(
            dish: dish,
            onEdit: onEdit,
            onDelete: onDelete,
            onToggleAvailability: onToggleAvailability,
          ),
        ),
      );
    }

    testWidgets('displays dish information correctly', (WidgetTester tester) async {
      bool onEditCalled = false;
      bool onDeleteCalled = false;
      bool onToggleCalled = false;

      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: testDish,
          onEdit: () => onEditCalled = true,
          onDelete: () => onDeleteCalled = true,
          onToggleAvailability: () => onToggleCalled = true,
        ),
      );

      // Check if dish name is displayed
      expect(find.text('Test Burger'), findsOneWidget);

      // Check if description is displayed
      expect(find.text('A delicious test burger'), findsOneWidget);

      // Check if price is displayed
      expect(find.text('R12.99'), findsOneWidget);

      // Check if category is displayed
      expect(find.text('Main Course'), findsOneWidget);

      // Check if available status is displayed
      expect(find.text('Available'), findsOneWidget);
    });

    testWidgets('displays unavailable dish correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: unavailableDish,
          onEdit: () {},
          onDelete: () {},
          onToggleAvailability: () {},
        ),
      );

      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.text('Available'), findsNothing);
    });

    testWidgets('displays featured dish correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: featuredDish,
          onEdit: () {},
          onDelete: () {},
          onToggleAvailability: () {},
        ),
      );

      // Check for star icon for featured dishes
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('displays image when available', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: testDish,
          onEdit: () {},
          onDelete: () {},
          onToggleAvailability: () {},
        ),
      );

      // Check if network image is displayed
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays placeholder when no image', (WidgetTester tester) async {
      final dishWithoutImage = testDish.copyWith(imageUrl: null);

      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: dishWithoutImage,
          onEdit: () {},
          onDelete: () {},
          onToggleAvailability: () {},
        ),
      );

      // Check if placeholder icon is displayed
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('displays dietary restrictions correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: testDish,
          onEdit: () {},
          onDelete: () {},
          onToggleAvailability: () {},
        ),
      );

      // Check if dietary restrictions are displayed
      expect(find.text('contains gluten'), findsOneWidget);
    });

    testWidgets('displays preparation time and spice level', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: testDish,
          onEdit: () {},
          onDelete: () {},
          onToggleAvailability: () {},
        ),
      );

      // Check if preparation time is displayed
      expect(find.text('15 min'), findsOneWidget);

      // Check if spice level is displayed
      expect(find.text('Spice: 2/5'), findsOneWidget);
    });

    testWidgets('triggers onEdit callback when edit button is pressed', (WidgetTester tester) async {
      bool onEditCalled = false;

      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: testDish,
          onEdit: () => onEditCalled = true,
          onDelete: () {},
          onToggleAvailability: () {},
        ),
      );

      // Find and tap the edit button
      await tester.tap(find.byKey(const Key('edit_button')));
      await tester.pump();

      expect(onEditCalled, isTrue);
    });

    testWidgets('triggers onDelete callback when delete button is pressed', (WidgetTester tester) async {
      bool onDeleteCalled = false;

      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: testDish,
          onEdit: () {},
          onDelete: () => onDeleteCalled = true,
          onToggleAvailability: () {},
        ),
      );

      // Find and tap the delete button
      await tester.tap(find.byKey(const Key('delete_button')));
      await tester.pump();

      expect(onDeleteCalled, isTrue);
    });

    testWidgets('triggers onToggleAvailability callback when toggle button is pressed', (WidgetTester tester) async {
      bool onToggleCalled = false;

      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: testDish,
          onEdit: () {},
          onDelete: () {},
          onToggleAvailability: () => onToggleCalled = true,
        ),
      );

      // Find and tap the toggle availability button
      await tester.tap(find.byKey(const Key('toggle_button')));
      await tester.pump();

      expect(onToggleCalled, isTrue);
    });

    testWidgets('displays correct toggle button text based on availability', (WidgetTester tester) async {
      // Test available dish
      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: testDish,
          onEdit: () {},
          onDelete: () {},
          onToggleAvailability: () {},
        ),
      );

      expect(find.text('Hide'), findsOneWidget);
      expect(find.text('Show'), findsNothing);

      // Test unavailable dish
      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: unavailableDish,
          onEdit: () {},
          onDelete: () {},
          onToggleAvailability: () {},
        ),
      );

      expect(find.text('Show'), findsOneWidget);
      expect(find.text('Hide'), findsNothing);
    });

    testWidgets('displays ingredients when available', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: testDish,
          onEdit: () {},
          onDelete: () {},
          onToggleAvailability: () {},
        ),
      );

      // Check if ingredients are displayed
      expect(find.text('beef patty, lettuce, tomato, bun'), findsOneWidget);
    });

    testWidgets('displays allergens when available', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: testDish,
          onEdit: () {},
          onDelete: () {},
          onToggleAvailability: () {},
        ),
      );

      // Check if allergens are displayed
      expect(find.text('gluten, dairy'), findsOneWidget);
    });

    testWidgets('handles dish without optional fields gracefully', (WidgetTester tester) async {
      final minimalDish = Dish(
        id: '1',
        vendorId: 'vendor-1',
        name: 'Simple Dish',
        priceCents: 999,
        category: 'Appetizer',
        available: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: minimalDish,
          onEdit: () {},
          onDelete: () {},
          onToggleAvailability: () {},
        ),
      );

      // Check that basic information is still displayed
      expect(find.text('Simple Dish'), findsOneWidget);
      expect(find.text('\$9.99'), findsOneWidget);
      expect(find.text('Appetizer'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);

      // Check that optional fields don't cause errors
      expect(find.byIcon(Icons.restaurant), findsOneWidget); // Placeholder image
    });

    testWidgets('applies correct styling for available status', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: testDish,
          onEdit: () {},
          onDelete: () {},
          onToggleAvailability: () {},
        ),
      );

      // Find the availability status container
      final availabilityContainer = tester.widget(find.byType(Container).last);
      final decoration = (availabilityContainer as Container).decoration as BoxDecoration;

      // Check if it has green color for available status
      expect(decoration.color, Colors.green.withOpacity(0.1));
    });

    testWidgets('applies correct styling for unavailable status', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          dish: unavailableDish,
          onEdit: () {},
          onDelete: () {},
          onToggleAvailability: () {},
        ),
      );

      // Find the availability status container
      final availabilityContainer = tester.widget(find.byType(Container).last);
      final decoration = (availabilityContainer as Container).decoration as BoxDecoration;

      // Check if it has red color for unavailable status
      expect(decoration.color, Colors.red.withOpacity(0.1));
    });
  });
}