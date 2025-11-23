# Chefleet Scripts

This directory contains automation scripts for schema validation, testing, and deployment.

## 📋 Available Scripts

### 1. Schema Validation

**`validate_schema.ts`** - Automated schema validation script

Validates edge functions against database schema to catch mismatches before deployment.

**Usage:**
```bash
deno run --allow-env --allow-net --allow-read scripts/validate_schema.ts
```

**Requirements:**
- Deno runtime
- `SUPABASE_URL` environment variable
- `SUPABASE_SERVICE_ROLE_KEY` environment variable

**What it checks:**
- ✅ Database schema alignment
- ✅ Edge function patterns
- ✅ Deprecated column names
- ✅ Required NOT NULL fields
- ✅ Guest user support
- ✅ CORS headers
- ✅ Error handling
- ✅ RLS policies

---

### 2. Edge Function Testing

**`test_all_edge_functions.sh`** (Linux/Mac) - Comprehensive edge function test suite

**`test_all_edge_functions.ps1`** (Windows) - PowerShell version

Tests all 7 edge functions with 28+ test cases covering error handling, validation, and schema alignment.

**Usage:**
```bash
# Linux/Mac
chmod +x scripts/test_all_edge_functions.sh
./scripts/test_all_edge_functions.sh

# Windows
.\scripts\test_all_edge_functions.ps1
```

**Requirements:**
- `SUPABASE_URL` environment variable
- `SUPABASE_ANON_KEY` environment variable
- curl (Bash version) or PowerShell 5.1+ (Windows version)

**Test Coverage:**
- create_order (5 tests)
- change_order_status (4 tests)
- generate_pickup_code (3 tests)
- migrate_guest_data (4 tests)
- report_user (4 tests)
- send_push (4 tests)
- upload_image_signed_url (4 tests)
- Schema alignment validation (3 checks)

---

### 3. Edge Function Testing (Automated - Legacy)

**`test_edge_functions_automated.sh`** - Original automated test script

**`test_edge_functions_automated.ps1`** - PowerShell version

Focused test suite for specific edge function scenarios.

**Usage:**
```bash
# Linux/Mac
./scripts/test_edge_functions_automated.sh

# Windows
.\scripts\test_edge_functions_automated.ps1
```

---

### 4. Database Scripts

**`004_payments_rls.sql`** - Payment RLS policies

**`004_payments_schema.sql`** - Payment schema

**`audit_schema.sql`** - Audit logging schema

**`generate_types.sh`** - Generate TypeScript types from database

**`setup_rls.sql`** - RLS policy setup

---

## 🚀 Quick Start

### Before Deploying Edge Functions

Run the full validation pipeline:

```bash
# 1. Validate schema
deno run --allow-env --allow-net --allow-read scripts/validate_schema.ts

# 2. Test edge functions
./scripts/test_all_edge_functions.sh  # or .ps1 on Windows

# 3. Run Flutter integration tests
flutter test integration_test/schema_validation_test.dart

# 4. If all pass, deploy
supabase functions deploy
```

---

## 🔧 Environment Setup

### Required Environment Variables

Create a `.env` file in the project root:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

Load environment variables:

```bash
# Linux/Mac
export $(cat .env | xargs)

# Windows PowerShell
Get-Content .env | ForEach-Object {
    $name, $value = $_.split('=')
    Set-Content env:\$name $value
}
```

---

## 📊 CI/CD Integration

These scripts are automatically run in GitHub Actions via `.github/workflows/validate-schema.yml`:

- **On push** to main/develop
- **On pull request** to main/develop
- **On changes** to edge functions or migrations
- **Manual trigger** via workflow dispatch

---

## 🐛 Troubleshooting

### Deno Not Found

Install Deno:
```bash
# Linux/Mac
curl -fsSL https://deno.land/install.sh | sh

# Windows
irm https://deno.land/install.ps1 | iex
```

### Permission Denied (Bash Scripts)

Make scripts executable:
```bash
chmod +x scripts/*.sh
```

### Environment Variables Not Set

Check if variables are loaded:
```bash
echo $SUPABASE_URL
echo $SUPABASE_ANON_KEY
```

### Schema Validation Fails

1. Check `DATABASE_SCHEMA.md` for correct column names
2. Review `EDGE_FUNCTION_CONTRACTS.md` for API contracts
3. See `COMMON_PITFALLS.md` for common issues

---

## 📚 Documentation

- **`DATABASE_SCHEMA.md`** - Complete schema reference
- **`EDGE_FUNCTION_CONTRACTS.md`** - API contracts for all functions
- **`SCHEMA_QUICK_REFERENCE.md`** - Quick lookup guide
- **`TEST_EDGE_FUNCTIONS.md`** - Manual testing guide
- **`COMMON_PITFALLS.md`** - Schema mismatch patterns
- **`PHASE_7_AUTOMATED_VALIDATION_COMPLETION.md`** - Phase 7 completion summary

---

## 🎯 Best Practices

### Before Every Deployment

1. ✅ Run schema validation
2. ✅ Run edge function tests
3. ✅ Check for deprecated column names
4. ✅ Verify guest user support
5. ✅ Review test results

### During Development

1. ✅ Keep `EXPECTED_SCHEMAS` in sync with migrations
2. ✅ Add test cases for new edge functions
3. ✅ Update documentation when schema changes
4. ✅ Run validation locally before pushing

### After Deployment

1. ✅ Monitor logs for errors
2. ✅ Verify edge functions are accessible
3. ✅ Test critical flows manually
4. ✅ Check RLS policies are working

---

## 🆘 Support

For issues or questions:

1. Check the documentation in the root directory
2. Review CI/CD logs in GitHub Actions
3. Run validation scripts locally for detailed errors
4. See `COMPREHENSIVE_SCHEMA_FIX_PLAN.md` for the complete plan

---

**Last Updated:** 2025-11-23  
**Phase:** 7 - Automated Validation Complete
