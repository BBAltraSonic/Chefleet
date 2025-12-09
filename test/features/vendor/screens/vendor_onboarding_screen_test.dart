import 'package:chefleet/features/vendor/blocs/vendor_onboarding_bloc.dart';
import 'package:chefleet/features/vendor/models/vendor_model.dart';
import 'package:chefleet/features/vendor/screens/vendor_onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockUser mockUser;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
  });

  testWidgets('restores saved onboarding progress into form fields', (tester) async {
    const restoredData = VendorOnboardingData(
      businessName: 'Restored Bistro',
      description: 'Handcrafted bites',
      cuisineType: 'Mediterranean',
      phone: '+15555550111',
      businessEmail: 'hi@restored.com',
      address: '456 Food Lane',
      addressText: '456 Food Lane, Flavor Town',
      latitude: 10.0,
      longitude: 20.0,
      termsAccepted: true,
    );

    when(() => mockUser.userMetadata).thenReturn({
      'vendor_onboarding_progress': {
        'data': restoredData.toJson(),
        'current_step': VendorOnboardingStep.review.name,
      },
    });

    final bloc = VendorOnboardingBloc(supabaseClient: mockSupabaseClient);
    addTearDown(bloc.close);

    await bloc.loadSavedProgress();

    await tester.pumpWidget(
      MaterialApp(
        home: VendorOnboardingScreen(bloc: bloc),
      ),
    );

    await tester.pumpAndSettle();

    final businessField = tester.widget<TextFormField>(find.byKey(const Key('business_name_field')));
    final addressField = tester.widget<TextFormField>(find.byKey(const Key('address_field')));

    expect(businessField.controller?.text, equals(restoredData.businessName));
    expect(addressField.controller?.text, equals(restoredData.addressText));
  });
}
