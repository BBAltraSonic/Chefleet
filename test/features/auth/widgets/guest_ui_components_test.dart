import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:chefleet/features/auth/blocs/auth_bloc.dart';
import 'package:chefleet/features/auth/widgets/guest_conversion_prompt.dart';
import 'package:chefleet/features/auth/screens/auth_screen.dart';
import 'package:chefleet/features/profile/widgets/profile_drawer.dart';
import 'package:chefleet/features/auth/blocs/user_profile_bloc.dart';
import 'package:chefleet/core/services/guest_conversion_service.dart';

import 'guest_ui_components_test.mocks.dart';

@GenerateMocks([AuthBloc, UserProfileBloc, GuestConversionService])
void main() {
  late MockAuthBloc mockAuthBloc;
  late MockUserProfileBloc mockUserProfileBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockUserProfileBloc = MockUserProfileBloc();
  });

  Widget createTestWidget(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<UserProfileBloc>.value(value: mockUserProfileBloc),
      ],
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('GuestConversionPrompt Widget Tests', () {
    testWidgets('shows prompt for guest users', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(
          const GuestConversionPrompt(
            context: ConversionPromptContext.general,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Get More from Chefleet'), findsOneWidget);
      expect(find.text('Create a free account to unlock all features and save your progress.'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('hides prompt for authenticated users', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.authenticated,
          isAuthenticated: true,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.authenticated,
          isAuthenticated: true,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(
          const GuestConversionPrompt(
            context: ConversionPromptContext.general,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Get More from Chefleet'), findsNothing);
      expect(find.text('Create Account'), findsNothing);
    });

    testWidgets('shows correct message for afterOrder context', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(
          const GuestConversionPrompt(
            context: ConversionPromptContext.afterOrder,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Save Your Order'), findsOneWidget);
      expect(find.text('Create an account to track your order and access your history.'), findsOneWidget);
    });

    testWidgets('shows correct message for profile context', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(
          const GuestConversionPrompt(
            context: ConversionPromptContext.profile,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Unlock All Features'), findsOneWidget);
      expect(find.text('Create an account to save favorites, track orders, and more.'), findsOneWidget);
    });

    testWidgets('calls onDismiss when Later button is tapped', (tester) async {
      // Arrange
      var dismissed = false;
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(
          GuestConversionPrompt(
            context: ConversionPromptContext.general,
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      // Assert
      expect(dismissed, isTrue);
    });
  });

  group('GuestConversionBanner Widget Tests', () {
    testWidgets('shows banner for guest users', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(const GuestConversionBanner()),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Create an account'), findsOneWidget);
      expect(find.text('Save your progress and unlock features'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('hides banner for authenticated users', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.authenticated,
          isAuthenticated: true,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.authenticated,
          isAuthenticated: true,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(const GuestConversionBanner()),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Create an account'), findsNothing);
      expect(find.text('Sign Up'), findsNothing);
    });

    testWidgets('shows close button when onDismiss is provided', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(
          GuestConversionBanner(onDismiss: () {}),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  group('AuthScreen - Guest Mode Button Tests', () {
    testWidgets('shows Continue as Guest button', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.unauthenticated,
          isAuthenticated: false,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.unauthenticated,
          isAuthenticated: false,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(const AuthScreen()),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.text('Browse and order without creating an account'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsWidgets);
    });

    testWidgets('guest button is disabled during loading', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.unauthenticated,
          isAuthenticated: false,
          isLoading: true,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.unauthenticated,
          isAuthenticated: false,
          isLoading: true,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(const AuthScreen()),
      );
      await tester.pumpAndSettle();

      // Assert
      final button = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Continue as Guest'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('shows OR divider between auth and guest options', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.unauthenticated,
          isAuthenticated: false,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.unauthenticated,
          isAuthenticated: false,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(const AuthScreen()),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('OR'), findsOneWidget);
    });
  });

  group('ProfileDrawer - Guest Mode Tests', () {
    testWidgets('shows guest header for guest users', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(const ProfileDrawer()),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Guest User'), findsOneWidget);
      expect(find.text('GUEST'), findsOneWidget);
      expect(find.text('Browsing without an account'), findsOneWidget);
    });

    testWidgets('shows Exit Guest Mode button for guest users', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(const ProfileDrawer()),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Exit Guest Mode'), findsOneWidget);
    });

    testWidgets('shows Logout button for authenticated users', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.authenticated,
          isAuthenticated: true,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.authenticated,
          isAuthenticated: true,
        ),
      ));
      when(mockUserProfileBloc.state).thenReturn(
        const UserProfileState(isLoading: false, profile: {}),
      );
      when(mockUserProfileBloc.stream).thenAnswer((_) => Stream.value(
        const UserProfileState(isLoading: false, profile: {}),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(const ProfileDrawer()),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('Exit Guest Mode'), findsNothing);
    });

    testWidgets('shows conversion prompt for guest users', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(const ProfileDrawer()),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Unlock All Features'), findsOneWidget);
    });
  });

  group('Guest UI Accessibility Tests', () {
    testWidgets('guest conversion prompt has proper semantics', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(
          const GuestConversionPrompt(
            context: ConversionPromptContext.general,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('guest badge has readable text', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      );
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345',
          isAuthenticated: false,
        ),
      ));

      // Act
      await tester.pumpWidget(
        createTestWidget(const ProfileDrawer()),
      );
      await tester.pumpAndSettle();

      // Assert
      final guestBadge = find.text('GUEST');
      expect(guestBadge, findsOneWidget);
    });
  });
}
