# Environment Setup Guide

This guide explains how to set up and manage environment variables for the Chefleet project.

## Overview

To keep sensitive information like API keys secure, we use environment variables stored in a `.env` file. This file is **never committed to version control** and is already included in `.gitignore`.

## Quick Setup

1. **Copy the template file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the .env file with your actual values:**
   ```bash
   nano .env  # or use your preferred editor
   ```

3. **Replace the placeholder values:**
   - `MAPS_API_KEY`: Your Google Maps API key
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_ANON_KEY`: Your Supabase anonymous key
   - `SUPABASE_SERVICE_ROLE_KEY`: Your Supabase service role key

## Required API Keys

### Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - **Maps SDK for Android** - Required for map functionality
   - **Places API** - Required for place search and autocomplete
   - **Directions API** - Required for routing (if using)
4. Create credentials:
   - Click "Create Credentials" > "API Key"
   - Restrict the key to Android apps only
   - Add your app's package name and SHA-1 certificate fingerprint
5. Copy the API key to your `.env` file

### Supabase Configuration

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Navigate to **Settings > API**
4. Copy the following values:
   - **Project URL** (SUPABASE_URL)
   - **anon** public key (SUPABASE_ANON_KEY)
   - **service_role** key (SUPABASE_SERVICE_ROLE_KEY)

## Security Best Practices

### ✅ Do
- Keep your `.env` file private and never share it
- Use different API keys for development and production
- Regularly rotate your API keys
- Restrict API keys to only the services they need
- Use IP restrictions where possible

### ❌ Don't
- Commit the `.env` file to version control
- Share API keys in public repositories
- Use production keys in development
- Leave API keys unrestricted

## Environment Priority

The build system reads environment variables in this priority order:

1. **`.env` file** (highest priority)
2. **`local.properties` file** (fallback for backward compatibility)
3. **Default empty string** (lowest priority)

This means if you have values in both `.env` and `local.properties`, the `.env` values will be used.

## Build Integration

The Android build system automatically reads from your `.env` file and makes the values available as BuildConfig fields. This means:

- No manual configuration required
- Values are available in your Android code via `BuildConfig.MAPS_API_KEY`
- Secure and automated integration

## Troubleshooting

### API Key Not Working

1. **Check the key format**: Ensure there are no extra spaces or characters
2. **Verify API permissions**: Make sure all required APIs are enabled
3. **Check key restrictions**: Ensure your Android package is added to the restrictions
4. **Clean rebuild**: Run `flutter clean && flutter pub get && flutter run`

### Build Errors

1. **Missing .env file**: Copy from `.env.example` if you don't have one
2. **Permission issues**: Ensure the `.env` file is readable
3. **Format errors**: Check for syntax errors in your `.env` file

### Security Concerns

If you accidentally commit your `.env` file:

1. **Immediately revoke** all exposed API keys
2. **Create new API keys**
3. **Remove the commit** if possible (use `git filter-branch` or similar)
4. **Add the key to GitHub's secret scanning**

## File Structure

```
chefleet/
├── .env                 # Your secrets (NEVER committed)
├── .env.example         # Template file (safe to share)
├── .gitignore          # Contains .env to prevent commits
├── android/
│   ├── app/
│   │   ├── build.gradle.kts    # Reads from .env
│   │   └── src/main/AndroidManifest.xml
│   └── local.properties       # Fallback location
└── docs/
    └── ENVIRONMENT_SETUP.md   # This file
```

## Support

If you need help with environment setup:

1. Check the [Flutter documentation](https://flutter.dev/docs)
2. Review the [Google Maps API documentation](https://developers.google.com/maps/documentation)
3. Consult the [Supabase documentation](https://supabase.com/docs)
4. Contact your development team for project-specific questions