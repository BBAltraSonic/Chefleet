import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/settings/screens/settings_screen.dart';
import 'package:chefleet/core/blocs/auth_bloc.dart';
import 'package:chefleet/core/blocs/auth_state.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('SettingsScreen Widget Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const SettingsScreen(),
        ),
      );
    }

    testWidgets('displays settings header', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        AuthState(status: AuthStatus.authenticated),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should display settings title
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('displays account section', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        AuthState(status: AuthStatus.authenticated),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should display account settings
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('displays notifications option', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        AuthState(status: AuthStatus.authenticated),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should have notifications option
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('tapping notifications navigates to notifications screen', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        AuthState(status: AuthStatus.authenticated),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap notifications
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      // Would verify navigation with router mock
    });

    testWidgets('displays privacy policy option', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        AuthState(status: AuthStatus.authenticated),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should have privacy policy
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('displays terms of service option', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        AuthState(status: AuthStatus.authenticated),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should have terms
      expect(find.text('Terms of Service'), findsOneWidget);
    });

    testWidgets('tapping privacy policy shows dialog', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        AuthState(status: AuthStatus.authenticated),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap privacy policy
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      // Should show dialog
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('tapping terms shows dialog', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        AuthState(status: AuthStatus.authenticated),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap terms
      await tester.tap(find.text('Terms of Service'));
      await tester.pumpAndSettle();

      // Should show dialog
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('displays logout option', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        AuthState(status: AuthStatus.authenticated),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should have logout button
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('tapping logout shows confirmation', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        AuthState(status: AuthStatus.authenticated),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap logout
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
    });

    testWidgets('displays app version', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        AuthState(status: AuthStatus.authenticated),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should display version
      expect(find.textContaining('Version'), findsOneWidget);
    });
  });
}
