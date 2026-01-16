import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_error_type.dart';

class AuthErrorParser {
  /// Parse AuthException into AuthErrorType
  static AuthErrorType parseError(dynamic error) {
    if (error is TimeoutException) {
      return AuthErrorType.networkError; // Or a specific timeout error if we had one
    }

    if (error is AuthException) {
      return _parseAuthException(error);
    }
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || 
        errorString.contains('connection') || 
        errorString.contains('socket') ||
        errorString.contains('offline')) {
      return AuthErrorType.networkError;
    }
    
    if (errorString.contains('profile')) {
      return AuthErrorType.profileCreation;
    }
    
    if (errorString.contains('guest')) {
      // Guest mode errors usually fall under unknown or specific logic
      return AuthErrorType.unknown;
    }

    return AuthErrorType.unknown;
  }

  static AuthErrorType _parseAuthException(AuthException e) {
    final message = e.message.toLowerCase();
    final statusCode = e.statusCode;
    
    // Rate limiting
    if (statusCode == '429' || message.contains('too many')) {
      return AuthErrorType.rateLimited;
    }
    
    // Server errors
    if (statusCode == '500' || statusCode == '502' || statusCode == '503') {
      return AuthErrorType.serverError;
    }

    // Invalid credentials
    if (message.contains('invalid login credentials') || 
        message.contains('invalid credentials') ||
        message.contains('email not confirmed')) {
      return AuthErrorType.invalidCredentials;
    }
    
    // User not found (treated as invalid credentials for security or specific type)
    if (message.contains('user not found') || message.contains('no user')) {
      return AuthErrorType.invalidCredentials; 
    }
    
    // Email already exists
    if (message.contains('already registered') || 
        message.contains('already exists') ||
        message.contains('user already registered')) {
      return AuthErrorType.emailExists;
    }
    
    // Weak password
    if (message.contains('password') && (message.contains('short') || message.contains('weak') || message.contains('security'))) {
      return AuthErrorType.weakPassword;
    }
    
    // Invalid email
    if (message.contains('invalid email') || message.contains('valid email')) {
      return AuthErrorType.invalidCredentials; // Or a more specific type if we add it
    }

    return AuthErrorType.unknown;
  }

  /// Get user-friendly message for the error type
  /// This is a fallback if specific message maps aren't used
  static String getUserFriendlyMessage(AuthErrorType type) {
    switch (type) {
      case AuthErrorType.invalidCredentials:
        return 'Invalid email or password. Please check your credentials.';
      case AuthErrorType.networkError:
        return 'Please check your internet connection.';
      case AuthErrorType.serverError:
        return 'Server error. Please try again later.';
      case AuthErrorType.rateLimited:
        return 'Too many attempts. Please wait a moment.';
      case AuthErrorType.emailExists:
        return 'This email is already registered. Please sign in.';
      case AuthErrorType.weakPassword:
        return 'Password is too weak. Please use a stronger password.';
      case AuthErrorType.sessionExpired:
        return 'Session expired. Please sign in again.';
      case AuthErrorType.profileCreation:
        return 'Failed to create profile. Please try again.';
      case AuthErrorType.firebaseInit:
        return 'Service initialization failed.';
      case AuthErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
