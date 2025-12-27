import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:chefleet/features/vendor/widgets/order_details_widget.dart';
import 'package:chefleet/features/orders/services/order_realtime_service.dart';
import 'package:chefleet/core/services/edge_function_service.dart';
import 'package:chefleet/core/services/supabase_service.dart';

// Generate mocks
@GenerateMocks([OrderRealtimeService, EdgeFunctionService, SupabaseService])
import 'order_details_widget_test.mocks.dart';

void main() {
  late MockOrderRealtimeService mockRealtimeService;
  late MockEdgeFunctionService mockEdgeFunctionService;
  late MockSupabaseService mockSupabaseService;

  setUp(() {
    mockRealtimeService = MockOrderRealtimeService();
    mockEdgeFunctionService = MockEdgeFunctionService();
    mockSupabaseService = MockSupabaseService();
  });

  Widget createTestWidget({required String orderId}) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<OrderRealtimeService>.value(value: mockRealtimeService),
          Provider<EdgeFunctionService>.value(value: mockEdgeFunctionService),
          Provider<SupabaseService>.value(value: mockSupabaseService),
        ],
        child: Scaffold(
          body: OrderDetailsWidget(
            orderId: orderId,
            onClose: () {},
          ),
        ),
      ),
    );
  }

  group('OrderDetailsWidget - Realtime Integration', () {
    testWidgets('subscribes to realtime updates on init', (tester) async {
      // Arrange
      const orderId = 'test-order-123';
      when(mockRealtimeService.subscribeToOrder(orderId))
          .thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget(orderId: orderId));

      // Assert
      verify(mockRealtimeService.subscribeToOrder(orderId)).called(1);
    });

    testWidgets('updates UI when realtime event received', (tester) async {
      // Arrange
      const orderId = 'test-order-123';
      final streamController = StreamController<Order>();
      
      when(mockRealtimeService.subscribeToOrder(orderId))
          .thenAnswer((_) => streamController.stream);

      // Act
      await tester.pumpWidget(createTestWidget(orderId: orderId));
      await tester.pump();

      // Emit update
      streamController.add(Order(
        id: orderId,
        status: 'confirmed',
        totalAmount: 25.99,
      ));
      await tester.pump();

      // Assert
      expect(find.text('CONFIRMED'), findsOneWidget);
    });

    testWidgets('cleans up subscription on dispose', (tester) async {
      // Arrange
      const orderId = 'test-order-123';
      final streamController = StreamController<Order>();
      
      when(mockRealtimeService.subscribeToOrder(orderId))
          .thenAnswer((_) => streamController.stream);

      // Act
      await tester.pumpWidget(createTestWidget(orderId: orderId));
      await tester.pumpWidget(Container()); // Dispose widget

      // Assert
      expect(streamController.hasListener, isFalse);
    });
  });

  group('OrderDetailsWidget - Optimistic Updates', () {
    testWidgets('updates UI immediately on status change', (tester) async {
      // Arrange
      const orderId = 'test-order-123';
      when(mockRealtimeService.subscribeToOrder(orderId))
          .thenAnswer((_) => Stream.value(Order(
                id: orderId,
                status: 'pending',
                totalAmount: 25.99,
              )));

      when(mockEdgeFunctionService.changeOrderStatus(
        orderId: orderId,
        newStatus: 'confirmed',
      )).thenAnswer((_) async => Right({'success': true}));

      // Act
      await tester.pumpWidget(createTestWidget(orderId: orderId));
      await tester.pumpAndSettle();

      // Find and tap accept button
      final acceptButton = find.text('Accept Order');
      expect(acceptButton, findsOneWidget);
      await tester.tap(acceptButton);

      // UI should update immediately (optimistic)
      await tester.pump(Duration.zero);

      // Assert
      expect(find.text('CONFIRMED'), findsOneWidget);
    });

    testWidgets('rolls back on error', (tester) async {
      // Arrange
      const orderId = 'test-order-123';
      when(mockRealtimeService.subscribeToOrder(orderId))
          .thenAnswer((_) => Stream.value(Order(
                id: orderId,
                status: 'pending',
                totalAmount: 25.99,
              )));

      when(mockEdgeFunctionService.changeOrderStatus(
        orderId: orderId,
        newStatus: 'confirmed',
      )).thenAnswer((_) async => Left('Network error'));

      // Act
      await tester.pumpWidget(createTestWidget(orderId: orderId));
      await tester.pumpAndSettle();

      // Tap accept button
      await tester.tap(find.text('Accept Order'));
      await tester.pump(Duration.zero);

      // Wait for error
      await tester.pumpAndSettle();

      // Assert - should rollback to pending
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('Failed to update status'), findsOneWidget);
    });
  });

  group('OrderDetailsWidget - QR Code Display', () {
    testWidgets('shows generate button when order is ready', (tester) async {
      // Arrange
      const orderId = 'test-order-123';
      when(mockRealtimeService.subscribeToOrder(orderId))
          .thenAnswer((_) => Stream.value(Order(
                id: orderId,
                status: 'ready',
                totalAmount: 25.99,
              )));

      // Act
      await tester.pumpWidget(createTestWidget(orderId: orderId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Generate Pickup Code'), findsOneWidget);
    });

    testWidgets('displays QR code after generation', (tester) async {
      // Arrange
      const orderId = 'test-order-123';
      when(mockRealtimeService.subscribeToOrder(orderId))
          .thenAnswer((_) => Stream.value(Order(
                id: orderId,
                status: 'ready',
                totalAmount: 25.99,
              )));

      when(mockEdgeFunctionService.generatePickupCode(orderId: orderId))
          .thenAnswer((_) async => Right({
                'pickup_code': '123456',
                'expires_at': DateTime.now().add(Duration(minutes: 30)).toIso8601String(),
              }));

      // Act
      await tester.pumpWidget(createTestWidget(orderId: orderId));
      await tester.pumpAndSettle();

      // Tap generate button
      await tester.tap(find.text('Generate Pickup Code'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(PickupCodeQrWidget), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);
    });
  });

  group('OrderDetailsWidget - Performance', () {
    testWidgets('does not rebuild unnecessarily', (tester) async {
      // Arrange
      const orderId = 'test-order-123';
      int buildCount = 0;
      
      when(mockRealtimeService.subscribeToOrder(orderId))
          .thenAnswer((_) => Stream.value(Order(
                id: orderId,
                status: 'pending',
                totalAmount: 25.99,
              )));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<OrderRealtimeService>.value(value: mockRealtimeService),
              Provider<EdgeFunctionService>.value(value: mockEdgeFunctionService),
            ],
            child: Builder(
              builder: (context) {
                buildCount++;
                return OrderDetailsWidget(orderId: orderId, onClose: () {});
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Assert - should only build once
      expect(buildCount, equals(1));
    });
  });
}
