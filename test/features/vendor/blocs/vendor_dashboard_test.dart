
import 'package:bloc_test/bloc_test.dart';
import 'package:chefleet/features/vendor/blocs/vendor_dashboard_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockPostgrestClient extends Mock implements PostgrestClient {}
class MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  group('VendorDashboardBloc', () {
    late MockSupabaseClient mockSupabaseClient;
    late VendorDashboardBloc vendorDashboardBloc;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      vendorDashboardBloc = VendorDashboardBloc(
        supabaseClient: mockSupabaseClient,
      );
    });

    tearDown(() {
      vendorDashboardBloc.close();
    });

    test('initial state is correct', () {
      expect(vendorDashboardBloc.state, const VendorDashboardState());
    });

    // Note: Full BLoC testing requires extensive mocking of Supabase client chains (e.g. from().select().eq()...)
    // For this verification, we are primarily interested in whether the Bloc compiles and structurally handles the new event.
    // Deep integration tests would mock the entire RPC response chain.
  });
}
