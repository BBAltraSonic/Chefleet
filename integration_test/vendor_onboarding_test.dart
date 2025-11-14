import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chefleet/main.dart' as app;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Vendor Onboarding Integration Tests', () {
    late SupabaseClient supabase;

    setUpAll(() async {
      // Initialize Supabase for testing
      // Note: In a real test environment, you would use test credentials
      supabase = Supabase.instance.client;
    });

    testWidgets('complete vendor onboarding flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the initial screen
      expect(find.text('Chefleet'), findsOneWidget);

      // Navigate to vendor registration (this would depend on your app's navigation)
      // For this test, we'll assume there's a "Become a Vendor" button
      final becomeVendorButton = find.text('Become a Vendor');
      if (becomeVendorButton.evaluate().isNotEmpty) {
        await tester.tap(becomeVendorButton);
        await tester.pumpAndSettle();
      }

      // Verify onboarding screen appears
      expect(find.byType(VendorOnboardingScreen), findsOneWidget);

      // Test Step 1: Business Information
      await _testBusinessInfoStep(tester);

      // Navigate to next step
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Test Step 2: Location Information
      await _testLocationStep(tester);

      // Navigate to next step
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Test Step 3: Documents Upload
      await _testDocumentsStep(tester);

      // Navigate to next step
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Test Step 4: Review and Submit
      await _testReviewStep(tester);

      // Submit the application
      await tester.tap(find.text('Submit Application'));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Application Submitted Successfully'), findsOneWidget);
    });

    testWidgets('onboarding form validation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to vendor onboarding
      await _navigateToVendorOnboarding(tester);

      // Test empty form validation
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter business name'), findsOneWidget);
      expect(find.text('Please enter phone number'), findsOneWidget);
      expect(find.text('Please enter address'), findsOneWidget);

      // Fill in required fields
      await tester.enterText(find.byKey(const Key('business_name_field')), 'Test Restaurant');
      await tester.enterText(find.byKey(const Key('phone_field')), '+1234567890');
      await tester.enterText(find.byKey(const Key('address_field')), '123 Test Street');

      // Now Next should work
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Verify we're on the next step
      expect(find.text('Location Information'), findsOneWidget);
    });

    testWidgets('onboarding progress indicator', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _navigateToVendorOnboarding(tester);

      // Check initial progress (Step 1 of 4)
      expect(find.text('Step 1 of 4'), findsOneWidget);

      // Fill business info and go to next step
      await _fillBusinessInfo(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Check progress updated (Step 2 of 4)
      expect(find.text('Step 2 of 4'), findsOneWidget);

      // Continue to next step
      await _fillLocationInfo(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Check progress updated (Step 3 of 4)
      expect(find.text('Step 3 of 4'), findsOneWidget);
    });

    testWidgets('onboarding navigation between steps', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _navigateToVendorOnboarding(tester);

      // Fill first step
      await _fillBusinessInfo(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Go back to previous step
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Verify we're back on business info step
      expect(find.text('Business Information'), findsOneWidget);
      expect(find.byKey(const Key('business_name_field')), findsOneWidget);

      // Verify data is preserved
      expect(find.text('Test Restaurant'), findsOneWidget);
    });

    testWidgets('image upload functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _navigateToVendorOnboarding(tester);

      // Navigate to documents step
      await _fillBusinessInfo(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await _fillLocationInfo(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Test logo upload
      await tester.tap(find.byKey(const Key('upload_logo_button')));
      await tester.pumpAndSettle();

      // In a real test, you would handle the image picker
      // For now, we'll verify the upload UI appears
      expect(find.text('Upload Logo'), findsOneWidget);

      // Test license upload
      await tester.tap(find.byKey(const Key('upload_license_button')));
      await tester.pumpAndSettle();

      expect(find.text('Upload Business License'), findsOneWidget);
    });

    testWidgets('terms acceptance validation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _navigateToVendorOnboarding(tester);

      // Navigate to review step
      await _fillBusinessInfo(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await _fillLocationInfo(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await _fillDocumentsInfo(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Try to submit without accepting terms
      await tester.tap(find.text('Submit Application'));
      await tester.pumpAndSettle();

      // Should show error about terms acceptance
      expect(find.text('Please accept the terms and conditions'), findsOneWidget);

      // Accept terms
      await tester.tap(find.byKey(const Key('terms_checkbox')));
      await tester.pumpAndSettle();

      // Now submit should work
      await tester.tap(find.text('Submit Application'));
      await tester.pumpAndSettle();

      // Should proceed to success
      expect(find.text('Application Submitted Successfully'), findsOneWidget);
    });
  });
}

// Helper functions
Future<void> _navigateToVendorOnboarding(WidgetTester tester) async {
  // This would navigate to the vendor onboarding screen
  // Implementation depends on your app's navigation structure
  final vendorButton = find.text('Become a Vendor');
  if (vendorButton.evaluate().isNotEmpty) {
    await tester.tap(vendorButton);
    await tester.pumpAndSettle();
  } else {
    // Alternative navigation if needed
    await tester.tap(find.byIcon(Icons.store));
    await tester.pumpAndSettle();
  }
}

Future<void> _fillBusinessInfo(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('business_name_field')), 'Test Restaurant');
  await tester.enterText(find.byKey(const Key('phone_field')), '+1234567890');
  await tester.enterText(find.byKey(const Key('address_field')), '123 Test Street');
  await tester.enterText(find.byKey(const Key('description_field')), 'A test restaurant for integration testing');
}

Future<void> _fillLocationInfo(WidgetTester tester) async {
  // This would fill location information
  // Implementation depends on your location picker widget
  await tester.tap(find.byKey(const Key('location_picker')));
  await tester.pumpAndSettle();

  // In a real test, you would interact with the map or location search
  await tester.enterText(find.byKey(const Key('location_search')), 'New York, NY');
  await tester.pumpAndSettle();

  await tester.tap(find.text('Select Location'));
  await tester.pumpAndSettle();
}

Future<void> _fillDocumentsInfo(WidgetTester tester) async {
  // This would handle document uploads
  // In a real test, you would mock file picker responses

  // Simulate logo upload
  await tester.tap(find.byKey(const Key('upload_logo_button')));
  await tester.pumpAndSettle();

  // Mock selection would go here
  await tester.pumpAndSettle();

  // Simulate license upload
  await tester.tap(find.byKey(const Key('upload_license_button')));
  await tester.pumpAndSettle();

  // Mock selection would go here
  await tester.pumpAndSettle();
}

Future<void> _testBusinessInfoStep(WidgetTester tester) async {
  // Verify step title
  expect(find.text('Business Information'), findsOneWidget);

  // Verify all required fields are present
  expect(find.byKey(const Key('business_name_field')), findsOneWidget);
  expect(find.byKey(const Key('phone_field')), findsOneWidget);
  expect(find.byKey(const Key('address_field')), findsOneWidget);
  expect(find.byKey(const Key('description_field')), findsOneWidget);

  // Test field validation
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();

  // Should show validation errors
  expect(find.text('Please enter business name'), findsOneWidget);

  // Fill fields correctly
  await _fillBusinessInfo(tester);
  await tester.pumpAndSettle();

  // Verify fields have content
  expect(find.text('Test Restaurant'), findsOneWidget);
  expect(find.text('+1234567890'), findsOneWidget);
  expect(find.text('123 Test Street'), findsOneWidget);
}

Future<void> _testLocationStep(WidgetTester tester) async {
  // Verify step title
  expect(find.text('Location Information'), findsOneWidget);

  // Verify location picker is present
  expect(find.byKey(const Key('location_picker')), findsOneWidget);

  // Test location selection
  await _fillLocationInfo(tester);
}

Future<void> _testDocumentsStep(WidgetTester tester) async {
  // Verify step title
  expect(find.text('Documents'), findsOneWidget);

  // Verify upload buttons are present
  expect(find.byKey(const Key('upload_logo_button')), findsOneWidget);
  expect(find.byKey(const Key('upload_license_button')), findsOneWidget);

  // Test document upload
  await _fillDocumentsInfo(tester);
}

Future<void> _testReviewStep(WidgetTester tester) async {
  // Verify step title
  expect(find.text('Review & Submit'), findsOneWidget);

  // Verify all information is displayed
  expect(find.text('Test Restaurant'), findsOneWidget);
  expect(find.text('+1234567890'), findsOneWidget);
  expect(find.text('123 Test Street'), findsOneWidget);

  // Verify terms checkbox is present
  expect(find.byKey(const Key('terms_checkbox')), findsOneWidget);

  // Verify submit button is present
  expect(find.text('Submit Application'), findsOneWidget);

  // Test terms acceptance
  await tester.tap(find.byKey(const Key('terms_checkbox')));
  await tester.pumpAndSettle();

  // Verify checkbox is checked
  final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
  expect(checkbox.value, isTrue);
}