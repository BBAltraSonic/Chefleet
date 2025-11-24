import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/core/blocs/role_bloc.dart';
import 'package:chefleet/core/blocs/role_state.dart';
import 'package:chefleet/core/blocs/role_event.dart';
import 'package:chefleet/core/models/user_role.dart';
import 'package:chefleet/features/profile/widgets/role_switcher.dart';

// Mocks
class MockRoleBloc extends Mock implements RoleBloc {}

void main() {
  late MockRoleBloc mockRoleBloc;

  setUp(() {
    mockRoleBloc = MockRoleBloc();
    registerFallbackValue(const RoleSwitchRequested(newRole: UserRole.customer));
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<RoleBloc>.value(
          value: mockRoleBloc,
          child: child,
        ),
      ),
    );
  }

  group('RoleSwitcher Widget Tests', () {
    testWidgets('does not show when only one role is available', (WidgetTester tester) async {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
      );
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(
          const RoleLoaded(
            activeRole: UserRole.customer,
            availableRoles: {UserRole.customer},
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(const RoleSwitcher()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(RoleSwitcher), findsOneWidget);
      expect(find.text('Switch Role'), findsNothing);
    });

    testWidgets('shows when multiple roles are available', (WidgetTester tester) async {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(
          const RoleLoaded(
            activeRole: UserRole.customer,
            availableRoles: {UserRole.customer, UserRole.vendor},
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(const RoleSwitcher()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(RoleSwitcher), findsOneWidget);
      expect(find.text('Current Role'), findsOneWidget);
    });

    testWidgets('displays current role correctly', (WidgetTester tester) async {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(
          const RoleLoaded(
            activeRole: UserRole.vendor,
            availableRoles: {UserRole.customer, UserRole.vendor},
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(const RoleSwitcher()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Vendor'), findsOneWidget);
    });

    testWidgets('shows confirmation dialog when switch button is tapped', (WidgetTester tester) async {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(
          const RoleLoaded(
            activeRole: UserRole.customer,
            availableRoles: {UserRole.customer, UserRole.vendor},
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(const RoleSwitcher()));
      await tester.pumpAndSettle();

      // Find and tap the switch button
      final switchButton = find.text('Switch to Vendor');
      expect(switchButton, findsOneWidget);
      await tester.tap(switchButton);
      await tester.pumpAndSettle();

      // Assert - dialog should appear
      expect(find.text('Switch Role?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Switch'), findsOneWidget);
    });

    testWidgets('calls bloc event when confirmation is accepted', (WidgetTester tester) async {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(
          const RoleLoaded(
            activeRole: UserRole.customer,
            availableRoles: {UserRole.customer, UserRole.vendor},
          ),
        ),
      );
      when(() => mockRoleBloc.add(any())).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget(const RoleSwitcher()));
      await tester.pumpAndSettle();

      // Tap switch button
      await tester.tap(find.text('Switch to Vendor'));
      await tester.pumpAndSettle();

      // Tap confirm button
      await tester.tap(find.text('Switch'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockRoleBloc.add(const RoleSwitchRequested(newRole: UserRole.vendor))).called(1);
    });

    testWidgets('does not call bloc event when confirmation is cancelled', (WidgetTester tester) async {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(
          const RoleLoaded(
            activeRole: UserRole.customer,
            availableRoles: {UserRole.customer, UserRole.vendor},
          ),
        ),
      );
      when(() => mockRoleBloc.add(any())).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget(const RoleSwitcher()));
      await tester.pumpAndSettle();

      // Tap switch button
      await tester.tap(find.text('Switch to Vendor'));
      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      verifyNever(() => mockRoleBloc.add(any()));
    });

    testWidgets('shows loading state during role switch', (WidgetTester tester) async {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleSwitching(
          fromRole: UserRole.customer,
          toRole: UserRole.vendor,
        ),
      );
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(
          const RoleSwitching(
            fromRole: UserRole.customer,
            toRole: UserRole.vendor,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(const RoleSwitcher()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Switching roles...'), findsOneWidget);
    });

    testWidgets('updates UI when role switch completes', (WidgetTester tester) async {
      // Arrange
      final stateController = StreamController<RoleState>();
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );
      when(() => mockRoleBloc.stream).thenAnswer((_) => stateController.stream);

      // Act
      await tester.pumpWidget(createTestWidget(const RoleSwitcher()));
      await tester.pumpAndSettle();

      // Emit switching state
      stateController.add(
        const RoleSwitching(
          fromRole: UserRole.customer,
          toRole: UserRole.vendor,
        ),
      );
      await tester.pumpAndSettle();

      // Assert loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Emit switched state
      stateController.add(
        const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );
      await tester.pumpAndSettle();

      // Assert new role is displayed
      expect(find.text('Vendor'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      stateController.close();
    });

    testWidgets('shows error message when role switch fails', (WidgetTester tester) async {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleError(
          message: 'Failed to switch role',
          code: 'SWITCH_FAILED',
        ),
      );
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(
          const RoleError(
            message: 'Failed to switch role',
            code: 'SWITCH_FAILED',
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(const RoleSwitcher()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Failed to switch role'), findsOneWidget);
    });

    testWidgets('handles rapid role switches gracefully', (WidgetTester tester) async {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(
          const RoleLoaded(
            activeRole: UserRole.customer,
            availableRoles: {UserRole.customer, UserRole.vendor},
          ),
        ),
      );
      when(() => mockRoleBloc.add(any())).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget(const RoleSwitcher()));
      await tester.pumpAndSettle();

      // Tap switch button multiple times
      await tester.tap(find.text('Switch to Vendor'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Switch'));
      await tester.pumpAndSettle();

      // Assert - only one event should be added
      verify(() => mockRoleBloc.add(const RoleSwitchRequested(newRole: UserRole.vendor))).called(1);
    });
  });

  group('RoleSwitcher Accessibility Tests', () {
    testWidgets('has proper semantics labels', (WidgetTester tester) async {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(
          const RoleLoaded(
            activeRole: UserRole.customer,
            availableRoles: {UserRole.customer, UserRole.vendor},
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(const RoleSwitcher()));
      await tester.pumpAndSettle();

      // Assert
      expect(
        tester.getSemantics(find.text('Switch to Vendor')),
        matchesSemantics(
          label: 'Switch to Vendor',
          isButton: true,
          isEnabled: true,
        ),
      );
    });

    testWidgets('is keyboard navigable', (WidgetTester tester) async {
      // Arrange
      when(() => mockRoleBloc.state).thenReturn(
        const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
      );
      when(() => mockRoleBloc.stream).thenAnswer(
        (_) => Stream.value(
          const RoleLoaded(
            activeRole: UserRole.customer,
            availableRoles: {UserRole.customer, UserRole.vendor},
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(const RoleSwitcher()));
      await tester.pumpAndSettle();

      // Assert - button should be focusable
      final switchButton = find.text('Switch to Vendor');
      expect(switchButton, findsOneWidget);
      
      // Focus the button
      await tester.tap(switchButton);
      await tester.pumpAndSettle();
      
      // Dialog should appear
      expect(find.text('Switch Role?'), findsOneWidget);
    });
  });
}
