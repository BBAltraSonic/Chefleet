import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorMessageMapper {
  static String getUserFriendlyMessage(dynamic error) {
    if (error is PostgrestException) {
      return _mapPostgrestException(error);
    }
    
    if (error is FunctionException) {
      return _mapFunctionException(error);
    }
    
    if (error is AuthException) {
      return _mapAuthException(error);
    }
    
    return 'Something went wrong. Please try again.';
  }

  static String _mapPostgrestException(PostgrestException e) {
    final code = e.code;
    final message = e.message.toLowerCase();
    
    if (code == '409' || message.contains('concurrent') || message.contains('conflict')) {
      return 'This data was recently updated. Refreshing for the latest changes...';
    }
    
    if (code == '23505' || message.contains('duplicate') || message.contains('unique constraint')) {
      return 'This item already exists. Please check your entries.';
    }
    
    if (code == '23503' || message.contains('foreign key') || message.contains('does not exist')) {
      return 'Required information is missing. Please try again.';
    }
    
    if (code == '42501' || message.contains('permission') || message.contains('authorization')) {
      return 'You do not have permission to perform this action.';
    }
    
    if (message.contains('network') || message.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    }
    
    return 'Unable to complete this request. Please try again.';
  }

  static String _mapFunctionException(FunctionException e) {
    final message = e.toString().toLowerCase();
    
    if (message.contains('rate limit') || message.contains('too many')) {
      return 'You are doing this too quickly. Please wait a moment and try again.';
    }
    
    if (message.contains('validation') || message.contains('invalid')) {
      return 'Some information is incorrect. Please check and try again.';
    }
    
    if (message.contains('not found')) {
      return 'The requested item was not found.';
    }
    
    if (message.contains('concurrent') || message.contains('conflict')) {
      return 'This data was recently updated. Please refresh and try again.';
    }
    
    return 'Unable to complete this action. Please try again.';
  }

  static String _mapAuthException(AuthException e) {
    if (e.message.contains('Invalid login')) {
      return 'Incorrect email or password.';
    }
    
    if (e.message.contains('Email not confirmed')) {
      return 'Please confirm your email address.';
    }
    
    if (e.message.contains('User already registered')) {
      return 'This email is already registered. Please try logging in.';
    }
    
    return 'Authentication failed. Please try again.';
  }
}
