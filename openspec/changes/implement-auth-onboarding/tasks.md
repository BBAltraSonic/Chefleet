## 1. Profile Creation UI
- [x] 1.1 Create profile creation screen with form fields
  - [x] Name input field (text)
  - [x] Avatar upload/camera selection
  - [x] Address input with autocomplete
  - [x] Notification preferences toggle
- [x] 1.2 Implement form validation
  - [x] Required field validation
  - [x] Address format validation
- [x] 1.3 Add profile management screen
  - [x] Edit existing profile functionality
  - [x] Avatar update capability

## 2. Local Data Storage
- [x] 2.1 Implement local storage for profile data
  - [x] Use SharedPreferences or secure storage
  - [x] Store user profile ID and basic info
  - [x] Implement data persistence across app restarts
- [x] 2.2 Generate temporary user identifiers
  - [x] Create UUID generator for profile IDs
  - [x] Ensure uniqueness across devices

## 3. Supabase Integration
- [x] 3.1 Create profile insertion logic
  - [x] Insert profile data into `users_public` table
  - [x] Handle metadata storage (notification preferences)
  - [x] Error handling for duplicate profiles
- [x] 3.2 Profile synchronization
  - [x] Sync local profile with remote when online
  - [x] Handle offline profile creation

## 4. Navigation Integration
- [x] 4.1 Integrate profile flow into app navigation
  - [x] Show profile creation on first launch
  - [x] Add profile management to navigation
  - [x] Handle profile completion state
- [x] 4.2 Profile-aware order flow
  - [x] Pass profile ID to order creation
  - [x] Include profile data in order context

## 5. State Management
- [x] 5.1 Create Profile BLoC
  - [x] Profile creation states (idle, loading, success, error)
  - [x] Profile update states
  - [x] Local storage state management
- [x] 5.2 Integrate with existing app state
  - [x] Connect profile state to navigation
  - [x] Handle profile initialization on app start

## 6. Testing
- [x] 6.1 Unit tests for profile BLoC
- [x] 6.2 Widget tests for profile screens
- [x] 6.3 Integration tests for profile-to-order flow