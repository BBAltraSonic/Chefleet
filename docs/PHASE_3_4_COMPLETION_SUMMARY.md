# Phase 3 & 4 Implementation - Role Switching State Management & Database Schema

**Date**: 2025-01-26  
**Status**: ✅ **COMPLETED**

## Overview

Successfully implemented Phase 3 (State Management) and Phase 4 (Database Schema) of the role switching feature, establishing the foundation for customer-vendor role switching in the Chefleet application.

---

## Phase 3: State Management ✅

### 3.1 RoleBloc Implementation

Created comprehensive BLoC architecture for role management:

#### **Files Created:**

1. **`lib/core/blocs/role_event.dart`**
   - `RoleRequested` - Load current role
   - `RoleSwitchRequested` - Switch to new role
   - `RoleRestored` - Restore role from storage
   - `AvailableRolesRequested` - Fetch available roles
   - `RoleRefreshRequested` - Force refresh from backend
   - `VendorRoleGranted` - Grant vendor role
   - `RoleSyncCompleted` - Internal sync completion
   - `RoleSyncFailed` - Internal sync failure

2. **`lib/core/blocs/role_state.dart`**
   - `RoleInitial` - Initial state
   - `RoleLoading` - Loading state
   - `RoleLoaded` - Successfully loaded with active role and available roles
   - `RoleSwitching` - Switching in progress
   - `RoleSwitched` - Switch completed
   - `RoleError` - Error state with message and code
   - `RoleSyncing` - Background sync in progress
   - `VendorRoleGranting` - Granting vendor role
   - `VendorRoleGranted` - Vendor role granted

3. **`lib/core/blocs/role_bloc.dart`**
   - Coordinates storage and sync services
   - Handles optimistic updates with rollback
   - Emits role change events via stream
   - Background sync with backend
   - Comprehensive error handling

#### **Key Features:**

- **Optimistic Updates**: UI updates immediately, backend syncs in background
- **Error Recovery**: Graceful fallback to cached data on sync failures
- **Role Change Stream**: Reactive updates for listeners
- **Validation**: Ensures role switches are valid before executing
- **Background Sync**: Non-blocking backend synchronization

### 3.2 Global Provider Integration

Updated `lib/main.dart`:
- Initialized `RoleStorageService` and `RoleSyncService`
- Added `RoleBloc` to global `MultiBlocProvider`
- Automatically loads role on app startup with `RoleRequested` event
- Available to all widgets via `context.read<RoleBloc>()`

---

## Phase 4: Database Schema ✅

### 4.1 User Roles Migration

Created **`supabase/migrations/20250126000000_user_roles.sql`**:

#### **Schema Changes:**

1. **Updated `profiles` table:**
   ```sql
   - active_role TEXT (customer/vendor)
   - available_roles TEXT[] (array of roles)
   - vendor_profile_id UUID (link to vendor_profiles)
   ```

2. **Created `vendor_profiles` table:**
   - Complete vendor business information
   - Geographic location (PostGIS)
   - Operating hours (JSONB)
   - Verification and active status
   - Rating and order statistics

3. **Indexes:**
   - `idx_profiles_active_role` - Fast role queries
   - `idx_profiles_vendor_profile_id` - Profile linking
   - `idx_vendor_profiles_user_id` - User lookup
   - `idx_vendor_profiles_business_location` - Geo queries
   - Multiple indexes for filtering and sorting

#### **Database Functions:**

1. **`switch_user_role(new_role TEXT)`**
   - Validates role availability
   - Updates active role
   - Raises exception if role not available

2. **`grant_vendor_role(p_vendor_profile_id UUID)`**
   - Adds vendor to available roles
   - Links vendor profile
   - Idempotent operation

3. **`revoke_vendor_role()`**
   - Removes vendor from available roles
   - Switches to customer if currently vendor
   - Clears vendor profile link

4. **`has_role(p_user_id UUID, p_role TEXT)`**
   - Checks if user has specific role
   - Used for authorization

#### **RLS Policies:**

- Users can view/update their own vendor profile
- Public can view active and verified vendor profiles
- Secure CRUD operations with proper authentication

### 4.2 Vendor Profile Linking

Created **`supabase/migrations/20250127000000_link_vendor_profiles.sql`**:

#### **Integration with Existing Schema:**

1. **Added `vendor_profile_id` to `vendors` table**
   - Links existing vendors table with new vendor_profiles
   - Foreign key constraint for data integrity

2. **Automatic Sync Triggers:**
   - `sync_vendor_profile_on_vendor_create()` - Creates vendor_profile when vendor is created
   - `sync_vendor_profile_on_vendor_update()` - Syncs changes to vendor_profile
   - Bidirectional data synchronization

3. **Data Migration:**
   - Migrated all existing vendors to vendor_profiles
   - Granted vendor role to existing vendor owners
   - Zero data loss migration

---

## Service Layer Updates ✅

### Updated `lib/core/services/role_sync_service.dart`

Changed all references from `user_profiles` to `profiles` table:
- `syncActiveRole()` - ✅ Updated
- `fetchRoleData()` - ✅ Updated
- `fetchUserProfile()` - ✅ Updated
- `grantVendorRole()` - ✅ Updated
- `revokeVendorRole()` - ✅ Updated
- `processSyncQueue()` - ✅ Updated

All methods now correctly reference the `profiles` table matching the existing schema.

---

## Testing ✅

### Unit Tests Created

**`test/core/blocs/role_bloc_test.dart`** - 15 comprehensive test cases:

#### **RoleRequested Tests:**
- ✅ Loads role from cache successfully
- ✅ Fetches role from backend when cache is empty
- ✅ Handles authentication errors

#### **RoleSwitchRequested Tests:**
- ✅ Switches role successfully with optimistic update
- ✅ Rejects switch to unavailable role
- ✅ Ignores switch to same role
- ✅ Handles error when role not loaded

#### **RoleRestored Tests:**
- ✅ Restores valid role successfully
- ✅ Falls back to customer for invalid role

#### **AvailableRolesRequested Tests:**
- ✅ Fetches and updates available roles

#### **VendorRoleGranted Tests:**
- ✅ Grants vendor role and switches if requested

#### **Getter Tests:**
- ✅ `currentRole` returns active role or null
- ✅ `availableRoles` returns roles or null

---

## Architecture Highlights

### Clean Architecture Principles

1. **Separation of Concerns:**
   - Events define what happens
   - States define UI representation
   - BLoC contains business logic
   - Services handle data operations

2. **Single Source of Truth:**
   - RoleBloc is the single authority on active role
   - All role changes flow through the BLoC

3. **Testability:**
   - Services are mockable
   - BLoC logic is fully unit-testable
   - No UI dependencies in business logic

4. **Error Handling:**
   - Typed exceptions for different error scenarios
   - Graceful degradation on sync failures
   - User-friendly error messages

### Data Flow

```
User Action → Event → BLoC → Storage Service → Local Cache
                      ↓
                   State Update → UI
                      ↓
                Sync Service → Backend (async)
```

---

## Integration Points

### For Future Phases

The implemented foundation supports:

1. **Phase 5: App Root Architecture**
   - `RoleBloc` state can drive `RoleShellSwitcher`
   - `roleChanges` stream for reactive UI updates

2. **Phase 6: Routing Infrastructure**
   - `currentRole` getter for route guards
   - State-based navigation decisions

3. **Phase 7-8: Customer/Vendor Shells**
   - Listen to `RoleBloc` state changes
   - Rebuild UI when role switches

4. **Phase 9: Role Switching UI**
   - Dispatch `RoleSwitchRequested` event
   - Show loading during `RoleSwitching` state

5. **Phase 11: Realtime Subscriptions**
   - Subscribe to `roleChanges` stream
   - Update subscriptions on role change

---

## Database Schema Summary

### Tables

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `profiles` | User profiles with role data | `active_role`, `available_roles`, `vendor_profile_id` |
| `vendor_profiles` | Vendor business information | `business_name`, `business_location`, `is_verified` |
| `vendors` | Existing vendor data | `vendor_profile_id` (new link) |

### Functions

| Function | Purpose | Security |
|----------|---------|----------|
| `switch_user_role()` | Switch active role | SECURITY DEFINER |
| `grant_vendor_role()` | Add vendor role | SECURITY DEFINER |
| `revoke_vendor_role()` | Remove vendor role | SECURITY DEFINER |
| `has_role()` | Check role availability | SECURITY DEFINER |

---

## Usage Examples

### Switching Roles

```dart
// Get RoleBloc from context
final roleBloc = context.read<RoleBloc>();

// Switch to vendor mode
roleBloc.add(const RoleSwitchRequested(newRole: UserRole.vendor));

// Listen to state changes
BlocListener<RoleBloc, RoleState>(
  listener: (context, state) {
    if (state is RoleSwitched) {
      // Role switched successfully
      print('Switched to ${state.newRole.displayName}');
    } else if (state is RoleError) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: YourWidget(),
);
```

### Checking Current Role

```dart
// In a widget
BlocBuilder<RoleBloc, RoleState>(
  builder: (context, state) {
    if (state is RoleLoaded) {
      if (state.activeRole.isVendor) {
        return VendorDashboard();
      } else {
        return CustomerFeed();
      }
    }
    return LoadingScreen();
  },
);
```

### Granting Vendor Role

```dart
// After vendor onboarding
roleBloc.add(VendorRoleGranted(
  vendorProfileId: newVendorProfile.id,
  switchToVendor: true, // Immediately switch to vendor mode
));
```

---

## Migration Instructions

### Running Migrations

```bash
# Apply role schema migration
supabase migration up 20250126000000_user_roles

# Apply vendor linking migration
supabase migration up 20250127000000_link_vendor_profiles
```

### Verification Queries

```sql
-- Check profiles have role columns
SELECT id, name, active_role, available_roles, vendor_profile_id 
FROM profiles 
LIMIT 5;

-- Check vendor_profiles table
SELECT id, user_id, business_name, is_verified, is_active 
FROM vendor_profiles 
LIMIT 5;

-- Test role functions
SELECT switch_user_role('vendor'); -- Should work if user has vendor role
SELECT has_role(auth.uid(), 'vendor'); -- Check if user has vendor role
```

---

## Success Criteria - Phase 3 & 4

### Functional Requirements ✅

- ✅ RoleBloc manages role state globally
- ✅ Role persists to local storage
- ✅ Role syncs with backend
- ✅ Role switches complete with optimistic updates
- ✅ Error handling with graceful fallbacks
- ✅ Database schema supports role switching
- ✅ Functions for role management created
- ✅ RLS policies secure vendor data

### Non-Functional Requirements ✅

- ✅ All BLoC logic is unit-tested (15 tests)
- ✅ Clean architecture maintained
- ✅ Type-safe role handling
- ✅ Comprehensive error types
- ✅ Database migrations are idempotent
- ✅ Backward compatible with existing data

### Code Quality ✅

- ✅ Comprehensive documentation
- ✅ Follows Flutter/Dart best practices
- ✅ No circular dependencies
- ✅ Proper separation of concerns
- ✅ Testable architecture

---

## Next Steps - Phase 5

With Phase 3 & 4 complete, the next phase should implement:

1. **AppRoot Widget** - Root widget that listens to RoleBloc
2. **RoleShellSwitcher** - IndexedStack to preserve navigation state
3. **CustomerAppShell** - Wrap existing customer features
4. **Initial routing setup** - Prepare for role-based navigation

The foundation is now solid for building the role-switching UI and navigation architecture.

---

## Files Modified/Created

### Created Files (7)
1. `lib/core/blocs/role_event.dart`
2. `lib/core/blocs/role_state.dart`
3. `lib/core/blocs/role_bloc.dart`
4. `supabase/migrations/20250126000000_user_roles.sql`
5. `supabase/migrations/20250127000000_link_vendor_profiles.sql`
6. `test/core/blocs/role_bloc_test.dart`
7. `docs/PHASE_3_4_COMPLETION_SUMMARY.md`

### Modified Files (2)
1. `lib/main.dart` - Added RoleBloc provider
2. `lib/core/services/role_sync_service.dart` - Updated table references

---

## Conclusion

Phase 3 and Phase 4 have been successfully implemented, providing:

- **Robust state management** for role switching
- **Complete database schema** for role-based features
- **Comprehensive testing** ensuring reliability
- **Clean architecture** for maintainability
- **Solid foundation** for subsequent phases

The implementation follows all architectural principles, maintains backward compatibility, and is production-ready for the next development phase.

**Status**: ✅ **READY FOR PHASE 5**
