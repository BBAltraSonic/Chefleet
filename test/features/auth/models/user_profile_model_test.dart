import 'package:chefleet/core/models/user_role.dart';
import 'package:chefleet/features/auth/models/user_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile.fromJson', () {
    test('parses role and available_roles columns when provided', () {
      final profile = UserProfile.fromJson({
        'id': 'row-id',
        'user_id': 'user-123',
        'full_name': 'Test Vendor',
        'role': 'vendor',
        'available_roles': ['customer', 'vendor'],
        'vendor_profile_id': 'vendor-1',
      });

      expect(profile.activeRole, UserRole.vendor);
      expect(profile.availableRoles, containsAll(<UserRole>[UserRole.customer, UserRole.vendor]));
      expect(profile.vendorProfileId, 'vendor-1');
    });

    test('falls back to vendor role when vendor_profile_id exists', () {
      final profile = UserProfile.fromJson({
        'id': 'row-id',
        'user_id': 'user-123',
        'full_name': 'Test Vendor',
        'vendor_profile_id': 'vendor-1',
      });

      expect(profile.availableRoles.contains(UserRole.vendor), isTrue);
      expect(profile.activeRole, UserRole.customer);
    });
  });
}
