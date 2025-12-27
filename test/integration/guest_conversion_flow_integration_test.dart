import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:chefleet/main.dart' as app;
import 'package:chefleet/core/services/guest_session_service.dart';
import 'package:chefleet/core/services/guest_conversion_service.dart';

/// Integration tests for guest-to-registered user conversion flow
/// 
/// Tests the complete conversion journey and data migration
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Guest Conversion Flow Integration Tests', () {
    late GuestSessionService guestSessionService;
    late GuestConversionService conversionService;

    setUp(() async {
      // Initialize Supabase
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL'),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      );

      guestSessionService = GuestSessionService();
      conversionService = GuestConversionService();
      
      // Clear any existing sessions
      await guestSessionService.clearGuestSession();
    });

    tearDown(() async {
      await guestSessionService.clearGuestSession();
    });

    testWidgets('Complete conversion flow - guest to registered', (tester) async {
      // Step 1: Start as guest
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      final guestSession = await guestSessionService.getGuestSession();
      final guestId = guestSession?.guestId;
      expect(guestId, isNotNull);

      // Step 2: Place an order as guest
      await _placeTestOrder(tester);
      await tester.pumpAndSettle();

      // Step 3: Conversion prompt should appear
      expect(find.text('Save Your Progress'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);

      // Step 4: Tap Create Account
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Step 5: Verify conversion screen appears
      expect(find.byType(app.GuestConversionScreen), findsOneWidget);
      expect(find.text('Create Your Account'), findsOneWidget);

      // Step 6: Fill in registration form
      await tester.enterText(
        find.byKey(const Key('conversion_name_field')),
        'Test User',
      );
      await tester.enterText(
        find.byKey(const Key('conversion_email_field')),
        'testuser@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('conversion_password_field')),
        'SecurePassword123!',
      );
      await tester.pumpAndSettle();

      // Step 7: Submit conversion
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 8: Verify conversion success
      expect(find.text('Account Created!'), findsOneWidget);

      // Step 9: Verify navigation to main app
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(app.MapScreen), findsOneWidget);

      // Step 10: Verify guest session is cleared
      final isGuest = await guestSessionService.isGuestMode();
      expect(isGuest, isFalse);

      // Step 11: Verify user is authenticated
      final user = Supabase.instance.client.auth.currentUser;
      expect(user, isNotNull);
      expect(user?.email, equals('testuser@example.com'));

      // Step 12: Verify guest data was migrated
      final orders = await Supabase.instance.client
          .from('orders')
          .select()
          .eq('user_id', user!.id);
      expect(orders, isNotEmpty);
    });

    testWidgets('Conversion from profile drawer', (tester) async {
      // Start as guest
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Open profile drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify guest header and conversion prompt
      expect(find.text('Guest User'), findsOneWidget);
      expect(find.text('GUEST'), findsOneWidget);
      expect(find.text('Unlock All Features'), findsOneWidget);

      // Tap conversion prompt
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Verify conversion screen
      expect(find.byType(app.GuestConversionScreen), findsOneWidget);
    });

    testWidgets('Conversion after 5 messages in chat', (tester) async {
      // Start as guest and place order
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      await _placeTestOrder(tester);
      await tester.pumpAndSettle();

      // Dismiss first conversion prompt
      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();

      // Navigate to chat
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      // Send 5 messages
      for (int i = 0; i < 5; i++) {
        await tester.enterText(
          find.byKey(const Key('chat_input')),
          'Test message $i',
        );
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();
      }

      // Verify conversion prompt appears after 5th message
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Save Your Progress'), findsOneWidget);
    });

    testWidgets('Conversion validates email format', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Navigate to conversion screen
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(
        find.byKey(const Key('conversion_email_field')),
        'invalid-email',
      );
      await tester.enterText(
        find.byKey(const Key('conversion_password_field')),
        'Password123!',
      );
      await tester.enterText(
        find.byKey(const Key('conversion_name_field')),
        'Test User',
      );

      // Try to submit
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.textContaining('valid email'), findsOneWidget);
    });

    testWidgets('Conversion validates password strength', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Navigate to conversion screen
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Enter weak password
      await tester.enterText(
        find.byKey(const Key('conversion_email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('conversion_password_field')),
        '123',
      );
      await tester.enterText(
        find.byKey(const Key('conversion_name_field')),
        'Test User',
      );

      // Try to submit
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.textContaining('6 characters'), findsOneWidget);
    });

    testWidgets('Conversion handles duplicate email error', (tester) async {
      // First, create an account
      final existingEmail = 'existing@example.com';
      await Supabase.instance.client.auth.signUp(
        email: existingEmail,
        password: 'Password123!',
      );

      // Start as guest
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Navigate to conversion
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Try to use existing email
      await tester.enterText(
        find.byKey(const Key('conversion_email_field')),
        existingEmail,
      );
      await tester.enterText(
        find.byKey(const Key('conversion_password_field')),
        'Password123!',
      );
      await tester.enterText(
        find.byKey(const Key('conversion_name_field')),
        'Test User',
      );

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify error message
      expect(find.textContaining('already registered'), findsOneWidget);
    });

    testWidgets('Can skip conversion and continue as guest', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      await _placeTestOrder(tester);
      await tester.pumpAndSettle();

      // Conversion prompt appears
      expect(find.text('Save Your Progress'), findsOneWidget);

      // Skip conversion
      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();

      // Verify still in guest mode
      final isGuest = await guestSessionService.isGuestMode();
      expect(isGuest, isTrue);

      // Verify can continue using app
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(app.MapScreen), findsOneWidget);
    });

    testWidgets('Conversion migrates order history', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      final guestSession = await guestSessionService.getGuestSession();
      final guestId = guestSession?.guestId;

      // Place multiple orders as guest
      await _placeTestOrder(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      await _placeTestOrder(tester);
      await tester.pumpAndSettle();

      // Convert to registered user
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('conversion_name_field')),
        'Test User',
      );
      await tester.enterText(
        find.byKey(const Key('conversion_email_field')),
        'testmigration@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('conversion_password_field')),
        'Password123!',
      );

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify orders were migrated
      final user = Supabase.instance.client.auth.currentUser;
      final orders = await Supabase.instance.client
          .from('orders')
          .select()
          .eq('user_id', user!.id);

      expect(orders.length, greaterThanOrEqualTo(2));
    });

    testWidgets('Conversion migrates chat messages', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Place order and start chat
      await _placeTestOrder(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      // Send messages
      await tester.enterText(
        find.byKey(const Key('chat_input')),
        'Test message',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Convert
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      await _fillConversionForm(tester, 'chatmigration@example.com');
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify messages were migrated
      final user = Supabase.instance.client.auth.currentUser;
      final messages = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('sender_id', user!.id);

      expect(messages, isNotEmpty);
    });
  });

  group('Conversion Analytics', () {
    testWidgets('tracks conversion attempts', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      final guestSession = await guestSessionService.getGuestSession();
      final guestId = guestSession?.guestId;

      // Attempt conversion
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Cancel
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify attempt was logged
      final attempts = await Supabase.instance.client
          .from('guest_conversion_attempts')
          .select()
          .eq('guest_id', guestId!);

      expect(attempts, isNotEmpty);
    });
  });
}

/// Helper to place a test order
Future<void> _placeTestOrder(WidgetTester tester) async {
  final dishMarker = find.byType(app.DishMarker).first;
  await tester.tap(dishMarker);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Add to Cart'));
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.shopping_cart));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Checkout'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const Key('delivery_address')), '123 Test St');
  await tester.enterText(find.byKey(const Key('phone_number')), '1234567890');
  await tester.pumpAndSettle();

  await tester.tap(find.text('Place Order'));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

/// Helper to fill conversion form
Future<void> _fillConversionForm(WidgetTester tester, String email) async {
  await tester.enterText(
    find.byKey(const Key('conversion_name_field')),
    'Test User',
  );
  await tester.enterText(
    find.byKey(const Key('conversion_email_field')),
    email,
  );
  await tester.enterText(
    find.byKey(const Key('conversion_password_field')),
    'Password123!',
  );
  await tester.pumpAndSettle();
}
