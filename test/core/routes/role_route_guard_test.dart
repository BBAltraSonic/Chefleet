import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/core/routes/role_route_guard.dart';
import 'package:chefleet/core/routes/app_routes.dart';
import 'package:chefleet/core/models/user_role.dart';
import 'package:chefleet/core/blocs/role_bloc.dart';
import 'package:chefleet/core/blocs/role_state.dart';

// Mocks
class MockRoleBloc extends Mock implements RoleBloc {}
class MockGoRouterState extends Mock implements GoRouterState {}

void main() {
  late MockRoleBloc mockRoleBloc;
  late RoleRouteGuard routeGuard;

  setUp(() {
    mockRoleBloc = MockRoleBloc();
    routeGuard = RoleRouteGuard(roleBloc: mockRoleBloc);
  });

  group('RoleRouteGuard - Customer Routes', () {
    test('allows customer to access customer routes', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(CustomerRoutes.feed);

      // Act
      final result = routeGuard.canAccess(state);

      // Assert
      expect(result, isTrue);
    });

    test('redirects vendor to vendor root when accessing customer routes', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(CustomerRoutes.feed);

      // Act
      final result = routeGuard.canAccess(state);
      final redirect = routeGuard.getRedirectPath(state);

      // Assert
      expect(result, isFalse);
      expect(redirect, equals(VendorRoutes.dashboard));
    });

    test('allows access to customer dish detail route', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn('${CustomerRoutes.dish}/123');

      // Act
      final result = routeGuard.canAccess(state);

      // Assert
      expect(result, isTrue);
    });

    test('allows access to customer cart route', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(CustomerRoutes.cart);

      // Act
      final result = routeGuard.canAccess(state);

      // Assert
      expect(result, isTrue);
    });

    test('allows access to customer orders route', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(CustomerRoutes.orders);

      // Act
      final result = routeGuard.canAccess(state);

      // Assert
      expect(result, isTrue);
    });
  });

  group('RoleRouteGuard - Vendor Routes', () {
    test('allows vendor to access vendor routes', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(VendorRoutes.dashboard);

      // Act
      final result = routeGuard.canAccess(state);

      // Assert
      expect(result, isTrue);
    });

    test('redirects customer to customer root when accessing vendor routes', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(VendorRoutes.dashboard);

      // Act
      final result = routeGuard.canAccess(state);
      final redirect = routeGuard.getRedirectPath(state);

      // Assert
      expect(result, isFalse);
      expect(redirect, equals(CustomerRoutes.feed));
    });

    test('blocks customer without vendor role from vendor routes', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(VendorRoutes.orders);

      // Act
      final result = routeGuard.canAccess(state);

      // Assert
      expect(result, isFalse);
    });

    test('allows access to vendor orders route', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(VendorRoutes.orders);

      // Act
      final result = routeGuard.canAccess(state);

      // Assert
      expect(result, isTrue);
    });

    test('allows access to vendor dishes route', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(VendorRoutes.dishes);

      // Act
      final result = routeGuard.canAccess(state);

      // Assert
      expect(result, isTrue);
    });

    test('allows access to vendor analytics route', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(VendorRoutes.analytics);

      // Act
      final result = routeGuard.canAccess(state);

      // Assert
      expect(result, isTrue);
    });
  });

  group('RoleRouteGuard - Shared Routes', () {
    test('allows customer to access shared routes', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(SharedRoutes.auth);

      // Act
      final result = routeGuard.canAccess(state);

      // Assert
      expect(result, isTrue);
    });

    test('allows vendor to access shared routes', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(SharedRoutes.onboarding);

      // Act
      final result = routeGuard.canAccess(state);

      // Assert
      expect(result, isTrue);
    });

    test('allows access to profile route from both roles', () {
      // Arrange - Customer
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(CustomerRoutes.profile);

      // Act
      final customerResult = routeGuard.canAccess(state);

      // Arrange - Vendor
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );
      when(() => state.matchedLocation).thenReturn(VendorRoutes.profile);

      // Act
      final vendorResult = routeGuard.canAccess(state);

      // Assert
      expect(customerResult, isTrue);
      expect(vendorResult, isTrue);
    });

    test('allows access to chat routes from both roles', () {
      // Arrange - Customer
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(CustomerRoutes.chat);

      // Act
      final customerResult = routeGuard.canAccess(state);

      // Arrange - Vendor
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );
      when(() => state.matchedLocation).thenReturn(VendorRoutes.chat);

      // Act
      final vendorResult = routeGuard.canAccess(state);

      // Assert
      expect(customerResult, isTrue);
      expect(vendorResult, isTrue);
    });
  });

  group('RoleRouteGuard - Edge Cases', () {
    test('redirects to customer root when role is not loaded', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(const RoleInitial());

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(CustomerRoutes.feed);

      // Act
      final result = routeGuard.canAccess(state);
      final redirect = routeGuard.getRedirectPath(state);

      // Assert
      expect(result, isFalse);
      expect(redirect, equals(SharedRoutes.auth));
    });

    test('handles unknown routes gracefully', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn('/unknown/route');

      // Act
      final result = routeGuard.canAccess(state);

      // Assert
      expect(result, isFalse);
    });

    test('logs unauthorized access attempts', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(VendorRoutes.dashboard);

      // Act
      routeGuard.canAccess(state);

      // Assert - verify logging occurred (implementation dependent)
      // This would require a logger mock in actual implementation
      expect(routeGuard.getLastUnauthorizedAttempt(), isNotNull);
    });

    test('handles rapid route changes', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );

      final state = MockGoRouterState();

      // Act - multiple rapid checks
      when(() => state.matchedLocation).thenReturn(CustomerRoutes.feed);
      final result1 = routeGuard.canAccess(state);

      when(() => state.matchedLocation).thenReturn(CustomerRoutes.orders);
      final result2 = routeGuard.canAccess(state);

      when(() => state.matchedLocation).thenReturn(CustomerRoutes.cart);
      final result3 = routeGuard.canAccess(state);

      // Assert
      expect(result1, isTrue);
      expect(result2, isTrue);
      expect(result3, isTrue);
    });

    test('handles deep links correctly', () {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn('${CustomerRoutes.dish}/abc-123?source=deeplink');

      // Act
      final result = routeGuard.canAccess(state);

      // Assert
      expect(result, isTrue);
    });
  });

  group('RoleRouteGuard - Role Switching Scenarios', () {
    test('allows access after role switch', () {
      // Arrange - Start as customer
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(VendorRoutes.dashboard);

      // Act - Try to access vendor route as customer
      final resultBeforeSwitch = routeGuard.canAccess(state);

      // Arrange - Switch to vendor
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );

      // Act - Try to access vendor route as vendor
      final resultAfterSwitch = routeGuard.canAccess(state);

      // Assert
      expect(resultBeforeSwitch, isFalse);
      expect(resultAfterSwitch, isTrue);
    });

    test('blocks previous role routes after switch', () {
      // Arrange - Start as vendor
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );

      final state = MockGoRouterState();
      when(() => state.matchedLocation).thenReturn(CustomerRoutes.cart);

      // Act - Try to access customer route as vendor
      final resultBeforeSwitch = routeGuard.canAccess(state);

      // Arrange - Switch to customer
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );

      // Act - Try to access customer route as customer
      final resultAfterSwitch = routeGuard.canAccess(state);

      // Assert
      expect(resultBeforeSwitch, isFalse);
      expect(resultAfterSwitch, isTrue);
    });
  });
}
