import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/core/blocs/role_bloc.dart';
import 'package:chefleet/core/blocs/role_state.dart';
import 'package:chefleet/core/models/user_role.dart';
import 'package:chefleet/features/profile/widgets/become_vendor_card.dart';
import 'package:chefleet/core/blocs/role_event.dart';

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

  group('BecomeVendorCard Widget Tests', () {
    testWidgets('shows "Become a Vendor" when vendor role is NOT available', (WidgetTester tester) async {
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
      await tester.pumpWidget(createTestWidget(const BecomeVendorCard()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Start Selling'), findsOneWidget);
      expect(find.text('Become a Vendor'), findsOneWidget);
      expect(find.text('Switch to Vendor Profile'), findsNothing);
    });

    testWidgets('shows "Switch to Vendor Profile" when vendor role IS available', (WidgetTester tester) async {
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
      await tester.pumpWidget(createTestWidget(const BecomeVendorCard()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Vendor Mode'), findsOneWidget);
      expect(find.text('Switch to Vendor Profile'), findsOneWidget);
      expect(find.text('Become a Vendor'), findsNothing);
    });
  });
}
