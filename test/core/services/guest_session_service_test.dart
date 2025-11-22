import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:chefleet/core/services/guest_session_service.dart';
import 'guest_session_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage, SupabaseClient, SupabaseQueryBuilder, PostgrestFilterBuilder])
void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late GuestSessionService service;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    
    service = GuestSessionService(
      secureStorage: mockSecureStorage,
      supabaseClient: mockSupabaseClient,
    );
  });

  group('GuestSessionService - getOrCreateGuestId', () {
    test('returns existing guest ID when found', () async {
      // Arrange
      const existingGuestId = 'guest_12345-abcde';
      when(mockSecureStorage.read(key: 'guest_session_id'))
          .thenAnswer((_) async => existingGuestId);

      // Act
      final result = await service.getOrCreateGuestId();

      // Assert
      expect(result, equals(existingGuestId));
      verify(mockSecureStorage.read(key: 'guest_session_id')).called(1);
      verifyNever(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')));
    });

    test('creates new guest ID when none exists', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'guest_session_id'))
          .thenAnswer((_) async => null);
      when(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});
      
      // Mock database insert
      when(mockSupabaseClient.from('guest_sessions'))
          .thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select(any))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq(any, any))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle())
          .thenAnswer((_) async => null);
      when(mockQueryBuilder.insert(any))
          .thenAnswer((_) async => {});

      // Act
      final result = await service.getOrCreateGuestId();

      // Assert
      expect(result, startsWith('guest_'));
      expect(result.length, greaterThan(10));
      verify(mockSecureStorage.write(key: 'guest_session_id', value: result)).called(1);
      verify(mockSecureStorage.write(
        key: 'guest_session_created_at',
        value: anyNamed('value'),
      )).called(1);
    });

    test('creates new guest ID when existing ID has invalid format', () async {
      // Arrange
      const invalidGuestId = 'invalid_format';
      when(mockSecureStorage.read(key: 'guest_session_id'))
          .thenAnswer((_) async => invalidGuestId);
      when(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});
      
      // Mock database insert
      when(mockSupabaseClient.from('guest_sessions'))
          .thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select(any))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq(any, any))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle())
          .thenAnswer((_) async => null);
      when(mockQueryBuilder.insert(any))
          .thenAnswer((_) async => {});

      // Act
      final result = await service.getOrCreateGuestId();

      // Assert
      expect(result, startsWith('guest_'));
      expect(result, isNot(equals(invalidGuestId)));
    });

    test('throws GuestSessionException on storage error', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'guest_session_id'))
          .thenThrow(Exception('Storage error'));

      // Act & Assert
      expect(
        () => service.getOrCreateGuestId(),
        throwsA(isA<GuestSessionException>()),
      );
    });
  });

  group('GuestSessionService - getGuestSession', () {
    test('returns null when no guest session exists', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'guest_session_id'))
          .thenAnswer((_) async => null);

      // Act
      final result = await service.getGuestSession();

      // Assert
      expect(result, isNull);
    });

    test('returns GuestSession with valid data', () async {
      // Arrange
      const guestId = 'guest_12345-abcde';
      final createdAt = DateTime.now().subtract(const Duration(days: 1));
      
      when(mockSecureStorage.read(key: 'guest_session_id'))
          .thenAnswer((_) async => guestId);
      when(mockSecureStorage.read(key: 'guest_session_created_at'))
          .thenAnswer((_) async => createdAt.toIso8601String());

      // Act
      final result = await service.getGuestSession();

      // Assert
      expect(result, isNotNull);
      expect(result!.guestId, equals(guestId));
      expect(result.createdAt.difference(createdAt).inSeconds, lessThan(1));
    });

    test('returns GuestSession with current time when createdAt is missing', () async {
      // Arrange
      const guestId = 'guest_12345-abcde';
      
      when(mockSecureStorage.read(key: 'guest_session_id'))
          .thenAnswer((_) async => guestId);
      when(mockSecureStorage.read(key: 'guest_session_created_at'))
          .thenAnswer((_) async => null);

      // Act
      final result = await service.getGuestSession();

      // Assert
      expect(result, isNotNull);
      expect(result!.guestId, equals(guestId));
      expect(result.createdAt.difference(DateTime.now()).inSeconds.abs(), lessThan(2));
    });

    test('throws GuestSessionException on error', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'guest_session_id'))
          .thenThrow(Exception('Storage error'));

      // Act & Assert
      expect(
        () => service.getGuestSession(),
        throwsA(isA<GuestSessionException>()),
      );
    });
  });

  group('GuestSessionService - isGuestMode', () {
    test('returns true when guest ID exists', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'guest_session_id'))
          .thenAnswer((_) async => 'guest_12345-abcde');

      // Act
      final result = await service.isGuestMode();

      // Assert
      expect(result, isTrue);
    });

    test('returns false when guest ID is null', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'guest_session_id'))
          .thenAnswer((_) async => null);

      // Act
      final result = await service.isGuestMode();

      // Assert
      expect(result, isFalse);
    });

    test('returns false when guest ID is empty', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'guest_session_id'))
          .thenAnswer((_) async => '');

      // Act
      final result = await service.isGuestMode();

      // Assert
      expect(result, isFalse);
    });
  });

  group('GuestSessionService - clearGuestSession', () {
    test('deletes both guest ID and created_at keys', () async {
      // Arrange
      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async => {});

      // Act
      await service.clearGuestSession();

      // Assert
      verify(mockSecureStorage.delete(key: 'guest_session_id')).called(1);
      verify(mockSecureStorage.delete(key: 'guest_session_created_at')).called(1);
    });

    test('throws GuestSessionException on error', () async {
      // Arrange
      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenThrow(Exception('Storage error'));

      // Act & Assert
      expect(
        () => service.clearGuestSession(),
        throwsA(isA<GuestSessionException>()),
      );
    });
  });

  group('GuestSessionService - validateGuestSession', () {
    test('returns true when session exists in database', () async {
      // Arrange
      const guestId = 'guest_12345-abcde';
      
      when(mockSupabaseClient.from('guest_sessions'))
          .thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select('id'))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('guest_id', guestId))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle())
          .thenAnswer((_) async => {'id': '123'});

      // Act
      final result = await service.validateGuestSession(guestId);

      // Assert
      expect(result, isTrue);
    });

    test('returns false when session does not exist in database', () async {
      // Arrange
      const guestId = 'guest_12345-abcde';
      
      when(mockSupabaseClient.from('guest_sessions'))
          .thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select('id'))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('guest_id', guestId))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle())
          .thenAnswer((_) async => null);

      // Act
      final result = await service.validateGuestSession(guestId);

      // Assert
      expect(result, isFalse);
    });

    test('throws GuestSessionException on database error', () async {
      // Arrange
      const guestId = 'guest_12345-abcde';
      
      when(mockSupabaseClient.from('guest_sessions'))
          .thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select('id'))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('guest_id', guestId))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle())
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => service.validateGuestSession(guestId),
        throwsA(isA<GuestSessionException>()),
      );
    });
  });

  group('GuestSessionService - updateLastActive', () {
    test('updates last_active_at timestamp', () async {
      // Arrange
      const guestId = 'guest_12345-abcde';
      
      when(mockSupabaseClient.from('guest_sessions'))
          .thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.update(any))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('guest_id', guestId))
          .thenAnswer((_) async => {});

      // Act
      await service.updateLastActive(guestId);

      // Assert
      verify(mockSupabaseClient.from('guest_sessions')).called(1);
      verify(mockQueryBuilder.update(argThat(contains('last_active_at')))).called(1);
      verify(mockFilterBuilder.eq('guest_id', guestId)).called(1);
    });

    test('does not throw on database error (non-critical)', () async {
      // Arrange
      const guestId = 'guest_12345-abcde';
      
      when(mockSupabaseClient.from('guest_sessions'))
          .thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.update(any))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('guest_id', guestId))
          .thenThrow(Exception('Database error'));

      // Act & Assert - should not throw
      await service.updateLastActive(guestId);
    });
  });

  group('GuestSessionService - getGuestSessionInfo', () {
    test('returns session info from database', () async {
      // Arrange
      const guestId = 'guest_12345-abcde';
      final sessionData = {
        'id': '123',
        'guest_id': guestId,
        'created_at': DateTime.now().toIso8601String(),
        'device_info': {'platform': 'flutter'},
      };
      
      when(mockSupabaseClient.from('guest_sessions'))
          .thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select('*'))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('guest_id', guestId))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle())
          .thenAnswer((_) async => sessionData);

      // Act
      final result = await service.getGuestSessionInfo(guestId);

      // Assert
      expect(result, isNotNull);
      expect(result!['guest_id'], equals(guestId));
      expect(result['device_info'], isNotNull);
    });

    test('returns null when session not found', () async {
      // Arrange
      const guestId = 'guest_12345-abcde';
      
      when(mockSupabaseClient.from('guest_sessions'))
          .thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select('*'))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('guest_id', guestId))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle())
          .thenAnswer((_) async => null);

      // Act
      final result = await service.getGuestSessionInfo(guestId);

      // Assert
      expect(result, isNull);
    });

    test('throws GuestSessionException on database error', () async {
      // Arrange
      const guestId = 'guest_12345-abcde';
      
      when(mockSupabaseClient.from('guest_sessions'))
          .thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select('*'))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('guest_id', guestId))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle())
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => service.getGuestSessionInfo(guestId),
        throwsA(isA<GuestSessionException>()),
      );
    });
  });

  group('GuestSession - Model', () {
    test('creates GuestSession with required fields', () {
      // Arrange & Act
      final session = GuestSession(
        guestId: 'guest_12345',
        createdAt: DateTime.now(),
      );

      // Assert
      expect(session.guestId, equals('guest_12345'));
      expect(session.createdAt, isNotNull);
      expect(session.isConverted, isFalse);
    });

    test('isConverted returns true when convertedToUserId is set', () {
      // Arrange & Act
      final session = GuestSession(
        guestId: 'guest_12345',
        createdAt: DateTime.now(),
        convertedToUserId: 'user_123',
      );

      // Assert
      expect(session.isConverted, isTrue);
    });

    test('fromJson creates GuestSession correctly', () {
      // Arrange
      final json = {
        'guest_id': 'guest_12345',
        'created_at': '2025-01-01T00:00:00.000Z',
        'device_info': {'platform': 'flutter'},
        'last_active_at': '2025-01-02T00:00:00.000Z',
        'converted_to_user_id': 'user_123',
        'converted_at': '2025-01-03T00:00:00.000Z',
      };

      // Act
      final session = GuestSession.fromJson(json);

      // Assert
      expect(session.guestId, equals('guest_12345'));
      expect(session.deviceInfo, isNotNull);
      expect(session.lastActiveAt, isNotNull);
      expect(session.convertedToUserId, equals('user_123'));
      expect(session.convertedAt, isNotNull);
      expect(session.isConverted, isTrue);
    });

    test('toJson serializes GuestSession correctly', () {
      // Arrange
      final createdAt = DateTime.parse('2025-01-01T00:00:00.000Z');
      final session = GuestSession(
        guestId: 'guest_12345',
        createdAt: createdAt,
        deviceInfo: {'platform': 'flutter'},
      );

      // Act
      final json = session.toJson();

      // Assert
      expect(json['guest_id'], equals('guest_12345'));
      expect(json['created_at'], equals(createdAt.toIso8601String()));
      expect(json['device_info'], isNotNull);
    });
  });

  group('GuestSessionException', () {
    test('creates exception with message', () {
      // Arrange & Act
      const exception = GuestSessionException('Test error');

      // Assert
      expect(exception.message, equals('Test error'));
      expect(exception.toString(), contains('Test error'));
    });
  });
}
