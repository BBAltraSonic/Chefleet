---
description: Repository Information Overview
alwaysApply: true
---

# Chefleet Information

## Summary
Chefleet is a cross-platform Flutter mobile application with Supabase backend integration. The project includes a Flutter mobile app supporting Android, iOS, Web, Linux, macOS, and Windows platforms, along with TypeScript-based Supabase Edge Functions for serverless backend operations. The application follows comprehensive quality assurance practices with automated CI/CD pipelines, code linting, security scanning, and performance monitoring.

## Structure
**Main Directories**:
- **lib/**: Flutter application source code (Dart)
- **edge-functions/**: Supabase Edge Functions (TypeScript/Deno)
- **android/**: Android native configuration
- **ios/**: iOS native configuration
- **test/**: Flutter unit and widget tests
- **documentation/**: Comprehensive development documentation
- **scripts/**: Quality assurance and database scripts
- **.github/workflows/**: CI/CD automation

### Main Repository Components
- **Flutter Application**: Cross-platform mobile/desktop app built with Dart/Flutter framework
- **Edge Functions**: Serverless TypeScript functions for backend operations (order management, payments, notifications)
- **Android Native Layer**: Kotlin-based Android configuration with Gradle build system
- **iOS Native Layer**: Swift/Objective-C iOS configuration
- **Database Layer**: PostgreSQL with RLS policies and migrations
- **Quality Assurance**: Automated testing, linting, security scanning

## Projects

### Flutter Mobile Application
**Configuration File**: `pubspec.yaml`

#### Language & Runtime
**Language**: Dart  
**SDK Version**: ^3.9.2  
**Framework**: Flutter (stable channel)  
**Package Manager**: pub (Flutter Package Manager)  
**Build System**: Flutter CLI / Dart SDK

#### Dependencies
**Main Dependencies**:
- `flutter` (SDK)
- `cupertino_icons` (^1.0.8) - iOS-style icons

**Development Dependencies**:
- `flutter_test` (SDK)
- `flutter_lints` (^5.0.0) - Code analysis and linting

#### Build & Installation
```bash
flutter pub get
flutter pub dev
flutter run
flutter build apk --release
flutter build appbundle --release
flutter build web --release
flutter build ios --release
```

#### Testing
**Framework**: flutter_test (built-in)  
**Test Location**: `test/` directory  
**Naming Convention**: `*_test.dart`, `widget_test.dart`  
**Configuration**: `analysis_options.yaml`  
**Run Command**:
```bash
flutter test
flutter test --coverage --reporter=expanded
flutter analyze
```

### Android Application
**Configuration File**: `android/app/build.gradle.kts`

#### Language & Runtime
**Language**: Kotlin  
**Build System**: Gradle with Kotlin DSL  
**Java Version**: 11 (sourceCompatibility & targetCompatibility)  
**Kotlin JVM Target**: 11  
**Package**: com.example.chefleet

#### Build & Installation
```bash
cd android
./gradlew clean
./gradlew assembleRelease
./gradlew bundleRelease
```

### Supabase Edge Functions
**Type**: TypeScript/Deno Serverless Functions

#### Language & Runtime
**Runtime**: Deno  
**Language**: TypeScript  
**Framework**: Supabase Functions  
**Main Package**: `@supabase/functions-js`, `@supabase/supabase-js@2`

#### Key Resources
**Edge Functions**:
- `change_order_status/index.ts` - Order status management
- `create_order/index.ts` - Order creation logic
- `generate_pickup_code/index.ts` - Pickup code generation
- `process_payment_webhook/index.ts` - Payment webhook processing
- `report_user/index.ts` - User reporting functionality
- `send_push/index.ts` - Push notification service
- `upload_image_signed_url/index.ts` - Image upload URL generation

#### Usage & Operations
**Deployment**:
```bash
supabase functions deploy <function-name>
```

**Local Development**:
```bash
supabase start
supabase functions serve
```

#### Validation
**Linting**: ESLint with TypeScript support (`.eslintrc.js`)  
**Code Style**: 2-space indentation, single quotes, semicolons  
**Security Rules**: No eval, no implied-eval, no script-url

### Database & Scripts
**Type**: PostgreSQL with Row Level Security

#### Key Resources
**Migration Scripts**: `migrations/` directory  
**Security Scripts**:
- `scripts/rls_policies.sql` - Row Level Security policies
- `scripts/test_rls_policies.sql` - RLS policy tests
- `scripts/create_test_accounts.sql` - Test account creation

#### Validation
**SQL Linting**: SQLFluff (`.sqlfluff` config)  
**Testing**: `scripts/rls_security_test_plan.md`  
**Quality Checks**: `scripts/quality-gate-check.sh`

### CI/CD Pipeline
**Configuration**: `.github/workflows/ci.yml`, `.github/workflows/release.yml`

#### Workflow Stages
**Quality Checks**:
- Code formatting verification
- Flutter analyze
- Dart code metrics
- ESLint for TypeScript

**Security Scanning**:
- Dependency vulnerability scanning
- SAST analysis
- License compliance checks

**Testing**:
- Unit tests (`flutter test`)
- Widget tests
- Integration tests (`integration_test/`)
- Performance tests (`test/performance/`)
- Coverage reporting

**Build Verification**:
- Android APK & App Bundle
- iOS build
- Web build (size limit: 5MB)
- Multi-platform builds

**Deployment**:
- Automated releases
- Version tagging
- Build artifact storage

#### Usage & Operations
**Pre-commit Hooks**: `.pre-commit-config.yaml` - Automated quality checks before commits  
**Dependency Management**: `DEPENDENCY_POLICY.md` - Security-first dependency policy with Dependabot automation  
**Development Guide**: `LOCAL_DEVELOPMENT.md` - Comprehensive setup instructions  
**Release Process**: `RELEASE_PROCEDURE.md` - Step-by-step release guidelines
