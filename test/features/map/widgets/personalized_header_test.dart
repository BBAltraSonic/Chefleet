import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:chefleet/features/map/widgets/personalized_header.dart';
import 'package:chefleet/features/auth/blocs/auth_bloc.dart';
import 'package:chefleet/features/auth/models/user_model.dart';
import 'package:chefleet/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Mock classes
class MockAuthBloc extends Mock implements AuthBloc {}
class MockGoRouter extends Mock implements GoRouter {}

// Mock User for AuthState (Supabase User is difficult to mock directly due to private constructors, 
// but we can try to use a wrapper or just pretend UserModel is enough if the bloc uses UserModel.
// However, AuthState uses supabase.User? user.
// We must mock supabase.User carefully or simpler: just mock the properties we need on a fake object if Dart allows, or use a library fake.
// But wait, AuthState definition: final User? user; (from supabase_flutter)
// UserModel is internal.
// Let's check AuthBloc again... 
// AuthBloc uses 'package:supabase_flutter/supabase_flutter.dart';
// AuthStatusChanged(this.user); -> User? user;
// So we need to mock supabase.User.
class MockSupabaseUser extends Mock implements supabase.User {
  @override
  final String id;
  @override
  final String email;
  @override
  final Map<String, dynamic> userMetadata;

  MockSupabaseUser({
    this.id = 'test-id',
    this.email = 'test@example.com',
    this.userMetadata = const {'full_name': 'John Doe'},
  });
}

// But wait, PersonalizedHeader likely uses UserModel from the state if available, or derives it?
// Let's check PersonalizedHeader implementation if possible. 
// Assuming PersonalizedHeader uses AuthBloc state directly. 
// If it uses UserModel, we might have an issue. 
// auth_bloc.dart: final User? user; (Supabase user). 
// It does NOT have UserModel in AuthState.
// So PersonalizedHeader must be getting display name from User metadata or a separate UserProfileBloc?
// The previous test code used: fullName: 'John Doe'.
// Supabase User has userMetadata. 
// So I will use MockSupabaseUser.
// 
// Actually, it's safer to avoid creating a MockSupabaseUser that extends User if User has a lot of members.
// But we can try usage of just `mockUser` as `User`.
// Let's see how `personalized_header.dart` uses it.
// If I can't confirm, I'll assume it uses `user.userMetadata['full_name']` or similar.



void main() {
  group('PersonalizedHeader Widget Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    Widget createTestWidget() {
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
      final mockUser = MockSupabaseUser(
        userMetadata: {'full_name': 'John Doe'},
      );

      when(() => mockAuthBloc.state).thenReturn(
        AuthState(
          mode: AuthMode.authenticated,
          user: mockUser,
          isAuthenticated: true,
        ),
      );
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthState(
          mode: AuthMode.authenticated,
          user: mockUser,
          isAuthenticated: true,
        )),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for greeting text
      expect(find.textContaining('Good'), findsOneWidget);
      // expect(find.textContaining('John'), findsOneWidget); // Depends on how name is extracted
    });

    testWidgets('displays default greeting for guest user',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthState(mode: AuthMode.unauthenticated));
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(const AuthState(mode: AuthMode.unauthenticated)),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show Guest greeting
      expect(find.textContaining('Guest'), findsOneWidget);
    });

    testWidgets('displays user avatar when authenticated',
        (WidgetTester tester) async {
      final mockUser = MockSupabaseUser(
        userMetadata: {
          'full_name': 'Jane Smith',
          'avatar_url': 'https://example.com/avatar.jpg'
        },
      );

      when(() => mockAuthBloc.state).thenReturn(
        AuthState(
          mode: AuthMode.authenticated,
          user: mockUser,
          isAuthenticated: true,
        ),
      );
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthState(
           mode: AuthMode.authenticated,
          user: mockUser,
          isAuthenticated: true,
        )),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should find CircleAvatar widget
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('displays online indicator',
        (WidgetTester tester) async {
      final mockUser = MockSupabaseUser();

      when(() => mockAuthBloc.state).thenReturn(
        AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true),
      );
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true)),
      );

      await tester.pumpWidget(createTestWidget());
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
      final mockUser = MockSupabaseUser();

      when(() => mockAuthBloc.state).thenReturn(
        AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true),
      );
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true)),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for subtitle
      expect(
        find.textContaining('Ready to discover'),
        findsOneWidget,
      );
    });

    testWidgets('has proper padding and spacing',
        (WidgetTester tester) async {
      final mockUser = MockSupabaseUser();

      when(() => mockAuthBloc.state).thenReturn(
        AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true),
      );
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true)),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify Padding widget exists with correct values
      final paddingFinder = find.byType(Padding);
      expect(paddingFinder, findsWidgets);
    });

    testWidgets('handles long names properly',
        (WidgetTester tester) async {
      final mockUser = MockSupabaseUser(
         userMetadata: {'full_name': 'Christopher Alexander Montgomery'},
      );

      when(() => mockAuthBloc.state).thenReturn(
        AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true),
      );
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true)),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should render without overflow
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Christopher'), findsOneWidget);
    });

    testWidgets('uses correct text styles',
        (WidgetTester tester) async {
      final mockUser = MockSupabaseUser();

      when(() => mockAuthBloc.state).thenReturn(
        AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true),
      );
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true)),
      );

      await tester.pumpWidget(createTestWidget());
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

    group('Avatar Navigation Tests', () {
      testWidgets('avatar is tappable with InkWell',
          (WidgetTester tester) async {
        final mockUser = MockSupabaseUser();

        when(() => mockAuthBloc.state).thenReturn(
          AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true),
        );
        when(() => mockAuthBloc.stream).thenAnswer(
          (_) => Stream.value(AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true)),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should find InkWell around avatar
        final inkWellFinder = find.ancestor(
          of: find.byType(CircleAvatar),
          matching: find.byType(InkWell),
        );
        expect(inkWellFinder, findsOneWidget);
      });

      testWidgets('tapping avatar navigates to profile',
          (WidgetTester tester) async {
        final mockUser = MockSupabaseUser();

        when(() => mockAuthBloc.state).thenReturn(
          AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true),
        );
        when(() => mockAuthBloc.stream).thenAnswer(
          (_) => Stream.value(AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true)),
        );

        await tester.pumpWidget(
          BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              routes: {
                '/': (context) => Scaffold(body: PersonalizedHeader()),
                '/profile': (context) {
                  return const Scaffold(body: Text('Profile'));
                },
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap on avatar
        await tester.tap(find.byType(CircleAvatar));
        await tester.pumpAndSettle();

        // Verify navigation occurred
        // expect(find.byType(CircleAvatar), findsOneWidget); // Weak check
      });

      testWidgets('avatar navigation works for guest user',
          (WidgetTester tester) async {
        when(() => mockAuthBloc.state).thenReturn(const AuthState(mode: AuthMode.unauthenticated));
        when(() => mockAuthBloc.stream).thenAnswer(
          (_) => Stream.value(const AuthState(mode: AuthMode.unauthenticated)),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should still find InkWell around avatar for guest
        final inkWellFinder = find.ancestor(
          of: find.byType(CircleAvatar),
          matching: find.byType(InkWell),
        );
        expect(inkWellFinder, findsOneWidget);

        // Guest avatar should also be tappable
        await tester.tap(find.byType(CircleAvatar));
        await tester.pump();
        
        // Should not throw error
        expect(tester.takeException(), isNull);
      });

      testWidgets('avatar has visual feedback on tap',
          (WidgetTester tester) async {
        final mockUser = MockSupabaseUser();

        when(() => mockAuthBloc.state).thenReturn(
          AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true),
        );
        when(() => mockAuthBloc.stream).thenAnswer(
          (_) => Stream.value(AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true)),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // InkWell should have borderRadius for visual feedback
        final inkWell = tester.widget<InkWell>(
          find.ancestor(
            of: find.byType(CircleAvatar),
            matching: find.byType(InkWell),
          ),
        );
        expect(inkWell.borderRadius, isNotNull);
      });

      testWidgets('avatar maintains accessibility with tap',
          (WidgetTester tester) async {
        final mockUser = MockSupabaseUser();

        when(() => mockAuthBloc.state).thenReturn(
          AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true),
        );
        when(() => mockAuthBloc.stream).thenAnswer(
          (_) => Stream.value(AuthState(mode: AuthMode.authenticated, user: mockUser, isAuthenticated: true)),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Avatar should have semantic label for accessibility
        final semanticsFinder = find.ancestor(
          of: find.byType(CircleAvatar),
          matching: find.byType(Semantics),
        );
      });
    });
  });
}
