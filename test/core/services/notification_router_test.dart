import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:chefleet/core/services/notification_router.dart';
import 'package:chefleet/core/models/user_role.dart';
import 'package:chefleet/core/blocs/role_bloc.dart';
import 'package:chefleet/core/blocs/role_event.dart';
import 'package:chefleet/core/blocs/role_state.dart';

// Mocks
class MockRoleBloc extends Mock implements RoleBloc {}
class MockGoRouter extends Mock implements GoRouter {}
class MockBuildContext extends Mock implements BuildContext {}

// Fake classes for mocktail
class FakeRoleEvent extends Fake implements RoleEvent {}

void main() {
  late MockRoleBloc mockRoleBloc;
  late MockGoRouter mockGoRouter;
  late NotificationRouter notificationRouter;

  setUpAll(() {
    registerFallbackValue(FakeRoleEvent());
    registerFallbackValue(UserRole.customer);
  });

  setUp(() {
    mockRoleBloc = MockRoleBloc();
    mockGoRouter = MockGoRouter();

    notificationRouter = NotificationRouter(
      roleBloc: mockRoleBloc,
      goRouter: mockGoRouter,
    );

    // Setup default mocks
    when(() => mockRoleBloc.currentRole).thenReturn(UserRole.customer);
    when(() => mockRoleBloc.availableRoles).thenReturn({UserRole.customer, UserRole.vendor});
    when(() => mockRoleBloc.add(any())).thenReturn(null);
    when(() => mockGoRouter.go(any())).thenReturn(null);
  });

  group('NotificationRouter - Parsing', () {
    test('parses valid notification data', () async {
      // Arrange
      final notificationData = {
        'type': 'new_order',
        'target_role': 'vendor',
        'route': '/vendor/orders',
        'title': 'New Order',
        'body': 'You have a new order',
        'params': {'order_id': '123'},
      };

      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        )),
      );

      // Act
      final result = await notificationRouter.handleNotification(notificationData);

      // Assert
      expect(result, isTrue);
      verify(() => mockGoRouter.go(any())).called(1);
    });

    test('returns false for invalid notification data', () async {
      // Arrange
      final notificationData = {
        'type': 'new_order',
        // Missing target_role and route
      };

      // Act
      final result = await notificationRouter.handleNotification(notificationData);

      // Assert
      expect(result, isFalse);
      verifyNever(() => mockGoRouter.go(any()));
    });
  });

  group('NotificationRouter - Role Validation', () {
    test('returns false when user does not have required role', () async {
      // Arrange
      when(() => mockRoleBloc.availableRoles).thenReturn({UserRole.customer});

      final notificationData = {
        'type': 'new_order',
        'target_role': 'vendor',
        'route': '/vendor/orders',
      };

      // Act
      final result = await notificationRouter.handleNotification(notificationData);

      // Assert
      expect(result, isFalse);
      verifyNever(() => mockGoRouter.go(any()));
    });

    test('navigates without role switch when already in correct role', () async {
      // Arrange
      when(() => mockRoleBloc.currentRole).thenReturn(UserRole.vendor);

      final notificationData = {
        'type': 'new_order',
        'target_role': 'vendor',
        'route': '/vendor/orders',
      };

      // Act
      final result = await notificationRouter.handleNotification(notificationData);

      // Assert
      expect(result, isTrue);
      verify(() => mockGoRouter.go(any())).called(1);
      verifyNever(() => mockRoleBloc.add(any()));
    });
  });

  group('NotificationRouter - Role Switching', () {
    test('switches role when notification requires different role', () async {
      // Arrange
      when(() => mockRoleBloc.currentRole).thenReturn(UserRole.customer);
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        )),
      );

      final notificationData = {
        'type': 'new_order',
        'target_role': 'vendor',
        'route': '/vendor/orders',
      };

      // Act
      final result = await notificationRouter.handleNotification(notificationData);

      // Assert
      expect(result, isTrue);
      verify(() => mockRoleBloc.add(any<RoleSwitchRequested>())).called(1);
      verify(() => mockGoRouter.go(any())).called(1);
    });

    test('handles role switch timeout gracefully', () async {
      // Arrange
      when(() => mockRoleBloc.currentRole).thenReturn(UserRole.customer);
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.periodic(const Duration(seconds: 10)), // Never completes
      );

      final notificationData = {
        'type': 'new_order',
        'target_role': 'vendor',
        'route': '/vendor/orders',
      };

      // Act
      final result = await notificationRouter.handleNotification(notificationData);

      // Assert
      expect(result, isFalse);
    });
  });

  group('NotificationRouter - Route Building', () {
    test('builds route with query parameters', () async {
      // Arrange
      when(() => mockRoleBloc.currentRole).thenReturn(UserRole.customer);

      final notificationData = {
        'type': 'order_status_update',
        'target_role': 'customer',
        'route': '/customer/orders',
        'params': {
          'order_id': '123',
          'status': 'ready',
        },
      };

      // Act
      await notificationRouter.handleNotification(notificationData);

      // Assert
      verify(() => mockGoRouter.go(argThat(contains('order_id=123')))).called(1);
    });
  });

  group('NotificationRouter - Static Methods', () {
    test('getRouteForNotificationType returns correct customer route', () {
      // Act
      final route = NotificationRouter.getRouteForNotificationType(
        'new_order',
        UserRole.customer,
      );

      // Assert
      expect(route, contains('/customer'));
    });

    test('getRouteForNotificationType returns correct vendor route', () {
      // Act
      final route = NotificationRouter.getRouteForNotificationType(
        'new_order',
        UserRole.vendor,
      );

      // Assert
      expect(route, contains('/vendor'));
    });

    test('getRouteForNotificationType includes parameters in route', () {
      // Act
      final route = NotificationRouter.getRouteForNotificationType(
        'order_status_update',
        UserRole.customer,
        params: {'order_id': '123'},
      );

      // Assert
      expect(route, contains('123'));
    });
  });

  group('NotificationData', () {
    test('converts to map correctly', () {
      // Arrange
      final notificationData = NotificationData(
        type: 'new_order',
        targetRole: UserRole.vendor,
        route: '/vendor/orders',
        params: {'order_id': '123'},
        title: 'New Order',
        body: 'You have a new order',
      );

      // Act
      final map = notificationData.toMap();

      // Assert
      expect(map['type'], equals('new_order'));
      expect(map['target_role'], equals('vendor'));
      expect(map['route'], equals('/vendor/orders'));
      expect(map['params'], equals({'order_id': '123'}));
      expect(map['title'], equals('New Order'));
      expect(map['body'], equals('You have a new order'));
    });

    test('toString returns formatted string', () {
      // Arrange
      final notificationData = NotificationData(
        type: 'new_order',
        targetRole: UserRole.vendor,
        route: '/vendor/orders',
        params: {},
      );

      // Act
      final string = notificationData.toString();

      // Assert
      expect(string, contains('new_order'));
      expect(string, contains('vendor'));
      expect(string, contains('/vendor/orders'));
    });
  });
}
