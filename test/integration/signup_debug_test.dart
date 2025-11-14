import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chefleet/core/repositories/supabase_repository.dart';

void main() {
  group('Signup Debug Tests', () {
    late SupabaseClient supabaseClient;

    setUpAll(() async {
      // Initialize Supabase for testing
      await Supabase.initialize(
        url: 'https://ydirqkqkkngasjkbdflh.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlkaXJxa3Fra25nYXNqa2JkZmxoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQxMjk4NDcsImV4cCI6MjA0OTcwNTg0N30.Mg4UKokQRWkzZQK1L5YAw0yfTBw7A6bLo3YjKb_JnNk',
      );
      supabaseClient = Supabase.instance.client;
    });

    test('Test direct database query to identify audit triggers', () async {
      try {
        // Try to query the information_schema to see what triggers exist
        // This might fail due to permissions, but it's worth a try
        final result = await supabaseClient.rpc('execute_sql', params: {
          'query': '''
            SELECT trigger_name, event_object_table, action_timing, action_condition, action_statement
            FROM information_schema.triggers
            WHERE trigger_schema = 'public'
            ORDER BY event_object_table, trigger_name
          '''
        });

        print('Triggers found: ${result.data}');
      } catch (e) {
        print('Error querying triggers: $e');
      }
    });

    test('Test if audit_logs table exists and is accessible', () async {
      try {
        final result = await supabaseClient
            .from('audit_logs')
            .select('id, table_name, action, created_at')
            .limit(1);

        print('Audit logs table accessible. Sample data: $result');
      } catch (e) {
        print('Error accessing audit_logs table: $e');

        // Try to create the audit_logs table if it doesn't exist
        try {
          await supabaseClient.rpc('execute_sql', params: {
            'query': '''
              CREATE TABLE IF NOT EXISTS public.audit_logs (
                  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
                  table_name text NOT NULL,
                  record_id uuid,
                  action text NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
                  old_data jsonb,
                  new_data jsonb,
                  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
                  created_at timestamptz DEFAULT now(),
                  metadata jsonb DEFAULT '{}'::jsonb
              );

              ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

              CREATE POLICY IF NOT EXISTS "Allow all operations on audit_logs"
              ON public.audit_logs FOR ALL USING (true);

              GRANT SELECT, INSERT ON public.audit_logs TO authenticated;
              GRANT SELECT, INSERT ON public.audit_logs TO service_role;
            '''
          });
          print('Created audit_logs table successfully');
        } catch (createError) {
          print('Error creating audit_logs table: $createError');
        }
      }
    });

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

    test('Test if we can disable triggers via SQL', () async {
      try {
        // Try to disable all triggers
        await supabaseClient.rpc('execute_sql', params: {
          'query': '''
            -- Disable all triggers on user-related tables
            ALTER TABLE public.users_public DISABLE TRIGGER ALL;
            ALTER TABLE public.profiles DISABLE TRIGGER ALL;
            ALTER TABLE public.auth.users DISABLE TRIGGER ALL;

            -- Or drop specific triggers
            DROP TRIGGER IF EXISTS users_public_audit_trigger ON public.users_public;
            DROP TRIGGER IF EXISTS profiles_audit_trigger ON public.profiles;
            DROP TRIGGER IF EXISTS audit_trigger ON public.auth.users;
          '''
        });

        print('Successfully disabled triggers');
      } catch (e) {
        print('Error disabling triggers: $e');
      }
    });
  });
}