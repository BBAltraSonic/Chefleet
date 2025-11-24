import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:chefleet/core/routes/deep_link_handler.dart';
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
  late DeepLinkHandler deepLinkHandler;

  setUpAll(() {
    registerFallbackValue(FakeRoleEvent());
    registerFallbackValue(UserRole.customer);
  });

  setUp(() {
    mockRoleBloc = MockRoleBloc();
    mockGoRouter = MockGoRouter();

    deepLinkHandler = DeepLinkHandler(
      roleBloc: mockRoleBloc,
      goRouter: mockGoRouter,
    );

    // Setup default mocks
    when(() => mockRoleBloc.currentRole).thenReturn(UserRole.customer);
    when(() => mockRoleBloc.availableRoles).thenReturn({UserRole.customer, UserRole.vendor});
    when(() => mockRoleBloc.add(any())).thenReturn(null);
    when(() => mockGoRouter.go(any())).thenReturn(null);
  });

  group('DeepLinkHandler - URI Validation', () {
    test('validates chefleet:// scheme', () async {
      // Arrange
      final uri = Uri.parse('chefleet://customer/feed');

      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        )),
      );

      // Act
      final result = await deepLinkHandler.handleDeepLink(uri);

      // Assert
      expect(result, isTrue);
    });

    test('validates https:// scheme with correct host', () async {
      // Arrange
      final uri = Uri.parse('https://chefleet.app/customer/feed');

      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        )),
      );

      // Act
      final result = await deepLinkHandler.handleDeepLink(uri);

      // Assert
      expect(result, isTrue);
    });

    test('rejects invalid scheme', () async {
      // Arrange
      final uri = Uri.parse('invalid://customer/feed');

      // Act
      final result = await deepLinkHandler.handleDeepLink(uri);

      // Assert
      expect(result, isFalse);
      verifyNever(() => mockGoRouter.go(any()));
    });

    test('rejects invalid host for https scheme', () async {
      // Arrange
      final uri = Uri.parse('https://invalid-host.com/customer/feed');

      // Act
      final result = await deepLinkHandler.handleDeepLink(uri);

      // Assert
      expect(result, isFalse);
      verifyNever(() => mockGoRouter.go(any()));
    });
  });

  group('DeepLinkHandler - Role Parsing', () {
    test('parses customer role from path', () async {
      // Arrange
      final uri = Uri.parse('chefleet://customer/feed');

      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        )),
      );

      // Act
      final result = await deepLinkHandler.handleDeepLink(uri);

      // Assert
      expect(result, isTrue);
      verify(() => mockGoRouter.go(argThat(contains('/customer')))).called(1);
    });

    test('parses vendor role from path', () async {
      // Arrange
      final uri = Uri.parse('chefleet://vendor/dashboard');

      when(() => mockRoleBloc.currentRole).thenReturn(UserRole.vendor);
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.vendor},
        )),
      );

      // Act
      final result = await deepLinkHandler.handleDeepLink(uri);

      // Assert
      expect(result, isTrue);
      verify(() => mockGoRouter.go(argThat(contains('/vendor')))).called(1);
    });

    test('handles shared routes without role prefix', () async {
      // Arrange
      final uri = Uri.parse('chefleet://auth/login');

      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        )),
      );

      // Act
      final result = await deepLinkHandler.handleDeepLink(uri);

      // Assert
      expect(result, isTrue);
      verify(() => mockGoRouter.go(argThat(contains('/auth')))).called(1);
    });
  });

  group('DeepLinkHandler - Role Validation', () {
    test('returns false when user does not have required role', () async {
      // Arrange
      when(() => mockRoleBloc.availableRoles).thenReturn({UserRole.customer});
      final uri = Uri.parse('chefleet://vendor/dashboard');

      // Act
      final result = await deepLinkHandler.handleDeepLink(uri);

      // Assert
      expect(result, isFalse);
      verifyNever(() => mockGoRouter.go(any()));
    });

    test('navigates without role switch when already in correct role', () async {
      // Arrange
      when(() => mockRoleBloc.currentRole).thenReturn(UserRole.customer);
      final uri = Uri.parse('chefleet://customer/feed');

      // Act
      final result = await deepLinkHandler.handleDeepLink(uri);

      // Assert
      expect(result, isTrue);
      verify(() => mockGoRouter.go(any())).called(1);
      verifyNever(() => mockRoleBloc.add(any()));
    });
  });

  group('DeepLinkHandler - Role Switching', () {
    test('switches role when deep link requires different role', () async {
      // Arrange
      when(() => mockRoleBloc.currentRole).thenReturn(UserRole.customer);
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        )),
      );

      final uri = Uri.parse('chefleet://vendor/dashboard');

      // Act
      final result = await deepLinkHandler.handleDeepLink(uri);

      // Assert
      expect(result, isTrue);
      verify(() => mockRoleBloc.add(any<RoleSwitchRequested>())).called(1);
      verify(() => mockGoRouter.go(any())).called(1);
    });

    test('handles role switch error gracefully', () async {
      // Arrange
      when(() => mockRoleBloc.currentRole).thenReturn(UserRole.customer);
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(const RoleError(
          message: 'Role switch failed',
        )),
      );

      final uri = Uri.parse('chefleet://vendor/dashboard');

      // Act
      final result = await deepLinkHandler.handleDeepLink(uri);

      // Assert
      expect(result, isFalse);
    });
  });

  group('DeepLinkHandler - Query Parameters', () {
    test('preserves query parameters in navigation', () async {
      // Arrange
      when(() => mockRoleBloc.currentRole).thenReturn(UserRole.customer);
      final uri = Uri.parse('chefleet://customer/orders?order_id=123&status=ready');

      // Act
      await deepLinkHandler.handleDeepLink(uri);

      // Assert
      verify(() => mockGoRouter.go(argThat(
        allOf(
          contains('order_id=123'),
          contains('status=ready'),
        ),
      ))).called(1);
    });
  });

  group('DeepLinkHandler - Static Methods', () {
    test('generateDeepLink creates chefleet:// URI', () {
      // Act
      final uri = DeepLinkHandler.generateDeepLink(
        role: UserRole.customer,
        path: '/feed',
      );

      // Assert
      expect(uri.scheme, equals('chefleet'));
      expect(uri.host, equals('customer'));
      expect(uri.path, equals('/feed'));
    });

    test('generateDeepLink creates https:// URI when useHttps is true', () {
      // Act
      final uri = DeepLinkHandler.generateDeepLink(
        role: UserRole.vendor,
        path: '/dashboard',
        useHttps: true,
      );

      // Assert
      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('chefleet.app'));
      expect(uri.path, contains('/vendor/dashboard'));
    });

    test('generateDeepLink includes query parameters', () {
      // Act
      final uri = DeepLinkHandler.generateDeepLink(
        role: UserRole.customer,
        path: '/orders',
        queryParameters: {'order_id': '123'},
      );

      // Assert
      expect(uri.queryParameters['order_id'], equals('123'));
    });

    test('generateShareableLink creates https URL string', () {
      // Act
      final link = DeepLinkHandler.generateShareableLink(
        role: UserRole.customer,
        path: '/feed',
      );

      // Assert
      expect(link, startsWith('https://'));
      expect(link, contains('chefleet.app'));
      expect(link, contains('/customer/feed'));
    });
  });

  group('DeepLinkData', () {
    test('toString returns formatted string', () {
      // Arrange
      final deepLinkData = DeepLinkData(
        targetRole: UserRole.vendor,
        path: '/vendor/dashboard',
        queryParameters: {'tab': 'orders'},
      );

      // Act
      final string = deepLinkData.toString();

      // Assert
      expect(string, contains('vendor'));
      expect(string, contains('/vendor/dashboard'));
      expect(string, contains('tab'));
    });
  });
}
