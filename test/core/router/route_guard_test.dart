import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:chefleet/core/router/app_router.dart';
import 'package:chefleet/core/routes/app_routes.dart';
import 'package:chefleet/features/auth/blocs/auth_bloc.dart';
import 'package:chefleet/features/auth/blocs/user_profile_bloc.dart';
import 'package:chefleet/core/blocs/role_bloc.dart';
import 'package:chefleet/core/blocs/role_state.dart';
import 'package:chefleet/core/models/user_role.dart';

// Mock classes
class MockAuthBloc extends Mock implements AuthBloc {}
class MockUserProfileBloc extends Mock implements UserProfileBloc {}
class MockRoleBloc extends Mock implements RoleBloc {}
class MockGoRouterState extends Mock implements GoRouterState {}

void main() {
  group('Route Guards - Loading State Handling', () {
    late MockAuthBloc authBloc;
    late MockUserProfileBloc profileBloc;
    late MockRoleBloc roleBloc;
    late MockGoRouterState routerState;

    setUp(() {
      authBloc = MockAuthBloc();
      profileBloc = MockUserProfileBloc();
      roleBloc = MockRoleBloc();
      routerState = MockGoRouterState();
    });

    test('Blocks navigation during auth loading', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(isLoading: true),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(),
      );
      when(() => roleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );
      when(() => routerState.matchedLocation).thenReturn(CustomerRoutes.map);

      // Act
      final redirect = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      ).routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, equals(AppRouter.splash));
    });

    test('Blocks navigation during role loading', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: true,
          isLoading: false,
          mode: AuthMode.authenticated,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(profile: {'name': 'Test User'}),
      );
      when(() => roleBloc.state).thenReturn(const RoleLoading());
      when(() => routerState.matchedLocation).thenReturn(CustomerRoutes.map);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, equals(AppRouter.splash));
    });

    test('Blocks navigation during role initial state', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: true,
          isLoading: false,
          mode: AuthMode.authenticated,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(profile: {'name': 'Test User'}),
      );
      when(() => roleBloc.state).thenReturn(const RoleInitial());
      when(() => routerState.matchedLocation).thenReturn(CustomerRoutes.map);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, equals(AppRouter.splash));
    });

    test('Blocks navigation during role switching', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: true,
          isLoading: false,
          mode: AuthMode.authenticated,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(profile: {'name': 'Test User'}),
      );
      when(() => roleBloc.state).thenReturn(
        const RoleSwitching(
          fromRole: UserRole.customer,
          toRole: UserRole.vendor,
        ),
      );
      when(() => routerState.matchedLocation).thenReturn(CustomerRoutes.map);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, equals(AppRouter.splash));
    });

    test('Blocks navigation during profile loading', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: true,
          isLoading: false,
          mode: AuthMode.authenticated,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(isLoading: true),
      );
      when(() => roleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );
      when(() => routerState.matchedLocation).thenReturn(CustomerRoutes.map);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, equals(AppRouter.splash));
    });
  });

  group('Route Guards - Role Error Handling', () {
    late MockAuthBloc authBloc;
    late MockUserProfileBloc profileBloc;
    late MockRoleBloc roleBloc;
    late MockGoRouterState routerState;

    setUp(() {
      authBloc = MockAuthBloc();
      profileBloc = MockUserProfileBloc();
      roleBloc = MockRoleBloc();
      routerState = MockGoRouterState();
    });

    test('Redirects to role selection on role error', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: true,
          isLoading: false,
          mode: AuthMode.authenticated,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(profile: {'name': 'Test User'}),
      );
      when(() => roleBloc.state).thenReturn(
        const RoleError(message: 'Test error'),
      );
      when(() => routerState.matchedLocation).thenReturn(CustomerRoutes.map);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, equals(AppRouter.roleSelection));
    });

    test('Redirects to role selection when role selection required', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: true,
          isLoading: false,
          mode: AuthMode.authenticated,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(profile: {'name': 'Test User'}),
      );
      when(() => roleBloc.state).thenReturn(
        const RoleSelectionRequired(),
      );
      when(() => routerState.matchedLocation).thenReturn(CustomerRoutes.map);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, equals(AppRouter.roleSelection));
    });

    test('Allows staying on role selection screen when error occurs', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: true,
          isLoading: false,
          mode: AuthMode.authenticated,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(profile: {'name': 'Test User'}),
      );
      when(() => roleBloc.state).thenReturn(
        const RoleError(message: 'Test error'),
      );
      when(() => routerState.matchedLocation).thenReturn(AppRouter.roleSelection);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, isNull);
    });
  });

  group('Route Guards - Unauthenticated Users', () {
    late MockAuthBloc authBloc;
    late MockUserProfileBloc profileBloc;
    late MockRoleBloc roleBloc;
    late MockGoRouterState routerState;

    setUp(() {
      authBloc = MockAuthBloc();
      profileBloc = MockUserProfileBloc();
      roleBloc = MockRoleBloc();
      routerState = MockGoRouterState();
    });

    test('Redirects unauthenticated users to auth screen', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: false,
          isLoading: false,
          mode: AuthMode.unauthenticated,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(),
      );
      when(() => roleBloc.state).thenReturn(const RoleInitial());
      when(() => routerState.matchedLocation).thenReturn(CustomerRoutes.map);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, equals(AppRouter.auth));
    });

    test('Allows unauthenticated users on public routes', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: false,
          isLoading: false,
          mode: AuthMode.unauthenticated,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(),
      );
      when(() => roleBloc.state).thenReturn(const RoleInitial());
      when(() => routerState.matchedLocation).thenReturn(AppRouter.auth);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, isNull);
    });

    test('Allows unauthenticated users on splash screen', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: false,
          isLoading: false,
          mode: AuthMode.unauthenticated,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(),
      );
      when(() => roleBloc.state).thenReturn(const RoleInitial());
      when(() => routerState.matchedLocation).thenReturn(AppRouter.splash);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, isNull);
    });
  });

  group('Route Guards - Guest Users', () {
    late MockAuthBloc authBloc;
    late MockUserProfileBloc profileBloc;
    late MockRoleBloc roleBloc;
    late MockGoRouterState routerState;

    setUp(() {
      authBloc = MockAuthBloc();
      profileBloc = MockUserProfileBloc();
      roleBloc = MockRoleBloc();
      routerState = MockGoRouterState();
    });

    test('Allows guest users on customer map', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: false,
          isLoading: false,
          mode: AuthMode.guest,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(),
      );
      when(() => roleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );
      when(() => routerState.matchedLocation).thenReturn(CustomerRoutes.map);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, isNull);
    });

    test('Allows guest users on checkout', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: false,
          isLoading: false,
          mode: AuthMode.guest,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(),
      );
      when(() => roleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );
      when(() => routerState.matchedLocation).thenReturn(CustomerRoutes.checkout);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, isNull);
    });

    test('Redirects guest users away from vendor routes', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: false,
          isLoading: false,
          mode: AuthMode.guest,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(),
      );
      when(() => roleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );
      when(() => routerState.matchedLocation).thenReturn(VendorRoutes.dashboard);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, equals(CustomerRoutes.map));
    });

    test('Redirects guest users away from profile routes', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: false,
          isLoading: false,
          mode: AuthMode.guest,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(),
      );
      when(() => roleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );
      when(() => routerState.matchedLocation).thenReturn(CustomerRoutes.profile);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, equals(CustomerRoutes.map));
    });
  });

  group('Route Guards - Profile Creation', () {
    late MockAuthBloc authBloc;
    late MockUserProfileBloc profileBloc;
    late MockRoleBloc roleBloc;
    late MockGoRouterState routerState;

    setUp(() {
      authBloc = MockAuthBloc();
      profileBloc = MockUserProfileBloc();
      roleBloc = MockRoleBloc();
      routerState = MockGoRouterState();
    });

    test('Redirects authenticated users without profile to profile creation', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: true,
          isLoading: false,
          mode: AuthMode.authenticated,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(), // Empty profile
      );
      when(() => roleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );
      when(() => routerState.matchedLocation).thenReturn(CustomerRoutes.map);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, equals(AppRouter.profileCreation));
    });

    test('Allows authenticated users on profile creation screen', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: true,
          isLoading: false,
          mode: AuthMode.authenticated,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(), // Empty profile
      );
      when(() => roleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );
      when(() => routerState.matchedLocation).thenReturn(AppRouter.profileCreation);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, isNull);
    });
  });

  group('Route Guards - Authenticated Users with Complete State', () {
    late MockAuthBloc authBloc;
    late MockUserProfileBloc profileBloc;
    late MockRoleBloc roleBloc;
    late MockGoRouterState routerState;

    setUp(() {
      authBloc = MockAuthBloc();
      profileBloc = MockUserProfileBloc();
      roleBloc = MockRoleBloc();
      routerState = MockGoRouterState();
    });

    test('Allows authenticated users with complete state on customer routes', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: true,
          isLoading: false,
          mode: AuthMode.authenticated,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(profile: {'name': 'Test User'}),
      );
      when(() => roleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );
      when(() => routerState.matchedLocation).thenReturn(CustomerRoutes.map);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, isNull);
    });

    test('Allows authenticated users with complete state on vendor routes', () {
      // Arrange
      when(() => authBloc.state).thenReturn(
        const AuthState(
          isAuthenticated: true,
          isLoading: false,
          mode: AuthMode.authenticated,
        ),
      );
      when(() => profileBloc.state).thenReturn(
        const UserProfileState(profile: {'name': 'Test User'}),
      );
      when(() => roleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.vendor},
        ),
      );
      when(() => routerState.matchedLocation).thenReturn(VendorRoutes.dashboard);

      // Act
      final router = AppRouter.createRouter(
        authBloc: authBloc,
        profileBloc: profileBloc,
        roleBloc: roleBloc,
      );
      final redirect = router.routerDelegate.redirect(null, routerState);

      // Assert
      expect(redirect, isNull);
    });
  });
}
