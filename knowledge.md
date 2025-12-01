# Chefleet

A mobile food marketplace Flutter app that connects buyers with local food vendors for cash-only pickup orders.

## Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: flutter_bloc
- **Navigation**: go_router
- **Backend**: Supabase (PostgreSQL, Edge Functions, Auth)
- **Maps**: Google Maps Flutter

## Key Commands

```bash
# Run the app
flutter run

# Run tests
flutter test

# Generate code (freezed, json_serializable)
flutter packages pub run build_runner build

# Analyze code
flutter analyze
```

## Project Structure

- `lib/core/` - Core utilities, blocs, services, routing
- `lib/features/` - Feature modules (auth, feed, map, order, vendor, etc.)
- `supabase/` - Supabase migrations and edge functions
- `test/` - Unit and widget tests

## User Roles

- **Customer**: Browse vendors, place orders, track pickups
- **Vendor**: Manage menu, receive orders, handle pickups

## Notes

- Cash-only transactions (no payment processing)
- Guest accounts supported with conversion flow
- Real-time order updates via Supabase subscriptions
