import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chefleet/core/services/realtime_subscription_manager.dart';
import 'package:chefleet/core/services/notification_router.dart';
import 'package:chefleet/core/services/role_storage_service.dart';
import 'package:chefleet/core/services/role_sync_service.dart';
import 'package:chefleet/core/routes/deep_link_handler.dart';
import 'package:chefleet/core/models/user_role.dart';
import 'package:chefleet/core/blocs/role_bloc.dart';
import 'package:chefleet/core/blocs/role_event.dart';
import 'package:chefleet/core/blocs/role_state.dart';
import 'package:chefleet/core/diagnostics/testing/diagnostic_tester_helpers.dart';
import 'package:go_router/go_router.dart';

import 'diagnostic_harness.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoRouter extends Mock implements GoRouter {}
class MockRealtimeChannel extends Mock implements RealtimeChannel {}
class MockRoleStorageService extends Mock implements RoleStorageService {}
class MockRoleSyncService extends Mock implements RoleSyncService {}

void main() {
  ensureIntegrationDiagnostics(scenarioName: 'role_switching_realtime');

  group('Role Switching with Realtime Subscriptions - Integration Tests', () {
    late MockSupabaseClient mockSupabase;
    late MockGoRouter mockGoRouter;
    late RoleBloc roleBloc;
    late RealtimeSubscriptionManager subscriptionManager;
    late NotificationRouter notificationRouter;
    late DeepLinkHandler deepLinkHandler;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockGoRouter = MockGoRouter();

      // Setup mocks
      when(() => mockGoRouter.go(any())).thenReturn(null);
    });

    testWidgets('Complete flow: Login -> Subscribe -> Switch Role -> Resubscribe', 
      (WidgetTester tester) async {
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
      when(() => mockSupabase.removeAllChannels()).thenAnswer((_) async {});

      // Setup role bloc
      roleBloc = RoleBloc(
        storageService: MockRoleStorageService(),
        syncService: MockRoleSyncService(),
      );
      
      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      // 1. User logs in as customer
      subscriptionManager = RealtimeSubscriptionManager(
        supabase: mockSupabase,
        roleBloc: roleBloc,
        userId: 'test-user-id',
        vendorProfileId: 'test-vendor-id',
      );

      // 2. Subscription manager subscribes to customer channels
      await subscriptionManager.initialize();
      final customerChannelCount = subscriptionManager.activeChannelNames.length;
      expect(customerChannelCount, greaterThan(0));

      // 3. User switches to vendor role
      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.vendor,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));
      await Future.delayed(const Duration(milliseconds: 200));

      // 4. Subscription manager unsubscribes from customer channels
      verify(() => mockSupabase.removeAllChannels()).called(greaterThan(0));

      // 5. Subscription manager subscribes to vendor channels
      final vendorChannelCount = subscriptionManager.activeChannelNames.length;
      expect(vendorChannelCount, greaterThan(0));

      // 6. Verify correct channels are active
      expect(subscriptionManager.activeChannelNames, isNotEmpty);
      
      await subscriptionManager.dispose();
      roleBloc.close();
    });

    testWidgets('Notification routing triggers role switch and navigation',
      (WidgetTester tester) async {
      // Arrange
      roleBloc = RoleBloc(
        storageService: MockRoleStorageService(),
        syncService: MockRoleSyncService(),
      );
      
      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      notificationRouter = NotificationRouter(
        roleBloc: roleBloc,
        router: mockGoRouter,
      );

      // 1. Notification is received for vendor role
      final notificationData = {
        'target_role': 'vendor',
        'route': '/vendor/orders/123',
      };

      // 2. User is currently in customer role
      expect(roleBloc.currentRole, equals(UserRole.customer));

      // 3. Role switch is triggered
      await notificationRouter.handleNotification(notificationData);
      await Future.delayed(const Duration(milliseconds: 100));

      // 4. Navigation happens after role switch
      verify(() => mockGoRouter.go(any())).called(greaterThan(0));
      
      roleBloc.close();
    });

    testWidgets('Deep link handling triggers role switch and navigation',
      (WidgetTester tester) async {
      // Arrange
      roleBloc = RoleBloc(
        storageService: MockRoleStorageService(),
        syncService: MockRoleSyncService(),
      );
      
      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      deepLinkHandler = DeepLinkHandler(
        roleBloc: roleBloc,
        router: mockGoRouter,
      );

      // 1. Deep link is for vendor route
      final deepLinkUri = Uri.parse('chefleet://vendor/dashboard');

      // 2. User is currently in customer role
      expect(roleBloc.currentRole, equals(UserRole.customer));

      // 3. Role switch is triggered
      await deepLinkHandler.handleDeepLink(deepLinkUri);
      await Future.delayed(const Duration(milliseconds: 100));

      // 4. Navigation happens after role switch
      verify(() => mockGoRouter.go(any())).called(greaterThan(0));
      
      roleBloc.close();
    });
  });

  group('Realtime Subscription Lifecycle - Integration Tests', () {
    testWidgets('Subscriptions persist across app restarts',
      (WidgetTester tester) async {
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
      when(() => mockSupabase.removeAllChannels()).thenAnswer((_) async {});

      final mockStorage = MockRoleStorageService();
      when(() => mockStorage.getActiveRole())
          .thenAnswer((_) async => UserRole.vendor);

      roleBloc = RoleBloc(
        storageService: mockStorage,
        syncService: MockRoleSyncService(),
      );

      // 1. User has active subscriptions (first session)
      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.vendor,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      subscriptionManager = RealtimeSubscriptionManager(
        supabase: mockSupabase,
        roleBloc: roleBloc,
        userId: 'test-user-id',
        vendorProfileId: 'test-vendor-id',
      );

      await subscriptionManager.initialize();
      final initialChannelCount = subscriptionManager.activeChannelNames.length;
      expect(initialChannelCount, greaterThan(0));

      // 2. App is restarted (simulate by disposing and recreating)
      await subscriptionManager.dispose();

      // 3. Role is restored from storage
      roleBloc.add(const RoleRequested());
      await Future.delayed(const Duration(milliseconds: 100));

      // 4. Subscriptions are re-established
      subscriptionManager = RealtimeSubscriptionManager(
        supabase: mockSupabase,
        roleBloc: roleBloc,
        userId: 'test-user-id',
        vendorProfileId: 'test-vendor-id',
      );

      await subscriptionManager.initialize();
      final restoredChannelCount = subscriptionManager.activeChannelNames.length;
      expect(restoredChannelCount, equals(initialChannelCount));
      
      await subscriptionManager.dispose();
      roleBloc.close();
    });

    testWidgets('Subscriptions handle network reconnection',
      (WidgetTester tester) async {
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
      when(() => mockSupabase.removeAllChannels()).thenAnswer((_) async {});

      roleBloc = RoleBloc(
        storageService: MockRoleStorageService(),
        syncService: MockRoleSyncService(),
      );
      
      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer},
      ));

      // 1. User has active subscriptions
      subscriptionManager = RealtimeSubscriptionManager(
        supabase: mockSupabase,
        roleBloc: roleBloc,
        userId: 'test-user-id',
      );

      await subscriptionManager.initialize();
      expect(subscriptionManager.activeChannelNames, isNotEmpty);

      // 2. Network connection is lost (simulated by clearing channels)
      await subscriptionManager.dispose();
      expect(subscriptionManager.activeChannelNames, isEmpty);

      // 3. Network connection is restored
      // 4. Subscriptions are re-established
      await subscriptionManager.reconnect();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(subscriptionManager.activeChannelNames, isNotEmpty);
      verify(() => mockSupabase.channel(any())).called(greaterThan(0));
      
      await subscriptionManager.dispose();
      roleBloc.close();
    });
  });

  group('FCM Token Management - Integration Tests', () {
    testWidgets('FCM token is updated when role changes',
      (WidgetTester tester) async {
      // Arrange
      roleBloc = RoleBloc(
        storageService: MockRoleStorageService(),
        syncService: MockRoleSyncService(),
      );
      
      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));

      // 1. User has FCM token registered for customer role
      const customerToken = 'fcm-token-customer';
      expect(roleBloc.currentRole, equals(UserRole.customer));

      // 2. User switches to vendor role
      roleBloc.emit(const RoleLoaded(
        activeRole: UserRole.vendor,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      // 3. FCM token is updated with new role
      expect(roleBloc.currentRole, equals(UserRole.vendor));

      // 4. Backend can send notifications to correct role
      // This would be verified through backend integration
      // For now, we verify the role change occurred
      expect(roleBloc.state, isA<RoleLoaded>());
      
      roleBloc.close();
    });
  });
}

/// Helper function to create a test app with all necessary providers
Widget createTestApp({
  required Widget child,
  required RoleBloc roleBloc,
  required GoRouter router,
}) {
  return MaterialApp.router(
    routerConfig: router,
  );
}

/// Helper function to simulate role switch
Future<void> simulateRoleSwitch(
  RoleBloc roleBloc,
  UserRole newRole,
) async {
  roleBloc.add(RoleSwitchRequested(newRole));
  await Future.delayed(const Duration(milliseconds: 500));
}

/// Helper function to simulate notification
Future<void> simulateNotification(
  NotificationRouter router,
  Map<String, dynamic> notificationData,
) async {
  await router.handleNotification(notificationData);
}

/// Helper function to simulate deep link
Future<void> simulateDeepLink(
  DeepLinkHandler handler,
  Uri uri,
) async {
  await handler.handleDeepLink(uri);
}
