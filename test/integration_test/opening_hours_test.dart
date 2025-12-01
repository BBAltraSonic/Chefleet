import 'package:flutter_test/flutter_test.dart';
import 'package:chefleet/features/vendor/models/vendor_model.dart';

void main() {
  group('Opening Hours Integration Tests', () {
    test('Vendor model supports opening hours JSON', () {
      // Test that vendor model can handle opening hours
      final vendor = Vendor(
        businessName: 'Test Restaurant',
        phone: '555-1234',
        address: '123 Main St',
        openHoursJson: {
          'monday': {'open': '09:00', 'close': '17:00'},
          'tuesday': {'open': '09:00', 'close': '17:00'},
          'wednesday': {'open': '09:00', 'close': '17:00'},
          'thursday': {'open': '09:00', 'close': '17:00'},
          'friday': {'open': '09:00', 'close': '17:00'},
          'saturday': {'open': '10:00', 'close': '15:00'},
          'sunday': null, // Closed
        },
      );

      expect(vendor.openHoursJson, isNotNull);
      expect(vendor.openingHoursJson!.contains('monday'), true);
      expect(vendor.openingHoursJson!.contains('sunday'), true);
    });

    test('Vendor model handles missing opening hours', () {
      final vendor = Vendor(
        businessName: 'Test Restaurant',
        phone: '555-1234',
        address: '123 Main St',
        openHoursJson: null,
      );

      expect(vendor.openingHoursJson, isNull);
    });

    test('Opening hours display works', () {
      final vendor = Vendor(
        businessName: 'Test Restaurant',
        phone: '555-1234',
        address: '123 Main St',
        openHoursJson: {
          'monday': {'open': '09:00', 'close': '17:00'},
          'tuesday': {'open': '09:00', 'close': '17:00'},
        },
      );

      expect(vendor.openingHoursDisplay, isNotNull);
      expect(vendor.openingHoursDisplay!.contains('Mon'), true);
    });
  });
}