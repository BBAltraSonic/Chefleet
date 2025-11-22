import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chefleet/core/services/guest_conversion_service.dart';
import 'package:chefleet/core/services/guest_session_service.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockPostgrestClient extends Mock implements PostgrestClient {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}
class MockPostgrestBuilder extends Mock implements PostgrestBuilder {}
class MockFunctionsClient extends Mock implements FunctionsClient {}
class MockFunctionResponse extends Mock implements FunctionResponse {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}
class MockGuestSessionService extends Mock implements GuestSessionService {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockPostgrestClient mockPostgrest;
  late MockFunctionsClient mockFunctions;
  late MockGuestSessionService mockGuestService;
  late GuestConversionService conversionService;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockPostgrest = MockPostgrestClient();
    mockFunctions = MockFunctionsClient();
    mockGuestService = MockGuestSessionService();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockSupabase.functions).thenReturn(mockFunctions);

    conversionService = GuestConversionService(
      supabaseClient: mockSupabase,
      guestSessionService: mockGuestService,
    );
  });

  group('GuestConversionService', () {
    group('convertGuestToRegistered', () {
      test('should successfully convert guest to registered user', () async {
        // Arrange
        const guestId = 'guest_test123';
        const email = 'test@example.com';
        const password = 'password123';
        const name = 'Test User';
        const userId = 'user-uuid-123';

        // Mock guest session validation
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        final mockBuilder = MockPostgrestBuilder();
        
        when(() => mockSupabase.from('guest_sessions')).thenReturn(mockPostgrest);
        when(() => mockPostgrest.select('id, converted_to_user_id'))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.eq('guest_id', guestId))
            .thenReturn(mockBuilder);
        when(() => mockBuilder.maybeSingle()).thenAnswer(
          (_) async => {
            'id': 'session-uuid',
            'converted_to_user_id': null,
          },
        );

        // Mock auth signup
        final mockUser = MockUser();
        final mockAuthResponse = MockAuthResponse();
        when(() => mockUser.id).thenReturn(userId);
        when(() => mockAuthResponse.user).thenReturn(mockUser);
        when(() => mockAuth.signUp(
          email: email,
          password: password,
          data: {'name': name},
        )).thenAnswer((_) async => mockAuthResponse);

        // Mock edge function call
        final mockFunctionResponse = MockFunctionResponse();
        when(() => mockFunctionResponse.data).thenReturn({
          'success': true,
          'message': 'Guest data migrated successfully',
          'orders_migrated': 2,
          'messages_migrated': 15,
        });
        when(() => mockFunctions.invoke(
          'migrate_guest_data',
          body: {
            'guest_id': guestId,
            'new_user_id': userId,
          },
        )).thenAnswer((_) async => mockFunctionResponse);

        // Mock guest session cleanup
        when(() => mockGuestService.clearGuestSession())
            .thenAnswer((_) async => {});

        // Act
        final result = await conversionService.convertGuestToRegistered(
          guestId: guestId,
          email: email,
          password: password,
          name: name,
        );

        // Assert
        expect(result.success, true);
        expect(result.userId, userId);
        expect(result.ordersMigrated, 2);
        expect(result.messagesMigrated, 15);

        verify(() => mockAuth.signUp(
          email: email,
          password: password,
          data: {'name': name},
        )).called(1);

        verify(() => mockFunctions.invoke(
          'migrate_guest_data',
          body: {
            'guest_id': guestId,
            'new_user_id': userId,
          },
        )).called(1);

        verify(() => mockGuestService.clearGuestSession()).called(1);
      });

      test('should fail if guest session is invalid', () async {
        // Arrange
        const guestId = 'guest_invalid';
        const email = 'test@example.com';
        const password = 'password123';
        const name = 'Test User';

        // Mock guest session validation - return null (not found)
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        final mockBuilder = MockPostgrestBuilder();
        
        when(() => mockSupabase.from('guest_sessions')).thenReturn(mockPostgrest);
        when(() => mockPostgrest.select('id, converted_to_user_id'))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.eq('guest_id', guestId))
            .thenReturn(mockBuilder);
        when(() => mockBuilder.maybeSingle()).thenAnswer((_) async => null);

        // Act
        final result = await conversionService.convertGuestToRegistered(
          guestId: guestId,
          email: email,
          password: password,
          name: name,
        );

        // Assert
        expect(result.success, false);
        expect(result.errorMessage, contains('Invalid or already converted'));

        verifyNever(() => mockAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ));
      });

      test('should fail if guest session is already converted', () async {
        // Arrange
        const guestId = 'guest_converted';
        const email = 'test@example.com';
        const password = 'password123';
        const name = 'Test User';

        // Mock guest session validation - already converted
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        final mockBuilder = MockPostgrestBuilder();
        
        when(() => mockSupabase.from('guest_sessions')).thenReturn(mockPostgrest);
        when(() => mockPostgrest.select('id, converted_to_user_id'))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.eq('guest_id', guestId))
            .thenReturn(mockBuilder);
        when(() => mockBuilder.maybeSingle()).thenAnswer(
          (_) async => {
            'id': 'session-uuid',
            'converted_to_user_id': 'existing-user-id',
          },
        );

        // Act
        final result = await conversionService.convertGuestToRegistered(
          guestId: guestId,
          email: email,
          password: password,
          name: name,
        );

        // Assert
        expect(result.success, false);
        expect(result.errorMessage, contains('Invalid or already converted'));
      });

      test('should fail if auth signup fails', () async {
        // Arrange
        const guestId = 'guest_test123';
        const email = 'test@example.com';
        const password = 'password123';
        const name = 'Test User';

        // Mock guest session validation
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        final mockBuilder = MockPostgrestBuilder();
        
        when(() => mockSupabase.from('guest_sessions')).thenReturn(mockPostgrest);
        when(() => mockPostgrest.select('id, converted_to_user_id'))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.eq('guest_id', guestId))
            .thenReturn(mockBuilder);
        when(() => mockBuilder.maybeSingle()).thenAnswer(
          (_) async => {
            'id': 'session-uuid',
            'converted_to_user_id': null,
          },
        );

        // Mock auth signup - return null user
        final mockAuthResponse = MockAuthResponse();
        when(() => mockAuthResponse.user).thenReturn(null);
        when(() => mockAuth.signUp(
          email: email,
          password: password,
          data: {'name': name},
        )).thenAnswer((_) async => mockAuthResponse);

        // Act
        final result = await conversionService.convertGuestToRegistered(
          guestId: guestId,
          email: email,
          password: password,
          name: name,
        );

        // Assert
        expect(result.success, false);
        expect(result.errorMessage, contains('Failed to create user account'));
      });
    });

    group('getGuestSessionStats', () {
      test('should return correct statistics', () async {
        // Arrange
        const guestId = 'guest_test123';

        // Mock orders query
        final mockOrdersFilter = MockPostgrestFilterBuilder();
        when(() => mockSupabase.from('orders')).thenReturn(mockPostgrest);
        when(() => mockPostgrest.select('id')).thenReturn(mockOrdersFilter);
        when(() => mockOrdersFilter.eq('guest_user_id', guestId))
            .thenAnswer((_) async => [
              {'id': 'order1'},
              {'id': 'order2'},
            ]);

        // Mock messages query
        final mockMessagesFilter = MockPostgrestFilterBuilder();
        when(() => mockSupabase.from('messages')).thenReturn(mockPostgrest);
        when(() => mockPostgrest.select('id')).thenReturn(mockMessagesFilter);
        when(() => mockMessagesFilter.eq('guest_sender_id', guestId))
            .thenAnswer((_) async => [
              {'id': 'msg1'},
              {'id': 'msg2'},
              {'id': 'msg3'},
            ]);

        // Mock session info
        final createdAt = DateTime.now().subtract(const Duration(days: 5));
        when(() => mockGuestService.getGuestSessionInfo(guestId))
            .thenAnswer((_) async => {
              'created_at': createdAt.toIso8601String(),
            });

        // Act
        final stats = await conversionService.getGuestSessionStats(guestId);

        // Assert
        expect(stats.orderCount, 2);
        expect(stats.messageCount, 3);
        expect(stats.sessionAge.inDays, 5);
        expect(stats.hasActivity, true);
      });

      test('should return zero stats for new guest', () async {
        // Arrange
        const guestId = 'guest_new';

        // Mock empty orders
        final mockOrdersFilter = MockPostgrestFilterBuilder();
        when(() => mockSupabase.from('orders')).thenReturn(mockPostgrest);
        when(() => mockPostgrest.select('id')).thenReturn(mockOrdersFilter);
        when(() => mockOrdersFilter.eq('guest_user_id', guestId))
            .thenAnswer((_) async => []);

        // Mock empty messages
        final mockMessagesFilter = MockPostgrestFilterBuilder();
        when(() => mockSupabase.from('messages')).thenReturn(mockPostgrest);
        when(() => mockPostgrest.select('id')).thenReturn(mockMessagesFilter);
        when(() => mockMessagesFilter.eq('guest_sender_id', guestId))
            .thenAnswer((_) async => []);

        // Mock session info
        when(() => mockGuestService.getGuestSessionInfo(guestId))
            .thenAnswer((_) async => {
              'created_at': DateTime.now().toIso8601String(),
            });

        // Act
        final stats = await conversionService.getGuestSessionStats(guestId);

        // Assert
        expect(stats.orderCount, 0);
        expect(stats.messageCount, 0);
        expect(stats.hasActivity, false);
      });
    });

    group('shouldPromptConversion', () {
      test('should prompt after first order', () {
        // Arrange
        const stats = GuestSessionStats(
          orderCount: 1,
          messageCount: 0,
          sessionAge: Duration(days: 1),
        );

        // Act
        final shouldPrompt = conversionService.shouldPromptConversion(stats);

        // Assert
        expect(shouldPrompt, true);
      });

      test('should prompt after 5 messages', () {
        // Arrange
        const stats = GuestSessionStats(
          orderCount: 0,
          messageCount: 5,
          sessionAge: Duration(days: 1),
        );

        // Act
        final shouldPrompt = conversionService.shouldPromptConversion(stats);

        // Assert
        expect(shouldPrompt, true);
      });

      test('should prompt after 7 days', () {
        // Arrange
        const stats = GuestSessionStats(
          orderCount: 0,
          messageCount: 0,
          sessionAge: Duration(days: 7),
        );

        // Act
        final shouldPrompt = conversionService.shouldPromptConversion(stats);

        // Assert
        expect(shouldPrompt, true);
      });

      test('should not prompt for new inactive guest', () {
        // Arrange
        const stats = GuestSessionStats(
          orderCount: 0,
          messageCount: 0,
          sessionAge: Duration(days: 1),
        );

        // Act
        final shouldPrompt = conversionService.shouldPromptConversion(stats);

        // Assert
        expect(shouldPrompt, false);
      });
    });
  });

  group('ConversionResult', () {
    test('should indicate data presence correctly', () {
      // With data
      const resultWithData = ConversionResult(
        success: true,
        userId: 'user-123',
        ordersMigrated: 2,
        messagesMigrated: 5,
      );
      expect(resultWithData.hasData, true);

      // Without data
      const resultWithoutData = ConversionResult(
        success: true,
        userId: 'user-123',
        ordersMigrated: 0,
        messagesMigrated: 0,
      );
      expect(resultWithoutData.hasData, false);
    });
  });

  group('GuestSessionStats', () {
    test('should indicate activity correctly', () {
      // With activity
      const statsWithActivity = GuestSessionStats(
        orderCount: 1,
        messageCount: 0,
        sessionAge: Duration(days: 1),
      );
      expect(statsWithActivity.hasActivity, true);

      // Without activity
      const statsWithoutActivity = GuestSessionStats(
        orderCount: 0,
        messageCount: 0,
        sessionAge: Duration(days: 1),
      );
      expect(statsWithoutActivity.hasActivity, false);
    });
  });
}
