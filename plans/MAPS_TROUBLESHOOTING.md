# Google Maps Not Rendering - Troubleshooting Guide

**Issue**: Map appears blank/gray or doesn't render  
**Status**: 🔴 NEEDS VERIFICATION  
**Date**: 2025-11-23

---

## Current Configuration

### API Key Status
- ✅ API Key present in `.env`: `AIzaSyDWJBaF47Fp11LrWTBsQEnospLdCglfmdQ`
- ✅ API Key present in `android/local.properties`
- ✅ AndroidManifest configured correctly
- ⏳ API Key validity: **NEEDS VERIFICATION**

### Configuration Files

**`.env`**:
```env
MAPS_API_KEY=AIzaSyDWJBaF47Fp11LrWTBsQEnospLdCglfmdQ
```

**`android/local.properties`**:
```properties
GOOGLE_MAPS_API_KEY=AIzaSyDWJBaF47Fp11LrWTBsQEnospLdCglfmdQ
```

**`android/app/src/main/AndroidManifest.xml`**:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${MAPS_API_KEY}"/>
```

---

## Common Causes & Solutions

### 1. API Key Not Enabled for Maps SDK ⚠️ MOST LIKELY

**Symptom**: Blank/gray map, no error in console

**Solution**:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to **APIs & Services** > **Library**
4. Search for "Maps SDK for Android"
5. Click on it and ensure it's **ENABLED**
6. Also enable:
   - **Maps SDK for Android** ✅
   - **Places API** (optional, for search)
   - **Directions API** (optional, for routing)

**How to verify**:
```bash
# Check if API is enabled via gcloud CLI
gcloud services list --enabled --project=YOUR_PROJECT_ID | grep maps
```

---

### 2. Billing Not Enabled 💳 CRITICAL

**Symptom**: Map loads briefly then goes blank

**Solution**:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **Billing**
3. Link a billing account to your project
4. **Note**: Google provides $200/month free credit for Maps

**Why this matters**:
- Google Maps requires billing even for free tier
- Without billing, maps won't render
- You won't be charged unless you exceed free tier

---

### 3. API Key Restrictions Mismatch 🔒

**Symptom**: Authorization error in logs

**Current App Details**:
- Package name: `com.example.chefleet`
- SHA-1 fingerprint: `B2:AB:8A:CA:67:D3:06:08:6D:2E:82:37:1C:21:A5:C4:89:4F:B3:B3`

**Solution**:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** > **Credentials**
3. Click on your API key
4. Under **Application restrictions**:
   - Select "Android apps"
   - Add package name: `com.example.chefleet`
   - Add SHA-1: `B2:AB:8A:CA:67:D3:06:08:6D:2E:82:37:1C:21:A5:C4:89:4F:B3:B3`

**Get your SHA-1 fingerprint**:
```bash
# Debug keystore (for development)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Or use Gradle
cd android
./gradlew signingReport
```

---

### 4. API Key Quota Exceeded 📊

**Symptom**: Map worked before, now doesn't

**Solution**:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** > **Dashboard**
3. Check quota usage for Maps SDK
4. If exceeded, either:
   - Wait for quota reset (daily)
   - Increase quota limits
   - Enable billing for higher limits

---

### 5. Network/Firewall Issues 🌐

**Symptom**: Map doesn't load, network errors in logs

**Solution**:
1. Check internet connectivity
2. Verify emulator has internet access:
   ```bash
   adb shell ping google.com
   ```
3. Check if corporate firewall blocks Google Maps
4. Try on different network

---

### 6. Incorrect API Key Format ⚠️

**Symptom**: Authorization failure

**Verification**:
```bash
# API key should be 39 characters
# Format: AIza[35 more characters]
echo "AIzaSyDWJBaF47Fp11LrWTBsQEnospLdCglfmdQ" | wc -c
# Should output: 40 (39 + newline)
```

**Current key**: ✅ Correct format (39 chars)

---

## Verification Steps

### Step 1: Verify API Key in Google Cloud Console

1. Go to: https://console.cloud.google.com/apis/credentials
2. Find your API key: `AIzaSyDWJBaF47Fp11LrWTBsQEnospLdCglfmdQ`
3. Check:
   - [ ] Key exists
   - [ ] Key is not restricted OR restricted to correct app
   - [ ] Maps SDK for Android is enabled
   - [ ] Billing is enabled

### Step 2: Test API Key Directly

Use this URL in a browser to test the API key:
```
https://maps.googleapis.com/maps/api/staticmap?center=37.7749,-122.4194&zoom=13&size=600x300&key=AIzaSyDWJBaF47Fp11LrWTBsQEnospLdCglfmdQ
```

**Expected**: Should show a map image of San Francisco  
**If fails**: API key is invalid or not configured correctly

### Step 3: Check App Logs

Look for these error messages:
```
E/Google Android Maps SDK: Authorization failure
E/Google Android Maps SDK: API Key: [your key]
E/Google Android Maps SDK: Android Application: [fingerprint];[package]
```

### Step 4: Verify Build Configuration

Check that the API key is being injected:
```bash
# Check build output
flutter run -d emulator-5554 2>&1 | grep -i "maps api"

# Should show:
# Maps API key from .env: AIzaSyDWJBaF47Fp11LrWTBsQEnospLdCglfmdQ
# Final maps API key: AIzaSyDWJBaF47Fp11LrWTBsQEnospLdCglfmdQ
```

---

## Quick Fixes to Try

### Fix 1: Clean Rebuild
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

### Fix 2: Invalidate Caches
```bash
# Delete build artifacts
rm -rf build/
rm -rf android/build/
rm -rf android/app/build/

# Rebuild
flutter run
```

### Fix 3: Use Unrestricted API Key (Testing Only)

**WARNING**: Only for testing, not production!

1. Create a new API key in Google Cloud Console
2. Don't add any restrictions
3. Replace in `.env` file
4. Rebuild and test

If this works, the issue is with API key restrictions.

### Fix 4: Enable All Required APIs

Run these commands (requires gcloud CLI):
```bash
gcloud services enable maps-android-backend.googleapis.com
gcloud services enable places-backend.googleapis.com
gcloud services enable directions-backend.googleapis.com
```

---

## Alternative: Create New API Key

If the current key doesn't work, create a new one:

### Step-by-Step:

1. **Go to Google Cloud Console**
   - https://console.cloud.google.com/

2. **Create/Select Project**
   - Create new project: "Chefleet"
   - Or select existing project

3. **Enable Billing**
   - Navigate to Billing
   - Link a billing account
   - (Required even for free tier)

4. **Enable APIs**
   - Go to APIs & Services > Library
   - Enable "Maps SDK for Android"
   - Enable "Places API" (optional)

5. **Create API Key**
   - Go to APIs & Services > Credentials
   - Click "Create Credentials" > "API Key"
   - Copy the key

6. **Restrict API Key** (Recommended)
   - Click on the key
   - Under "Application restrictions":
     - Select "Android apps"
     - Add package: `com.example.chefleet`
     - Add SHA-1: `B2:AB:8A:CA:67:D3:06:08:6D:2E:82:37:1C:21:A5:C4:89:4F:B3:B3`
   - Under "API restrictions":
     - Select "Restrict key"
     - Select "Maps SDK for Android"
   - Save

7. **Update `.env` File**
   ```env
   MAPS_API_KEY=YOUR_NEW_API_KEY_HERE
   ```

8. **Update `android/local.properties`**
   ```properties
   GOOGLE_MAPS_API_KEY=YOUR_NEW_API_KEY_HERE
   ```

9. **Rebuild**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## Debugging Commands

### Check if API key is in APK
```bash
# Build APK
flutter build apk --debug

# Extract and check
unzip -p build/app/outputs/flutter-apk/app-debug.apk AndroidManifest.xml | grep -a "API_KEY"
```

### Check runtime logs
```bash
# Filter for Maps-related logs
adb logcat | grep -i "maps\|google"

# Look for authorization errors
adb logcat | grep -i "authorization\|api.*key"
```

### Test Maps SDK directly
Create a minimal test:
```dart
// test_maps.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 13,
  ),
  onMapCreated: (controller) {
    print('✅ Map created successfully!');
  },
  onCameraMove: (position) {
    print('✅ Map is interactive!');
  },
)
```

---

## Expected Behavior vs Current

### Expected (Working Map)
```
✅ Map tiles load
✅ Can zoom/pan
✅ Markers appear
✅ Location button works
✅ No authorization errors
```

### Current (Not Working)
```
❌ Map appears blank/gray
❌ No tiles loading
❌ May show "For development purposes only" watermark
❌ Authorization errors in logs
```

---

## Google Cloud Console Checklist

Visit: https://console.cloud.google.com/

- [ ] Project created
- [ ] Billing enabled (required!)
- [ ] Maps SDK for Android enabled
- [ ] API key created
- [ ] API key restrictions configured (or unrestricted for testing)
- [ ] API key copied to `.env` and `local.properties`
- [ ] App rebuilt after configuration

---

## Contact Google Support

If none of the above works:

1. **Check Google Maps Platform Status**
   - https://status.cloud.google.com/

2. **Google Maps Platform Support**
   - https://developers.google.com/maps/support

3. **Stack Overflow**
   - Tag: `google-maps-android`
   - Include: API key (first/last 4 chars only), error logs

---

## Temporary Workaround

While debugging Maps, you can use a fallback UI:

```dart
// In map_screen.dart
if (state.mapError != null) {
  return Column(
    children: [
      Icon(Icons.map_outlined, size: 100),
      Text('Map temporarily unavailable'),
      Text('Showing list view instead'),
      Expanded(child: DishListView()),
    ],
  );
}
```

---

## Success Indicators

You'll know it's working when you see:

1. **In logs**:
   ```
   D/MapsInitializer: loadedRenderer: LATEST
   I/Google Maps Android API: Successfully loaded map
   ```

2. **In UI**:
   - Map tiles visible
   - Can zoom/pan
   - Markers appear
   - Location button works

3. **No errors**:
   - No authorization failures
   - No "For development purposes only" watermark
   - No blank/gray screen

---

## Next Steps

1. **Verify API key in Google Cloud Console**
   - Check if Maps SDK is enabled
   - Check if billing is enabled
   - Check restrictions match app

2. **Test API key directly**
   - Use the Static Maps URL above
   - Should return a map image

3. **If still not working**
   - Create a new API key
   - Use unrestricted key for testing
   - Check app logs for specific errors

4. **Report findings**
   - What error messages appear?
   - Does the test URL work?
   - Is billing enabled?

---

**Priority**: 🔴 HIGH  
**Blocking**: Yes - Map is core feature  
**Estimated Fix Time**: 15-30 minutes (if API key issue)

**Most Likely Cause**: API key not enabled for Maps SDK or billing not enabled in Google Cloud Console.
