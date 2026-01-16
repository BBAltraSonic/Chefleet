import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/diagnostics/diagnostic_domains.dart';
import '../../../core/diagnostics/diagnostic_harness.dart';
import '../../../core/diagnostics/diagnostic_severity.dart';
import '../../../core/blocs/base_bloc.dart';
import '../../../core/services/guest_session_service.dart';
import '../models/auth_error_type.dart';
import '../utils/auth_error_parser.dart';

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
  const AuthSignupRequested(
    this.email,
    this.password,
    this.name, {
    this.initialRole,
  });

  final String email;
  final String password;
  final String name;
  final String? initialRole;

  @override
  List<Object?> get props => [email, password, name, initialRole];
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

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
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
    this.errorType,
    this.retryCount = 0,
    this.errorTimestamp,
  });

  final AuthMode mode;
  final User? user;
  final String? guestId;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final AuthErrorType? errorType;
  final int retryCount;
  final DateTime? errorTimestamp;

  bool get isGuest => mode == AuthMode.guest;

  AuthState copyWith({
    AuthMode? mode,
    User? user,
    String? guestId,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    AuthErrorType? errorType,
    int? retryCount,
    DateTime? errorTimestamp,
  }) {
    return AuthState(
      mode: mode ?? this.mode,
      user: user ?? this.user,
      guestId: guestId ?? this.guestId,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      errorType: errorType ?? this.errorType,
      retryCount: retryCount ?? this.retryCount,
      errorTimestamp: errorTimestamp ?? this.errorTimestamp,
    );
  }

  @override
  List<Object?> get props => [
        mode,
        user,
        guestId,
        isAuthenticated,
        isLoading,
        errorMessage,
        errorType,
        retryCount,
        errorTimestamp,
      ];
}

class AuthBloc extends AppBloc<AuthEvent, AuthState> {
  AuthBloc({
    GuestSessionService? guestSessionService,
    SupabaseClient? supabaseClient,
  })  : _guestSessionService = guestSessionService ?? GuestSessionService(),
        _supabaseClient = supabaseClient ?? Supabase.instance.client,
        // CRITICAL: Hydrate initial state SYNCHRONOUSLY in constructor
        // This ensures auth state is available immediately for BootstrapOrchestrator
        // preventing the flash from unauthenticated -> authenticated screens
        super(_getInitialAuthState(supabaseClient ?? Supabase.instance.client)) {
    // Register all event handlers first
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthErrorOccurred>(_onAuthErrorOccurred);
    on<AuthGuestModeStarted>(_onGuestModeStarted);
    on<AuthGuestToRegisteredRequested>(_onGuestToRegisteredRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSessionExpired>(_onSessionExpired);

    // Set up auth state listener for automatic session recovery
    _setupAuthStateListener();
  }

  /// Get initial auth state synchronously by checking Supabase session.
  /// This MUST be synchronous to avoid race conditions during app bootstrap.
  static AuthState _getInitialAuthState(SupabaseClient client) {
    try {
      final currentUser = client.auth.currentUser;
      
      if (currentUser != null) {
        // User has active session - return authenticated state immediately
        return AuthState(
          mode: AuthMode.authenticated,
          user: currentUser,
          isAuthenticated: true,
          isLoading: false,
        );
      }
      
      // No active session - return unauthenticated state
      return const AuthState(
        mode: AuthMode.unauthenticated,
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e) {
      // On error, default to unauthenticated
      return const AuthState(
        mode: AuthMode.unauthenticated,
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  final GuestSessionService _guestSessionService;
  final SupabaseClient _supabaseClient;
  final DiagnosticHarness _diagnostics = DiagnosticHarness.instance;

  void _logAuth(
    String event, {
    DiagnosticSeverity severity = DiagnosticSeverity.info,
    Map<String, Object?> payload = const <String, Object?>{},
    String? correlationId,
  }) {
    _diagnostics.log(
      domain: DiagnosticDomains.auth,
      event: event,
      severity: severity,
      payload: payload,
      correlationId: correlationId ?? _currentCorrelationScope(),
    );
  }

  String? _currentCorrelationScope() {
    if (state.user != null) {
      return 'user-${state.user!.id}';
    }
    if (state.guestId != null) {
      return 'guest-${state.guestId}';
    }
    return null;
  }

  void _setupAuthStateListener() {
    // Listen to Supabase auth state changes for automatic session recovery
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      if (isClosed) return;

      final AuthChangeEvent event = data.event;
      final User? user = data.session?.user;

      switch (event) {
        case AuthChangeEvent.initialSession:
          // Initial session is handled synchronously in constructor
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
          if (user != null) {
            // Token refreshed successfully, update user state
            add(AuthStatusChanged(user));
          } else {
            // Token refresh failed - session expired
            add(const AuthSessionExpired());
          }
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
      // Clear the error message and type
      emit(state.copyWith(
        errorMessage: null,
        errorType: null,
      ));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Reset error state and start loading
    emit(state.copyWith(
      isLoading: true, 
      errorMessage: null,
      errorType: null,
    ));
    
    _logAuth(
      'login.request',
      severity: DiagnosticSeverity.debug,
      payload: {'email': event.email},
    );

    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      ).timeout(const Duration(seconds: 10));

      if (response.user != null) {
        add(AuthStatusChanged(response.user));
        _logAuth(
          'login.success',
          payload: {'userId': response.user!.id},
          correlationId: 'user-${response.user!.id}',
        );
      } else {
        // This case usually throws, but just in case
        const errorType = AuthErrorType.invalidCredentials;
        emit(state.copyWith(
          isLoading: false,
          errorMessage: AuthErrorParser.getUserFriendlyMessage(errorType),
          errorType: errorType,
          errorTimestamp: DateTime.now(),
        ));
        
        _logAuth(
          'login.failure',
          severity: DiagnosticSeverity.warn,
          payload: {'reason': 'invalid_credentials'},
        );
      }
    } catch (e) {
      final errorType = AuthErrorParser.parseError(e);
      final userFriendlyMessage = AuthErrorParser.getUserFriendlyMessage(errorType);

      emit(state.copyWith(
        isLoading: false,
        errorMessage: userFriendlyMessage,
        errorType: errorType,
        errorTimestamp: DateTime.now(),
      ));
      
      _logAuth(
        'login.error',
        severity: DiagnosticSeverity.error,
        payload: {
          'message': userFriendlyMessage, 
          'raw': e.toString(),
          'errorType': errorType.toString(),
        },
      );
    }
  }

  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true, 
      errorMessage: null,
      errorType: null,
    ));
    
    _logAuth(
      'signup.request',
      severity: DiagnosticSeverity.debug,
      payload: {
        'email': event.email,
        if (event.initialRole != null) 'initialRole': event.initialRole,
      },
    );

    try {
      print('DEBUG: Starting signup for email: ${event.email}');

      final response = await _supabaseClient.auth.signUp(
        email: event.email,
        password: event.password,
        data: {
          'name': event.name,
          if (event.initialRole != null) 'initial_role': event.initialRole,
        },
      ).timeout(const Duration(seconds: 10));

      print('DEBUG: Signup response received');
      print('DEBUG: User created: ${response.user?.email}');
      print('DEBUG: Session active: ${response.session != null}');

      if (response.user != null) {
        print('DEBUG: Signup successful, attempting to create profile...');

        // Try to create profile manually since the trigger might be failing
        try {
          final supabase = _supabaseClient;
          final profileResult = await supabase
              .from('users_public')
              .upsert({
                'user_id': response.user!.id,
                'full_name': event.name,
                'created_at': DateTime.now().toIso8601String(),
              }, onConflict: 'user_id')
              .select()
              .maybeSingle();

          print('DEBUG: Profile creation result: $profileResult');

        } catch (profileError) {
          print('DEBUG: Profile creation failed: $profileError');

          // If profile creation fails due to audit trigger, try a workaround
          if (profileError.toString().contains('audit_logs') ||
              profileError.toString().contains('500')) {
            print('DEBUG: Detected audit trigger issue, user created but profile failed');
            _logAuth(
              'signup.profile_fallback',
              severity: DiagnosticSeverity.warn,
              payload: {'message': profileError.toString()},
            );
          } else {
            // Re-throw non-audit related errors
            rethrow;
          }
        }

        add(AuthStatusChanged(response.user));
        _logAuth(
          'signup.success',
          payload: {'userId': response.user!.id},
          correlationId: 'user-${response.user!.id}',
        );
      } else {
        const errorType = AuthErrorType.unknown;
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Signup failed. Please try again.',
          errorType: errorType,
          errorTimestamp: DateTime.now(),
        ));
        
        _logAuth(
          'signup.failure',
          severity: DiagnosticSeverity.warn,
          payload: {'reason': 'unknown'},
        );
      }
    } catch (e) {
      print('DEBUG: Detailed signup error:');
      print('DEBUG: Error type: ${e.runtimeType}');
      print('DEBUG: Error message: ${e.toString()}');

      final errorType = AuthErrorParser.parseError(e);
      final userFriendlyMessage = AuthErrorParser.getUserFriendlyMessage(errorType);

      emit(state.copyWith(
        isLoading: false,
        errorMessage: userFriendlyMessage,
        errorType: errorType,
        errorTimestamp: DateTime.now(),
      ));
      
      _logAuth(
        'signup.error',
        severity: DiagnosticSeverity.error,
        payload: {
          'message': userFriendlyMessage, 
          'raw': e.toString(),
          'errorType': errorType.toString(),
        },
      );
    }
  }


  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      _logAuth('logout.request', severity: DiagnosticSeverity.debug);
      await _supabaseClient.auth.signOut();
      add(const AuthStatusChanged(null));
      _logAuth('logout.success');
    } catch (e) {
      final errorType = AuthErrorParser.parseError(e);
      final userFriendlyMessage = AuthErrorParser.getUserFriendlyMessage(errorType);
      
      emit(state.copyWith(
        errorMessage: userFriendlyMessage,
        errorType: errorType,
        errorTimestamp: DateTime.now(),
      ));
      
      _logAuth(
        'logout.error',
        severity: DiagnosticSeverity.error,
        payload: {
          'message': userFriendlyMessage,
          'raw': e.toString(),
          'errorType': errorType.toString(),
        },
      );
    }
  }

  void _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) {
    // Immediately emit resolved auth state (no loading state)
    emit(state.copyWith(
      mode: event.user != null ? AuthMode.authenticated : AuthMode.unauthenticated,
      user: event.user,
      guestId: null,
      isAuthenticated: event.user != null,
      isLoading: false, // Critical: isLoading must be false for bootstrap
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

    emit(state.copyWith(
      isLoading: true, 
      errorMessage: null,
      errorType: null,
    ));

    try {
      final guestId = state.guestId!;

      // 1. Create auth.users account
      final response = await _supabaseClient.auth.signUp(
        email: event.email,
        password: event.password,
        data: {'name': event.name},
      ).timeout(const Duration(seconds: 10));

      if (response.user == null) {
        const errorType = AuthErrorType.unknown;
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to create account. Please try again.',
          errorType: errorType,
          errorTimestamp: DateTime.now(),
        ));
        return;
      }

      final newUserId = response.user!.id;

      // 2. Call edge function to migrate guest data
      try {
        final migrationResponse = await _supabaseClient.functions.invoke(
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
      final errorType = AuthErrorParser.parseError(e);
      final userFriendlyMessage = AuthErrorParser.getUserFriendlyMessage(errorType);

      emit(state.copyWith(
        isLoading: false,
        errorMessage: userFriendlyMessage,
        errorType: errorType,
        errorTimestamp: DateTime.now(),
      ));
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true, 
      errorMessage: null,
      errorType: null,
    ));
    
    _logAuth(
      'google_signin.request',
      severity: DiagnosticSeverity.debug,
    );

    try {
      // Initiate OAuth flow with Google
      final response = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'chefleet://auth-callback',
      );

      if (!response) {
        const errorType = AuthErrorType.unknown;
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Google sign-in was cancelled or failed.',
          errorType: errorType,
          errorTimestamp: DateTime.now(),
        ));
        
        _logAuth(
          'google_signin.cancelled',
          severity: DiagnosticSeverity.warn,
        );
      } else {
        // The OAuth flow will redirect and trigger AuthStatusChanged
        // via the auth state listener when the user completes the flow
        _logAuth(
          'google_signin.initiated',
          severity: DiagnosticSeverity.debug,
        );
      }
    } on AuthException catch (e) {
      final errorType = AuthErrorParser.parseError(e);
      final userFriendlyMessage = AuthErrorParser.getUserFriendlyMessage(errorType);

      emit(state.copyWith(
        isLoading: false,
        errorMessage: userFriendlyMessage,
        errorType: errorType,
        errorTimestamp: DateTime.now(),
      ));
      
      _logAuth(
        'google_signin.error',
        severity: DiagnosticSeverity.error,
        payload: {
          'message': userFriendlyMessage, 
          'raw': e.toString(),
          'code': e.code,
        },
      );
    } catch (e) {
      final errorType = AuthErrorParser.parseError(e);
      final userFriendlyMessage = AuthErrorParser.getUserFriendlyMessage(errorType);

      emit(state.copyWith(
        isLoading: false,
        errorMessage: userFriendlyMessage,
        errorType: errorType,
        errorTimestamp: DateTime.now(),
      ));
      
      _logAuth(
        'google_signin.error',
        severity: DiagnosticSeverity.error,
        payload: {
          'message': userFriendlyMessage,
          'raw': e.toString(),
        },
      );
    }
  }

  void _onSessionExpired(AuthSessionExpired event, Emitter<AuthState> emit) {
    _logAuth(
      'session.expired',
      severity: DiagnosticSeverity.warn,
    );
    
    emit(const AuthState(
      mode: AuthMode.unauthenticated,
      isAuthenticated: false,
      isLoading: false,
      errorMessage: 'Your session has expired. Please sign in again.',
    ));
  }
  
  /// Helper method to update user password
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    
    // First verify current password by attempting to sign in
    try {
      await _supabaseClient.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );
    } catch (e) {
      throw Exception('Current password is incorrect');
    }
    
    // Update to new password
    await _supabaseClient.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    
    _logAuth(
      'password.updated',
      payload: {'userId': user.id},
    );
  }
}