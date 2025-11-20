# Environment Configuration

This document describes how to configure the Chefleet application using environment variables.

## Required Environment Variables

The application requires the following environment variables to be set:

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous/public key

## Development Setup

### Running the Application

Use the `--dart-define` flag to pass environment variables when running the app:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### Building the Application

#### Android

```bash
flutter build apk \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

```bash
flutter build appbundle \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

#### iOS

```bash
flutter build ios \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

#### Web

```bash
flutter build web \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### Running Tests

Tests also require environment variables:

```bash
flutter test \
  --dart-define=SUPABASE_URL=https://your-test-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-test-anon-key
```

## IDE Configuration

### VS Code

Create a `.vscode/launch.json` file (not tracked in git):

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Chefleet (Development)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=SUPABASE_URL=https://your-project.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=your-anon-key"
      ]
    }
  ]
}
```

### Android Studio / IntelliJ

1. Go to **Run** → **Edit Configurations**
2. Select your run configuration
3. In the **Additional run args** field, add:
   ```
   --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

## CI/CD Configuration

### GitHub Actions

Store credentials as GitHub Secrets and pass them to the build:

```yaml
- name: Build APK
  env:
    SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
    SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
  run: |
    flutter build apk \
      --dart-define=SUPABASE_URL=$SUPABASE_URL \
      --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

## Security Notes

- **Never commit** environment variables to version control
- Use different Supabase projects for development, staging, and production
- For production builds, ensure credentials are managed securely through your CI/CD platform
- The `.vscode/launch.json` file is gitignored to prevent accidental credential commits
- Test credentials should be for a separate test environment, never production

## Obtaining Supabase Credentials

1. Go to your Supabase project dashboard
2. Click on **Settings** → **API**
3. Copy the **Project URL** (this is your `SUPABASE_URL`)
4. Copy the **anon/public key** (this is your `SUPABASE_ANON_KEY`)

## Troubleshooting

### Missing Environment Variables Error

If you see the error:
```
Missing required environment variables. Please provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.
```

This means you forgot to pass the environment variables. Use the `--dart-define` flags as shown above.

### Empty Environment Variables

If environment variables are being read as empty strings:

1. Ensure there are no typos in the variable names
2. Check that you're using the correct syntax for your platform
3. For CI/CD, verify that secrets are properly configured and exposed
