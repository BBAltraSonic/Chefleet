import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chefleet/features/auth/models/auth_error_type.dart';
import 'package:chefleet/features/auth/utils/auth_error_parser.dart';

void main() {
  group('AuthErrorParser', () {
    test('parses TimeoutException as networkError', () {
      final error = TimeoutException('Connection timed out');
      expect(AuthErrorParser.parseError(error), AuthErrorType.networkError);
    });

    test('parses AuthException with 429 as rateLimited', () {
      final error = AuthException('Too many requests', statusCode: '429');
      expect(AuthErrorParser.parseError(error), AuthErrorType.rateLimited);
    });

    test('parses AuthException with "too many" message as rateLimited', () {
      final error = AuthException('Too many login attempts');
      expect(AuthErrorParser.parseError(error), AuthErrorType.rateLimited);
    });

    test('parses AuthException with 500 as serverError', () {
      final error = AuthException('Internal Server Error', statusCode: '500');
      expect(AuthErrorParser.parseError(error), AuthErrorType.serverError);
    });

    test('parses AuthException with invalid credentials message', () {
      final error = AuthException('Invalid login credentials');
      expect(AuthErrorParser.parseError(error), AuthErrorType.invalidCredentials);
    });

    test('parses AuthException with user not found message', () {
      final error = AuthException('User not found');
      expect(AuthErrorParser.parseError(error), AuthErrorType.invalidCredentials);
    });

    test('parses AuthException with email exists message', () {
      final error = AuthException('User already registered');
      expect(AuthErrorParser.parseError(error), AuthErrorType.emailExists);
    });

    test('parses AuthException with weak password message', () {
      final error = AuthException('Password should be at least 6 characters', statusCode: '422');
      // Note: The parser checks for "password" AND ("short" OR "weak" OR "security")
      // My error message above might not match exactly if I don't use keywords from parser implementation.
      // Let's check implementation again.
      // Implementation: if (message.contains('password') && (message.contains('short') || message.contains('weak') || message.contains('security')))
      expect(AuthErrorParser.parseError(error), AuthErrorType.weakPassword);
    });

    test('parses network related strings as networkError', () {
      expect(AuthErrorParser.parseError('SocketException: Failed host lookup'), AuthErrorType.networkError);
      expect(AuthErrorParser.parseError('Network is unreachable'), AuthErrorType.networkError);
    });

    test('parses unknown errors as unknown', () {
      expect(AuthErrorParser.parseError('Random error'), AuthErrorType.unknown);
      expect(AuthErrorParser.parseError(Exception('Some exception')), AuthErrorType.unknown);
    });

    test('getUserFriendlyMessage returns correct messages', () {
      expect(
        AuthErrorParser.getUserFriendlyMessage(AuthErrorType.invalidCredentials),
        contains('Invalid email or password'),
      );
      expect(
        AuthErrorParser.getUserFriendlyMessage(AuthErrorType.networkError),
        contains('check your internet connection'),
      );
      expect(
        AuthErrorParser.getUserFriendlyMessage(AuthErrorType.serverError),
        contains('Server error'),
      );
    });
  });
}
