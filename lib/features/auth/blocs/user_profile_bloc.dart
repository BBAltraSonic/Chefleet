import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/blocs/base_bloc.dart';
import '../models/user_profile_model.dart';

class UserProfileEvent extends AppEvent {
  const UserProfileEvent();
}

class UserProfileLoaded extends UserProfileEvent {
  const UserProfileLoaded();
}

class UserProfileCreated extends UserProfileEvent {
  const UserProfileCreated(this.profile);

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

class UserProfileUpdated extends UserProfileEvent {
  const UserProfileUpdated(this.profile);

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

class UserProfileAvatarUpdated extends UserProfileEvent {
  const UserProfileAvatarUpdated(this.avatarUrl);

  final String avatarUrl;

  @override
  List<Object?> get props => [avatarUrl];
}

class UserProfileAddressUpdated extends UserProfileEvent {
  const UserProfileAddressUpdated(this.address);

  final UserAddress address;

  @override
  List<Object?> get props => [address];
}

class UserProfileNotificationPreferencesUpdated extends UserProfileEvent {
  const UserProfileNotificationPreferencesUpdated(this.preferences);

  final NotificationPreferences preferences;

  @override
  List<Object?> get props => [preferences];
}

class UserProfileCleared extends UserProfileEvent {
  const UserProfileCleared();
}

class UserProfileState extends AppState {
  const UserProfileState({
    this.profile = UserProfile.empty,
    this.isLoading = false,
    this.errorMessage,
  });

  final UserProfile profile;
  final bool isLoading;
  final String? errorMessage;

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [profile, isLoading, errorMessage];
}

class UserProfileBloc extends AppBloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc() : super(const UserProfileState()) {
    on<UserProfileLoaded>(_onProfileLoaded);
    on<UserProfileCreated>(_onProfileCreated);
    on<UserProfileUpdated>(_onProfileUpdated);
    on<UserProfileAvatarUpdated>(_onAvatarUpdated);
    on<UserProfileAddressUpdated>(_onAddressUpdated);
    on<UserProfileNotificationPreferencesUpdated>(_onNotificationPreferencesUpdated);
    on<UserProfileCleared>(_onProfileCleared);
  }

  static const String _profileKey = 'user_profile';
  final _uuid = const Uuid();

  Future<void> _onProfileLoaded(
    UserProfileLoaded event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);

      if (profileJson != null) {
        final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
        final profile = UserProfile.fromJson(profileMap);

        // Try to sync with remote
        try {
          final response = await Supabase.instance.client
              .from('users_public')
              .select()
              .eq('id', profile.id)
              .maybeSingle();

          if (response != null) {
            final remoteProfile = UserProfile.fromJson(response);
            await _saveProfileLocally(remoteProfile);
            emit(state.copyWith(profile: remoteProfile, isLoading: false));
          } else {
            emit(state.copyWith(profile: profile, isLoading: false));
          }
        } catch (e) {
          // Remote sync failed, use local profile
          emit(state.copyWith(profile: profile, isLoading: false));
        }
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile: ${e.toString()}',
      ));
    }
  }

  Future<void> _onProfileCreated(
    UserProfileCreated event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // Create profile with temporary ID
      final profile = event.profile.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Supabase
      try {
        await Supabase.instance.client
            .from('users_public')
            .insert(profile.toJson());
      } catch (e) {
        // If remote save fails, continue with local storage only
        print('Warning: Could not save profile to remote: $e');
      }

      // Save locally
      await _saveProfileLocally(profile);

      emit(state.copyWith(
        profile: profile,
        isLoading: false,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create profile: ${e.toString()}',
      ));
    }
  }

  Future<void> _onProfileUpdated(
    UserProfileUpdated event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final updatedProfile = event.profile.copyWith(
        updatedAt: DateTime.now(),
      );

      // Update in Supabase
      try {
        await Supabase.instance.client
            .from('users_public')
            .update(updatedProfile.toJson())
            .eq('id', updatedProfile.id);
      } catch (e) {
        // If remote update fails, continue with local storage only
        print('Warning: Could not update profile in remote: $e');
      }

      // Update locally
      await _saveProfileLocally(updatedProfile);

      emit(state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update profile: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAvatarUpdated(
    UserProfileAvatarUpdated event,
    Emitter<UserProfileState> emit,
  ) async {
    if (state.profile.isEmpty) return;

    final updatedProfile = state.profile.copyWith(
      avatarUrl: event.avatarUrl,
      updatedAt: DateTime.now(),
    );

    add(UserProfileUpdated(updatedProfile));
  }

  Future<void> _onAddressUpdated(
    UserProfileAddressUpdated event,
    Emitter<UserProfileState> emit,
  ) async {
    if (state.profile.isEmpty) return;

    final updatedProfile = state.profile.copyWith(
      address: event.address,
      updatedAt: DateTime.now(),
    );

    add(UserProfileUpdated(updatedProfile));
  }

  Future<void> _onNotificationPreferencesUpdated(
    UserProfileNotificationPreferencesUpdated event,
    Emitter<UserProfileState> emit,
  ) async {
    if (state.profile.isEmpty) return;

    final updatedProfile = state.profile.copyWith(
      notificationPreferences: event.preferences,
      updatedAt: DateTime.now(),
    );

    add(UserProfileUpdated(updatedProfile));
  }

  Future<void> _saveProfileLocally(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    add(const UserProfileCleared());
  }

  void _onProfileCleared(UserProfileCleared event, Emitter<UserProfileState> emit) {
    emit(const UserProfileState());
  }
}