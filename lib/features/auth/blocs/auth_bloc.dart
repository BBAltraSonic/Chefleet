import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/blocs/base_bloc.dart';
import '../../../core/services/guest_session_service.dart';

class AuthEvent extends AppEvent {
  const AuthEvent();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested(this.email, this.password);

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthSignupRequested extends AuthEvent {
  const AuthSignupRequested(this.email, this.password, this.name);

  final String email;
  final String password;
  final String name;

  @override
  List<Object?> get props => [email, password, name];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthStatusChanged extends AuthEvent {
  const AuthStatusChanged(this.user);

  final User? user;

  @override
  List<Object?> get props => [user];
}

class AuthErrorOccurred extends AuthEvent {
  const AuthErrorOccurred(this.errorMessage);

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

class AuthGuestModeStarted extends AuthEvent {
  const AuthGuestModeStarted();
}

class AuthGuestToRegisteredRequested extends AuthEvent {
  const AuthGuestToRegisteredRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  final String email;
  final String password;
  final String name;

  @override
  List<Object?> get props => [email, password, name];
}

enum AuthMode {
  guest,           // Anonymous user with guest_id
  authenticated,   // Registered user with auth.users record
  unauthenticated  // No session (splash/auth screens)
}

class AuthState extends AppState {
  const AuthState({
    this.mode = AuthMode.unauthenticated,
    this.user,
    this.guestId,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthMode mode;
  final User? user;
  final String? guestId;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  bool get isGuest => mode == AuthMode.guest;

  AuthState copyWith({
    AuthMode? mode,
    User? user,
    String? guestId,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      mode: mode ?? this.mode,
      user: user ?? this.user,
      guestId: guestId ?? this.guestId,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [mode, user, guestId, isAuthenticated, isLoading, errorMessage];
}

class AuthBloc extends AppBloc<AuthEvent, AuthState> {
  AuthBloc({
    GuestSessionService? guestSessionService,
  })  : _guestSessionService = guestSessionService ?? GuestSessionService(),
        super(const AuthState()) {
    // Register all event handlers first
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthErrorOccurred>(_onAuthErrorOccurred);
    on<AuthGuestModeStarted>(_onGuestModeStarted);
    on<AuthGuestToRegisteredRequested>(_onGuestToRegisteredRequested);

    // Initialize auth state after handlers are registered
    _initializeAuth();

    // Set up auth state listener for automatic session recovery
    _setupAuthStateListener();
  }

  final GuestSessionService _guestSessionService;

  void _initializeAuth() {
    try {
      // Get current auth state safely
      final currentUser = Supabase.instance.client.auth.currentUser;

      // Use addPostFrameCallback to ensure the widget tree is fully built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isClosed) return; // Don't add events if bloc is disposed
        add(AuthStatusChanged(currentUser));
      });
    } catch (e) {
      // Handle initialization errors gracefully
      if (isClosed) return;
      add(AuthErrorOccurred('Auth initialization failed: ${e.toString()}'));
    }
  }

  void _setupAuthStateListener() {
    // Listen to Supabase auth state changes for automatic session recovery
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (isClosed) return;

      final AuthChangeEvent event = data.event;
      final User? user = data.session?.user;

      switch (event) {
        case AuthChangeEvent.initialSession:
          // Initial session is handled by _initializeAuth
          break;
        case AuthChangeEvent.signedIn:
          add(AuthStatusChanged(user));
          break;
        case AuthChangeEvent.signedOut:
          add(const AuthStatusChanged(null));
          break;
        case AuthChangeEvent.userUpdated:
          add(AuthStatusChanged(user));
          break;
        case AuthChangeEvent.userDeleted:
          add(const AuthStatusChanged(null));
          break;
        case AuthChangeEvent.passwordRecovery:
          // Handle password recovery if needed
          break;
        case AuthChangeEvent.tokenRefreshed:
          // Token is refreshed automatically, just update user state
          add(AuthStatusChanged(user));
          break;
        case AuthChangeEvent.mfaChallengeVerified:
          // MFA challenge verified, update user state
          add(AuthStatusChanged(user));
          break;
      }
    });
  }

  void _onAuthErrorOccurred(AuthErrorOccurred event, Emitter<AuthState> emit) {
    // Only update error message if it's not empty (used for clearing errors)
    if (event.errorMessage.isNotEmpty) {
      emit(state.copyWith(errorMessage: event.errorMessage));
    } else {
      // Clear the error message
      emit(state.copyWith(errorMessage: null));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        add(AuthStatusChanged(response.user));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Login failed. Please check your credentials.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Login error: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      print('DEBUG: Starting signup for email: ${event.email}');

      final response = await Supabase.instance.client.auth.signUp(
        email: event.email,
        password: event.password,
        data: {'name': event.name},
      );

      print('DEBUG: Signup response received');
      print('DEBUG: User created: ${response.user?.email}');
      print('DEBUG: Session active: ${response.session != null}');
      // Note: AuthResponse doesn't have error property directly
      // The error is thrown as an exception, not part of the response

      if (response.user != null) {
        print('DEBUG: Signup successful, attempting to create profile...');

        // Try to create profile manually since the trigger might be failing
        try {
          final supabase = Supabase.instance.client;
          final profileResult = await supabase
              .from('profiles')
              .insert({
                'id': response.user!.id,
                'email': event.email,
                'name': event.name,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .maybeSingle();

          print('DEBUG: Profile creation result: $profileResult');

        } catch (profileError) {
          print('DEBUG: Profile creation failed: $profileError');

          // If profile creation fails due to audit trigger, try a workaround
          if (profileError.toString().contains('audit_logs') ||
              profileError.toString().contains('500')) {
            print('DEBUG: Detected audit trigger issue, user created but profile failed');
            // Still proceed with successful signup since auth user was created
            // The profile can be created later or through a separate process
          } else {
            // Re-throw non-audit related errors
            rethrow;
          }
        }

        add(AuthStatusChanged(response.user));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Signup failed. Please try again.',
        ));
      }
    } catch (e) {
      print('DEBUG: Detailed signup error:');
      print('DEBUG: Error type: ${e.runtimeType}');
      print('DEBUG: Error message: ${e.toString()}');

      if (e is AuthException) {
        print('DEBUG: Auth error code: ${e.code}');
        print('DEBUG: Auth error status: ${e.statusCode}');
        print('DEBUG: Auth error details: ${e.message}');
      }

      // Try a more specific error message
      String userFriendlyMessage = 'Signup error: ${e.toString()}';
      if (e.toString().contains('Database error saving new user')) {
        userFriendlyMessage = 'Registration temporarily unavailable due to database maintenance. Please try again in a few minutes.';
      }

      emit(state.copyWith(
        isLoading: false,
        errorMessage: userFriendlyMessage,
      ));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await Supabase.instance.client.auth.signOut();
      add(const AuthStatusChanged(null));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Logout error: ${e.toString()}',
      ));
    }
  }

  void _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(
      mode: event.user != null ? AuthMode.authenticated : AuthMode.unauthenticated,
      user: event.user,
      guestId: null,
      isAuthenticated: event.user != null,
      isLoading: false,
      errorMessage: null,
    ));
  }

  Future<void> _onGuestModeStarted(
    AuthGuestModeStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final guestId = await _guestSessionService.getOrCreateGuestId();
      
      emit(state.copyWith(
        mode: AuthMode.guest,
        guestId: guestId,
        user: null,
        isAuthenticated: false,
        isLoading: false,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        mode: AuthMode.unauthenticated,
        isLoading: false,
        errorMessage: 'Failed to start guest mode: ${e.toString()}',
      ));
    }
  }

  Future<void> _onGuestToRegisteredRequested(
    AuthGuestToRegisteredRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.mode != AuthMode.guest || state.guestId == null) {
      emit(state.copyWith(
        errorMessage: 'Not in guest mode',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final guestId = state.guestId!;

      // 1. Create auth.users account
      final response = await Supabase.instance.client.auth.signUp(
        email: event.email,
        password: event.password,
        data: {'name': event.name},
      );

      if (response.user == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to create account. Please try again.',
        ));
        return;
      }

      final newUserId = response.user!.id;

      // 2. Call edge function to migrate guest data
      try {
        final migrationResponse = await Supabase.instance.client.functions.invoke(
          'migrate_guest_data',
          body: {
            'guest_id': guestId,
            'new_user_id': newUserId,
          },
        );

        final migrationData = migrationResponse.data as Map<String, dynamic>?;
        if (migrationData?['success'] != true) {
          throw Exception(migrationData?['message'] ?? 'Migration failed');
        }
      } catch (migrationError) {
        // Log migration error but don't fail the conversion
        print('Warning: Guest data migration failed: $migrationError');
        // The user account is created, so we proceed
      }

      // 3. Clear local guest session
      await _guestSessionService.clearGuestSession();

      // 4. Transition to authenticated state
      emit(state.copyWith(
        mode: AuthMode.authenticated,
        user: response.user,
        guestId: null,
        isAuthenticated: true,
        isLoading: false,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Conversion failed: ${e.toString()}',
      ));
    }
  }
}