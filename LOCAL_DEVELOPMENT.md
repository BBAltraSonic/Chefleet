# Local Development Guide

This guide provides comprehensive instructions for setting up and working with the Chefleet project locally.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Flutter Development](#flutter-development)
3. [Supabase Edge Functions](#supabase-edge-functions)
4. [Database Development](#database-development)
5. [Local Supabase Emulator](#local-supabase-emulator)
6. [Development Workflow](#development-workflow)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools
- **Flutter SDK**: 3.16.0 or higher
- **Dart SDK**: 3.2.0 or higher (included with Flutter)
- **Git**: 2.30.0 or higher
- **Node.js**: 18.0.0 or higher (for Edge Functions)
- **Supabase CLI**: 1.50.0 or higher
- **Docker**: 20.10.0 or higher (for local Supabase)

### IDE/Editor Setup
- **VS Code** (recommended) with Flutter and Dart extensions
- **Android Studio** with Flutter plugin (alternative)
- **IntelliJ IDEA** with Flutter plugin (alternative)

### Platform-Specific Requirements
- **iOS Development**: Xcode 14.0+, iOS Simulator
- **Android Development**: Android Studio, Android SDK
- **Web Development**: Chrome (for testing)

## Flutter Development

### Environment Setup

1. **Install Flutter SDK**
   ```bash
   # Download Flutter from https://flutter.dev/docs/get-started/install
   # Extract to ~/development/flutter or equivalent
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

2. **Verify Installation**
   ```bash
   flutter doctor
   flutter doctor -v  # Detailed version info
   ```

3. **Set Up Development Environment**
   ```bash
   # Clone the repository
   git clone <repository-url> chefleet
   cd chefleet

   # Get dependencies
   flutter pub get

   # Install development dependencies
   flutter pub dev
   ```

### Running the App

1. **Check Available Devices**
   ```bash
   flutter devices
   ```

2. **Run on Specific Device**
   ```bash
   # Web
   flutter run -d chrome

   # iOS Simulator
   flutter run -d "iPhone 14"

   # Android Emulator
   flutter run -d "Pixel 6"

   # Use first available device
   flutter run
   ```

3. **Debug Mode with Hot Reload**
   ```bash
   # Start with hot reload enabled
   flutter run --hot

   # Manual hot reload (press 'r' in terminal)
   flutter run
   # Press 'r' for hot reload, 'R' for hot restart
   ```

### Development Commands

```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format .

# Build for different platforms
flutter build apk
flutter build ios
flutter build web
```

### Flutter Debugging

1. **Debug Panel in VS Code**
   - Set breakpoints in VS Code
   - Use Flutter: Attach to Device
   - View variables and call stack

2. **Debug Prints**
   ```dart
   debugPrint('Debug info: $variable');
   print('Info: $variable');  // Production prints (be careful)
   ```

3. **Flutter Inspector**
   - Use in VS Code or Android Studio
   - Inspect widget tree
   - Modify widget properties at runtime

4. **Logging**
   ```dart
   import 'package:flutter/foundation.dart';

   if (kDebugMode) {
     print('Debug only information');
   }
   ```

## Supabase Edge Functions

### Environment Setup

1. **Install Supabase CLI**
   ```bash
   # macOS
   brew install supabase/tap/supabase

   # Windows
   scoop install supabase

   # Linux
   curl -L https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.tar.gz | tar xz
   sudo mv supabase /usr/local/bin/
   ```

2. **Login to Supabase**
   ```bash
   supabase login
   ```

3. **Link to Project**
   ```bash
   supabase link --project-ref <your-project-ref>
   ```

### Local Development

1. **Start Local Development**
   ```bash
   # Start Supabase services locally
   supabase start

   # Start specific services
   supabase start db auth storage edge-functions
   ```

2. **Edge Functions Development**
   ```bash
   # Create new Edge Function
   supabase functions new <function-name>

   # Develop locally
   supabase functions serve --env-file .env.local

   # Deploy to production
   supabase functions deploy <function-name>
   ```

3. **Environment Variables**
   ```bash
   # .env.local for development
   SUPABASE_URL=http://localhost:54321
   SUPABASE_ANON_KEY=your-local-anon-key
   SUPABASE_SERVICE_ROLE_KEY=your-local-service-role-key
   ```

### Edge Functions Testing

```bash
# Test locally with curl
curl -i -X POST 'http://localhost:54321/functions/v1/<function-name>' \
  -H 'Authorization: Bearer your-anon-key' \
  -H 'Content-Type: application/json' \
  -d '{ "key": "value" }'

# Use the Supabase CLI to invoke functions
supabase functions invoke <function-name> --data '{"key":"value"}'
```

## Database Development

### Local Database Setup

1. **Start Local Supabase**
   ```bash
   supabase start
   ```

2. **Access Local Database**
   - **URL**: `postgresql://postgres:postgres@localhost:54322/postgres`
   - **Studio**: `http://localhost:54323`
   - **API URL**: `http://localhost:54321`

### Creating Migrations

1. **Create New Migration**
   ```bash
   supabase migration new <migration-name>
   ```

2. **Write Migration SQL**
   ```sql
   -- supabase/migrations/20240101_create_users_table.sql
   CREATE TABLE users (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     email TEXT UNIQUE NOT NULL,
     created_at TIMESTAMPTZ DEFAULT NOW()
   );
   ```

3. **Apply Migrations Locally**
   ```bash
   supabase db push
   ```

4. **Reset Database**
   ```bash
   supabase db reset
   ```

### Database Development Workflow

```bash
# 1. Start local development
supabase start

# 2. Make schema changes in Studio or SQL editor
# (Go to http://localhost:54323)

# 3. Generate migration from changes
supabase db diff --schema public --use-migra -f migration_name

# 4. Test migration
supabase migration up

# 5. Deploy to staging/production
supabase db push
```

### Database Testing

```bash
# Run specific migration
supabase migration up migration_name

# Check migration status
supabase migration list

# Generate types
supabase gen types typescript --local > types.ts
```

## Local Supabase Emulator

### Complete Local Setup

1. **Initialize Supabase Project**
   ```bash
   # If not already initialized
   supabase init

   # Start all services
   supabase start
   ```

2. **Service URLs (Local)**
   ```bash
   # Studio (UI)
   Studio URL: http://localhost:54323

   # API URLs
   API URL: http://localhost:54321
   API REST URL: http://localhost:54321/rest/v1/
   GraphQL URL: http://localhost:54321/graphql/v1/

   # Database
   DB URL: postgresql://postgres:postgres@localhost:54322/postgres

   # Auth
   Auth URL: http://localhost:54321/auth/v1/

   # Storage
   Storage URL: http://localhost:54321/storage/v1

   # Edge Functions
   Edge Functions URL: http://localhost:54321/functions/v1/
   ```

3. **Environment Configuration**
   ```bash
   # Copy local environment variables
   supabase status

   # Export for shell session
   export SUPABASE_URL=http://localhost:54321
   export SUPABASE_ANON_KEY=$(supabase status | grep "anon key" | awk '{print $3}')
   ```

### Managing Local Services

```bash
# Check status
supabase status

# Stop services
supabase stop

# Stop and delete data
supabase stop --no-backup

# Restart services
supabase restart

# View logs
supabase logs

# Access database directly
psql 'postgresql://postgres:postgres@localhost:54322/postgres'
```

## Development Workflow

### Daily Workflow

1. **Morning Setup**
   ```bash
   # Start local services
   supabase start

   # Get latest changes
   git pull origin main

   # Update dependencies
   flutter pub get
   ```

2. **Development**
   ```bash
   # Start Flutter app
   flutter run

   # Make changes in separate terminal
   # Hot reload will update automatically
   ```

3. **Before Commit**
   ```bash
   # Run all checks
   pre-commit run --all-files

   # Run tests
   flutter test

   # Check formatting
   dart format .
   ```

### Feature Development

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/new-feature
   ```

2. **Development Steps**
   ```bash
   # Make changes
   # Test locally
   flutter test

   # Check code quality
   flutter analyze
   dart format .

   # Commit with conventional commit
   git commit -m "feat(auth): add user login functionality"
   ```

3. **Push and Create PR**
   ```bash
   git push origin feature/new-feature
   # Create PR in GitHub with the provided template
   ```

### Pre-commit Hooks

The project includes pre-commit hooks that run automatically:

```bash
# Install hooks (one-time setup)
pre-commit install

# Run manually on all files
pre-commit run --all-files

# Run on staged files only
pre-commit run
```

### Code Quality Checks

```bash
# Flutter-specific
flutter analyze
flutter test
dart format .

# SQL formatting
sqlfluff fix path/to/migrations/

# Edge Functions linting
npx eslint functions/
```

## Troubleshooting

### Common Flutter Issues

1. **"flutter command not found"**
   ```bash
   # Add Flutter to PATH
   export PATH="$PATH:/path/to/flutter/bin"
   # Add to ~/.zshrc or ~/.bashrc for permanence
   ```

2. **"Unable to locate Android SDK"**
   ```bash
   # Set ANDROID_HOME environment variable
   export ANDROID_HOME=$HOME/Library/Android/sdk
   export PATH=$PATH:$ANDROID_HOME/emulator
   export PATH=$PATH:$ANDROID_HOME/tools
   export PATH=$PATH:$ANDROID_HOME/tools/bin
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   ```

3. **"pod install fails" (iOS)**
   ```bash
   cd ios
   pod install --repo-update
   cd ..
   ```

4. **Gradle build fails (Android)**
   ```bash
   # Clean build
   flutter clean
   flutter pub get
   flutter build apk --debug
   ```

### Common Supabase Issues

1. **"supabase start fails"**
   ```bash
   # Check Docker is running
   docker --version

   # Check available ports
   netstat -an | grep 54321

   # Reset Docker
   docker system prune -a
   ```

2. **"Database connection refused"**
   ```bash
   # Check Supabase status
   supabase status

   # Restart services
   supabase restart
   ```

3. **"Migration fails to apply"**
   ```bash
   # Check current migration status
   supabase migration list

   # Reset and restart
   supabase db reset
   supabase db push
   ```

### Pre-commit Hook Issues

1. **"pre-commit: command not found"**
   ```bash
   # Install pre-commit
   pip install pre-commit

   # Or with Homebrew (macOS)
   brew install pre-commit
   ```

2. **"Hook fails unexpectedly"**
   ```bash
   # Run hook manually for debugging
   pre-commit run <hook-id> --verbose

   # Skip specific hook (temporary)
   git commit --no-verify -m "commit message"
   ```

### Performance Issues

1. **Flutter app slow startup**
   ```bash
   # Use profile mode for performance testing
   flutter run --profile

   # Check for unnecessary rebuilds
   flutter run --trace-startup --profile
   ```

2. **Hot reload not working**
   ```bash
   # Restart Flutter
   flutter clean
   flutter pub get
   flutter run
   ```

### Getting Help

1. **Check logs**
   ```bash
   # Flutter logs
   flutter logs

   # Supabase logs
   supabase logs

   # Pre-commit logs
   pre-commit run --all-files --verbose
   ```

2. **Verify environment**
   ```bash
   flutter doctor -v
   supabase status
   node --version
   npm --version
   ```

3. **Community resources**
   - [Flutter Documentation](https://flutter.dev/docs)
   - [Supabase Documentation](https://supabase.com/docs)
   - Project GitHub Issues
   - Team communication channels

## Environment Variables Reference

### Development Environment

```bash
# Flutter Environment (optional)
FLUTTER_ROOT=/path/to/flutter
PUB_CACHE=~/.pub-cache

# Supabase Local
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=your-local-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-local-service-role-key
SUPABASE_DB_URL=postgresql://postgres:postgres@localhost:54322/postgres

# Google Maps (if using locally)
GOOGLE_MAPS_API_KEY=your-api-key
```

### VS Code Settings

```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "files.associations": {
    "*.sql": "sql"
  },
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  }
}
```