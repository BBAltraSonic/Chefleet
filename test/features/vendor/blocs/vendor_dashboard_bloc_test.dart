import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:chefleet/features/vendor/blocs/vendor_dashboard_bloc.dart';
import 'package:chefleet/features/vendor/services/vendor_orders_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockVendorOrdersService extends Mock implements VendorOrdersService {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockVendorOrdersService mockVendorOrdersService;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockVendorOrdersService = MockVendorOrdersService();
  });

  VendorDashboardBloc buildBloc() => VendorDashboardBloc(
        supabaseClient: mockSupabaseClient,
        ordersService: mockVendorOrdersService,
      );

  group('LoadOrders', () {
    final orders = [
      {
        'id': 'order-1',
        'status': 'pending',
        'total_amount': 24.0,
      },
      {
        'id': 'order-2',
        'status': 'completed',
        'total_amount': 18.5,
      },
    ];

    blocTest<VendorDashboardBloc, VendorDashboardState>(
      'loads orders and applies filter when service succeeds',
      setUp: () {
        when(
          () => mockVendorOrdersService.fetchRecentOrders(
            vendorId: 'vendor-1',
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => orders);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadOrders(vendorId: 'vendor-1', statusFilter: 'pending')),
      expect: () => [
        VendorDashboardState(
          orders: orders,
          filteredOrders: [orders.first],
          statusFilter: 'pending',
        ),
      ],
      verify: (_) {
        verify(
          () => mockVendorOrdersService.fetchRecentOrders(
            vendorId: 'vendor-1',
            limit: any(named: 'limit'),
          ),
        ).called(1);
      },
    );

    blocTest<VendorDashboardBloc, VendorDashboardState>(
      'emits error message when service throws',
      setUp: () {
        when(
          () => mockVendorOrdersService.fetchRecentOrders(
            vendorId: any(named: 'vendorId'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('boom'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadOrders(vendorId: 'vendor-2')),
      expect: () => [
        const VendorDashboardState(
          errorMessage: 'Failed to load orders: Exception: boom',
        ),
      ],
    );
  });
}
