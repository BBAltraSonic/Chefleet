# Critical Remediation Plan - Chefleet App
**Created**: 2025-11-22  
**Priority**: High  
**Target Completion**: 2 weeks (10 business days)

---

## Overview

This plan addresses critical security issues, architectural problems, and incomplete remediation phases identified in the November 22, 2025 assessment. The work is organized into 5 sprints with clear deliverables and acceptance criteria.

---

## Sprint 1: Security & Configuration (Days 1-2) 🔴 CRITICAL

### Objective
Eliminate hard-coded credentials and configure essential API keys.

### Tasks

#### 1.1 Secure Supabase Credentials (Priority: CRITICAL)
**Current State**: Hard-coded URL and anon key in `lib/main.dart`

**Steps**:
1. Create `.env` file structure:
   ```env
   # .env.example (commit this)
   SUPABASE_URL=your_supabase_url_here
   SUPABASE_ANON_KEY=your_anon_key_here
   GOOGLE_MAPS_API_KEY=your_maps_key_here
   ```

2. Add `.env` to `.gitignore`:
   ```gitignore
   # Environment files
   .env
   .env.local
   .env.*.local
   ```

3. Update `lib/main.dart` to use environment variables:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     // Load environment variables
     await dotenv.load(fileName: ".env");
     
     await Supabase.initialize(
       url: dotenv.env['SUPABASE_URL']!,
       anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
     );
     
     runApp(const MyApp());
   }
   ```

4. Add `flutter_dotenv` to `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_dotenv: ^5.1.0
   
   flutter:
     assets:
       - .env
   ```

5. Update test files to use mock credentials or test environment

**Files to Modify**:
- `lib/main.dart`
- `pubspec.yaml`
- `.gitignore`
- `test/**/*.dart` (remove hard-coded test credentials)

**Acceptance Criteria**:
- ✅ No credentials in source code
- ✅ `.env.example` documented with all required keys
- ✅ App runs with environment-loaded credentials
- ✅ Tests use mocked credentials
- ✅ Git history cleaned (if credentials were committed)

**Time Estimate**: 4 hours

---

#### 1.2 Configure Google Maps API Key
**Current State**: Maps API key is null, maps may not work in production

**Steps**:
1. Obtain Google Maps API key from Google Cloud Console
2. Add to `.env` file
3. Configure for Android (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="${GOOGLE_MAPS_API_KEY}"/>
   ```

4. Configure for iOS (`ios/Runner/AppDelegate.swift`):
   ```swift
   GMSServices.provideAPIKey(dotenv.env['GOOGLE_MAPS_API_KEY']!)
   ```

5. Update build scripts to inject API key at build time

**Files to Modify**:
- `android/app/src/main/AndroidManifest.xml`
- `android/app/build.gradle`
- `ios/Runner/AppDelegate.swift`
- `.env.example`

**Acceptance Criteria**:
- ✅ Maps render correctly in debug and release builds
- ✅ No API key warnings in logs
- ✅ API key not exposed in version control

**Time Estimate**: 2 hours

---

#### 1.3 Update Documentation
**Steps**:
1. Create `docs/ENVIRONMENT_SETUP.md` with detailed setup instructions
2. Update `README.md` with environment configuration section
3. Document API key acquisition process
4. Add troubleshooting section for common environment issues

**Acceptance Criteria**:
- ✅ New developer can set up environment in <15 minutes
- ✅ All required environment variables documented
- ✅ Clear instructions for obtaining API keys

**Time Estimate**: 2 hours

---

### Sprint 1 Deliverables
- ✅ All credentials moved to environment variables
- ✅ Google Maps API key configured
- ✅ Documentation updated
- ✅ `.env.example` committed
- ✅ Git history cleaned (if needed)

**Total Sprint 1 Time**: 8 hours (1 day)

---

## Sprint 2: Navigation Unification (Days 3-4) 🟡 HIGH

### Objective
Eliminate dual navigation system, migrate fully to `go_router`.

### Current State Analysis
- `go_router` configured in `app_router.dart` but not used
- Custom `PersistentNavigationShell` with `IndexedStack` in use
- `MaterialApp` instead of `MaterialApp.router`
- Deep linking may not work

### Tasks

#### 2.1 Audit Current Navigation
**Steps**:
1. Document all current routes and their usage
2. Identify deep link requirements
3. Map custom shell behavior to go_router patterns
4. List all navigation-related BLoCs and their dependencies

**Deliverable**: Navigation audit document

**Time Estimate**: 2 hours

---

#### 2.2 Implement go_router Shell Route
**Steps**:
1. Create `ShellRoute` for persistent bottom navigation:
   ```dart
   ShellRoute(
     builder: (context, state, child) {
       return PersistentNavigationShell(child: child);
     },
     routes: [
       GoRoute(
         path: '/map',
         pageBuilder: (context, state) => NoTransitionPage(
           child: MapScreen(),
         ),
       ),
       GoRoute(
         path: '/feed',
         pageBuilder: (context, state) => NoTransitionPage(
           child: FeedScreen(),
         ),
       ),
       // ... other tab routes
     ],
   )
   ```

2. Refactor `PersistentNavigationShell` to work with go_router:
   - Remove `IndexedStack` logic
   - Use `child` parameter from ShellRoute
   - Update navigation to use `context.go()` instead of BLoC events

3. Implement route guards:
   ```dart
   redirect: (context, state) {
     final authState = context.read<AuthBloc>().state;
     final isAuthenticated = authState.mode == AuthMode.authenticated;
     
     if (!isAuthenticated && !state.matchedLocation.startsWith('/auth')) {
       return '/splash';
     }
     return null;
   }
   ```

**Files to Modify**:
- `lib/core/router/app_router.dart`
- `lib/shared/widgets/persistent_navigation_shell.dart`
- `lib/main.dart`
- `lib/core/blocs/navigation_bloc.dart` (may be simplified or removed)

**Acceptance Criteria**:
- ✅ Single navigation system (go_router only)
- ✅ Bottom navigation works with go_router
- ✅ Deep links functional
- ✅ Route guards working
- ✅ No navigation-related BLoC if not needed

**Time Estimate**: 8 hours

---

#### 2.3 Update All Navigation Calls
**Steps**:
1. Find all `Navigator.push()` calls and replace with `context.go()` or `context.push()`
2. Find all `Navigator.pop()` calls and replace with `context.pop()`
3. Update navigation BLoC usage to use go_router state
4. Test all navigation flows

**Tools**:
```bash
# Find all Navigator usage
grep -r "Navigator\." lib/ --include="*.dart"

# Find all navigation BLoC usage
grep -r "NavigationBloc" lib/ --include="*.dart"
```

**Acceptance Criteria**:
- ✅ All screens accessible via go_router
- ✅ Back button works correctly
- ✅ Tab state preserved when switching
- ✅ Deep links tested and working

**Time Estimate**: 6 hours

---

#### 2.4 Remove Legacy Navigation Code
**Steps**:
1. Remove unused navigation BLoC code (if fully replaced)
2. Remove old route definitions
3. Clean up navigation-related utilities
4. Update tests to use go_router test helpers

**Acceptance Criteria**:
- ✅ No dead navigation code
- ✅ Tests passing
- ✅ Code coverage maintained

**Time Estimate**: 2 hours

---

### Sprint 2 Deliverables
- ✅ Single navigation system (go_router)
- ✅ Deep linking functional
- ✅ All screens accessible
- ✅ Navigation tests passing
- ✅ Documentation updated

**Total Sprint 2 Time**: 18 hours (2.25 days)

---

## Sprint 3: Edge Functions & Payment Cleanup (Days 5-6) 🟡 MEDIUM

### Objective
Consolidate edge functions, remove unused payment code.

### Tasks

#### 3.1 Consolidate Edge Functions (Phase 2)
**Current State**: Functions split between `supabase/functions/` and `edge-functions/`

**Steps**:
1. Audit all edge functions:
   ```bash
   # List all functions
   ls -la supabase/functions/
   ls -la edge-functions/
   ```

2. Identify active vs. legacy functions:
   - **Keep**: create_order, change_order_status, generate_pickup_code, migrate_guest_data
   - **Remove**: create_payment_intent, manage_payment_methods, process_payment_webhook

3. Move any needed functions from `edge-functions/` to `supabase/functions/`

4. Delete `edge-functions/` folder:
   ```bash
   git rm -r edge-functions/
   ```

5. Update function imports in Dart code:
   ```dart
   // Find all edge function calls
   grep -r "functions.invoke" lib/ --include="*.dart"
   ```

6. Add `deno.json` for version pinning:
   ```json
   {
     "imports": {
       "supabase": "https://esm.sh/@supabase/supabase-js@2.38.4"
     }
   }
   ```

7. Deploy functions to dev:
   ```bash
   supabase functions deploy create_order
   supabase functions deploy change_order_status
   supabase functions deploy generate_pickup_code
   supabase functions deploy migrate_guest_data
   ```

**Files to Modify**:
- Delete `edge-functions/` directory
- Update function call sites in `lib/`
- Add `supabase/functions/deno.json`

**Acceptance Criteria**:
- ✅ Single functions directory
- ✅ All functions deployed and tested
- ✅ No references to old function paths
- ✅ Functions documented

**Time Estimate**: 4 hours

---

#### 3.2 Remove Payment Code (Phase 6)
**Current State**: Stripe integration removed but code remains

**Steps**:
1. Identify all payment-related code:
   ```bash
   # Find payment-related files
   find lib/ -name "*payment*" -o -name "*stripe*"
   
   # Find payment service usage
   grep -r "PaymentService\|StripeService\|payment_intent" lib/ --include="*.dart"
   ```

2. Remove payment-related files:
   - `lib/core/services/payment_service.dart`
   - `lib/features/payment/**` (if exists)
   - Payment-related BLoC events/states

3. Remove payment UI components:
   - Payment method screens
   - Card input widgets
   - Payment selection UI

4. Update order flow to cash-only:
   ```dart
   // In OrderBloc
   enum PaymentMethod {
     cash, // Only option
   }
   ```

5. Remove payment-related database tables (if not used):
   - Create migration to drop: `payment_methods`, `payment_intents`, etc.

6. Update documentation to reflect cash-only

**Files to Remove/Modify**:
- `lib/core/services/payment_service.dart` (remove)
- `lib/features/order/blocs/order_bloc.dart` (update)
- `lib/features/order/screens/*` (remove payment UI)
- Payment-related tests

**Acceptance Criteria**:
- ✅ No payment code in codebase
- ✅ Order flow works cash-only
- ✅ No broken references
- ✅ Tests passing
- ✅ Documentation updated

**Time Estimate**: 6 hours

---

#### 3.3 Update Order Flow Documentation
**Steps**:
1. Document cash-only order flow
2. Update user-facing documentation
3. Create vendor documentation for cash handling
4. Update API documentation

**Acceptance Criteria**:
- ✅ Clear cash-only flow documented
- ✅ Vendor instructions updated
- ✅ User expectations set

**Time Estimate**: 2 hours

---

### Sprint 3 Deliverables
- ✅ Single edge functions directory
- ✅ All payment code removed
- ✅ Cash-only order flow working
- ✅ Documentation updated
- ✅ Functions deployed to dev

**Total Sprint 3 Time**: 12 hours (1.5 days)

---

## Sprint 4: Code Quality & Performance (Days 7-8) 🟢 MEDIUM

### Objective
Fix lint warnings, improve performance, clean up code quality issues.

### Tasks

#### 4.1 Fix Lint Warnings
**Current Issues**:
- Dead code in `dish_detail_screen.dart:82`
- Unnecessary null checks (lines 294, 304, 468)

**Steps**:
1. Fix dead code (line 82):
   ```dart
   // Remove this check - .single() throws instead of returning null
   // if (dishResponse == null) {
   //   throw Exception('Dish not found');
   // }
   
   // Just use try-catch around the query
   try {
     final dishResponse = await supabase
       .from('dishes')
       .select('...')
       .eq('id', widget.dishId)
       .single();
     // Process response
   } catch (e) {
     throw Exception('Dish not found: $e');
   }
   ```

2. Fix unnecessary null checks:
   ```dart
   // Line 294: Remove unnecessary null check
   // Before: if (_dish != null) { ... }
   // After: Just use _dish! or restructure
   
   // Line 304: Remove unnecessary ! operator
   // Before: _dish!.imageUrl
   // After: _dish.imageUrl
   
   // Line 468: Replace ?. with .
   // Before: vendor?.name
   // After: vendor.name
   ```

3. Run analyzer and fix remaining issues:
   ```bash
   flutter analyze
   ```

**Files to Modify**:
- `lib/features/dish/screens/dish_detail_screen.dart`

**Acceptance Criteria**:
- ✅ Zero lint warnings in modified files
- ✅ `flutter analyze` passes
- ✅ No runtime errors introduced

**Time Estimate**: 2 hours

---

#### 4.2 Optimize Initial Load Performance
**Current Issue**: 43-50 frames dropped during initial load (~1.3s delay)

**Steps**:
1. Profile app startup:
   ```bash
   flutter run --profile --trace-startup
   ```

2. Identify bottlenecks:
   - Heavy BLoC initialization
   - Supabase connection
   - Google Maps initialization

3. Implement lazy loading:
   ```dart
   // Defer non-critical BLoC initialization
   BlocProvider(
     lazy: true, // Don't create until accessed
     create: (context) => SomeBlocNotNeededImmediately(),
   )
   ```

4. Optimize Supabase initialization:
   ```dart
   // Move to isolate if possible
   await Supabase.initialize(
     url: dotenv.env['SUPABASE_URL']!,
     anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
     realtimeClientOptions: RealtimeClientOptions(
       eventsPerSecond: 2, // Reduce if not needed
     ),
   );
   ```

5. Defer Maps initialization:
   ```dart
   // Load map widget only when tab is visible
   if (state.currentTab == NavigationTab.map) {
     return MapScreen();
   }
   ```

6. Add splash screen with progress indicator:
   ```dart
   // Show meaningful loading states
   class SplashScreen extends StatefulWidget {
     // Show progress: "Loading...", "Connecting...", "Ready!"
   }
   ```

**Acceptance Criteria**:
- ✅ Frame drops reduced to <10 frames
- ✅ Initial load time <500ms
- ✅ Smooth animations during startup
- ✅ No perceived lag

**Time Estimate**: 6 hours

---

#### 4.3 Address ImageReader Buffer Warnings
**Current Issue**: `Unable to acquire a buffer item` warnings

**Steps**:
1. Investigate Google Maps texture buffer usage
2. Adjust buffer pool size if needed:
   ```dart
   // In map initialization
   GoogleMap(
     // ... other properties
     liteModeEnabled: false, // Ensure full rendering
   )
   ```

3. Monitor memory usage during map interactions
4. Consider reducing map complexity if needed (fewer markers, simpler styles)

**Acceptance Criteria**:
- ✅ Warnings reduced or eliminated
- ✅ No memory leaks
- ✅ Smooth map interactions

**Time Estimate**: 3 hours

---

#### 4.4 Code Cleanup
**Steps**:
1. Remove debug print statements:
   ```bash
   # Find all print statements
   grep -r "print\|debugPrint" lib/ --include="*.dart"
   ```

2. Replace with proper logging:
   ```dart
   import 'package:logger/logger.dart';
   
   final logger = Logger();
   logger.d('Debug message');
   logger.i('Info message');
   logger.e('Error message');
   ```

3. Remove commented-out code
4. Format all files:
   ```bash
   dart format lib/ test/
   ```

5. Run code metrics:
   ```bash
   flutter pub run dart_code_metrics:metrics analyze lib
   ```

**Acceptance Criteria**:
- ✅ No print statements in production code
- ✅ Consistent formatting
- ✅ No commented-out code
- ✅ Code metrics improved

**Time Estimate**: 3 hours

---

### Sprint 4 Deliverables
- ✅ Zero lint warnings
- ✅ Improved startup performance
- ✅ Clean, formatted code
- ✅ Proper logging implemented
- ✅ Performance metrics documented

**Total Sprint 4 Time**: 14 hours (1.75 days)

---

## Sprint 5: Testing & CI/CD (Days 9-10) 🟢 HIGH

### Objective
Fix test suite, implement CI/CD pipeline.

### Tasks

#### 5.1 Fix Unit Tests (Phase 8)
**Current State**: 800+ analyzer issues in test code

**Steps**:
1. Run tests and document failures:
   ```bash
   flutter test --reporter expanded > test_results.txt
   ```

2. Fix test dependencies:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. Update mocks for API changes:
   ```dart
   // Use mockito or mocktail
   import 'package:mocktail/mocktail.dart';
   
   class MockSupabaseClient extends Mock implements SupabaseClient {}
   class MockAuthBloc extends Mock implements AuthBloc {}
   ```

4. Remove live Supabase calls in tests:
   ```dart
   // Before: Real Supabase call
   await Supabase.instance.client.from('orders').select();
   
   // After: Mocked call
   when(() => mockClient.from('orders')).thenReturn(mockQueryBuilder);
   when(() => mockQueryBuilder.select()).thenAnswer((_) async => []);
   ```

5. Fix undefined symbols:
   - Import missing dependencies
   - Update deprecated API usage
   - Fix type mismatches

6. Organize tests by feature:
   ```
   test/
     unit/
       blocs/
       services/
       repositories/
     widget/
       screens/
       widgets/
     integration/
       flows/
   ```

**Acceptance Criteria**:
- ✅ All unit tests passing
- ✅ No live external calls in tests
- ✅ Test coverage >70% for critical paths
- ✅ Tests run in <2 minutes

**Time Estimate**: 8 hours

---

#### 5.2 Fix Integration Tests
**Current State**: Tests attempt live Supabase access

**Steps**:
1. Set up local Supabase for testing:
   ```bash
   supabase start
   ```

2. Create test data fixtures:
   ```dart
   // test/fixtures/test_data.dart
   class TestData {
     static final testVendor = Vendor(id: 'test-1', ...);
     static final testDish = Dish(id: 'test-2', ...);
   }
   ```

3. Update integration tests to use test database:
   ```dart
   setUpAll(() async {
     await Supabase.initialize(
       url: 'http://localhost:54321',
       anonKey: 'test-anon-key',
     );
   });
   ```

4. Create test helpers:
   ```dart
   // test/helpers/test_helpers.dart
   Future<void> seedTestData() async {
     // Insert test vendors, dishes, etc.
   }
   
   Future<void> cleanupTestData() async {
     // Clean up after tests
   }
   ```

5. Document integration test setup in README

**Acceptance Criteria**:
- ✅ Integration tests passing
- ✅ Tests use local Supabase
- ✅ Test data isolated
- ✅ Setup documented

**Time Estimate**: 6 hours

---

#### 5.3 Implement CI/CD Pipeline (Phase 9)
**Steps**:
1. Create GitHub Actions workflow (`.github/workflows/ci.yml`):
   ```yaml
   name: CI
   
   on:
     push:
       branches: [main, develop]
     pull_request:
       branches: [main, develop]
   
   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         
         - name: Setup Flutter
           uses: subosito/flutter-action@v2
           with:
             flutter-version: '3.35.5'
             
         - name: Install dependencies
           run: flutter pub get
           
         - name: Generate code
           run: flutter pub run build_runner build --delete-conflicting-outputs
           
         - name: Analyze
           run: flutter analyze
           
         - name: Run tests
           run: flutter test --coverage
           
         - name: Upload coverage
           uses: codecov/codecov-action@v3
           with:
             files: ./coverage/lcov.info
   
     build:
       needs: test
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         
         - name: Setup Flutter
           uses: subosito/flutter-action@v2
           
         - name: Build APK
           run: flutter build apk --release
           
         - name: Upload APK
           uses: actions/upload-artifact@v3
           with:
             name: app-release.apk
             path: build/app/outputs/flutter-apk/app-release.apk
   ```

2. Add secrets to GitHub:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `GOOGLE_MAPS_API_KEY`

3. Configure branch protection:
   - Require CI to pass before merge
   - Require code review
   - No direct pushes to main

4. Set up automated deployments:
   ```yaml
   deploy:
     needs: build
     if: github.ref == 'refs/heads/main'
     runs-on: ubuntu-latest
     steps:
       - name: Deploy to Firebase App Distribution
         # or TestFlight, Play Store, etc.
   ```

**Files to Create**:
- `.github/workflows/ci.yml`
- `.github/workflows/release.yml`
- `docs/CI_CD_SETUP.md`

**Acceptance Criteria**:
- ✅ CI runs on every PR
- ✅ Tests must pass to merge
- ✅ Automated builds working
- ✅ Coverage reports generated
- ✅ Branch protection enabled

**Time Estimate**: 6 hours

---

#### 5.4 Quality Gates
**Steps**:
1. Set up code coverage requirements:
   ```yaml
   # codecov.yml
   coverage:
     status:
       project:
         default:
           target: 70%
           threshold: 5%
   ```

2. Add pre-commit hooks:
   ```yaml
   # .pre-commit-config.yaml
   repos:
     - repo: local
       hooks:
         - id: flutter-analyze
           name: Flutter Analyze
           entry: flutter analyze
           language: system
           pass_filenames: false
           
         - id: flutter-format
           name: Flutter Format
           entry: flutter format
           language: system
           types: [dart]
   ```

3. Install pre-commit:
   ```bash
   pip install pre-commit
   pre-commit install
   ```

4. Document quality standards in CONTRIBUTING.md

**Acceptance Criteria**:
- ✅ Pre-commit hooks installed
- ✅ Coverage requirements enforced
- ✅ Quality standards documented

**Time Estimate**: 2 hours

---

### Sprint 5 Deliverables
- ✅ All tests passing
- ✅ CI/CD pipeline operational
- ✅ Code coverage >70%
- ✅ Automated deployments configured
- ✅ Quality gates enforced

**Total Sprint 5 Time**: 22 hours (2.75 days)

---

## Summary Timeline

| Sprint | Focus | Duration | Priority |
|--------|-------|----------|----------|
| **Sprint 1** | Security & Configuration | 1 day | 🔴 Critical |
| **Sprint 2** | Navigation Unification | 2.25 days | 🟡 High |
| **Sprint 3** | Edge Functions & Payment Cleanup | 1.5 days | 🟡 Medium |
| **Sprint 4** | Code Quality & Performance | 1.75 days | 🟢 Medium |
| **Sprint 5** | Testing & CI/CD | 2.75 days | 🟢 High |
| **Total** | | **9.25 days** | |

**Buffer**: 0.75 days for unexpected issues  
**Total with Buffer**: **10 business days (2 weeks)**

---

## Success Metrics

### Security
- ✅ Zero hard-coded credentials in source
- ✅ All secrets in environment variables
- ✅ Git history cleaned

### Architecture
- ✅ Single navigation system
- ✅ Single edge functions directory
- ✅ No payment code

### Quality
- ✅ Zero lint warnings
- ✅ All tests passing
- ✅ Code coverage >70%
- ✅ Performance improved (frame drops <10)

### DevOps
- ✅ CI/CD pipeline operational
- ✅ Automated testing on PRs
- ✅ Branch protection enabled
- ✅ Automated deployments

---

## Risk Mitigation

### High-Risk Areas
1. **Navigation Refactor**: May break existing flows
   - **Mitigation**: Incremental migration, extensive testing
   
2. **Payment Code Removal**: May have hidden dependencies
   - **Mitigation**: Thorough code search, staged removal
   
3. **Test Fixes**: May uncover deeper issues
   - **Mitigation**: Fix incrementally, prioritize critical paths

### Rollback Plan
- Each sprint should be in a separate branch
- Tag stable points for easy rollback
- Keep feature flags for major changes

---

## Post-Completion Checklist

### Documentation
- [ ] All environment variables documented
- [ ] Navigation architecture documented
- [ ] Order flow (cash-only) documented
- [ ] CI/CD setup documented
- [ ] Contributing guidelines updated

### Code Quality
- [ ] `flutter analyze` passes with zero issues
- [ ] All tests passing
- [ ] Code coverage >70%
- [ ] No TODO/FIXME comments without tickets

### Security
- [ ] No credentials in source
- [ ] API keys properly secured
- [ ] Git history cleaned
- [ ] Security audit passed

### Performance
- [ ] Initial load <500ms
- [ ] Frame drops <10 frames
- [ ] Memory usage stable
- [ ] No memory leaks

### Deployment
- [ ] CI/CD pipeline operational
- [ ] Automated tests running
- [ ] Branch protection enabled
- [ ] Deployment process documented

---

## Next Steps After Completion

1. **User Acceptance Testing (UAT)**
   - Test all user flows
   - Verify cash-only order process
   - Test deep linking
   - Performance testing on real devices

2. **Production Deployment**
   - Deploy to staging environment
   - Run smoke tests
   - Deploy to production
   - Monitor for issues

3. **Post-Launch Monitoring**
   - Set up error tracking (Sentry)
   - Monitor performance metrics
   - Track user feedback
   - Plan next iteration

---

## Resources Required

### Team
- 1 Senior Flutter Developer (full-time)
- 1 Backend Developer (part-time for edge functions)
- 1 QA Engineer (part-time for testing)
- 1 DevOps Engineer (part-time for CI/CD)

### Tools
- GitHub Actions (CI/CD)
- Codecov (coverage tracking)
- Sentry (error tracking)
- Firebase App Distribution (beta testing)

### Budget
- Google Maps API costs (estimate usage)
- Supabase hosting (current tier sufficient?)
- CI/CD minutes (GitHub Actions free tier may suffice)

---

## Appendix A: Command Reference

### Development
```bash
# Run app with environment
flutter run --dart-define-from-file=.env

# Analyze code
flutter analyze

# Format code
dart format lib/ test/

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### Supabase
```bash
# Start local Supabase
supabase start

# Deploy function
supabase functions deploy <function-name>

# Run migrations
supabase db push

# Generate types
supabase gen types typescript --local > lib/types/database.types.ts
```

### Git
```bash
# Clean credentials from history (if needed)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch lib/main.dart" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (DANGEROUS - coordinate with team)
git push origin --force --all
```

---

**Plan Owner**: Development Team  
**Reviewers**: Tech Lead, Product Manager  
**Approval Date**: TBD  
**Start Date**: TBD  
**Target Completion**: TBD + 2 weeks

---

*This plan should be reviewed and adjusted based on team capacity and priorities.*
