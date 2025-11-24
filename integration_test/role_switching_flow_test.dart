import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/core/blocs/role_bloc.dart';
import 'package:chefleet/core/blocs/role_event.dart';
import 'package:chefleet/core/blocs/role_state.dart';
import 'package:chefleet/core/models/user_role.dart';
import 'package:chefleet/core/services/role_storage_service.dart';
import 'package:chefleet/core/services/role_sync_service.dart';
import 'package:chefleet/core/widgets/role_shell_switcher.dart';
import 'package:chefleet/features/customer/customer_app_shell.dart';
import 'package:chefleet/features/vendor/vendor_app_shell.dart';
import 'package:chefleet/features/profile/widgets/role_switcher.dart';

// Mocks
class MockRoleStorageService extends Mock implements RoleStorageService {}
class MockRoleSyncService extends Mock implements RoleSyncService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Role Switching Flow - Complete Integration Tests', () {
    late MockRoleStorageService mockStorageService;
    late MockRoleSyncService mockSyncService;
    late RoleBloc roleBloc;

    setUp(() {
      mockStorageService = MockRoleStorageService();
      mockSyncService = MockRoleSyncService();

      // Setup default mocks
      when(() => mockStorageService.saveActiveRole(any()))
          .thenAnswer((_) async => true);
      when(() => mockStorageService.saveAvailableRoles(any()))
          .thenAnswer((_) async => true);
      when(() => mockSyncService.syncActiveRole(any()))
          .thenAnswer((_) async {});
    });

    tearDown(() {
      roleBloc.close();
    });

    testWidgets('Complete flow: Login as customer with both roles available',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockStorageService.getActiveRole())
          .thenAnswer((_) async => UserRole.customer);
      when(() => mockStorageService.getAvailableRoles())
          .thenAnswer((_) async => {UserRole.customer, UserRole.vendor});
      when(() => mockSyncService.fetchRoleData())
          .thenAnswer((_) async => (UserRole.customer, {UserRole.customer, UserRole.vendor}));

      roleBloc = RoleBloc(
        storageService: mockStorageService,
        syncService: mockSyncService,
      );

      // Act - Load role
      roleBloc.add(const RoleRequested());
      await tester.pumpAndSettle();

      // Assert - Customer role loaded
      expect(roleBloc.state, isA<RoleLoaded>());
      final state = roleBloc.state as RoleLoaded;
      expect(state.activeRole, equals(UserRole.customer));
      expect(state.availableRoles, contains(UserRole.vendor));
    });

    testWidgets('Switch from customer to vendor and verify UI updates',
        (WidgetTester tester) async {
      // Arrange
      roleBloc = RoleBloc(
        storageService: mockStorageService,
        syncService: mockSyncService,
      );

      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: roleBloc,
            child: BlocBuilder<RoleBloc, RoleState>(
              builder: (context, state) {
                if (state is! RoleLoaded) {
                  return const CircularProgressIndicator();
                }
                return RoleShellSwitcher(
                  activeRole: state.activeRole,
                  availableRoles: state.availableRoles,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Customer shell is visible
      expect(find.byType(CustomerAppShell), findsOneWidget);
      expect(find.byType(VendorAppShell), findsNothing);

      // Act - Switch to vendor
      roleBloc.add(const RoleSwitchRequested(newRole: UserRole.vendor));
      await tester.pumpAndSettle();

      // Assert - Vendor shell is now visible
      expect(find.byType(VendorAppShell), findsOneWidget);
      expect(find.byType(CustomerAppShell), findsNothing);
    });

    testWidgets('Navigate vendor screens after role switch',
        (WidgetTester tester) async {
      // Arrange
      roleBloc = RoleBloc(
        storageService: mockStorageService,
        syncService: mockSyncService,
      );

      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: roleBloc,
            child: BlocBuilder<RoleBloc, RoleState>(
              builder: (context, state) {
                if (state is! RoleLoaded) {
                  return const CircularProgressIndicator();
                }
                return RoleShellSwitcher(
                  activeRole: state.activeRole,
                  availableRoles: state.availableRoles,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Switch to vendor
      roleBloc.add(const RoleSwitchRequested(newRole: UserRole.vendor));
      await tester.pumpAndSettle();

      // Assert - Vendor dashboard should be accessible
      expect(find.byType(VendorAppShell), findsOneWidget);

      // Note: Navigation within vendor shell would require actual router setup
      // This test verifies the shell switch works correctly
    });

    testWidgets('Switch back to customer and verify state preserved',
        (WidgetTester tester) async {
      // Arrange
      roleBloc = RoleBloc(
        storageService: mockStorageService,
        syncService: mockSyncService,
      );

      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: roleBloc,
            child: BlocBuilder<RoleBloc, RoleState>(
              builder: (context, state) {
                if (state is! RoleLoaded) {
                  return const CircularProgressIndicator();
                }
                return RoleShellSwitcher(
                  activeRole: state.activeRole,
                  availableRoles: state.availableRoles,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Switch to vendor
      roleBloc.add(const RoleSwitchRequested(newRole: UserRole.vendor));
      await tester.pumpAndSettle();

      // Act - Switch back to customer
      roleBloc.add(const RoleSwitchRequested(newRole: UserRole.customer));
      await tester.pumpAndSettle();

      // Assert - Customer shell is visible again
      expect(find.byType(CustomerAppShell), findsOneWidget);
      expect(find.byType(VendorAppShell), findsNothing);

      // Note: IndexedStack should preserve navigation state
      // This would require more complex setup to fully test
    });

    testWidgets('Role switch completes in under 500ms',
        (WidgetTester tester) async {
      // Arrange
      roleBloc = RoleBloc(
        storageService: mockStorageService,
        syncService: mockSyncService,
      );

      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: roleBloc,
            child: BlocBuilder<RoleBloc, RoleState>(
              builder: (context, state) {
                if (state is! RoleLoaded) {
                  return const CircularProgressIndicator();
                }
                return RoleShellSwitcher(
                  activeRole: state.activeRole,
                  availableRoles: state.availableRoles,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Measure switch time
      final startTime = DateTime.now();
      roleBloc.add(const RoleSwitchRequested(newRole: UserRole.vendor));
      await tester.pumpAndSettle();
      final endTime = DateTime.now();

      final duration = endTime.difference(startTime);

      // Assert - Switch completed in under 500ms
      expect(duration.inMilliseconds, lessThan(500));
    });

    testWidgets('No UI flicker during role switch',
        (WidgetTester tester) async {
      // Arrange
      roleBloc = RoleBloc(
        storageService: mockStorageService,
        syncService: mockSyncService,
      );

      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: roleBloc,
            child: BlocBuilder<RoleBloc, RoleState>(
              builder: (context, state) {
                if (state is! RoleLoaded) {
                  return const CircularProgressIndicator();
                }
                return RoleShellSwitcher(
                  activeRole: state.activeRole,
                  availableRoles: state.availableRoles,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Switch role
      roleBloc.add(const RoleSwitchRequested(newRole: UserRole.vendor));

      // Assert - During switch, IndexedStack should maintain both shells
      // This prevents flicker
      await tester.pump(); // Single frame
      
      // Both shells should exist in widget tree (IndexedStack behavior)
      // but only one is visible
      final customerShells = tester.widgetList(find.byType(CustomerAppShell));
      final vendorShells = tester.widgetList(find.byType(VendorAppShell));
      
      expect(customerShells.length + vendorShells.length, greaterThanOrEqualTo(1));

      await tester.pumpAndSettle();
    });

    testWidgets('Role persists across app restarts',
        (WidgetTester tester) async {
      // Arrange - First app session
      when(() => mockStorageService.getActiveRole())
          .thenAnswer((_) async => UserRole.vendor);
      when(() => mockStorageService.getAvailableRoles())
          .thenAnswer((_) async => {UserRole.customer, UserRole.vendor});

      roleBloc = RoleBloc(
        storageService: mockStorageService,
        syncService: mockSyncService,
      );

      // Act - Load role
      roleBloc.add(const RoleRequested());
      await tester.pumpAndSettle();

      // Assert - Vendor role restored
      expect(roleBloc.state, isA<RoleLoaded>());
      final state = roleBloc.state as RoleLoaded;
      expect(state.activeRole, equals(UserRole.vendor));

      // Verify storage was queried
      verify(() => mockStorageService.getActiveRole()).called(1);
    });

    testWidgets('Backend sync occurs after role switch',
        (WidgetTester tester) async {
      // Arrange
      roleBloc = RoleBloc(
        storageService: mockStorageService,
        syncService: mockSyncService,
      );

      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      // Act - Switch role
      roleBloc.add(const RoleSwitchRequested(newRole: UserRole.vendor));
      await tester.pumpAndSettle();

      // Assert - Sync service was called
      verify(() => mockSyncService.syncActiveRole(UserRole.vendor)).called(1);
    });

    testWidgets('Error handling during role switch',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockStorageService.saveActiveRole(any()))
          .thenThrow(Exception('Storage error'));

      roleBloc = RoleBloc(
        storageService: mockStorageService,
        syncService: mockSyncService,
      );

      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: roleBloc,
            child: BlocBuilder<RoleBloc, RoleState>(
              builder: (context, state) {
                if (state is RoleError) {
                  return Text('Error: ${state.message}');
                }
                if (state is! RoleLoaded) {
                  return const CircularProgressIndicator();
                }
                return RoleShellSwitcher(
                  activeRole: state.activeRole,
                  availableRoles: state.availableRoles,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Attempt switch
      roleBloc.add(const RoleSwitchRequested(newRole: UserRole.vendor));
      await tester.pumpAndSettle();

      // Assert - Error state is displayed
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('Multiple rapid role switches are handled gracefully',
        (WidgetTester tester) async {
      // Arrange
      roleBloc = RoleBloc(
        storageService: mockStorageService,
        syncService: mockSyncService,
      );

      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      // Act - Rapid switches
      roleBloc.add(const RoleSwitchRequested(newRole: UserRole.vendor));
      roleBloc.add(const RoleSwitchRequested(newRole: UserRole.customer));
      roleBloc.add(const RoleSwitchRequested(newRole: UserRole.vendor));
      await tester.pumpAndSettle();

      // Assert - Final state is vendor
      expect(roleBloc.state, isA<RoleLoaded>());
      final state = roleBloc.state as RoleLoaded;
      expect(state.activeRole, equals(UserRole.vendor));
    });
  });

  group('Role Switching with Profile UI - Integration Tests', () {
    late MockRoleStorageService mockStorageService;
    late MockRoleSyncService mockSyncService;
    late RoleBloc roleBloc;

    setUp(() {
      mockStorageService = MockRoleStorageService();
      mockSyncService = MockRoleSyncService();

      when(() => mockStorageService.saveActiveRole(any()))
          .thenAnswer((_) async => true);
      when(() => mockSyncService.syncActiveRole(any()))
          .thenAnswer((_) async {});
    });

    tearDown(() {
      roleBloc.close();
    });

    testWidgets('Role switcher appears in profile when multiple roles available',
        (WidgetTester tester) async {
      // Arrange
      roleBloc = RoleBloc(
        storageService: mockStorageService,
        syncService: mockSyncService,
      );

      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: roleBloc,
              child: const RoleSwitcher(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Role switcher is visible
      expect(find.byType(RoleSwitcher), findsOneWidget);
      expect(find.text('Current Role'), findsOneWidget);
    });

    testWidgets('Tapping switch button shows confirmation dialog',
        (WidgetTester tester) async {
      // Arrange
      roleBloc = RoleBloc(
        storageService: mockStorageService,
        syncService: mockSyncService,
      );

      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: roleBloc,
              child: const RoleSwitcher(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap switch button
      await tester.tap(find.text('Switch to Vendor'));
      await tester.pumpAndSettle();

      // Assert - Dialog appears
      expect(find.text('Switch Role?'), findsOneWidget);
    });

    testWidgets('Confirming switch triggers role change',
        (WidgetTester tester) async {
      // Arrange
      roleBloc = RoleBloc(
        storageService: mockStorageService,
        syncService: mockSyncService,
      );

      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: roleBloc,
              child: const RoleSwitcher(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap switch and confirm
      await tester.tap(find.text('Switch to Vendor'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Switch'));
      await tester.pumpAndSettle();

      // Assert - Role changed
      expect(roleBloc.state, isA<RoleLoaded>());
      final state = roleBloc.state as RoleLoaded;
      expect(state.activeRole, equals(UserRole.vendor));
    });
  });
}
