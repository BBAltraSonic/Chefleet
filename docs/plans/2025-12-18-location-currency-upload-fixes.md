# Location, Currency & Upload Fixes Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix critical issues: default location to South Africa with auto-detect, replace hardcoded $ with R currency formatter, add missing Android permissions for image uploads, and ensure all UI elements handle overflow properly.

**Architecture:** Multi-phase approach addressing location defaults, currency formatting, Android permissions, and UI constraints systematically.

**Tech Stack:** Flutter, Dart, Google Maps, Supabase Storage, Android Manifest, CurrencyFormatter (intl package)

---

## Phase 1: Default Location & Auto-Detection (South Africa)

### Issue
The app defaults to San Francisco coordinates across multiple files instead of South Africa, and location auto-detection may not be working consistently.

### Files to Modify
- [`lib/features/map/screens/map_screen.dart`](lib/features/map/screens/map_screen.dart) - Line 119
- [`lib/features/map/blocs/map_bloc.dart`](lib/features/map/blocs/map_bloc.dart) - Line 50  
- [`lib/features/vendor/widgets/place_pin_map.dart`](lib/features/vendor/widgets/place_pin_map.dart) - Line 27

### Solution

**Step 1: Create South Africa location constants**

File: `lib/core/constants/app_constants.dart` (create new file)

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppConstants {
  // South Africa - Default to Johannesburg (largest city, central location)
  static const LatLng defaultLocationSouthAfrica = LatLng(-26.2041, 28.0473); // Johannesburg
  static const double defaultZoom = 14.0;
  
  // Alternative: Cape Town if preferred
  // static const LatLng defaultLocationSouthAfrica = LatLng(-33.9249, 18.4241);
  
  // Backup locations for testing
  static const LatLng johannesburg = LatLng(-26.2041, 28.0473);
  static const LatLng capeTown = LatLng(-33.9249, 18.4241);
  static const LatLng durban = LatLng(-29.8587, 31.0218);
  static const LatLng pretoria = LatLng(-25.7479, 28.2293);
}
```

**Expected:** New constants file created with South African coordinates

**Step 2: Update map_screen.dart default location**

File: `lib/features/map/screens/map_screen.dart`

Replace line 119:

```dart
// OLD:
: const LatLng(37.7749, -122.4194),

// NEW:
: AppConstants.defaultLocationSouthAfrica,
```

Add import at top:
```dart
import '../../../../core/constants/app_constants.dart';
```

**Expected:** Map screen defaults to Johannesburg

**Step 3: Update map_bloc.dart default location**

File: `lib/features/map/blocs/map_bloc.dart`

Replace line 50:

```dart
// OLD:
this.center = const LatLng(37.7749, -122.4194), // San Francisco default

// NEW:
this.center = AppConstants.defaultLocationSouthAfrica, // Johannesburg, South Africa default
```

Add import at top:
```dart
import '../../constants/app_constants.dart';
```

**Expected:** Map bloc state defaults to Johannesburg

**Step 4: Update place_pin_map.dart default location**

File: `lib/features/vendor/widgets/place_pin_map.dart`

Replace line 27:

```dart
// OLD:
_currentPosition = widget.initialPosition ?? const LatLng(37.7749, -122.4194); // Default to SF

// NEW:
_currentPosition = widget.initialPosition ?? AppConstants.defaultLocationSouthAfrica; // Default to Johannesburg
```

Add import at top:
```dart
import '../../../core/constants/app_constants.dart';
```

**Expected:** Pin placement widget defaults to Johannesburg

**Step 5: Verify location auto-detection**

Review `lib/features/map/blocs/map_feed_bloc.dart` line 664-707:
- The `_getCurrentLocation()` method already exists and looks correct
- Ensure it's being called during initialization
- Add debug logging to track when it succeeds/fails

Run app and check:
```bash
flutter run --debug
# Check logs for:
# "🔍 MapFeedBloc._getCurrentLocation: Starting location fetch..."
# "✅ MapFeedBloc._getCurrentLocation: Got position: ..."
```

**Expected:** Location permission requested, map moves to user's actual location after granting permission

**Commit:**
```bash
git add lib/core/constants/app_constants.dart lib/features/map/screens/map_screen.dart lib/features/map/blocs/map_bloc.dart lib/features/vendor/widgets/place_pin_map.dart
git commit -m "fix: change default location from San Francisco to Johannesburg, South Africa"
```

---

## Phase 2: Currency Symbol Fix ($ → R)

### Issue
Multiple components hardcode the USD symbol (`$`) instead of using the existing `CurrencyFormatter` that correctly displays South African Rand (`R`).

### Analysis
The `lib/shared/utils/currency_formatter.dart` already exists and is correctly configured:
- Symbol: `'R'`
- Locale: `'en_ZA'`
- Format: `R15.50`

But many components bypass it and hardcode `$`.

### Files to Fix

**Step 1: Fix hardcoded price prefix in constants**

File: `lib/core/constants/app_strings.dart` line 149

```dart
// OLD:
static const String pricePrefix = '\$';

// NEW:
static const String pricePrefix = 'R'; // South African Rand
```

**Expected:** Constant now shows R instead of $

**Step 2: Fix vendor dish card widget**

File: `lib/features/vendor/widgets/dish_card.dart` line 114

```dart
// OLD:
'\$${(dish.priceCents / 100).toStringAsFixed(2)}',

// NEW:
CurrencyFormatter.formatCents(dish.priceCents),
```

Add import at top of file if not present:
```dart
import '../../../shared/utils/currency_formatter.dart';
```

**Expected:** Dish cards now show R15.50 format

**Step 3: Audit all price displays**

Run comprehensive search for any remaining hardcoded dollar signs:

```bash
# Find all price-related displays not using CurrencyFormatter
grep -rn "priceCents" lib/ | grep -v "CurrencyFormatter"

# Find hardcoded dollar signs in price contexts  
grep -rn '"\$"' lib/ 
grep -rn "'\$'" lib/
```

Files to manually verify:
- All `feed` widgets displaying prices
- Customer-facing screens showing prices
- Order summary/checkout flows

Files already correct (✅):
- `lib/features/vendor/screens/vendor_dashboard_screen.dart`
- `lib/features/vendor/widgets/menu_item_card.dart`
- `lib/features/vendor/widgets/order_details_widget.dart`
- `lib/features/vendor/screens/order_management_screen.dart`

**Step 4: Fix any remaining instances**

For each file found with hardcoded `$`:

```dart
// PATTERN TO REPLACE:
'\$${price.toStringAsFixed(2)}'
'\$${(priceCents / 100).toStringAsFixed(2)}'

// WITH:
CurrencyFormatter.format(price)
CurrencyFormatter.formatCents(priceCents)
```

**Expected:** All prices throughout app display as R (not $)

**Commit:**
```bash
git add lib/core/constants/app_strings.dart lib/features/vendor/widgets/dish_card.dart
git commit -m "fix: replace hardcoded $ with R currency formatter for South African Rand"
```

---

## Phase 3: Image Upload Permissions Fix

### Issue
From screenshot showing "Failed to upload image" - Android permissions for camera and storage are missing from the manifest.

### Root Cause
`android/app/src/main/AndroidManifest.xml` only has location permissions, missing:
- Camera access (for taking photos)
- Storage read/write (for picking from gallery)
- Media permissions (Android 13+)

### Files to Modify
- `android/app/src/main/AndroidManifest.xml`

### Solution

**Step 1: Add required permissions to AndroidManifest.xml**

File: `android/app/src/main/AndroidManifest.xml`

Add these permissions after the existing location permissions (after line 4):

```xml
<!-- Existing location permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>

<!-- Camera and Storage Permissions for Image Upload -->
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
    android:maxSdkVersion="29"/>

<!-- Android 13+ (API 33+) Granular Media Permissions -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>

<!-- Optional: Declare camera feature (not required, allows app on devices without camera) -->
<uses-feature android:name="android.hardware.camera" android:required="false"/>
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false"/>
```

**Expected:** Manifest now declares all required permissions

**Step 2: Add runtime permission checks before image operations**

Files using `ImagePicker` that need permission checks:
- `lib/features/vendor/screens/dish_edit_screen.dart` - `_pickImage()` at line 100
- `lib/features/vendor/screens/media_upload_screen.dart` - `_pickImages()` at line 422
- `lib/features/vendor/screens/vendor_onboarding_screen.dart` - `_pickImage()` at line 918
- `lib/features/auth/screens/profile_creation_screen.dart` - line 52

Example permission check pattern for **gallery** (add before `ImagePicker().pickImage()`):

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> _pickImage() async {
  try {
    // Request storage/photos permission
    PermissionStatus status;
    if (Platform.isAndroid) {
      // Android 13+ uses photos permission
      if (await Permission.photos.isGranted) {
        status = PermissionStatus.granted;
      } else {
        status = await Permission.photos.request();
      }
    } else {
      status = await Permission.photos.request();
    }
    
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to select images'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
}
```

For **camera** access:

```dart
Future<void> _takePhoto() async {
  try {
    // Request camera permission
    final status = await Permission.camera.request();
    
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to take photos'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    
    // ... rest of image handling
  } catch (e) {
    // ... error handling
  }
}
```

Add `import 'dart:io';` if not present.

**Expected:** Permission prompts appear before camera/gallery access

**Step 3: Verify Supabase storage bucket configuration**

Check that required buckets exist and have proper RLS policies:

Required buckets:
- `dish-images` - Used in `lib/features/vendor/screens/dish_edit_screen.dart` line 322
- `vendor-media` - Used in `lib/features/vendor/blocs/media_upload_bloc.dart` line 57

In Supabase dashboard, verify policies allow:
- Authenticated vendors can INSERT
- Public can SELECT (for displaying images)

Example RLS policy for `dish-images` bucket:

```sql
-- Allow authenticated users to upload
CREATE POLICY "Authenticated users can upload dish images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'dish-images');

-- Allow public to view images
CREATE POLICY "Public can view dish images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'dish-images');

-- Allow vendors to delete their own images
CREATE POLICY "Vendors can delete their dish images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'dish-images' AND auth.uid() = owner);
```

**Expected:** Images upload successfully, public URLs work

**Commit:**
```bash
git add android/app/src/main/AndroidManifest.xml lib/features/vendor/screens/dish_edit_screen.dart lib/features/vendor/screens/media_upload_screen.dart
git commit -m "fix: add camera and storage permissions for image uploads on Android"
```

---

## Phase 4: UI Overflow Fixes

### Issue
Ensure all UI components handle content overflow gracefully with no red overflow indicators.

### Analysis
From grep results, most components already use `TextOverflow.ellipsis`. Need to:
1. Identify specific overflow issues from testing
2. Add `Flexible`/`Expanded` wrappers where needed
3. Test on small screens

### Files to Review

**Step 1: Test all screens on small device**

Run app on emulator with small screen (320px width):

```bash
flutter emulators --launch <emulator_id>
# Or in Android Studio, create Pixel device with small screen
```

Test these screens for overflow:
- Vendor onboarding flow
- Add/Edit dish form  
- Business hours configuration
- Order details modal
- Chat messages
- Stats dashboard

**Step 2: Common overflow patterns to fix**

Pattern 1 - Horizontal overflow in Row:

```dart
// BAD:
Row(
  children: [
    Icon(Icons.location),
    Text(veryLongAddress), // Can overflow!
  ],
)

// GOOD:
Row(
  children: [
    Icon(Icons.location),
    SizedBox(width: 8),
    Expanded(
      child: Text(
        veryLongAddress,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    ),
  ],
)
```

Pattern 2 - Column overflow:

```dart
// BAD:
Column(
  children: [
    VeryTallWidget(),
    AnotherWidget(),
  ],
)

// GOOD:
SingleChildScrollView(
  child: Column(
    children: [
      VeryTallWidget(),
      AnotherWidget(),
    ],
  ),
)
```

Pattern 3 - Form field constraints:

```dart
// GOOD:
TextField(
  maxLines: 1,
  decoration: InputDecoration(
    labelText: 'Dish Name',
    constraints: BoxConstraints(maxWidth: double.infinity),
  ),
)
```

**Step 3: Fix identified overflow issues**

Based on screenshots, likely problem areas:

File: `lib/features/vendor/widgets/opening_hours_widget.dart`
- Check time picker row doesn't overflow on small screens
- Wrap day names in Flexible if needed

File: `lib/features/vendor/screens/dish_edit_screen.dart`
- Verify form fields have proper constraints
- Add SingleChildScrollView if form overflows

File: `lib/features/vendor/widgets/stats_card.dart`
- Already has FittedBox at line 72-93 ✅

**Expected:** No red overflow indicators on any screen

**Commit:**
```bash
git add lib/features/vendor/widgets/opening_hours_widget.dart
git commit -m "fix: prevent UI overflow on small screens with proper constraints"
```

---

## Phase 5: Testing & Verification

### Comprehensive Testing Checklist

**Location Testing:**
- [ ] App opens with map centered on Johannesburg, South Africa
- [ ] Location permission prompt appears on first launch
- [ ] After granting permission, map moves to actual user location
- [ ] If permission denied, stays on Johannesburg default
- [ ] Vendor pin placement defaults to South African coordinates

**Currency Testing:**
- [ ] All dish prices show `R` symbol (not `$`)
- [ ] Prices format as `R15.50` (not `$15.50`)
- [ ] Vendor dashboard revenue shows `R` symbol
- [ ] Order totals show `R` symbol
- [ ] Customer checkout shows `R` symbol
- [ ] Price input fields accept ZAR values

**Image Upload Testing:**
- [ ] "Take Photo" opens camera app
- [ ] Camera permission prompt appears if not granted
- [ ] Photo captured successfully
- [ ] "Choose from Gallery" opens photo picker
- [ ] Storage permission prompt appears if not granted
- [ ] Selected image displays in preview
- [ ] Image uploads to Supabase successfully
- [ ] Public URL generated correctly
- [ ] Image displays in app after upload
- [ ] Test on Android 13+ device for new media permissions

**Overflow Testing:**
- [ ] No red overflow indicators on any screen
- [ ] Long vendor names truncate with ellipsis
- [ ] Long dish descriptions truncate properly
- [ ] Business hours UI fits on screen
- [ ] Add dish form scrolls properly
- [ ] Order details modal handles long content
- [ ] Chat messages wrap correctly
- [ ] Test on 320px width emulator

### Test Devices
- Android emulator (Pixel 5, Android 13+)
- Small screen device (320px width)
- Large screen (tablet)
- Physical device if available

### Verification Commands

```bash
# Run app in debug mode
flutter run --debug

# Check for console errors
flutter logs

# Run on specific device
flutter run -d <device_id>

# Build APK for testing
flutter build apk --debug
```

### Rollback Plan
If issues occur:
- Phase 1: Revert to SF coordinates temporarily (low risk)
- Phase 2: Only affects display, safe to revert
- Phase 3: Removing permissions is safe (just won't work)
- Phase 4: CSS-only changes, easily reverted

All changes are isolated and can be reverted independently.

---

## Summary of Changes

### Files Modified: ~10-15 files

**New Files:**
1. `lib/core/constants/app_constants.dart` - South African location constants

**Modified Files:**
2. `lib/features/map/screens/map_screen.dart` - Default location
3. `lib/features/map/blocs/map_bloc.dart` - Default location
4. `lib/features/vendor/widgets/place_pin_map.dart` - Default location
5. `lib/core/constants/app_strings.dart` - Currency prefix
6. `lib/features/vendor/widgets/dish_card.dart` - Use CurrencyFormatter
7. `android/app/src/main/AndroidManifest.xml` - Add permissions
8-11. `lib/features/vendor/screens/dish_edit_screen.dart` + 3 other files - Add permission checks
12-14. UI files with overflow fixes (TBD based on testing)

### Estimated Implementation Time
- Phase 1 (Location): 30 minutes
- Phase 2 (Currency): 45 minutes (includes audit)
- Phase 3 (Permissions): 60 minutes (includes testing)
- Phase 4 (Overflow): 30-60 minutes (depending on issues found)
- Phase 5 (Testing): 60 minutes

**Total: 3-4 hours**

### Dependencies
- No new packages required
- Uses existing `geolocator`, `image_picker`, `permission_handler`, `intl`
- `CurrencyFormatter` already exists and is correctly configured

### Breaking Changes
**None** - these are all bug fixes that correct existing behavior to match South African requirements.

### Success Criteria
1. Map always defaults to South Africa
2. Zero instances of `$` symbol in price displays
3. Image uploads work on all Android versions
4. No UI overflow errors on any screen size

---

## Notes

- **Location Choice**: Johannesburg chosen as default (largest city, central). Can easily change to Cape Town if preferred by updating `AppConstants.defaultLocationSouthAfrica`.
- **Currency**: The `CurrencyFormatter` already exists and is perfectly configured. Just need to ensure all components use it instead of hardcoding.
- **Permissions**: Android 13+ requires new granular media permissions (`READ_MEDIA_IMAGES`) in addition to legacy storage permissions.
- **Testing**: Critical to test on Android 13+ device to verify new permission model works correctly.

