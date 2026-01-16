import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:chefleet/core/services/guest_session_service.dart';
import 'package:chefleet/features/auth/blocs/auth_bloc.dart';
import 'package:chefleet/features/auth/models/auth_error_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockGuestSessionService extends Mock implements GuestSessionService {}
class MockUser extends Mock implements User {}
class MockSession extends Mock implements Session {}
class MockAuthResponse extends Mock implements AuthResponse {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuthClient;
  late MockGuestSessionService mockGuestSessionService;
  late MockUser mockUser;
  late MockSession mockSession;
  late MockAuthResponse mockAuthResponse;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockAuthClient = MockGoTrueClient();
    mockGuestSessionService = MockGuestSessionService();
    mockUser = MockUser();
    mockSession = MockSession();
    mockAuthResponse = MockAuthResponse();

    // Setup Supabase Client mock
    when(() => mockSupabaseClient.auth).thenReturn(mockAuthClient);
    
    // Setup generic user properties
    when(() => mockUser.id).thenReturn('test-user-id');
    when(() => mockUser.email).thenReturn('test@example.com');
    
    // Setup auth response
    when(() => mockAuthResponse.user).thenReturn(mockUser);
    when(() => mockAuthResponse.session).thenReturn(mockSession);
    
    // Setup session
    when(() => mockSession.user).thenReturn(mockUser);

    // Setup Auth Listener (important as AuthBloc listens to it)
    when(() => mockAuthClient.onAuthStateChange).thenAnswer(
      (_) => Stream.empty(),
    );
    
    // Initial state check
    when(() => mockAuthClient.currentUser).thenReturn(null);
  });

  group('AuthBloc Error Handling', () {
    blocTest<AuthBloc, AuthState>(
      'emits invalidCredentials error on login failure',
      build: () => AuthBloc(
        supabaseClient: mockSupabaseClient,
        guestSessionService: mockGuestSessionService,
      ),
      act: (bloc) {
        // Setup login failure
        when(() => mockAuthClient.signInWithPassword(
          email: 'test@example.com',
          password: 'wrong-password',
        )).thenThrow(const AuthException('Invalid login credentials'));
        
        bloc.add(const AuthLoginRequested('test@example.com', 'wrong-password'));
      },
      expect: () => [
        // Loading state
        isA<AuthState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.errorMessage, 'errorMessage', null),
        // Error state
        isA<AuthState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorType, 'errorType', AuthErrorType.invalidCredentials)
            .having((s) => s.errorMessage, 'errorMessage', contains('Invalid email or password')),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits networkError on timeout',
      build: () => AuthBloc(
        supabaseClient: mockSupabaseClient,
        guestSessionService: mockGuestSessionService,
      ),
      act: (bloc) {
        // Setup timeout (we can't easily simulate Future.timeout in sync test, 
        // but we can simulate the exception it throws)
        when(() => mockAuthClient.signInWithPassword(
          email: 'test@example.com',
          password: 'password',
        )).thenThrow(TimeoutException('Timed out'));
        
        bloc.add(const AuthLoginRequested('test@example.com', 'password'));
      },
      expect: () => [
        isA<AuthState>().having((s) => s.isLoading, 'isLoading', true),
        isA<AuthState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorType, 'errorType', AuthErrorType.networkError),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits rateLimited error on 429',
      build: () => AuthBloc(
        supabaseClient: mockSupabaseClient,
        guestSessionService: mockGuestSessionService,
      ),
      act: (bloc) {
        when(() => mockAuthClient.signInWithPassword(
          email: 'test@example.com',
          password: 'password',
        )).thenThrow(const AuthException('Too many requests', statusCode: '429'));
        
        bloc.add(const AuthLoginRequested('test@example.com', 'password'));
      },
      expect: () => [
        isA<AuthState>().having((s) => s.isLoading, 'isLoading', true),
        isA<AuthState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorType, 'errorType', AuthErrorType.rateLimited),
      ],
    );
    
    blocTest<AuthBloc, AuthState>(
      'clears error when requested',
      build: () => AuthBloc(
        supabaseClient: mockSupabaseClient,
        guestSessionService: mockGuestSessionService,
      ),
      seed: () => const AuthState(
        errorMessage: 'Some error',
        errorType: AuthErrorType.unknown,
      ),
      act: (bloc) => bloc.add(const AuthErrorOccurred('')),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.errorMessage, 'errorMessage', null)
            .having((s) => s.errorType, 'errorType', null),
      ],
    );
  });
}
