# Immediate Action Checklist - Start Here! 🚀

**Created**: 2025-11-22  
**Priority**: CRITICAL  
**Time to Complete**: 1 day

---

## 🔴 CRITICAL: Security Fix (Do This First!)

### Task 1: Secure Supabase Credentials (2-3 hours)

#### Step 1: Add flutter_dotenv package
```bash
flutter pub add flutter_dotenv
```

#### Step 2: Create .env file
```bash
# Create .env file (DO NOT COMMIT THIS)
cat > .env << EOF
SUPABASE_URL=your_actual_supabase_url
SUPABASE_ANON_KEY=your_actual_anon_key
GOOGLE_MAPS_API_KEY=your_maps_key
EOF
```

#### Step 3: Create .env.example
```bash
# Create .env.example (COMMIT THIS)
cat > .env.example << EOF
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
GOOGLE_MAPS_API_KEY=your_google_maps_key_here
EOF
```

#### Step 4: Update .gitignore
Add to `.gitignore`:
```gitignore
# Environment files
.env
.env.local
.env.*.local
```

#### Step 5: Update pubspec.yaml
Add to `flutter:` section:
```yaml
flutter:
  assets:
    - .env
```

#### Step 6: Update lib/main.dart
Replace the hard-coded credentials section with:

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

#### Step 7: Test
```bash
flutter run
# Verify app still works
```

#### Step 8: Clean Git History (if credentials were committed)
⚠️ **WARNING**: This rewrites history. Coordinate with team first!

```bash
# Backup first!
git branch backup-before-cleanup

# Remove credentials from history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch lib/main.dart" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (coordinate with team!)
git push origin --force --all
```

#### Verification Checklist
- [ ] `.env` file created and populated
- [ ] `.env.example` committed
- [ ] `.env` added to .gitignore
- [ ] `flutter_dotenv` added to pubspec.yaml
- [ ] `.env` added to assets in pubspec.yaml
- [ ] `lib/main.dart` updated to use dotenv
- [ ] App runs successfully
- [ ] No credentials visible in source code
- [ ] Git history cleaned (if needed)

---

## 🟡 HIGH PRIORITY: Quick Wins (Rest of Day 1)

### Task 2: Fix Lint Warnings (30 minutes)

Open `lib/features/dish/screens/dish_detail_screen.dart` and apply these fixes:

#### Fix 1: Remove dead code (line 82)
```dart
// BEFORE:
final dishResponse = await supabase
    .from('dishes')
    .select('...')
    .eq('id', widget.dishId)
    .single();

if (dishResponse == null) {  // ❌ This is dead code
  throw Exception('Dish not found');
}

// AFTER:
try {
  final dishResponse = await supabase
      .from('dishes')
      .select('...')
      .eq('id', widget.dishId)
      .single();
  // Process response...
} catch (e) {
  throw Exception('Dish not found: $e');
}
```

#### Fix 2: Remove unnecessary null checks
Find and fix these patterns:

```dart
// Line ~294: Remove unnecessary null check
// BEFORE:
if (_dish != null && _dish!.imageUrl != null) {
  // ...
}

// AFTER:
if (_dish.imageUrl != null) {
  // ...
}

// Line ~304: Remove unnecessary ! operator
// BEFORE:
Text(_dish!.name)

// AFTER:
Text(_dish.name)

// Line ~468: Replace ?. with .
// BEFORE:
vendor?.name

// AFTER:
vendor.name
```

#### Verification
```bash
flutter analyze
# Should show fewer warnings
```

---

### Task 3: Configure Google Maps API Key (1 hour)

#### For Android
1. Open `android/app/src/main/AndroidManifest.xml`
2. Add inside `<application>` tag:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}"/>
```

3. Open `android/app/build.gradle`
4. Add in `defaultConfig`:
```gradle
defaultConfig {
    // ... existing config
    
    // Load from .env
    def envFile = rootProject.file('../.env')
    if (envFile.exists()) {
        def env = new Properties()
        envFile.withInputStream { env.load(it) }
        manifestPlaceholders = [
            GOOGLE_MAPS_API_KEY: env.getProperty('GOOGLE_MAPS_API_KEY', '')
        ]
    }
}
```

#### For iOS
1. Open `ios/Runner/AppDelegate.swift`
2. Add at the top:
```swift
import GoogleMaps
```

3. Add in `application(_:didFinishLaunchingWithOptions:)`:
```swift
// Load API key from environment
if let path = Bundle.main.path(forResource: ".env", ofType: nil),
   let contents = try? String(contentsOfFile: path),
   let apiKey = contents.components(separatedBy: "\n")
       .first(where: { $0.hasPrefix("GOOGLE_MAPS_API_KEY=") })?
       .replacingOccurrences(of: "GOOGLE_MAPS_API_KEY=", with: "") {
    GMSServices.provideAPIKey(apiKey)
}
```

#### Verification
```bash
flutter run
# Check logs - should not see "Maps API key: null"
```

---

### Task 4: Create Documentation (30 minutes)

#### Create docs/ENVIRONMENT_SETUP.md
```markdown
# Environment Setup

## Prerequisites
- Flutter 3.35.5+
- Dart 3.9.2+
- Supabase account
- Google Cloud account (for Maps API)

## Setup Steps

1. Clone repository
2. Copy `.env.example` to `.env`
3. Fill in your credentials:
   - Get Supabase URL and anon key from your Supabase project settings
   - Get Google Maps API key from Google Cloud Console
4. Run `flutter pub get`
5. Run `flutter run`

## Troubleshooting

### App won't start
- Check that `.env` file exists
- Verify all keys are filled in
- Run `flutter clean && flutter pub get`

### Maps not loading
- Verify Google Maps API key is correct
- Check that Maps SDK is enabled in Google Cloud Console
- Ensure billing is enabled for your Google Cloud project
```

#### Update README.md
Add a section at the top:
```markdown
## Quick Start

1. **Set up environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

For detailed setup instructions, see [docs/ENVIRONMENT_SETUP.md](docs/ENVIRONMENT_SETUP.md)
```

---

## End of Day 1 Checklist

- [ ] ✅ Credentials secured (no hard-coded secrets)
- [ ] ✅ Lint warnings fixed
- [ ] ✅ Google Maps API configured
- [ ] ✅ Documentation updated
- [ ] ✅ App runs successfully
- [ ] ✅ Changes committed to git
- [ ] ✅ `.env.example` committed (but NOT `.env`)

---

## What's Next? (Day 2+)

After completing these immediate tasks, proceed with the full [CRITICAL_REMEDIATION_PLAN.md](./CRITICAL_REMEDIATION_PLAN.md):

1. ✅ **Sprint 2**: Navigation Unification (COMPLETE)
2. ✅ **Sprint 3**: Edge Functions & Payment Cleanup (COMPLETE)
3. **Sprint 4**: Code Quality & Performance (1-2 days) - NEXT
4. **Sprint 5**: Testing & CI/CD (2-3 days)

---

## Need Help?

### Common Issues

**Q: App crashes after environment changes**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

**Q: Can't find my Supabase credentials**
- Go to your Supabase project dashboard
- Click on Settings → API
- Copy the URL and anon/public key

**Q: Google Maps not working**
- Ensure Maps SDK for Android/iOS is enabled
- Check API key restrictions in Google Cloud Console
- Verify billing is enabled

**Q: Git history cleanup seems scary**
- It is! Make a backup branch first
- Coordinate with your team
- Consider just moving forward with secured code if history cleanup is too risky

---

## Success Criteria

By end of Day 1, you should have:
- ✅ No credentials in source code
- ✅ App running with environment variables
- ✅ Maps loading correctly
- ✅ Zero critical lint warnings
- ✅ Documentation for new developers

**Estimated Time**: 4-5 hours of focused work

---

*Let's get started! 🚀*
