import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/core/router/app_router.dart';
import 'package:chefleet/core/routes/app_routes.dart';
import 'package:chefleet/core/models/user_role.dart';
import 'package:chefleet/core/blocs/auth_bloc.dart';
import 'package:chefleet/core/blocs/role_bloc.dart';

// Mocks
class MockAuthBloc extends Mock implements AuthBloc {}
class MockRoleBloc extends Mock implements RoleBloc {}

void main() {
  group('Routing Integration Tests', () {
    late MockAuthBloc mockAuthBloc;
    late MockRoleBloc mockRoleBloc;
    late GoRouter router;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      mockRoleBloc = MockRoleBloc();
      
      // Set up default authenticated state
      when(() => mockAuthBloc.state).thenReturn(
        const AuthLoaded(userId: 'test-user-id', isGuest: false),
      );
      when(() => mockRoleBloc.state).thenReturn(
        RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: [UserRole.customer],
        ),
      );
      when(() => mockRoleBloc.currentRole).thenReturn(UserRole.customer);
      when(() => mockRoleBloc.availableRoles).thenReturn([UserRole.customer]);

      router = createRouter(
        authBloc: mockAuthBloc,
        roleBloc: mockRoleBloc,
      );
    });

    group('Authentication Flow', () {
      testWidgets('Should redirect to splash when not authenticated', (tester) async {
        when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
        
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SplashScreen), findsOneWidget);
      });

      testWidgets('Should navigate from splash to auth screen', (tester) async {
        when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
        
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.go(SharedRoutes.auth);
        await tester.pumpAndSettle();

        expect(find.byType(AuthScreen), findsOneWidget);
      });

      testWidgets('Should redirect to role selection after auth', (tester) async {
        when(() => mockAuthBloc.state).thenReturn(
          const AuthLoaded(userId: 'test-user', isGuest: false),
        );
        when(() => mockRoleBloc.state).thenReturn(const RoleLoading());
        
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        expect(router.location, equals(SharedRoutes.roleSelection));
      });
    });

    group('Customer Routes', () {
      testWidgets('Should navigate to customer map screen', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.go(CustomerRoutes.map);
        await tester.pumpAndSettle();

        expect(find.byType(MapScreen), findsOneWidget);
        expect(router.location, equals(CustomerRoutes.map));
      });

      testWidgets('Should navigate to dish detail', (tester) async {
        const dishId = 'test-dish-123';
        
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.push(CustomerRoutes.dishDetail(dishId));
        await tester.pumpAndSettle();

        expect(find.byType(DishDetailScreen), findsOneWidget);
        expect(router.location, contains(dishId));
      });

      testWidgets('Should navigate to orders list', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.push(CustomerRoutes.orders);
        await tester.pumpAndSettle();

        expect(find.byType(CustomerOrdersScreen), findsOneWidget);
      });

      testWidgets('Should navigate to order detail', (tester) async {
        const orderId = 'test-order-123';
        
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.push(CustomerRoutes.orderDetail(orderId));
        await tester.pumpAndSettle();

        expect(find.byType(OrderDetailScreen), findsOneWidget);
        expect(router.location, contains(orderId));
      });

      testWidgets('Should navigate to chat detail', (tester) async {
        const orderId = 'test-order-123';
        
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.push(CustomerRoutes.chatDetail(orderId));
        await tester.pumpAndSettle();

        expect(find.byType(ChatDetailScreen), findsOneWidget);
        expect(router.location, contains(orderId));
      });

      testWidgets('Should navigate to profile', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.push(CustomerRoutes.profile);
        await tester.pumpAndSettle();

        expect(find.byType(ProfileScreen), findsOneWidget);
      });
    });

    group('Vendor Routes', () {
      setUp(() {
        when(() => mockRoleBloc.state).thenReturn(
          RoleLoaded(
            activeRole: UserRole.vendor,
            availableRoles: [UserRole.vendor, UserRole.customer],
          ),
        );
        when(() => mockRoleBloc.currentRole).thenReturn(UserRole.vendor);
      });

      testWidgets('Should navigate to vendor dashboard', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.go(VendorRoutes.dashboard);
        await tester.pumpAndSettle();

        expect(find.byType(VendorDashboardScreen), findsOneWidget);
      });

      testWidgets('Should navigate to vendor orders', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.push(VendorRoutes.orders);
        await tester.pumpAndSettle();

        expect(find.byType(VendorOrdersScreen), findsOneWidget);
      });

      testWidgets('Should navigate to dishes management', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.push(VendorRoutes.dishes);
        await tester.pumpAndSettle();

        expect(find.byType(DishesManagementScreen), findsOneWidget);
      });

      testWidgets('Should navigate to add dish', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.push(VendorRoutes.dishAdd);
        await tester.pumpAndSettle();

        expect(find.byType(AddDishScreen), findsOneWidget);
      });

      testWidgets('Should navigate to edit dish', (tester) async {
        const dishId = 'test-dish-123';
        
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.push(VendorRoutes.dishEditWithId(dishId));
        await tester.pumpAndSettle();

        expect(find.byType(EditDishScreen), findsOneWidget);
        expect(router.location, contains(dishId));
      });
    });

    group('Role-Based Guards', () {
      testWidgets('Should block customer from accessing vendor routes', (tester) async {
        when(() => mockRoleBloc.currentRole).thenReturn(UserRole.customer);
        when(() => mockRoleBloc.availableRoles).thenReturn([UserRole.customer]);
        
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.go(VendorRoutes.dashboard);
        await tester.pumpAndSettle();

        // Should redirect to customer home
        expect(router.location, equals(CustomerRoutes.map));
      });

      testWidgets('Should block vendor from accessing customer routes', (tester) async {
        when(() => mockRoleBloc.currentRole).thenReturn(UserRole.vendor);
        when(() => mockRoleBloc.availableRoles).thenReturn([UserRole.vendor]);
        
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.go(CustomerRoutes.map);
        await tester.pumpAndSettle();

        // Should redirect to vendor home
        expect(router.location, equals(VendorRoutes.dashboard));
      });

      testWidgets('Should allow dual-role users to access both', (tester) async {
        when(() => mockRoleBloc.currentRole).thenReturn(UserRole.customer);
        when(() => mockRoleBloc.availableRoles).thenReturn([
          UserRole.customer,
          UserRole.vendor,
        ]);
        
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        // Access customer route
        router.go(CustomerRoutes.map);
        await tester.pumpAndSettle();
        expect(find.byType(MapScreen), findsOneWidget);

        // Switch role and access vendor route
        when(() => mockRoleBloc.currentRole).thenReturn(UserRole.vendor);
        router.go(VendorRoutes.dashboard);
        await tester.pumpAndSettle();
        expect(find.byType(VendorDashboardScreen), findsOneWidget);
      });
    });

    group('Deep Link Handling', () {
      testWidgets('Should handle customer dish deep link', (tester) async {
        const dishId = 'deep-link-dish';
        final uri = Uri.parse('chefleet://customer/dish/$dishId');
        
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.go(uri.toString());
        await tester.pumpAndSettle();

        expect(find.byType(DishDetailScreen), findsOneWidget);
      });

      testWidgets('Should handle vendor order deep link', (tester) async {
        when(() => mockRoleBloc.currentRole).thenReturn(UserRole.vendor);
        
        const orderId = 'deep-link-order';
        final uri = Uri.parse('chefleet://vendor/orders/$orderId');
        
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.go(uri.toString());
        await tester.pumpAndSettle();

        expect(find.byType(OrderDetailScreen), findsOneWidget);
      });
    });

    group('Back Navigation', () {
      testWidgets('Should pop back through navigation stack', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        // Navigate through multiple screens
        router.go(CustomerRoutes.map);
        await tester.pumpAndSettle();
        
        const dishId = 'test-dish';
        router.push(CustomerRoutes.dishDetail(dishId));
        await tester.pumpAndSettle();
        
        expect(find.byType(DishDetailScreen), findsOneWidget);

        // Navigate back
        router.pop();
        await tester.pumpAndSettle();

        expect(find.byType(MapScreen), findsOneWidget);
      });

      testWidgets('Should handle back navigation at root', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.go(CustomerRoutes.map);
        await tester.pumpAndSettle();

        // Try to pop at root
        final canPop = router.canPop();
        expect(canPop, isFalse);
      });
    });

    group('Guest User Access', () {
      setUp(() {
        when(() => mockAuthBloc.state).thenReturn(
          const AuthLoaded(userId: 'guest-user', isGuest: true),
        );
      });

      testWidgets('Should allow guest to view map', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.go(CustomerRoutes.map);
        await tester.pumpAndSettle();

        expect(find.byType(MapScreen), findsOneWidget);
      });

      testWidgets('Should redirect guest from restricted routes', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        router.go(CustomerRoutes.orders);
        await tester.pumpAndSettle();

        // Should redirect to auth or show conversion prompt
        expect(router.location, anyOf(
          equals(SharedRoutes.auth),
          equals(CustomerRoutes.map),
        ));
      });
    });

    group('Route Helper Functions', () {
      test('Should correctly identify customer routes', () {
        expect(RouteHelper.isCustomerRoute(CustomerRoutes.map), isTrue);
        expect(RouteHelper.isCustomerRoute(CustomerRoutes.orders), isTrue);
        expect(RouteHelper.isCustomerRoute(VendorRoutes.dashboard), isFalse);
      });

      test('Should correctly identify vendor routes', () {
        expect(RouteHelper.isVendorRoute(VendorRoutes.dashboard), isTrue);
        expect(RouteHelper.isVendorRoute(VendorRoutes.orders), isTrue);
        expect(RouteHelper.isVendorRoute(CustomerRoutes.map), isFalse);
      });

      test('Should correctly identify shared routes', () {
        expect(RouteHelper.isSharedRoute(SharedRoutes.splash), isTrue);
        expect(RouteHelper.isSharedRoute(SharedRoutes.auth), isTrue);
        expect(RouteHelper.isSharedRoute(CustomerRoutes.map), isFalse);
      });

      test('Should get correct root route for role', () {
        expect(
          RouteHelper.getRootRouteForRole('customer'),
          equals(CustomerRoutes.map),
        );
        expect(
          RouteHelper.getRootRouteForRole('vendor'),
          equals(VendorRoutes.dashboard),
        );
      });
    });
  });
}
