import 'package:bloc_test/bloc_test.dart';
import 'package:chefleet/features/vendor/blocs/vendor_onboarding_bloc.dart';
import 'package:chefleet/features/vendor/models/vendor_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  setUpAll(() {
    registerFallbackValue(const UserAttributes());
  });

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

  const sampleData = VendorOnboardingData(
    businessName: 'Test Bistro',
    description: 'Great bites',
    cuisineType: 'Fusion',
    phone: '+15555550123',
    businessEmail: 'hello@testbistro.com',
    address: '12 Test Way',
    addressText: '12 Test Way, City',
    latitude: 37.0,
    longitude: -122.0,
    termsAccepted: true,
  );

  group('VendorOnboardingBloc autosave', () {
    blocTest<VendorOnboardingBloc, VendorOnboardingState>(
      'emits loading then saved when OnboardingSaved is dispatched manually',
      setUp: () {
        when(() => mockGoTrueClient.updateUser(any())).thenAnswer((_) async => mockUser);
      },
      build: () => VendorOnboardingBloc(supabaseClient: mockSupabaseClient),
      act: (bloc) => bloc.add(const OnboardingSaved(
        onboardingData: sampleData,
        currentStep: VendorOnboardingStep.review,
      )),
      expect: () => const [
        VendorOnboardingState(status: VendorOnboardingStatus.loading),
        VendorOnboardingState(status: VendorOnboardingStatus.saved),
      ],
      verify: (_) {
        verify(() => mockGoTrueClient.updateUser(any())).called(1);
      },
    );

    test('loadSavedProgress hydrates onboardingData and currentStep', () async {
      final savedMetadata = {
        'vendor_onboarding_progress': {
          'data': sampleData.toJson(),
          'current_step': VendorOnboardingStep.review.name,
        },
      };

      when(() => mockUser.userMetadata).thenReturn(savedMetadata);

      final bloc = VendorOnboardingBloc(supabaseClient: mockSupabaseClient);

      await bloc.loadSavedProgress();

      expect(bloc.state.status, VendorOnboardingStatus.loaded);
      expect(bloc.state.onboardingData.businessName, sampleData.businessName);
      expect(bloc.state.onboardingData.addressText, sampleData.addressText);
      expect(bloc.state.currentStep, VendorOnboardingStep.review);
      expect(bloc.state.canGoBack, isTrue);

      await bloc.close();
    });
  });
}
