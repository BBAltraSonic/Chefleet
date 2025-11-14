import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chefleet/features/feed/widgets/vendor_mini_card.dart';
import 'package:chefleet/features/feed/models/vendor_model.dart';

void main() {
  group('VendorMiniCard Widget', () {
    late Vendor testVendor;

    setUp(() {
      testVendor = Vendor(
        id: 'vendor1',
        name: 'Test Vendor',
        latitude: 37.7749,
        longitude: -122.4194,
        isActive: true,
        dishCount: 5,
      );
    });

    testWidgets('displays vendor information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VendorMiniCard(
              vendor: testVendor,
              dishCount: 5,
              onClose: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Vendor'), findsOneWidget);
      expect(find.textContaining('5'), findsWidgets);
    });

    testWidgets('close button triggers onClose callback', (WidgetTester tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VendorMiniCard(
              vendor: testVendor,
              dishCount: 5,
              onClose: () {
                closed = true;
              },
              onViewDetails: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(closed, true);
    });

    testWidgets('view details triggers onViewDetails callback', (WidgetTester tester) async {
      bool viewedDetails = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VendorMiniCard(
              vendor: testVendor,
              dishCount: 5,
              onClose: () {},
              onViewDetails: () {
                viewedDetails = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('View Details'));
      await tester.pumpAndSettle();

      expect(viewedDetails, true);
    });
  });
}
