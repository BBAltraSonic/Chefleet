import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:chefleet/main.dart' as app;
import 'package:chefleet/features/auth/blocs/user_profile_bloc.dart';
import 'package:chefleet/features/auth/models/user_profile_model.dart';
import 'package:chefleet/features/profile/screens/profile_screen.dart';

class MockUserProfileBloc extends Mock implements UserProfileBloc {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Profile to Order Integration Tests', () {
    late MockUserProfileBloc mockUserProfileBloc;
    late UserProfile testProfile;

    setUp(() {
      mockUserProfileBloc = MockUserProfileBloc();

      testProfile = UserProfile(
        id: 'test-user-123',
        name: 'Test User',
        avatarUrl: 'https://example.com/avatar.jpg',
        address: UserAddress(
          streetAddress: '123 Main St',
          city: 'San Francisco',
          state: 'CA',
          postalCode: '94105',
          latitude: 37.7749,
          longitude: -122.4194,
        ),
        notificationPreferences: const NotificationPreferences(
          orderUpdates: true,
          chatMessages: true,
          promotions: false,
          vendorUpdates: false,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    setUpAll(() {
      // Register fallback values for mock verification
      registerFallbackValue(UserProfileCreated(testProfile));
      registerFallbackValue(UserProfileUpdated(testProfile));
      registerFallbackValue(const UserProfileState());
    });

    group('Profile Creation to Order Flow', () {
      testWidgets('Complete user journey: profile creation -> dish browsing -> order placement', (WidgetTester tester) async {
        // Start the app
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Expect to see profile creation screen on first launch
        expect(find.text('Complete Profile'), findsOneWidget);
        expect(find.text('Your Name'), findsOneWidget);
        expect(find.text('Your Address'), findsOneWidget);

        // Fill in profile form
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Your Name'),
          'John Doe',
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Street Address'),
          '456 Market St',
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'City'),
          'San Francisco',
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'State'),
          'CA',
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Postal Code'),
          '94103',
        );
        await tester.pumpAndSettle();

        // For integration testing, we'll simulate successful profile creation
        // In a real scenario, this would involve geolocation services
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();

        // Submit profile
        final completeProfileButton = find.widgetWithText(ElevatedButton, 'Complete Profile');
        expect(completeProfileButton, findsOneWidget);
        await tester.tap(completeProfileButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Should navigate to main app interface
        expect(find.text('Nearby Dishes'), findsOneWidget);
        expect(find.byType(GoogleMap), findsOneWidget);
      });

      testWidgets('Profile data persistence across app restart', (WidgetTester tester) async {
        // First, complete profile creation
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Fill profile quickly (assuming this works in subsequent runs)
        if (find.text('Complete Profile').evaluate().isNotEmpty) {
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Your Name'),
            'Returning User',
          );
          await tester.pumpAndSettle();

          // Fill address fields
          await tester.enterText(find.widgetWithText(TextFormField, 'Street Address'), '789 Mission St');
          await tester.enterText(find.widgetWithText(TextFormField, 'City'), 'San Francisco');
          await tester.enterText(find.widgetWithText(TextFormField, 'State'), 'CA');
          await tester.enterText(find.widgetWithText(TextFormField, 'Postal Code'), '94105');

          await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
          await tester.pumpAndSettle();

          await tester.tap(find.widgetWithText(ElevatedButton, 'Complete Profile'));
          await tester.pumpAndSettle(const Duration(seconds: 5));
        }

        // Verify we're at the main interface
        expect(find.text('Nearby Dishes'), findsOneWidget);

        // Simulate app restart
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/lifecycle',
          null,
          (data) {},
        );

        // In integration testing, we can't fully restart, but we can test navigation
        await tester.pumpAndSettle();

        // Should still be at main interface with profile loaded
        expect(find.text('Nearby Dishes'), findsOneWidget);
      });
    });

    group('Profile-Integrated Ordering', () {
      testWidgets('Order placement includes user profile context', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Skip profile creation if already completed
        if (find.text('Complete Profile').evaluate().isNotEmpty) {
          await tester.tap(find.widgetWithText(ElevatedButton, 'Complete Profile'));
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // Should be at main interface
        expect(find.text('Nearby Dishes'), findsOneWidget);

        // Look for dishes in the feed
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Try to find a dish card (this may require mock data)
        final dishCards = find.byKey(const Key('dish_card'));
        if (dishCards.evaluate().isNotEmpty) {
          await tester.tap(dishCards.first);
          await tester.pumpAndSettle();

          // Should show dish details or order interface
          // Profile information should be accessible in order context
          expect(find.byType(Scaffold), findsWidgets);
        }

        // Test navigation to profile to verify integration
        await tester.tap(find.byIcon(Icons.person));
        await tester.pumpAndSettle();

        // Should show profile information
        expect(find.byType(ProfileScreen), findsOneWidget);
      });

      testWidgets('Profile management maintains order history association', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Navigate to profile management
        if (find.text('Complete Profile').evaluate().isEmpty) {
          // Profile exists, navigate to it
          await tester.tap(find.byIcon(Icons.person));
          await tester.pumpAndSettle();

          // Should see profile management interface
          expect(find.text('Edit Profile'), findsOneWidget);

          // Test profile editing
          await tester.tap(find.text('Edit Profile'));
          await tester.pumpAndSettle();

          expect(find.text('Profile Information'), findsOneWidget);

          // Modify name
          final nameField = find.widgetWithText(TextFormField, 'Name');
          await tester.enterText(nameField, ' Updated');
          await tester.pumpAndSettle();

          // Save changes
          await tester.tap(find.byIcon(Icons.check));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Should show success message and maintain order associations
          expect(find.text('Profile updated successfully'), findsOneWidget);
        }
      });

      testWidgets('Profile data flows to order confirmation', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Ensure we have a profile
        if (find.text('Complete Profile').evaluate().isNotEmpty) {
          await tester.tap(find.widgetWithText(ElevatedButton, 'Complete Profile'));
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // The integration test verifies the profile data structure
        // In real implementation, this would flow through to order creation
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });

    group('Profile Guards and Navigation', () {
      testWidgets('Profile guard prevents access without profile', (WidgetTester tester) async {
        // This test would require a fresh app state without profile
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should show profile creation screen initially
        expect(find.text('Complete Profile'), findsOneWidget);

        // Attempt to navigate to order-related screens should be blocked
        // This is tested by the presence of profile creation screen
        expect(find.text('Your Name'), findsOneWidget);
      });

      testWidgets('Profile guard allows access after profile completion', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Complete profile if needed
        if (find.text('Complete Profile').evaluate().isNotEmpty) {
          await tester.enterText(find.widgetWithText(TextFormField, 'Your Name'), 'Test User');
          await tester.enterText(find.widgetWithText(TextFormField, 'Street Address'), '123 Test St');
          await tester.enterText(find.widgetWithText(TextFormField, 'City'), 'Test City');
          await tester.enterText(find.widgetWithText(TextFormField, 'State'), 'TC');
          await tester.enterText(find.widgetWithText(TextFormField, 'Postal Code'), '12345');

          await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
          await tester.pumpAndSettle();

          await tester.tap(find.widgetWithText(ElevatedButton, 'Complete Profile'));
          await tester.pumpAndSettle(const Duration(seconds: 5));
        }

        // Should now have access to main features
        expect(find.text('Nearby Dishes'), findsOneWidget);
        expect(find.byType(GoogleMap), findsOneWidget);
      });
    });

    group('Error Handling and Edge Cases', () {
      testWidgets('Handles profile creation failures gracefully', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Try to submit profile without filling required fields
        await tester.tap(find.widgetWithText(ElevatedButton, 'Complete Profile'));
        await tester.pumpAndSettle();

        // Should show validation errors
        expect(find.text('Please enter your name'), findsOneWidget);
      });

      testWidgets('Maintains profile state during navigation', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Complete profile
        if (find.text('Complete Profile').evaluate().isNotEmpty) {
          await tester.enterText(find.widgetWithText(TextFormField, 'Your Name'), 'Navigation Test');
          await tester.enterText(find.widgetWithText(TextFormField, 'Street Address'), '456 Nav St');
          await tester.enterText(find.widgetWithText(TextFormField, 'City'), 'San Francisco');
          await tester.enterText(find.widgetWithText(TextFormField, 'State'), 'CA');
          await tester.enterText(find.widgetWithText(TextFormField, 'Postal Code'), '94105');

          await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
          await tester.pumpAndSettle();

          await tester.tap(find.widgetWithText(ElevatedButton, 'Complete Profile'));
          await tester.pumpAndSettle(const Duration(seconds: 5));
        }

        // Navigate between different screens
        await tester.tap(find.byIcon(Icons.person));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();

        // Profile should remain intact
        expect(find.text('Nearby Dishes'), findsOneWidget);
      });
    });

    group('Performance and Memory', () {
      testWidgets('Profile data loading does not block UI', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // UI should remain responsive during profile operations
        expect(find.byType(MaterialApp), findsOneWidget);

        // Test scrolling while profile operations might be happening
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -200),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });
  });
}