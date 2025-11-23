import 'package:chefleet/features/feed/models/vendor_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Vendor model phone fields', () {
    test('fromJson prefers phone over phone_number when both are present', () {
      final vendor = Vendor.fromJson({
        'id': 'vendor_1',
        'business_name': 'Test Vendor',
        'description': 'Test',
        'latitude': 0,
        'longitude': 0,
        'address': '123 Test St',
        'phone': '+123',
        'phone_number': '+456',
      });

      expect(vendor.phoneNumber, '+123');
    });

    test('fromJson falls back to phone_number for legacy rows', () {
      final vendor = Vendor.fromJson({
        'id': 'vendor_2',
        'business_name': 'Legacy Vendor',
        'description': 'Legacy',
        'latitude': 0,
        'longitude': 0,
        'address': '456 Test St',
        'phone_number': '+999',
      });

      expect(vendor.phoneNumber, '+999');
    });

    test('toJson stores phoneNumber under phone column expected by DB schema', () {
      const vendor = Vendor(
        id: 'vendor_3',
        name: 'Persisted Vendor',
        description: 'Persisted',
        latitude: 0,
        longitude: 0,
        address: '789 Test St',
        phoneNumber: '+111',
        isActive: true,
      );

      final json = vendor.toJson();

      expect(json['phone'], '+111');
      expect(json.containsKey('phone_number'), isFalse);
    });
  });
}
