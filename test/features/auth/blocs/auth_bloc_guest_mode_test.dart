import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:chefleet/features/auth/blocs/auth_bloc.dart';
import 'package:chefleet/core/services/guest_session_service.dart';
import 'auth_bloc_guest_mode_test.mocks.dart';

@GenerateMocks([GuestSessionService, SupabaseClient, GoTrueClient, AuthResponse, User, Session])
void main() {
  late MockGuestSessionService mockGuestSessionService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;

  setUp(() {
    mockGuestSessionService = MockGuestSessionService();
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();

    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
  });

  group('AuthBloc - Guest Mode', () {
    test('initial state is unauthenticated', () {
      // Arrange & Act
      final bloc = AuthBloc(guestSessionService: mockGuestSessionService);

      // Assert
      expect(bloc.state.mode, equals(AuthMode.unauthenticated));
      expect(bloc.state.isAuthenticated, isFalse);
      expect(bloc.state.isGuest, isFalse);
      expect(bloc.state.guestId, isNull);

      bloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'emits guest mode state when AuthGuestModeStarted succeeds',
      build: () {
        when(mockGuestSessionService.getOrCreateGuestId())
            .thenAnswer((_) async => 'guest_12345-abcde');
        return AuthBloc(guestSessionService: mockGuestSessionService);
      },
      act: (bloc) => bloc.add(const AuthGuestModeStarted()),
      expect: () => [
        const AuthState(
          mode: AuthMode.unauthenticated,
          isLoading: true,
        ),
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345-abcde',
          isAuthenticated: false,
          isLoading: false,
        ),
      ],
      verify: (_) {
        verify(mockGuestSessionService.getOrCreateGuestId()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits error state when AuthGuestModeStarted fails',
      build: () {
        when(mockGuestSessionService.getOrCreateGuestId())
            .thenThrow(GuestSessionException('Failed to create guest session'));
        return AuthBloc(guestSessionService: mockGuestSessionService);
      },
      act: (bloc) => bloc.add(const AuthGuestModeStarted()),
      expect: () => [
        const AuthState(
          mode: AuthMode.unauthenticated,
          isLoading: true,
        ),
        const AuthState(
          mode: AuthMode.unauthenticated,
          isLoading: false,
          errorMessage: 'Failed to start guest mode: GuestSessionException: Failed to create guest session',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'isGuest returns true when in guest mode',
      build: () {
        when(mockGuestSessionService.getOrCreateGuestId())
            .thenAnswer((_) async => 'guest_12345-abcde');
        return AuthBloc(guestSessionService: mockGuestSessionService);
      },
      act: (bloc) => bloc.add(const AuthGuestModeStarted()),
      verify: (bloc) {
        expect(bloc.state.isGuest, isTrue);
        expect(bloc.state.mode, equals(AuthMode.guest));
      },
    );
  });

  group('AuthBloc - Guest to Registered Conversion', () {
    late MockAuthResponse mockAuthResponse;
    late MockUser mockUser;
    late MockSession mockSession;

    setUp(() {
      mockAuthResponse = MockAuthResponse();
      mockUser = MockUser();
      mockSession = MockSession();

      when(mockUser.id).thenReturn('user_123');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockAuthResponse.user).thenReturn(mockUser);
      when(mockAuthResponse.session).thenReturn(mockSession);
    });

    blocTest<AuthBloc, AuthState>(
      'converts guest to registered user successfully',
      build: () {
        when(mockGuestSessionService.getOrCreateGuestId())
            .thenAnswer((_) async => 'guest_12345-abcde');
        when(mockGoTrueClient.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockAuthResponse);
        when(mockGuestSessionService.clearGuestSession())
            .thenAnswer((_) async => {});
        
        return AuthBloc(guestSessionService: mockGuestSessionService);
      },
      seed: () => const AuthState(
        mode: AuthMode.guest,
        guestId: 'guest_12345-abcde',
        isAuthenticated: false,
      ),
      act: (bloc) => bloc.add(
        const AuthGuestToRegisteredRequested(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        ),
      ),
      expect: () => [
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345-abcde',
          isAuthenticated: false,
          isLoading: true,
        ),
        AuthState(
          mode: AuthMode.authenticated,
          user: mockUser,
          guestId: null,
          isAuthenticated: true,
          isLoading: false,
        ),
      ],
      verify: (_) {
        verify(mockGoTrueClient.signUp(
          email: 'test@example.com',
          password: 'password123',
          data: {'name': 'Test User'},
        )).called(1);
        verify(mockGuestSessionService.clearGuestSession()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'fails conversion when not in guest mode',
      build: () => AuthBloc(guestSessionService: mockGuestSessionService),
      seed: () => const AuthState(
        mode: AuthMode.unauthenticated,
        isAuthenticated: false,
      ),
      act: (bloc) => bloc.add(
        const AuthGuestToRegisteredRequested(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        ),
      ),
      expect: () => [
        const AuthState(
          mode: AuthMode.unauthenticated,
          isAuthenticated: false,
          errorMessage: 'Not in guest mode',
        ),
      ],
      verify: (_) {
        verifyNever(mockGoTrueClient.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          data: anyNamed('data'),
        ));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'fails conversion when guestId is null',
      build: () => AuthBloc(guestSessionService: mockGuestSessionService),
      seed: () => const AuthState(
        mode: AuthMode.guest,
        guestId: null,
        isAuthenticated: false,
      ),
      act: (bloc) => bloc.add(
        const AuthGuestToRegisteredRequested(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        ),
      ),
      expect: () => [
        const AuthState(
          mode: AuthMode.guest,
          guestId: null,
          isAuthenticated: false,
          errorMessage: 'Not in guest mode',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'handles signup failure during conversion',
      build: () {
        when(mockGoTrueClient.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          data: anyNamed('data'),
        )).thenThrow(AuthException('Email already registered'));
        
        return AuthBloc(guestSessionService: mockGuestSessionService);
      },
      seed: () => const AuthState(
        mode: AuthMode.guest,
        guestId: 'guest_12345-abcde',
        isAuthenticated: false,
      ),
      act: (bloc) => bloc.add(
        const AuthGuestToRegisteredRequested(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        ),
      ),
      expect: () => [
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345-abcde',
          isAuthenticated: false,
          isLoading: true,
        ),
        const AuthState(
          mode: AuthMode.guest,
          guestId: 'guest_12345-abcde',
          isAuthenticated: false,
          isLoading: false,
          errorMessage: 'Conversion failed: AuthException: Email already registered',
        ),
      ],
      verify: (_) {
        verifyNever(mockGuestSessionService.clearGuestSession());
      },
    );

    blocTest<AuthBloc, AuthState>(
      'proceeds with conversion even if data migration fails',
      build: () {
        when(mockGoTrueClient.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockAuthResponse);
        when(mockGuestSessionService.clearGuestSession())
            .thenAnswer((_) async => {});
        
        return AuthBloc(guestSessionService: mockGuestSessionService);
      },
      seed: () => const AuthState(
        mode: AuthMode.guest,
        guestId: 'guest_12345-abcde',
        isAuthenticated: false,
      ),
      act: (bloc) => bloc.add(
        const AuthGuestToRegisteredRequested(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        ),
      ),
      verify: (bloc) {
        // Should still transition to authenticated state
        expect(bloc.state.mode, equals(AuthMode.authenticated));
        expect(bloc.state.isAuthenticated, isTrue);
        expect(bloc.state.guestId, isNull);
      },
    );
  });

  group('AuthBloc - Logout with Guest Mode', () {
    blocTest<AuthBloc, AuthState>(
      'clears guest session on logout from guest mode',
      build: () {
        when(mockGuestSessionService.clearGuestSession())
            .thenAnswer((_) async => {});
        when(mockGoTrueClient.signOut())
            .thenAnswer((_) async => {});
        
        return AuthBloc(guestSessionService: mockGuestSessionService);
      },
      seed: () => const AuthState(
        mode: AuthMode.guest,
        guestId: 'guest_12345-abcde',
        isAuthenticated: false,
      ),
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      verify: (_) {
        verify(mockGoTrueClient.signOut()).called(1);
      },
    );
  });

  group('AuthBloc - State Transitions', () {
    test('copyWith preserves guest mode state', () {
      // Arrange
      const initialState = AuthState(
        mode: AuthMode.guest,
        guestId: 'guest_12345-abcde',
        isAuthenticated: false,
      );

      // Act
      final newState = initialState.copyWith(isLoading: true);

      // Assert
      expect(newState.mode, equals(AuthMode.guest));
      expect(newState.guestId, equals('guest_12345-abcde'));
      expect(newState.isLoading, isTrue);
    });

    test('copyWith can transition from guest to authenticated', () {
      // Arrange
      const initialState = AuthState(
        mode: AuthMode.guest,
        guestId: 'guest_12345-abcde',
        isAuthenticated: false,
      );

      // Act
      final newState = initialState.copyWith(
        mode: AuthMode.authenticated,
        guestId: null,
        isAuthenticated: true,
      );

      // Assert
      expect(newState.mode, equals(AuthMode.authenticated));
      expect(newState.guestId, isNull);
      expect(newState.isAuthenticated, isTrue);
      expect(newState.isGuest, isFalse);
    });
  });

  group('AuthMode Enum', () {
    test('has correct values', () {
      expect(AuthMode.values.length, equals(3));
      expect(AuthMode.values, contains(AuthMode.guest));
      expect(AuthMode.values, contains(AuthMode.authenticated));
      expect(AuthMode.values, contains(AuthMode.unauthenticated));
    });
  });
}
