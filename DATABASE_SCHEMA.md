# Database Schema Reference

**Generated**: 2025-11-23  
**Purpose**: Complete reference for Chefleet database schema  
**Source**: Live database schema audit (Phase 1 of Comprehensive Schema Fix Plan)

---

## 📋 Table of Contents

1. [Schema Overview](#schema-overview)
2. [Critical Tables](#critical-tables)
3. [Schema Mismatches Identified](#schema-mismatches-identified)
4. [Column Reference by Table](#column-reference-by-table)
5. [Foreign Key Relationships](#foreign-key-relationships)
6. [NOT NULL Constraints](#not-null-constraints)
7. [Check Constraints](#check-constraints)

---

## Schema Overview

### All Tables in Public Schema

| Table Name | RLS Enabled | Row Count | Primary Purpose |
|------------|-------------|-----------|-----------------|
| `orders` | ✅ Yes | 0 | Order management |
| `order_items` | ✅ Yes | 0 | Order line items |
| `messages` | ✅ Yes | 0 | Chat between buyers/vendors |
| `guest_sessions` | ✅ Yes | 0 | Guest user sessions |
| `users_public` | ✅ Yes | 0 | Public user profiles |
| `vendors` | ✅ Yes | 4 | Vendor profiles |
| `dishes` | ✅ Yes | 10 | Menu items |
| `payments_archived` | ✅ Yes | 0 | Payment records |
| `payment_refunds` | ✅ Yes | 0 | Refund records |
| `notifications` | ✅ Yes | 0 | User notifications |
| `moderation_reports` | ✅ Yes | 0 | Content moderation |
| `audit_logs` | ✅ Yes | 14 | System audit trail |
| `app_settings` | ✅ Yes | 12 | Application settings |
| `vendor_quick_replies` | ✅ Yes | 0 | Quick reply templates |
| `device_tokens` | ✅ Yes | 0 | Push notification tokens |
| `favourites` | ✅ Yes | 0 | User favorites |
| `order_status_history` | ✅ Yes | 0 | Order status changes |
| `user_addresses` | ✅ Yes | 0 | Saved addresses |
| `vendor_analytics` | ✅ Yes | 0 | Vendor metrics |

---

## Critical Tables

### Priority Order (from Comprehensive Schema Fix Plan)

1. ✅ **orders** - Fixed (v6 edge function)
2. ✅ **messages** - Fixed (guest support added)
3. ✅ **guest_sessions** - Fixed (INSERT policy added)
4. ⏸️ **order_items** - Needs verification
5. ⏸️ **payments_archived** - Not yet tested
6. ⏸️ **users_public** - Needs verification
7. ⏸️ **vendors** - Partially tested
8. ⏸️ **dishes** - Partially tested
9. ⏸️ **notifications** - Not tested
10. ⏸️ **moderation_reports** - Not tested

---

## Schema Mismatches Identified

### ⚠️ Base Migration vs Live Database

The base migration (`20250120000000_base_schema.sql`) defines an **older schema** that has been modified by subsequent migrations. Key differences:

#### Orders Table Differences

| Base Migration | Live Database | Status |
|----------------|---------------|--------|
| `user_id` (NOT NULL) | `buyer_id` (NOT NULL) | ✅ Renamed |
| `total_cents` (NOT NULL) | `total_amount` (NOT NULL) | ✅ Added |
| `pickup_time` | `estimated_fulfillment_time` | ✅ Renamed |
| ❌ Missing | `guest_user_id` (nullable) | ✅ Added for guest support |
| ❌ Missing | `pickup_address` (nullable) | ✅ Added |
| ❌ Missing | `cash_payment_confirmed` (boolean) | ✅ Added |
| ❌ Missing | `idempotency_key` (unique) | ✅ Added |

#### Messages Table Differences

| Base Migration | Live Database | Status |
|----------------|---------------|--------|
| `sender_id` (NOT NULL) | `sender_id` (nullable) | ✅ Changed for guest support |
| `recipient_id` (NOT NULL) | ❌ Removed | ⚠️ Breaking change |
| ❌ Missing | `guest_sender_id` (nullable) | ✅ Added |
| ❌ Missing | `sender_type` (text) | ✅ Added |
| ❌ Missing | `is_read` (boolean) | ✅ Added |

#### Users Public Table Differences

| Base Migration | Live Database | Status |
|----------------|---------------|--------|
| `id` → `auth.users(id)` | `id` (UUID) | ✅ Same |
| `name` (NOT NULL) | `full_name` (nullable) | ⚠️ Changed |
| `address` (JSONB) | ❌ Removed | ⚠️ Breaking change |
| ❌ Missing | `user_id` → `auth.users(id)` | ✅ Added |
| ❌ Missing | `phone`, `bio`, `location_city`, `location_state` | ✅ Added |

---

## Column Reference by Table

### 1. Orders Table

**Purpose**: Stores all order information for both guest and registered users

| Column Name | Data Type | Nullable | Default | Constraints |
|-------------|-----------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | PRIMARY KEY |
| `buyer_id` | uuid | NO | - | FK → `users.id` |
| `vendor_id` | uuid | NO | - | FK → `vendors.id` |
| `total_amount` | numeric | NO | - | - |
| `status` | text | NO | `'pending'` | CHECK (7 values) |
| `pickup_code` | text | NO | - | UNIQUE |
| `notes` | text | YES | - | - |
| `created_at` | timestamptz | YES | `now()` | - |
| `updated_at` | timestamptz | YES | `now()` | - |
| `idempotency_key` | text | YES | - | UNIQUE |
| `subtotal_cents` | integer | NO | `0` | - |
| `tax_cents` | integer | NO | `0` | - |
| `delivery_fee_cents` | integer | NO | `0` | - |
| `service_fee_cents` | integer | NO | `0` | - |
| `tip_cents` | integer | NO | `0` | - |
| `estimated_fulfillment_time` | timestamptz | YES | - | - |
| `actual_fulfillment_time` | timestamptz | YES | - | - |
| `pickup_code_expires_at` | timestamptz | YES | - | - |
| `buyer_latitude` | numeric | YES | - | - |
| `buyer_longitude` | numeric | YES | - | - |
| `pickup_address` | text | YES | - | - |
| `special_instructions` | text | YES | - | - |
| `fulfillment_method` | text | YES | `'pickup'` | - |
| `estimated_prep_time_minutes` | integer | YES | - | - |
| `cancellation_reason` | text | YES | - | - |
| `cancelled_by` | uuid | YES | - | FK → `users.id` |
| `cancelled_at` | timestamptz | YES | - | - |
| `total_cents` | integer | NO | `GENERATED ALWAYS` | Derived from *_cents columns |
| `cash_payment_confirmed` | boolean | YES | `false` | - |
| `cash_payment_notes` | text | YES | - | - |
| `guest_user_id` | text | YES | - | FK → `guest_sessions.guest_id` |

**Status Values**: `pending`, `confirmed`, `preparing`, `ready`, `picked_up`, `completed`, `cancelled`

**Critical Notes**:
- ✅ `total_amount` is NOT NULL (required for all orders)
- ✅ `_cents` columns are NOT NULL with default 0 ensuring totals are deterministic
- ✅ `total_cents` is a generated column (cannot be inserted/updated manually)
- ✅ `guest_user_id` allows guest orders
- ✅ `pickup_code` is NOT NULL and UNIQUE

---

### 2. Order Items Table

**Purpose**: Line items for each order

| Column Name | Data Type | Nullable | Default | Constraints |
|-------------|-----------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | PRIMARY KEY |
| `order_id` | uuid | NO | - | FK → `orders.id` |
| `dish_id` | uuid | NO | - | FK → `dishes.id` |
| `quantity` | integer | NO | - | - |
| `unit_price` | numeric | NO | - | - |
| `created_at` | timestamptz | YES | `now()` | - |
| `dish_name` | text | YES | - | Snapshot of dish name |
| `dish_price_cents` | integer | YES | - | Snapshot of price |
| `special_instructions` | text | YES | - | - |
| `added_ingredients` | text[] | YES | - | - |
| `removed_ingredients` | text[] | YES | - | - |

**Critical Notes**:
- ✅ All required fields are NOT NULL
- ✅ Includes dish snapshots (`dish_name`, `dish_price_cents`)
- ✅ Supports customization (`added_ingredients`, `removed_ingredients`)

---

### 3. Messages Table

**Purpose**: Chat messages between buyers and vendors

| Column Name | Data Type | Nullable | Default | Constraints |
|-------------|-----------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | PRIMARY KEY |
| `order_id` | uuid | NO | - | FK → `orders.id` |
| `sender_id` | uuid | YES | - | FK → `users.id` |
| `content` | text | NO | - | - |
| `message_type` | text | YES | `'text'` | CHECK: `text`, `system` |
| `read_at` | timestamptz | YES | - | - |
| `created_at` | timestamptz | YES | `now()` | - |
| `guest_sender_id` | text | YES | - | FK → `guest_sessions.guest_id` |
| `sender_type` | text | YES | `'buyer'` | CHECK: `buyer`, `vendor`, `system` |
| `is_read` | boolean | YES | `false` | - |

**Critical Notes**:
- ✅ `sender_id` is nullable (for guest support)
- ✅ `guest_sender_id` for guest messages
- ✅ `sender_type` distinguishes buyer/vendor/system
- ⚠️ Either `sender_id` OR `guest_sender_id` must be set (mutually exclusive)

---

### 4. Guest Sessions Table

**Purpose**: Tracks guest user sessions before conversion

| Column Name | Data Type | Nullable | Default | Constraints |
|-------------|-----------|----------|---------|-------------|
| `guest_id` | text | NO | - | PRIMARY KEY |
| `device_id` | text | YES | - | - |
| `created_at` | timestamptz | YES | `now()` | - |
| `last_active_at` | timestamptz | YES | `now()` | - |
| `converted_to_user_id` | uuid | YES | - | FK → `users_public.id` |
| `converted_at` | timestamptz | YES | - | - |
| `metadata` | jsonb | YES | `'{}'` | - |

**Critical Notes**:
- ✅ `guest_id` is the primary key (text, not UUID)
- ✅ Tracks conversion to registered user
- ✅ Metadata for additional tracking

---

### 5. Users Public Table

**Purpose**: Public user profiles (synced with auth.users)

| Column Name | Data Type | Nullable | Default | Constraints |
|-------------|-----------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | PRIMARY KEY |
| `user_id` | uuid | NO | - | FK → `auth.users.id` |
| `full_name` | text | YES | - | - |
| `avatar_url` | text | YES | - | - |
| `phone` | text | YES | - | - |
| `bio` | text | YES | - | - |
| `location_city` | text | YES | - | - |
| `location_state` | text | YES | - | - |
| `preferences` | jsonb | YES | `'{}'` | - |
| `is_active` | boolean | YES | `true` | - |
| `last_seen_at` | timestamptz | YES | - | - |
| `created_at` | timestamptz | NO | `now()` | - |
| `updated_at` | timestamptz | NO | `now()` | - |

**Critical Notes**:
- ⚠️ `full_name` is nullable (was `name` NOT NULL in base migration)
- ✅ `user_id` references `auth.users.id`
- ✅ Separate `id` for public profile

---

### 6. Vendors Table

**Purpose**: Vendor/restaurant profiles

| Column Name | Data Type | Nullable | Default | Constraints |
|-------------|-----------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | PRIMARY KEY |
| `owner_id` | uuid | NO | - | FK → `users.id` |
| `business_name` | text | NO | - | - |
| `description` | text | YES | - | - |
| `phone` | text | YES | - | - |
| `address` | text | YES | - | - |
| `latitude` | numeric | YES | - | - |
| `longitude` | numeric | YES | - | - |
| `is_active` | boolean | YES | `true` | - |
| `created_at` | timestamptz | YES | `now()` | - |
| `updated_at` | timestamptz | YES | `now()` | - |
| `business_email` | text | YES | - | - |
| `website_url` | text | YES | - | - |
| `business_hours` | jsonb | YES | `'{}'` | - |
| `rating` | numeric | YES | - | CHECK: 0-5 |
| `review_count` | integer | YES | `0` | - |
| `cuisine_type` | text | YES | - | - |
| `price_range` | text | YES | - | CHECK: $, $$, $$$, $$$$ |
| `delivery_radius_km` | integer | YES | `5` | - |
| `min_order_amount_cents` | integer | YES | `0` | - |
| `fulfillment_time_minutes` | integer | YES | `30` | - |
| `status` | text | YES | `'pending'` | CHECK (5 values) |
| `location` | geography | YES | - | PostGIS geography |
| `logo_url` | text | YES | - | - |
| `license_url` | text | YES | - | - |
| `dish_count` | integer | YES | `0` | - |
| `open_hours_json` | jsonb | YES | `'{}'` | - |
| `metadata` | jsonb | YES | `'{}'` | - |

**Status Values**: `pending`, `approved`, `active`, `suspended`, `inactive`

**Critical Notes**:
- ✅ `business_name` is NOT NULL
- ✅ Location stored as both lat/lng and PostGIS geography
- ✅ `dish_count` auto-updated by trigger

---

### 7. Dishes Table

**Purpose**: Menu items for vendors

| Column Name | Data Type | Nullable | Default | Constraints |
|-------------|-----------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | PRIMARY KEY |
| `vendor_id` | uuid | NO | - | FK → `vendors.id` |
| `name` | text | NO | - | - |
| `description` | text | YES | - | - |
| `price` | numeric | NO | - | CHECK: >= 0 |
| `category` | text | YES | - | - |
| `image_url` | text | YES | - | - |
| `available` | boolean | YES | `true` | - |
| `created_at` | timestamptz | YES | `now()` | - |
| `updated_at` | timestamptz | YES | `now()` | - |
| `description_long` | text | YES | - | - |
| `ingredients` | text[] | YES | - | - |
| `allergens` | text[] | YES | - | - |
| `dietary_restrictions` | text[] | YES | - | - |
| `preparation_time_minutes` | integer | YES | `15` | - |
| `spice_level` | integer | YES | - | CHECK: 0-5 |
| `is_featured` | boolean | YES | `false` | - |
| `category_enum` | text | YES | - | CHECK (6 values) |
| `price_cents` | integer | YES | - | - |
| `is_vegetarian` | boolean | YES | `false` | - |
| `is_vegan` | boolean | YES | `false` | - |
| `is_gluten_free` | boolean | YES | `false` | - |
| `nutritional_info` | jsonb | YES | - | - |
| `popularity_score` | numeric | YES | `0` | - |
| `order_count` | integer | YES | `0` | - |

**Category Enum Values**: `appetizer`, `main`, `dessert`, `beverage`, `snack`, `side`

**Critical Notes**:
- ✅ `name` and `price` are NOT NULL
- ⚠️ Both `price` (numeric) and `price_cents` (integer) exist
- ✅ Rich metadata (allergens, dietary restrictions, etc.)

---

### 8. Payments Archived Table

**Purpose**: Payment transaction records

| Column Name | Data Type | Nullable | Default | Constraints |
|-------------|-----------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | PRIMARY KEY |
| `order_id` | uuid | NO | - | FK → `orders.id` |
| `payment_intent_id` | text | YES | - | UNIQUE |
| `amount_cents` | integer | NO | - | - |
| `currency` | text | NO | `'USD'` | - |
| `status` | text | YES | `'pending'` | CHECK (6 values) |
| `payment_method` | text | YES | - | CHECK: card, cash, digital_wallet |
| `processor` | text | YES | - | CHECK: stripe, square, paypal, cash |
| `processor_fee_cents` | integer | YES | `0` | - |
| `processor_response` | jsonb | YES | - | - |
| `created_at` | timestamptz | NO | `now()` | - |
| `updated_at` | timestamptz | NO | `now()` | - |
| `completed_at` | timestamptz | YES | - | - |

**Status Values**: `pending`, `processing`, `succeeded`, `failed`, `cancelled`, `refunded`

**Critical Notes**:
- ✅ `amount_cents` is NOT NULL
- ✅ Supports multiple payment processors
- ✅ Stores processor response as JSONB

---

### 9. Notifications Table

**Purpose**: User notifications

| Column Name | Data Type | Nullable | Default | Constraints |
|-------------|-----------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | PRIMARY KEY |
| `user_id` | uuid | NO | - | FK → `users_public.id` |
| `title` | text | NO | - | - |
| `message` | text | NO | - | - |
| `type` | text | NO | - | - |
| `data` | jsonb | YES | `'{}'` | - |
| `read_at` | timestamptz | YES | - | - |
| `created_at` | timestamptz | NO | `now()` | - |

**Critical Notes**:
- ✅ All core fields are NOT NULL
- ✅ `data` JSONB for flexible notification payloads

---

### 10. Moderation Reports Table

**Purpose**: Content moderation and user reports

| Column Name | Data Type | Nullable | Default | Constraints |
|-------------|-----------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | PRIMARY KEY |
| `reporter_id` | uuid | YES | - | FK → `users_public.id` |
| `reported_user_id` | uuid | YES | - | FK → `users_public.id` |
| `reported_vendor_id` | uuid | YES | - | FK → `vendors.id` |
| `reported_order_id` | uuid | YES | - | FK → `orders.id` |
| `reported_message_id` | uuid | YES | - | FK → `messages.id` |
| `report_type` | text | NO | - | - |
| `reason` | text | NO | - | - |
| `description` | text | NO | - | - |
| `status` | text | YES | `'pending'` | - |
| `priority` | text | YES | `'medium'` | - |
| `reviewed_by` | uuid | YES | - | FK → `users.id` |
| `review_notes` | text | YES | - | - |
| `action_taken` | text | YES | - | - |
| `created_at` | timestamptz | NO | `now()` | - |
| `updated_at` | timestamptz | NO | `now()` | - |

**Critical Notes**:
- ✅ Supports reporting multiple entity types
- ✅ Workflow tracking (status, priority, reviewed_by)

---

## Foreign Key Relationships

### Orders Table
- `buyer_id` → `users.id`
- `vendor_id` → `vendors.id`
- `cancelled_by` → `users.id`
- `guest_user_id` → `guest_sessions.guest_id`

### Order Items Table
- `order_id` → `orders.id` (CASCADE DELETE)
- `dish_id` → `dishes.id`

### Messages Table
- `order_id` → `orders.id` (CASCADE DELETE)
- `sender_id` → `users.id`
- `guest_sender_id` → `guest_sessions.guest_id`

### Guest Sessions Table
- `converted_to_user_id` → `users_public.id`

### Users Public Table
- `user_id` → `auth.users.id` (CASCADE DELETE)

### Vendors Table
- `owner_id` → `users.id` (CASCADE DELETE)

### Dishes Table
- `vendor_id` → `vendors.id` (CASCADE DELETE)

### Payments Archived Table
- `order_id` → `orders.id`

### Notifications Table
- `user_id` → `users_public.id`

### Moderation Reports Table
- `reporter_id` → `users_public.id`
- `reported_user_id` → `users_public.id`
- `reported_vendor_id` → `vendors.id`
- `reported_order_id` → `orders.id`
- `reported_message_id` → `messages.id`
- `reviewed_by` → `users.id`

---

## NOT NULL Constraints

### Critical NOT NULL Fields by Table

#### Orders
- `id`, `buyer_id`, `vendor_id`, `total_amount`, `status`, `pickup_code`

#### Order Items
- `id`, `order_id`, `dish_id`, `quantity`, `unit_price`

#### Messages
- `id`, `order_id`, `content`
- ⚠️ `sender_id` is nullable (for guest support)

#### Guest Sessions
- `guest_id` (PRIMARY KEY)

#### Users Public
- `id`, `user_id`, `created_at`, `updated_at`
- ⚠️ `full_name` is nullable

#### Vendors
- `id`, `owner_id`, `business_name`

#### Dishes
- `id`, `vendor_id`, `name`, `price`

#### Payments Archived
- `id`, `order_id`, `amount_cents`, `currency`, `created_at`, `updated_at`

#### Notifications
- `id`, `user_id`, `title`, `message`, `type`, `created_at`

#### Moderation Reports
- `id`, `report_type`, `reason`, `description`, `created_at`, `updated_at`

---

## Check Constraints

### Orders Table
- `status` IN (`pending`, `confirmed`, `preparing`, `ready`, `picked_up`, `completed`, `cancelled`)

### Messages Table
- `message_type` IN (`text`, `system`)
- `sender_type` IN (`buyer`, `vendor`, `system`)

### Vendors Table
- `rating` BETWEEN 0 AND 5
- `price_range` IN (`$`, `$$`, `$$$`, `$$$$`)
- `status` IN (`pending`, `approved`, `active`, `suspended`, `inactive`)

### Dishes Table
- `price` >= 0
- `spice_level` BETWEEN 0 AND 5
- `category_enum` IN (`appetizer`, `main`, `dessert`, `beverage`, `snack`, `side`)

### Payments Archived Table
- `status` IN (`pending`, `processing`, `succeeded`, `failed`, `cancelled`, `refunded`)
- `payment_method` IN (`card`, `cash`, `digital_wallet`)
- `processor` IN (`stripe`, `square`, `paypal`, `cash`)

---

## Next Steps (Phase 2)

1. ✅ Validate edge functions against this schema
2. ⏸️ Verify Flutter models match column names
3. ⏸️ Audit RLS policies for guest support
4. ⏸️ Test all critical flows

---

## Related Documents

- `COMPREHENSIVE_SCHEMA_FIX_PLAN.md` - Master plan
- `EDGE_FUNCTION_CONTRACTS.md` - ⏸️ To be created in Phase 2
- `supabase/migrations/20250120000000_base_schema.sql` - Base migration
- `supabase/migrations/20250122000000_guest_accounts.sql` - Guest support migration
