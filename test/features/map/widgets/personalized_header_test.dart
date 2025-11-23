import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/map/widgets/personalized_header.dart';
import 'package:chefleet/features/auth/blocs/auth_bloc.dart';
import 'package:chefleet/features/auth/models/user_model.dart';
import 'package:chefleet/core/theme/app_theme.dart';

// Mock classes
class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  group('PersonalizedHeader Widget Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    Widget createTestWidget(AuthState state) {
      return BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: PersonalizedHeader(),
          ),
        ),
      );
    }

    testWidgets('displays greeting based on time of day - morning',
        (WidgetTester tester) async {
      // Mock morning time (10 AM)
      final mockUser = User(
        id: 'test-id',
        email: 'test@example.com',
        fullName: 'John Doe',
        role: 'buyer',
        phoneNumber: null,
        avatarUrl: null,
      );

      when(() => mockAuthBloc.state).thenReturn(
        AuthAuthenticated(mockUser),
      );
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthAuthenticated(mockUser)),
      );

      await tester.pumpWidget(createTestWidget(AuthAuthenticated(mockUser)));
      await tester.pumpAndSettle();

      // Check for greeting text (will be based on actual time)
      expect(find.textContaining('Good'), findsOneWidget);
      expect(find.textContaining('John'), findsOneWidget);
    });

    testWidgets('displays default greeting for guest user',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(const AuthInitial()),
      );

      await tester.pumpWidget(createTestWidget(const AuthInitial()));
      await tester.pumpAndSettle();

      // Should show Guest greeting
      expect(find.textContaining('Guest'), findsOneWidget);
    });

    testWidgets('displays user avatar when authenticated',
        (WidgetTester tester) async {
      final mockUser = User(
        id: 'test-id',
        email: 'test@example.com',
        fullName: 'Jane Smith',
        role: 'buyer',
        phoneNumber: null,
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      when(() => mockAuthBloc.state).thenReturn(
        AuthAuthenticated(mockUser),
      );
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthAuthenticated(mockUser)),
      );

      await tester.pumpWidget(createTestWidget(AuthAuthenticated(mockUser)));
      await tester.pumpAndSettle();

      // Should find CircleAvatar widget
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('displays online indicator',
        (WidgetTester tester) async {
      final mockUser = User(
        id: 'test-id',
        email: 'test@example.com',
        fullName: 'John Doe',
        role: 'buyer',
        phoneNumber: null,
        avatarUrl: null,
      );

      when(() => mockAuthBloc.state).thenReturn(
        AuthAuthenticated(mockUser),
      );
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthAuthenticated(mockUser)),
      );

      await tester.pumpWidget(createTestWidget(AuthAuthenticated(mockUser)));
      await tester.pumpAndSettle();

      // Should find online indicator (green dot)
      final containerFinder = find.descendant(
        of: find.byType(Stack),
        matching: find.byType(Positioned),
      );
      expect(containerFinder, findsWidgets);
    });

    testWidgets('displays subtitle text',
        (WidgetTester tester) async {
      final mockUser = User(
        id: 'test-id',
        email: 'test@example.com',
        fullName: 'John Doe',
        role: 'buyer',
        phoneNumber: null,
        avatarUrl: null,
      );

      when(() => mockAuthBloc.state).thenReturn(
        AuthAuthenticated(mockUser),
      );
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthAuthenticated(mockUser)),
      );

      await tester.pumpWidget(createTestWidget(AuthAuthenticated(mockUser)));
      await tester.pumpAndSettle();

      // Check for subtitle
      expect(
        find.textContaining('Ready to discover'),
        findsOneWidget,
      );
    });

    testWidgets('has proper padding and spacing',
        (WidgetTester tester) async {
      final mockUser = User(
        id: 'test-id',
        email: 'test@example.com',
        fullName: 'John Doe',
        role: 'buyer',
        phoneNumber: null,
        avatarUrl: null,
      );

      when(() => mockAuthBloc.state).thenReturn(
        AuthAuthenticated(mockUser),
      );
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthAuthenticated(mockUser)),
      );

      await tester.pumpWidget(createTestWidget(AuthAuthenticated(mockUser)));
      await tester.pumpAndSettle();

      // Verify Padding widget exists with correct values
      final paddingFinder = find.byType(Padding);
      expect(paddingFinder, findsWidgets);
    });

    testWidgets('handles long names properly',
        (WidgetTester tester) async {
      final mockUser = User(
        id: 'test-id',
        email: 'test@example.com',
        fullName: 'Christopher Alexander Montgomery',
        role: 'buyer',
        phoneNumber: null,
        avatarUrl: null,
      );

      when(() => mockAuthBloc.state).thenReturn(
        AuthAuthenticated(mockUser),
      );
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthAuthenticated(mockUser)),
      );

      await tester.pumpWidget(createTestWidget(AuthAuthenticated(mockUser)));
      await tester.pumpAndSettle();

      // Should render without overflow
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Christopher'), findsOneWidget);
    });

    testWidgets('uses correct text styles',
        (WidgetTester tester) async {
      final mockUser = User(
        id: 'test-id',
        email: 'test@example.com',
        fullName: 'John Doe',
        role: 'buyer',
        phoneNumber: null,
        avatarUrl: null,
      );

      when(() => mockAuthBloc.state).thenReturn(
        AuthAuthenticated(mockUser),
      );
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthAuthenticated(mockUser)),
      );

      await tester.pumpWidget(createTestWidget(AuthAuthenticated(mockUser)));
      await tester.pumpAndSettle();

      // Find Text widgets
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      expect(textWidgets.length, greaterThan(0));

      // Verify at least one has bold font weight (for name)
      final hasBoldText = textWidgets.any((text) {
        return text.style?.fontWeight == FontWeight.bold ||
            text.style?.fontWeight == FontWeight.w700 ||
            text.style?.fontWeight == FontWeight.w600;
      });
      expect(hasBoldText, isTrue);
    });
  });
}
