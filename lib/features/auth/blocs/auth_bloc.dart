import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/blocs/base_bloc.dart';

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

class AuthState extends AppState {
  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [user, isAuthenticated, isLoading, errorMessage];
}

class AuthBloc extends AppBloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    // Register all event handlers first
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthErrorOccurred>(_onAuthErrorOccurred);

    // Initialize auth state after handlers are registered
    _initializeAuth();

    // Set up auth state listener for automatic session recovery
    _setupAuthStateListener();
  }

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
      final response = await Supabase.instance.client.auth.signUp(
        email: event.email,
        password: event.password,
        data: {'name': event.name},
      );

      if (response.user != null) {
        add(AuthStatusChanged(response.user));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Signup failed. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Signup error: ${e.toString()}',
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
      user: event.user,
      isAuthenticated: event.user != null,
      isLoading: false,
      errorMessage: null,
    ));
  }
}