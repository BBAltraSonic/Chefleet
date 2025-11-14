import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chefleet/features/feed/widgets/dish_card.dart';
import 'package:chefleet/features/feed/models/dish_model.dart';

void main() {
  group('DishCard Widget', () {
    late Dish testDish;

    setUp(() {
      testDish = Dish(
        id: 'dish1',
        name: 'Test Dish',
        price: 10.99,
        vendorId: 'vendor1',
        available: true,
        description: 'A delicious test dish',
      );
    });

    testWidgets('displays dish information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DishCard(
              dish: testDish,
              vendorName: 'Test Vendor',
              distance: 1.5,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Dish'), findsOneWidget);
      expect(find.text('Test Vendor'), findsOneWidget);
      expect(find.text('\$10.99'), findsOneWidget);
    });

    testWidgets('responds to tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DishCard(
              dish: testDish,
              vendorName: 'Test Vendor',
              distance: 1.5,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DishCard));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('displays distance when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DishCard(
              dish: testDish,
              vendorName: 'Test Vendor',
              distance: 2.3,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('km'), findsWidgets);
    });
  });
}
