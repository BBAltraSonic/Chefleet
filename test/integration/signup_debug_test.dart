import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chefleet/core/repositories/supabase_repository.dart';

void main() {
  group('Signup Debug Tests', () {
    late SupabaseClient supabaseClient;

    setUpAll(() async {
      const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
      const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception(
          'Missing test environment variables. '
          'Please provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.',
        );
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      supabaseClient = Supabase.instance.client;
    });

    // Removed: RPC-DDL test that attempted to query information_schema
    // Use Supabase Dashboard or CLI for database introspection instead

    // Removed: RPC-DDL test that attempted to create tables via SQL
    // Use Supabase migrations for schema changes instead

    test('Test user signup with detailed error logging', () async {
      try {
        // Generate a unique test email
        final testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
        final testPassword = 'TestPassword123!';

        print('Attempting signup with email: $testEmail');

        // Attempt to sign up
        final authResponse = await supabaseClient.auth.signUp(
          email: testEmail,
          password: testPassword,
        );

        print('Signup successful: ${authResponse.user?.email}');
        print('User session: ${authResponse.session?.accessToken}');

        // If successful, try to create a profile
        if (authResponse.user != null) {
          try {
            final profileResult = await supabaseClient
                .from('profiles')
                .insert({
                  'id': authResponse.user!.id,
                  'email': testEmail,
                  'created_at': DateTime.now().toIso8601String(),
                })
                .select();

            print('Profile created successfully: $profileResult');
          } catch (profileError) {
            print('Error creating profile: $profileError');
          }
        }

      } catch (e) {
        print('Signup error details:');
        print('Type: ${e.runtimeType}');
        print('Message: ${e.toString()}');

        if (e is AuthException) {
          print('Auth error details:');
          print('Code: ${e.code}');
          print('Message: ${e.message}');
          print('Status code: ${e.statusCode}');
        }
      }
    });

    // Removed: RPC-DDL test that attempted to modify triggers
    // Use Supabase Dashboard or migrations for trigger management
  });
}