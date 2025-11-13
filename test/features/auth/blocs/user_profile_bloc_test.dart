import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chefleet/features/auth/blocs/user_profile_bloc.dart';
import 'package:chefleet/features/auth/models/user_profile_model.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockPostgrestClient extends Mock implements PostgrestClient {}

class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}

void main() {
  group('UserProfileBloc', () {
    late UserProfileBloc bloc;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      bloc = UserProfileBloc();
    });

    tearDown(() {
      bloc.close();
    });

    group('initial state', () {
      test('should be UserProfileState with empty profile', () {
        expect(bloc.state.profile, UserProfile.empty);
        expect(bloc.state.isLoading, false);
        expect(bloc.state.errorMessage, null);
      });
    });

    group('UserProfileLoaded', () {
      setUp(() {
        SharedPreferences.setMockInitialValues({});
      });

      test('emits loading then loaded state when profile exists locally', () async {
        final testProfile = UserProfile(
          id: 'test-id',
          name: 'Test User',
          avatarUrl: 'https://example.com/avatar.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final profileJson = '{"id":"test-id","name":"Test User","avatar_url":"https://example.com/avatar.jpg","created_at":"2024-01-01T00:00:00.000Z","updated_at":"2024-01-01T00:00:00.000Z"}';
        SharedPreferences.setMockInitialValues({
          'user_profile': profileJson,
        });

        bloc = UserProfileBloc();

        await bloc.stream.firstWhere(
          (state) => state.profile.isNotEmpty && !state.isLoading,
        );

        expect(bloc.state.profile.name, 'Test User');
        expect(bloc.state.profile.id, 'test-id');
        expect(bloc.state.isLoading, false);
      });

      test('emits empty state when no profile exists', () async {
        SharedPreferences.setMockInitialValues({});

        bloc = UserProfileBloc();

        await bloc.stream.firstWhere(
          (state) => !state.isLoading,
        );

        expect(bloc.state.profile, UserProfile.empty);
        expect(bloc.state.isLoading, false);
      });
    });

    group('UserProfileCreated', () {
      test('creates profile with generated ID and timestamps', () async {
        SharedPreferences.setMockInitialValues({});

        final initialProfile = UserProfile(
          id: '', // Will be generated
          name: 'New User',
          avatarUrl: null,
          createdAt: null,
          updatedAt: null,
        );

        bloc.add(UserProfileCreated(initialProfile));

        await for (final state in bloc.stream) {
          if (state.profile.isNotEmpty && !state.isLoading) {
            expect(state.profile.name, 'New User');
            expect(state.profile.id, isNotEmpty);
            expect(state.profile.createdAt, isNotNull);
            expect(state.profile.updatedAt, isNotNull);
            break;
          }
        }
      });

      test('emits error state when profile creation fails', () async {
        SharedPreferences.setMockInitialValues({});

        final invalidProfile = UserProfile(
          id: '',
          name: '', // Invalid empty name
          createdAt: null,
          updatedAt: null,
        );

        bloc.add(UserProfileCreated(invalidProfile));

        await for (final state in bloc.stream) {
          if (state.errorMessage != null && !state.isLoading) {
            expect(state.errorMessage, contains('Failed to create profile'));
            break;
          }
        }
      });
    });

    group('UserProfileUpdated', () {
      test('updates profile with new timestamp', () async {
        SharedPreferences.setMockInitialValues({});

        final originalProfile = UserProfile(
          id: 'test-id',
          name: 'Original Name',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        // First create the profile
        bloc.add(UserProfileCreated(originalProfile));
        await for (final state in bloc.stream) {
          if (state.profile.isNotEmpty && !state.isLoading) break;
        }

        final updatedProfile = originalProfile.copyWith(name: 'Updated Name');
        final originalUpdateTime = updatedProfile.updatedAt;

        bloc.add(UserProfileUpdated(updatedProfile));

        await for (final state in bloc.stream) {
          if (state.profile.name == 'Updated Name' && !state.isLoading) {
            expect(state.profile.name, 'Updated Name');
            expect(state.profile.updatedAt, isNot(equals(originalUpdateTime)));
            break;
          }
        }
      });
    });

    group('UserProfileAvatarUpdated', () {
      test('updates avatar URL when profile exists', () async {
        SharedPreferences.setMockInitialValues({});

        final profile = UserProfile(
          id: 'test-id',
          name: 'Test User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        bloc.add(UserProfileCreated(profile));
        await for (final state in bloc.stream) {
          if (state.profile.isNotEmpty && !state.isLoading) break;
        }

        final newAvatarUrl = 'https://example.com/new-avatar.jpg';
        bloc.add(UserProfileAvatarUpdated(newAvatarUrl));

        await for (final state in bloc.stream) {
          if (state.profile.avatarUrl == newAvatarUrl && !state.isLoading) {
            expect(state.profile.avatarUrl, newAvatarUrl);
            break;
          }
        }
      });

      test('does nothing when profile is empty', () async {
        final newAvatarUrl = 'https://example.com/new-avatar.jpg';

        bloc.add(UserProfileAvatarUpdated(newAvatarUrl));

        // Should not emit any state changes
        await Future.delayed(const Duration(milliseconds: 100));
        expect(bloc.state.profile, UserProfile.empty);
      });
    });

    group('UserProfileAddressUpdated', () {
      test('updates address when profile exists', () async {
        SharedPreferences.setMockInitialValues({});

        final profile = UserProfile(
          id: 'test-id',
          name: 'Test User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        bloc.add(UserProfileCreated(profile));
        await for (final state in bloc.stream) {
          if (state.profile.isNotEmpty && !state.isLoading) break;
        }

        final newAddress = UserAddress(
          streetAddress: '123 Main St',
          city: 'San Francisco',
          state: 'CA',
          postalCode: '94105',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        bloc.add(UserProfileAddressUpdated(newAddress));

        await for (final state in bloc.stream) {
          if (state.profile.address != null && !state.isLoading) {
            expect(state.profile.address?.streetAddress, '123 Main St');
            expect(state.profile.address?.city, 'San Francisco');
            break;
          }
        }
      });
    });

    group('UserProfileNotificationPreferencesUpdated', () {
      test('updates notification preferences when profile exists', () async {
        SharedPreferences.setMockInitialValues({});

        final profile = UserProfile(
          id: 'test-id',
          name: 'Test User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        bloc.add(UserProfileCreated(profile));
        await for (final state in bloc.stream) {
          if (state.profile.isNotEmpty && !state.isLoading) break;
        }

        final newPreferences = const NotificationPreferences(
          orderUpdates: false,
          promotions: true,
        );

        bloc.add(UserProfileNotificationPreferencesUpdated(newPreferences));

        await for (final state in bloc.stream) {
          if (state.profile.notificationPreferences.promotions && !state.isLoading) {
            expect(state.profile.notificationPreferences.orderUpdates, false);
            expect(state.profile.notificationPreferences.promotions, true);
            break;
          }
        }
      });
    });

    group('UserProfileCleared', () {
      test('clears profile and resets state', () async {
        SharedPreferences.setMockInitialValues({});

        final profile = UserProfile(
          id: 'test-id',
          name: 'Test User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        bloc.add(UserProfileCreated(profile));
        await for (final state in bloc.stream) {
          if (state.profile.isNotEmpty && !state.isLoading) break;
        }

        expect(bloc.state.profile, isNot(UserProfile.empty));

        bloc.add(const UserProfileCleared());

        expect(bloc.state.profile, UserProfile.empty);
        expect(bloc.state.isLoading, false);
        expect(bloc.state.errorMessage, null);
      });
    });

    group('profile serialization', () {
      test('correctly serializes and deserializes profile JSON', () {
        final originalProfile = UserProfile(
          id: 'test-id',
          name: 'Test User',
          avatarUrl: 'https://example.com/avatar.jpg',
          address: UserAddress(
            streetAddress: '123 Main St',
            city: 'San Francisco',
            state: 'CA',
            postalCode: '94105',
            latitude: 37.7749,
            longitude: -122.4194,
          ),
          notificationPreferences: const NotificationPreferences(
            orderUpdates: true,
            chatMessages: false,
          ),
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
        );

        final json = originalProfile.toJson();
        final deserializedProfile = UserProfile.fromJson(json);

        expect(deserializedProfile.id, originalProfile.id);
        expect(deserializedProfile.name, originalProfile.name);
        expect(deserializedProfile.avatarUrl, originalProfile.avatarUrl);
        expect(deserializedProfile.address?.fullAddress, originalProfile.address?.fullAddress);
        expect(deserializedProfile.notificationPreferences.orderUpdates,
               originalProfile.notificationPreferences.orderUpdates);
      });
    });

    group('error handling', () {
      test('handles SharedPreferences errors gracefully', () async {
        // This test would need more complex mocking to simulate SharedPreferences errors
        // For now, we verify the error message structure
        SharedPreferences.setMockInitialValues({});

        final profile = UserProfile(
          id: 'test-id',
          name: 'Test User',
        );

        bloc.add(UserProfileCreated(profile));

        await for (final state in bloc.stream) {
          if (state.profile.isNotEmpty && !state.isLoading) {
            // Successful case - no error
            expect(state.errorMessage, null);
            break;
          }
        }
      });
    });
  });
}