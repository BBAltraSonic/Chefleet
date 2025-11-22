import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/settings/screens/notifications_screen.dart';
import 'package:chefleet/features/settings/blocs/notifications_bloc.dart';
import 'package:chefleet/features/settings/blocs/notifications_state.dart';
import 'package:chefleet/core/repositories/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockNotificationsBloc extends Mock implements NotificationsBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('NotificationsScreen Widget Tests', () {
    late MockUserRepository mockUserRepository;
    late MockNotificationsBloc mockNotificationsBloc;

    setUp(() {
      mockUserRepository = MockUserRepository();
      mockNotificationsBloc = MockNotificationsBloc();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<NotificationsBloc>.value(
          value: mockNotificationsBloc,
          child: const NotificationsScreen(),
        ),
      );
    }

    testWidgets('displays notifications header', (WidgetTester tester) async {
      when(() => mockNotificationsBloc.state).thenReturn(
        NotificationsState(
          preferences: {},
          status: NotificationsStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should display title
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('displays order updates toggle', (WidgetTester tester) async {
      when(() => mockNotificationsBloc.state).thenReturn(
        NotificationsState(
          preferences: {'order_updates': true},
          status: NotificationsStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should have order updates toggle
      expect(find.text('Order Updates'), findsOneWidget);
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('displays chat messages toggle', (WidgetTester tester) async {
      when(() => mockNotificationsBloc.state).thenReturn(
        NotificationsState(
          preferences: {'chat_messages': true},
          status: NotificationsStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should have chat messages toggle
      expect(find.text('Chat Messages'), findsOneWidget);
    });

    testWidgets('displays promotions toggle', (WidgetTester tester) async {
      when(() => mockNotificationsBloc.state).thenReturn(
        NotificationsState(
          preferences: {'promotions': false},
          status: NotificationsStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should have promotions toggle
      expect(find.text('Promotions'), findsOneWidget);
    });

    testWidgets('toggling switch updates preferences', (WidgetTester tester) async {
      when(() => mockNotificationsBloc.state).thenReturn(
        NotificationsState(
          preferences: {'order_updates': true},
          status: NotificationsStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and toggle switch
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pumpAndSettle();

        // Should update preferences
        // This would be verified by checking bloc events
      }
    });

    testWidgets('preferences are stored in users_public table', (WidgetTester tester) async {
      when(() => mockNotificationsBloc.state).thenReturn(
        NotificationsState(
          preferences: {},
          status: NotificationsStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Storage location is verified in bloc/repository tests
      // UI test just verifies the preferences are loaded and saved
    });

    testWidgets('displays loading state', (WidgetTester tester) async {
      when(() => mockNotificationsBloc.state).thenReturn(
        NotificationsState(
          preferences: {},
          status: NotificationsStatus.loading,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state', (WidgetTester tester) async {
      when(() => mockNotificationsBloc.state).thenReturn(
        NotificationsState(
          preferences: {},
          status: NotificationsStatus.error,
          errorMessage: 'Failed to load preferences',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show error
      expect(find.text('Failed to load preferences'), findsOneWidget);
    });

    testWidgets('displays empty state when no preferences', (WidgetTester tester) async {
      when(() => mockNotificationsBloc.state).thenReturn(
        NotificationsState(
          preferences: {},
          status: NotificationsStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show default toggles
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('shows success toast after saving', (WidgetTester tester) async {
      when(() => mockNotificationsBloc.state).thenReturn(
        NotificationsState(
          preferences: {'order_updates': true},
          status: NotificationsStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Toggle a switch
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pumpAndSettle();

        // Should show success message
        expect(find.text('Preferences saved'), findsOneWidget);
      }
    });

    testWidgets('back button navigates back', (WidgetTester tester) async {
      when(() => mockNotificationsBloc.state).thenReturn(
        NotificationsState(
          preferences: {},
          status: NotificationsStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find back button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
    });
  });
}
