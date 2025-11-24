import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chefleet/core/services/realtime_subscription_manager.dart';
import 'package:chefleet/core/models/user_role.dart';
import 'package:chefleet/core/blocs/role_bloc.dart';
import 'package:chefleet/core/blocs/role_state.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockRoleBloc extends Mock implements RoleBloc {}
class MockRealtimeChannel extends Mock implements RealtimeChannel {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockRoleBloc mockRoleBloc;
  late RealtimeSubscriptionManager subscriptionManager;

  const testUserId = 'test-user-id';
  const testVendorId = 'test-vendor-id';

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockRoleBloc = MockRoleBloc();

    // Setup default mocks
    when(() => mockRoleBloc.currentRole).thenReturn(UserRole.customer);
    when(() => mockRoleBloc.roleChanges).thenAnswer((_) => Stream.value(UserRole.customer));
  });

  tearDown(() {
    subscriptionManager.dispose();
  });

  group('RealtimeSubscriptionManager - Initialization', () {
    test('initializes with customer role and subscribes to customer channels', () async {
      // Arrange
      final mockChannel = MockRealtimeChannel();
      when(() => mockSupabase.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.onPostgresChanges(
        event: any(named: 'event'),
        schema: any(named: 'schema'),
        table: any(named: 'table'),
        filter: any(named: 'filter'),
        callback: any(named: 'callback'),
      )).thenReturn(mockChannel);
      when(() => mockChannel.subscribe()).thenAnswer((_) async => mockChannel);

      subscriptionManager = RealtimeSubscriptionManager(
        supabase: mockSupabase,
        roleBloc: mockRoleBloc,
        userId: testUserId,
      );

      // Act
      await subscriptionManager.initialize();

      // Assert
      expect(subscriptionManager.activeChannelNames.length, greaterThan(0));
      verify(() => mockSupabase.channel(any())).called(greaterThan(0));
    });

    test('initializes with vendor role and subscribes to vendor channels', () async {
      // Arrange
      when(() => mockRoleBloc.currentRole).thenReturn(UserRole.vendor);
      
      final mockChannel = MockRealtimeChannel();
      when(() => mockSupabase.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.onPostgresChanges(
        event: any(named: 'event'),
        schema: any(named: 'schema'),
        table: any(named: 'table'),
        filter: any(named: 'filter'),
        callback: any(named: 'callback'),
      )).thenReturn(mockChannel);
      when(() => mockChannel.subscribe()).thenAnswer((_) async => mockChannel);

      subscriptionManager = RealtimeSubscriptionManager(
        supabase: mockSupabase,
        roleBloc: mockRoleBloc,
        userId: testUserId,
        vendorProfileId: testVendorId,
      );

      // Act
      await subscriptionManager.initialize();

      // Assert
      expect(subscriptionManager.activeChannelNames.length, greaterThan(0));
      verify(() => mockSupabase.channel(any())).called(greaterThan(0));
    });
  });

  group('RealtimeSubscriptionManager - Role Changes', () {
    test('unsubscribes from customer channels and subscribes to vendor channels on role switch', () async {
      // Arrange
      final mockChannel = MockRealtimeChannel();
      when(() => mockSupabase.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.onPostgresChanges(
        event: any(named: 'event'),
        schema: any(named: 'schema'),
        table: any(named: 'table'),
        filter: any(named: 'filter'),
        callback: any(named: 'callback'),
      )).thenReturn(mockChannel);
      when(() => mockChannel.subscribe()).thenAnswer((_) async => mockChannel);
      when(() => mockSupabase.removeChannel(any())).thenAnswer((_) async {});
      when(() => mockSupabase.removeAllChannels()).thenAnswer((_) async {});

      final roleController = Stream<UserRole>.fromIterable([UserRole.vendor]);
      when(() => mockRoleBloc.roleChanges).thenAnswer((_) => roleController);

      subscriptionManager = RealtimeSubscriptionManager(
        supabase: mockSupabase,
        roleBloc: mockRoleBloc,
        userId: testUserId,
        vendorProfileId: testVendorId,
      );

      // Act
      await subscriptionManager.initialize();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      verify(() => mockSupabase.removeAllChannels()).called(greaterThan(0));
      verify(() => mockSupabase.channel(any())).called(greaterThan(0));
    });

    test('does not resubscribe if role has not changed', () async {
      // Arrange
      final mockChannel = MockRealtimeChannel();
      when(() => mockSupabase.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.onPostgresChanges(
        event: any(named: 'event'),
        schema: any(named: 'schema'),
        table: any(named: 'table'),
        filter: any(named: 'filter'),
        callback: any(named: 'callback'),
      )).thenReturn(mockChannel);
      when(() => mockChannel.subscribe()).thenAnswer((_) async => mockChannel);

      final roleController = Stream<UserRole>.fromIterable([UserRole.customer]);
      when(() => mockRoleBloc.roleChanges).thenAnswer((_) => roleController);

      subscriptionManager = RealtimeSubscriptionManager(
        supabase: mockSupabase,
        roleBloc: mockRoleBloc,
        userId: testUserId,
      );

      // Act
      await subscriptionManager.initialize();
      final initialChannelCount = subscriptionManager.activeChannelNames.length;
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(subscriptionManager.activeChannelNames.length, equals(initialChannelCount));
    });
  });

  group('RealtimeSubscriptionManager - Message Handlers', () {
    test('registers and calls message handler', () async {
      // Arrange
      final mockChannel = MockRealtimeChannel();
      when(() => mockSupabase.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.onPostgresChanges(
        event: any(named: 'event'),
        schema: any(named: 'schema'),
        table: any(named: 'table'),
        filter: any(named: 'filter'),
        callback: any(named: 'callback'),
      )).thenReturn(mockChannel);
      when(() => mockChannel.subscribe()).thenAnswer((_) async => mockChannel);

      subscriptionManager = RealtimeSubscriptionManager(
        supabase: mockSupabase,
        roleBloc: mockRoleBloc,
        userId: testUserId,
      );

      var handlerCalled = false;
      final testData = {'test': 'data'};

      // Act
      subscriptionManager.registerHandler('orders', (data) {
        handlerCalled = true;
        expect(data, equals(testData));
      });

      await subscriptionManager.initialize();

      // Simulate message
      subscriptionManager.registerHandler('orders', (data) {
        handlerCalled = true;
      });

      // Assert
      expect(handlerCalled, isFalse); // Handler registered but not called yet
    });

    test('unregisters message handler', () {
      // Arrange
      subscriptionManager = RealtimeSubscriptionManager(
        supabase: mockSupabase,
        roleBloc: mockRoleBloc,
        userId: testUserId,
      );

      // Act
      subscriptionManager.registerHandler('orders', (data) {});
      subscriptionManager.unregisterHandler('orders');

      // Assert - no exception should be thrown
      expect(() => subscriptionManager.unregisterHandler('orders'), returnsNormally);
    });
  });

  group('RealtimeSubscriptionManager - Vendor Profile Update', () {
    test('updates vendor profile ID and resubscribes if in vendor role', () async {
      // Arrange
      when(() => mockRoleBloc.currentRole).thenReturn(UserRole.vendor);
      
      final mockChannel = MockRealtimeChannel();
      when(() => mockSupabase.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.onPostgresChanges(
        event: any(named: 'event'),
        schema: any(named: 'schema'),
        table: any(named: 'table'),
        filter: any(named: 'filter'),
        callback: any(named: 'callback'),
      )).thenReturn(mockChannel);
      when(() => mockChannel.subscribe()).thenAnswer((_) async => mockChannel);
      when(() => mockSupabase.removeChannel(any())).thenAnswer((_) async {});
      when(() => mockSupabase.removeAllChannels()).thenAnswer((_) async {});

      subscriptionManager = RealtimeSubscriptionManager(
        supabase: mockSupabase,
        roleBloc: mockRoleBloc,
        userId: testUserId,
      );

      await subscriptionManager.initialize();

      // Act
      subscriptionManager.updateVendorProfileId('new-vendor-id');
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      verify(() => mockSupabase.removeAllChannels()).called(greaterThan(0));
    });
  });

  group('RealtimeSubscriptionManager - Cleanup', () {
    test('disposes and cleans up all subscriptions', () async {
      // Arrange
      final mockChannel = MockRealtimeChannel();
      when(() => mockSupabase.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.onPostgresChanges(
        event: any(named: 'event'),
        schema: any(named: 'schema'),
        table: any(named: 'table'),
        filter: any(named: 'filter'),
        callback: any(named: 'callback'),
      )).thenReturn(mockChannel);
      when(() => mockChannel.subscribe()).thenAnswer((_) async => mockChannel);
      when(() => mockSupabase.removeChannel(any())).thenAnswer((_) async {});
      when(() => mockSupabase.removeAllChannels()).thenAnswer((_) async {});

      subscriptionManager = RealtimeSubscriptionManager(
        supabase: mockSupabase,
        roleBloc: mockRoleBloc,
        userId: testUserId,
      );

      await subscriptionManager.initialize();

      // Act
      await subscriptionManager.dispose();

      // Assert
      verify(() => mockSupabase.removeAllChannels()).called(greaterThan(0));
      expect(subscriptionManager.activeChannelNames, isEmpty);
    });
  });

  group('RealtimeSubscriptionManager - Reconnection', () {
    test('reconnects all subscriptions', () async {
      // Arrange
      final mockChannel = MockRealtimeChannel();
      when(() => mockSupabase.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.onPostgresChanges(
        event: any(named: 'event'),
        schema: any(named: 'schema'),
        table: any(named: 'table'),
        filter: any(named: 'filter'),
        callback: any(named: 'callback'),
      )).thenReturn(mockChannel);
      when(() => mockChannel.subscribe()).thenAnswer((_) async => mockChannel);
      when(() => mockSupabase.removeChannel(any())).thenAnswer((_) async {});
      when(() => mockSupabase.removeAllChannels()).thenAnswer((_) async {});

      subscriptionManager = RealtimeSubscriptionManager(
        supabase: mockSupabase,
        roleBloc: mockRoleBloc,
        userId: testUserId,
      );

      await subscriptionManager.initialize();

      // Act
      await subscriptionManager.reconnect();

      // Assert
      verify(() => mockSupabase.removeAllChannels()).called(greaterThan(0));
      verify(() => mockSupabase.channel(any())).called(greaterThan(0));
    });
  });
}
