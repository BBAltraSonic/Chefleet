// This is a patch file showing the required changes to fix the auth flash issue.
// Replace the AuthBloc class constructor and initialization in auth_bloc.dart with this code:

class AuthBloc extends AppBloc<AuthEvent, AuthState> {
  AuthBloc({
    GuestSessionService? guestSessionService,
  })  : _guestSessionService = guestSessionService ?? GuestSessionService(),
        // CRITICAL: Hydrate initial state SYNCHRONOUSLY in constructor
        // This ensures auth state is available immediately for BootstrapOrchestrator
        // preventing the flash from unauthenticated -> authenticated screens
        super(_getInitialAuthState()) {
    // Register all event handlers first
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthErrorOccurred>(_onAuthErrorOccurred);
    on<AuthGuestModeStarted>(_onGuestModeStarted);
    on<AuthGuestToRegisteredRequested>(_onGuestToRegisteredRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);

    // Set up auth state listener for automatic session recovery
    _setupAuthStateListener();
  }

  /// Get initial auth state synchronously by checking Supabase session.
  /// This MUST be synchronous to avoid race conditions during app bootstrap.
  static AuthState _getInitialAuthState() {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      
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
  final DiagnosticHarness _diagnostics = DiagnosticHarness.instance;

  // ... rest of the AuthBloc implementation remains the same ...
  // REMOVE the old _initializeAuth() method completely
  // UPDATE the comment in _setupAuthStateListener from "Initial session is handled by _initializeAuth"
  // to "Initial session is handled synchronously in constructor"
}
