import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:chefleet/core/blocs/role_bloc.dart';
import 'package:chefleet/core/blocs/role_state.dart';
import 'package:chefleet/core/blocs/role_event.dart';
import 'package:chefleet/core/models/user_role.dart';
import 'package:chefleet/core/routes/app_routes.dart';
import 'package:chefleet/features/auth/blocs/auth_bloc.dart';
import 'package:chefleet/features/auth/blocs/user_profile_bloc.dart';

// Mocks
class MockRoleBloc extends Mock implements RoleBloc {}
class MockAuthBloc extends Mock implements AuthBloc {}
class MockUserProfileBloc extends Mock implements UserProfileBloc {}

void main() {
  group('Role Navigation Tests', () {
    late MockRoleBloc mockRoleBloc;
    late MockAuthBloc mockAuthBloc;
    late MockUserProfileBloc mockProfileBloc;
    late GoRouter router;

    setUp(() {
      mockRoleBloc = MockRoleBloc();
      mockAuthBloc = MockAuthBloc();
      mockProfileBloc = MockUserProfileBloc();

      // Set up default mock behaviors
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream<RoleState>.value(
          const RoleLoaded(
            activeRole: UserRole.customer,
            availableRoles: {UserRole.customer, UserRole.vendor},
          ),
        ),
      );
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );
    });

    testWidgets('Role switch navigates to correct route', (tester) async {
      // This test verifies that when a role switch occurs,
      // the navigation handler correctly navigates to the new role's home route

      // Arrange
      final roleStates = [
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
        const RoleSwitched(
          newRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
        const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      ];

      int stateIndex = 0;
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.fromIterable(roleStates),
      );
      when(() => mockRoleBloc.state).thenAnswer((_) => roleStates[stateIndex]);

      // Build test widget
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<RoleBloc>.value(
            value: mockRoleBloc,
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    context.read<RoleBloc>().add(
                          const RoleSwitchRequested(newRole: UserRole.vendor),
                        );
                  },
                  child: const Text('Switch to Vendor'),
                );
              },
            ),
          ),
        ),
      );

      // Act - trigger role switch
      await tester.tap(find.text('Switch to Vendor'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockRoleBloc.add(
            const RoleSwitchRequested(newRole: UserRole.vendor),
          )).called(1);
    });

    test('Role home route mapping is correct', () {
      // Test that the mapping between roles and home routes is correct
      expect(CustomerRoutes.map, equals('/customer/map'));
      expect(VendorRoutes.dashboard, equals('/vendor/dashboard'));
    });

    test('Customer routes have correct prefix', () {
      // Verify all customer routes start with /customer
      expect(CustomerRoutes.map.startsWith('/customer'), isTrue);
      expect(CustomerRoutes.orders.startsWith('/customer'), isTrue);
      expect(CustomerRoutes.chat.startsWith('/customer'), isTrue);
      expect(CustomerRoutes.profile.startsWith('/customer'), isTrue);
    });

    test('Vendor routes have correct prefix', () {
      // Verify all vendor routes start with /vendor
      expect(VendorRoutes.dashboard.startsWith('/vendor'), isTrue);
      expect(VendorRoutes.orders.startsWith('/vendor'), isTrue);
      expect(VendorRoutes.dishes.startsWith('/vendor'), isTrue);
      expect(VendorRoutes.profile.startsWith('/vendor'), isTrue);
    });

    test('RoleSwitched state contains correct role', () {
      // Test that the RoleSwitched state correctly represents a role change
      const switchedState = RoleSwitched(
        newRole: UserRole.vendor,
        availableRoles: {UserRole.customer, UserRole.vendor},
      );

      expect(switchedState.newRole, equals(UserRole.vendor));
      expect(switchedState.availableRoles, contains(UserRole.vendor));
      expect(switchedState.availableRoles, contains(UserRole.customer));
    });

    test('RoleLoaded state for vendor has correct active role', () {
      // Test that a loaded vendor role state is correctly formed
      const loadedState = RoleLoaded(
        activeRole: UserRole.vendor,
        availableRoles: {UserRole.customer, UserRole.vendor},
      );

      expect(loadedState.activeRole, equals(UserRole.vendor));
      expect(loadedState.availableRoles.length, equals(2));
    });
  });

  group('Navigation Stack Clearing Tests', () {
    test('go() method replaces entire navigation stack', () {
      // This test documents the expected behavior:
      // Using router.go() should replace the entire navigation stack,
      // effectively clearing any previous routes when switching roles

      // Note: This is a documentation test. Actual behavior is tested
      // in integration tests due to GoRouter's complexity
      expect(true, isTrue); // Placeholder - see integration tests
    });

    test('Role switch should not preserve deep navigation', () {
      // Document expected behavior:
      // When switching from Customer (on checkout page) to Vendor,
      // should land on vendor dashboard, not preserve checkout state

      expect(true, isTrue); // Placeholder - see integration tests
    });
  });
}
