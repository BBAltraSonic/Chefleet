# Change: Implement Profile Onboarding (No Auth MVP)

## Why
Enable user profile creation for the Chefleet food marketplace MVP, allowing users to complete their profile with essential information for order fulfillment without requiring authentication.

## What Changes
- Create profile creation/completion screen for first-time users (name, avatar, default address)
- Store minimal user data and notification preferences in `users_public` table
- Implement simple local state management for profile data
- Create user profile management functionality
- Generate temporary user identifiers for order tracking
- Store profile data locally on device for session persistence

## Impact
- Affected specs: user-profile, navigation, order-creation
- Affected code: profile screens, local storage, Supabase anonymous inserts
- Non-breaking: Users can access app without authentication requirements