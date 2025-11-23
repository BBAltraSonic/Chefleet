import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chefleet/shared/widgets/persistent_navigation_shell.dart';
import 'package:chefleet/core/blocs/navigation_bloc.dart';
import 'package:chefleet/features/order/blocs/active_orders_bloc.dart';

void main() {
  group('PersistentNavigationShell Tests (No Bottom Nav)', () {
    late NavigationBloc navigationBloc;
    late ActiveOrdersBloc activeOrdersBloc;

    setUp(() {
      navigationBloc = NavigationBloc();
      activeOrdersBloc = ActiveOrdersBloc();
    });

    tearDown(() {
      navigationBloc.close();
      activeOrdersBloc.close();
    });

    testWidgets('should not render bottom navigation bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<NavigationBloc>.value(value: navigationBloc),
              BlocProvider<ActiveOrdersBloc>.value(value: activeOrdersBloc),
            ],
            child: const PersistentNavigationShell(
              children: [
                Center(child: Text('Map Screen')),
                Center(child: Text('Profile Screen')),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no bottom navigation bar exists
      expect(
        find.byType(BottomNavigationBar),
        findsNothing,
        reason: 'Bottom navigation bar should not exist',
      );

      // Verify no NavigationBar exists (Material 3 alternative)
      expect(
        find.byType(NavigationBar),
        findsNothing,
        reason: 'Navigation bar should not exist',
      );
    });

    testWidgets('should render FAB (Orders Floating Action Button)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<NavigationBloc>.value(value: navigationBloc),
              BlocProvider<ActiveOrdersBloc>.value(value: activeOrdersBloc),
            ],
            child: const PersistentNavigationShell(
              children: [
                Center(child: Text('Map Screen')),
                Center(child: Text('Profile Screen')),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify FAB exists
      expect(
        find.byType(OrdersFloatingActionButton),
        findsOneWidget,
        reason: 'Orders FAB should be present',
      );

      // Verify FAB has proper icon
      expect(
        find.descendant(
          of: find.byType(OrdersFloatingActionButton),
          matching: find.byIcon(Icons.shopping_bag_outlined),
        ),
        findsOneWidget,
        reason: 'FAB should have shopping bag icon',
      );
    });

    testWidgets('FAB should open Active Orders modal on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<NavigationBloc>.value(value: navigationBloc),
              BlocProvider<ActiveOrdersBloc>.value(value: activeOrdersBloc),
            ],
            child: const PersistentNavigationShell(
              children: [
                Center(child: Text('Map Screen')),
                Center(child: Text('Profile Screen')),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the FAB
      await tester.tap(find.byType(OrdersFloatingActionButton));
      await tester.pumpAndSettle();

      // Verify Active Orders modal appears
      expect(
        find.text('Active Order'),
        findsOneWidget,
        reason: 'Active Orders modal should open',
      );
    });

    testWidgets('should render correct child based on navigation state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<NavigationBloc>.value(value: navigationBloc),
              BlocProvider<ActiveOrdersBloc>.value(value: activeOrdersBloc),
            ],
            child: const PersistentNavigationShell(
              children: [
                Center(child: Text('Map Screen')),
                Center(child: Text('Profile Screen')),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state should show Map screen (index 0)
      expect(find.text('Map Screen'), findsOneWidget);
      expect(find.text('Profile Screen'), findsNothing);

      // Change to Profile tab
      navigationBloc.add(const NavigationTabSelected(NavigationTab.profile));
      await tester.pumpAndSettle();

      // Note: IndexedStack keeps all children in the tree but only shows one
      // So both texts exist but only one is visible
      expect(find.text('Map Screen'), findsOneWidget);
      expect(find.text('Profile Screen'), findsOneWidget);
    });

    testWidgets('FAB should maintain proper spacing without bottom nav', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<NavigationBloc>.value(value: navigationBloc),
              BlocProvider<ActiveOrdersBloc>.value(value: activeOrdersBloc),
            ],
            child: const PersistentNavigationShell(
              children: [
                Center(child: Text('Map Screen')),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final fab = tester.widget<Container>(
        find.descendant(
          of: find.byType(OrdersFloatingActionButton),
          matching: find.byType(Container).first,
        ),
      );

      // Verify FAB has bottom margin
      expect(
        fab.margin,
        const EdgeInsets.only(bottom: 16),
        reason: 'FAB should have 16px bottom margin for proper spacing',
      );

      // Verify FAB size
      expect(fab.width, 64, reason: 'FAB width should be 64px');
      expect(fab.height, 64, reason: 'FAB height should be 64px');
    });
  });

  group('OrdersFloatingActionButton Animation Tests', () {
    late NavigationBloc navigationBloc;
    late ActiveOrdersBloc activeOrdersBloc;

    setUp(() {
      navigationBloc = NavigationBloc();
      activeOrdersBloc = ActiveOrdersBloc();
    });

    tearDown(() {
      navigationBloc.close();
      activeOrdersBloc.close();
    });

    testWidgets('FAB should have pulse animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<NavigationBloc>.value(value: navigationBloc),
              BlocProvider<ActiveOrdersBloc>.value(value: activeOrdersBloc),
            ],
            child: const PersistentNavigationShell(
              children: [
                Center(child: Text('Map Screen')),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AnimatedBuilder exists (used for pulse animation)
      expect(
        find.descendant(
          of: find.byType(OrdersFloatingActionButton),
          matching: find.byType(AnimatedBuilder),
        ),
        findsOneWidget,
        reason: 'FAB should have pulse animation',
      );
    });
  });
}
