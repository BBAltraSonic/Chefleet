# Chefleet

**Version:** 1.0.0 (Pre-Release)  
**Status:** 🔄 UAT In Progress  
**Platform:** Android (iOS planned for v1.2)

Chefleet is a mobile marketplace connecting home chefs with local food enthusiasts. Order authentic homemade dishes from talented cooks in your neighborhood.

## 🎯 Project Status

**Implementation:** ✅ Complete (Phases 0-8)  
**UAT Preparation:** ✅ Complete (Phase 9)  
**Stakeholder Sign-off:** ⏳ Pending  
**Release:** 🔜 Coming Soon

### Key Metrics
- ✅ 19/19 screens implemented (100%)
- ✅ 95.8% visual parity with design reference
- ✅ 14 test files (widget, golden, integration, accessibility, performance)
- ✅ WCAG AA accessibility compliance
- ✅ All performance benchmarks met
- ✅ 0 critical issues

## 🚀 Features

### For Buyers
- **Browse & Discover** - Interactive map and feed views to find local dishes
- **Order Management** - Place orders with pickup time selection
- **Real-time Tracking** - Live order status updates with pickup codes
- **In-app Chat** - Communicate with vendors about orders
- **Favorites** - Save and quickly reorder favorite dishes
- **Profile & Settings** - Manage account, notifications, and preferences

### For Vendors
- **Dashboard** - Manage orders and track business metrics
- **Menu Management** - Add, edit, and manage dish availability
- **Order Processing** - Accept, prepare, and complete orders
- **Pickup Verification** - Secure code-based order completion
- **Customer Communication** - Chat with customers in real-time
- **Business Analytics** - Track revenue and performance

## 🛠️ Tech Stack

### Frontend
- **Framework:** Flutter 3.x
- **State Management:** flutter_bloc
- **Routing:** go_router
- **UI:** Material Design 3 with custom Glass UI theme
- **Maps:** google_maps_flutter
- **Typography:** Plus Jakarta Sans

### Backend
- **Database:** Supabase (PostgreSQL)
- **Authentication:** Supabase Auth
- **Real-time:** Supabase Realtime
- **Storage:** Supabase Storage
- **Edge Functions:** Deno (TypeScript)

### Testing
- **Widget Tests:** flutter_test
- **Integration Tests:** integration_test
- **Mocking:** mocktail
- **BLoC Testing:** bloc_test
- **Golden Tests:** Visual regression testing

## 📋 Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / VS Code
- Supabase account and project
- Google Maps API key

## 🔧 Setup

### 1. Clone Repository
```bash
git clone <repository-url>
cd Chefleet
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Environment
Create `.env` file (copy from `.env.example`):
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

### 4. Run Database Migrations
```bash
# Apply migrations to Supabase project
supabase db push
```

### 5. Deploy Edge Functions (Optional)
```bash
# Deploy to Supabase
supabase functions deploy create_order
supabase functions deploy change_order_status
supabase functions deploy generate_pickup_code
```

### 6. Run Application
```bash
# Development
flutter run

# Release
flutter run --release
```

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Run Widget Tests
```bash
flutter test test/features/
```

### Run Integration Tests
```bash
flutter test integration_test/
```

### Run Golden Tests
```bash
# Update baselines
flutter test --update-goldens

# Compare against baselines
flutter test test/golden/
```

### Run with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
start coverage/html/index.html
```

### Run Analyzer
```bash
flutter analyze
```

## 📱 Build

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS (Future)
```bash
flutter build ios --release
```

## 📖 Documentation

### Implementation Guides
- [User Flows Completion Plan](plans/user-flows-completion.md)
- [Environment Setup](docs/ENVIRONMENT_SETUP.md)
- [Local Development](LOCAL_DEVELOPMENT.md)

### Phase Completion Summaries
- [Phase 5: Routing & Navigation](PHASE_5_COMPLETION_SUMMARY.md)
- [Phase 7: Testing & Quality](PHASE_7_COMPLETION_SUMMARY.md)
- [Phase 8: Accessibility & Performance](docs/PHASE_8_COMPLETION_SUMMARY.md)
- [Phase 9: UAT & Sign-off](PHASE_9_COMPLETION_SUMMARY.md)

### UAT & Release
- [UAT Guide](PHASE_9_UAT_GUIDE.md)
- [Validation Report](PHASE_9_VALIDATION_REPORT.md)
- [Material Design Deviations](MATERIAL_DESIGN_DEVIATIONS.md)
- [Release Readiness Checklist](RELEASE_READINESS_CHECKLIST.md)

### Technical Documentation
- [Database Schema](documentation/database-schema.md)
- [Edge Functions API](documentation/edge-functions-api.md)
- [Database Security](documentation/database-security.md)

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── blocs/          # Global BLoCs (auth, theme)
│   ├── exceptions/     # Custom exceptions
│   ├── models/         # Data models
│   ├── router/         # go_router configuration
│   ├── services/       # API services
│   ├── theme/          # App theme and design tokens
│   └── utils/          # Utilities and helpers
├── features/
│   ├── auth/           # Authentication screens and logic
│   ├── chat/           # In-app messaging
│   ├── dish/           # Dish browsing and detail
│   ├── feed/           # Feed view
│   ├── map/            # Map view
│   ├── order/          # Order management
│   ├── profile/        # User profile
│   ├── settings/       # App settings
│   └── vendor/         # Vendor-specific features
├── shared/
│   ├── blocs/          # Shared BLoCs
│   └── widgets/        # Reusable widgets
└── main.dart           # Application entry point
```

## 🎨 Design System

### Color Palette
- **Primary Green:** #00A86B
- **Secondary Green:** #4A5568
- **Background:** #F7FAFC
- **Dark Text:** #1A202C
- **Border Green:** #E2E8F0

### Typography
- **Font Family:** Plus Jakarta Sans
- **Headings:** Bold (700)
- **Body:** Regular (400)
- **Captions:** Medium (500)

### Glass UI
- **Blur:** 18.0 (navigation), 12.0 (cards)
- **Opacity:** 0.8 (navigation), 0.9 (cards)
- **Border:** 1px solid rgba(255, 255, 255, 0.2)

## 🔐 Security

- ✅ Row Level Security (RLS) enabled on all tables
- ✅ API keys not hardcoded (use environment variables)
- ✅ Pickup code verification server-side
- ✅ One-time use pickup codes
- ✅ Ownership checks on all operations
- ✅ Input validation and sanitization

## ♿ Accessibility

- ✅ WCAG AA color contrast (≥4.5:1)
- ✅ Tap targets ≥48x48dp
- ✅ Semantic labels on all interactive elements
- ✅ Text scaling up to 2.5x
- ✅ Screen reader support (TalkBack)
- ✅ Logical focus order

## ⚡ Performance

- ✅ App launch <3s (cold), <1s (warm)
- ✅ Screen transitions <300ms
- ✅ List scrolling ≥55fps
- ✅ Search debounce 600ms
- ✅ Realtime updates <3s latency
- ✅ Image caching and optimization

## 🐛 Known Issues

### Non-Blocking
- 636 analyzer warnings (mostly deprecations) - scheduled for v1.1
- Golden test baselines need generation before release
- Tour completion persistence TODO (vendor quick tour)

### Deferred to v1.1
- Deep links (requires platform-specific config)
- Secrets management via --dart-define
- Deprecation warning cleanup

## 🗺️ Roadmap

### v1.0 (Current)
- ✅ Complete buyer and vendor flows
- ✅ Real-time order tracking
- ✅ In-app chat
- ✅ Pickup code verification
- ⏳ UAT and stakeholder sign-off
- ⏳ Google Play Store release

### v1.1 (Planned)
- Deep link support
- Push notifications
- Payment integration (Stripe)
- Enhanced analytics
- Deprecation cleanup

### v1.2 (Future)
- iOS support
- Offline mode
- Dark theme
- Multi-language support
- Advanced search filters

## 📄 License

[License information to be added]

## 👥 Contributors

[Contributor information to be added]

## 📞 Support

For issues and questions:
- Create an issue in the repository
- Contact: [support email to be added]

## 🙏 Acknowledgments

- Design reference screens
- Flutter and Dart teams
- Supabase team
- Open source community

---

**Last Updated:** 2025-01-21  
**Next Milestone:** Stakeholder Sign-off & Release
