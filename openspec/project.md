# Project Context

## Purpose
Chefleet is a mobile food marketplace that connects buyers with local food vendors for cash-based pickup orders. The app features a map-driven discovery experience where users can browse nearby dishes, place orders, chat with vendors, and get directions for pickup. Vendors manage their listings, accept orders in real-time, and coordinate with customers through in-app chat.

**Key Goals:**
- Provide seamless map-based food discovery with smooth scroll/fade micro-interactions
- Enable real-time order coordination between buyers and vendors
- Support cash-only transactions with pickup code system
- Deliver polished, intuitive UX with glass morphism design language

## Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile app (iOS/Android)
- **flutter_bloc** - State management for reactive UI patterns
- **Google Maps Flutter Plugin** - Native map integration with pins, routes, and clustering

### Backend & Services
- **Supabase MCP Server** - Authentication, PostgreSQL database, real-time subscriptions, and chat channels
- **Context7 MCP** - Business logic orchestration, AI-driven vendor matching, and API coordination
- **Firebase Cloud Messaging (FCM)** - Push notifications for orders, messages, and alerts
- **Google Maps SDK** - Geolocation, route directions, and Places Autocomplete

## Project Conventions

### Code Style
- **Language**: Dart (Flutter)
- **State Management**: BLoC pattern with flutter_bloc
- **Naming Conventions**:
  - Files: `snake_case.dart`
  - Classes: `PascalCase`
  - Variables/functions: `camelCase`
  - Constants: `kPascalCase` or `SCREAMING_SNAKE_CASE`
- **No comments** unless explicitly requested or for complex business logic
- **Formatting**: Use `dart format` with default settings
- **Linting**: Follow `flutter_lints` recommended rules

### Architecture Patterns
- **Layered Architecture**:
  - **Presentation Layer**: Widgets, screens, BLoC state management
  - **Domain Layer**: Business logic, use cases, entities
  - **Data Layer**: Repository pattern, API clients, local storage
- **NestedScrollView/CustomScrollView** for map+feed scroll coordination
- **SliverPersistentHeader** for animated map height (60% ↔ 20%)
- **AnimatedOpacity + Transform** for parallax and fade effects
- **Debouncing/Throttling**:
  - Map bounds update: 600ms debounce after idle
  - Search autocomplete: 300ms debounce
  - Chat rate limit: 5 messages per 10 seconds
- **Real-time**: Supabase Realtime channels for orders and chat
- **Navigation**: Bottom navigation bar with center-docked FAB for active orders

### Testing Strategy
- **Unit Tests**: Core business logic, state management (BLoCs), utilities
- **Widget Tests**: Key UI components, interaction flows
- **Integration Tests**: Critical user journeys (order flow, chat, map interactions)
- **Test Coverage**: Aim for >70% on business logic
- **Tools**: `flutter_test`, `mocktail` for mocking
- Run tests with `flutter test` before committing

### Git Workflow
- **Branching**: `main` for production, feature branches (`feature/add-chat`, `fix/map-fade`)
- **Commits**: Conventional commits format (`feat:`, `fix:`, `refactor:`, `docs:`)
- **Pull Requests**: Required for all changes; must pass tests and linting
- **No direct commits** to `main` branch

## Domain Context

### User Roles
- **Buyer**: Discovers dishes on map, places cash pickup orders, chats with vendors
- **Vendor**: Manages listings, receives/accepts orders, coordinates pickup via chat

### Core Concepts
- **Map-Driven Discovery**: 60% hero map with pins, fade/shrink to 20% on feed scroll
- **Real-time Orders**: Buyer creates → Vendor accepts → Vendor marks ready → Buyer collects
- **Pickup Codes**: Unique code generated per order for verification at pickup
- **Order Status Flow**: `pending` → `accepted` → `ready` → `completed`
- **Cash-Only**: No in-app payments; coordination via chat and pickup codes
- **Geospatial Queries**: Feed updates based on map viewport bounds
- **Chat Scoping**: Each order gets a dedicated chat thread

### Map Interaction Rules
- **Map Height**: 60% (default) → 20% (scrolled) of screen height
- **Map Opacity**: 1.0 (full) → 0.15 (faded) during scroll
- **Animation**: 200ms ease-out for height/opacity transitions
- **Parallax**: Feed scrolls over map with glass blur overlay
- **Pin Tap**: Opens mini info card anchored to bottom of map
- **Pan Debounce**: 600ms idle delay before feed refresh

## Important Constraints
- **Cash-Only Transactions**: No payment processing; warn users not to share payment details in chat
- **Offline Support**: Show cached results with clear "offline" banner; block orders when offline
- **Rate Limiting**: 
  - Chat: 5 messages per 10 seconds (server-side)
  - Autocomplete: 300ms client-side debounce
- **Accessibility**: WCAG AA color contrast, screen reader labels on interactive elements
- **Performance**: Map must remain mounted and responsive even when minimized; avoid jank with hardware acceleration
- **Security**: No comments with secrets/keys; use environment variables for API keys

## External Dependencies

### APIs & SDKs
- **Google Maps Platform**:
  - Maps SDK for Flutter (map display, markers, polylines)
  - Places API (autocomplete, geocoding)
  - Directions API (route calculation)
- **Supabase**:
  - Authentication (email/phone)
  - PostgreSQL database (orders, dishes, vendors, messages)
  - Realtime subscriptions (order updates, chat)
- **Firebase**:
  - Cloud Messaging (push notifications)
  - Analytics (optional, for usage metrics)

### Third-Party Packages
- `google_maps_flutter` - Native map widget
- `flutter_bloc` - State management
- `supabase_flutter` - Supabase client
- `firebase_messaging` - FCM integration
- `geolocator` - Location services
- `http` or `dio` - HTTP client for APIs
