-- ============================================
-- COMPREHENSIVE SCHEMA AUDIT SCRIPT
-- ============================================
-- Purpose: Identify all potential schema issues before they cause runtime errors
-- Run this against your Supabase database

-- ============================================
-- 1. ORDERS TABLE AUDIT
-- ============================================
SELECT 
  'orders' as table_name,
  column_name,
  data_type,
  is_nullable,
  column_default,
  CASE 
    WHEN is_nullable = 'NO' AND column_default IS NULL THEN '⚠️ REQUIRED'
    ELSE '✓ OK'
  END as status
FROM information_schema.columns
WHERE table_name = 'orders'
ORDER BY ordinal_position;

-- ============================================
-- 2. ORDER_ITEMS TABLE AUDIT
-- ============================================
SELECT 
  'order_items' as table_name,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'order_items'
ORDER BY ordinal_position;

-- ============================================
-- 3. MESSAGES TABLE AUDIT (Guest Support)
-- ============================================
SELECT 
  'messages' as table_name,
  column_name,
  data_type,
  is_nullable,
  column_default,
  CASE 
    WHEN column_name IN ('sender_id', 'guest_sender_id') THEN '👤 USER FIELD'
    WHEN is_nullable = 'NO' THEN '⚠️ REQUIRED'
    ELSE '✓ OK'
  END as notes
FROM information_schema.columns
WHERE table_name = 'messages'
ORDER BY ordinal_position;

-- ============================================
-- 4. GUEST_SESSIONS TABLE AUDIT
-- ============================================
SELECT 
  'guest_sessions' as table_name,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'guest_sessions'
ORDER BY ordinal_position;

-- ============================================
-- 5. RLS POLICIES AUDIT
-- ============================================
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd as command,
  CASE 
    WHEN cmd = 'INSERT' THEN '📝 CREATE'
    WHEN cmd = 'SELECT' THEN '👁️ READ'
    WHEN cmd = 'UPDATE' THEN '✏️ MODIFY'
    WHEN cmd = 'DELETE' THEN '🗑️ DELETE'
    WHEN cmd = 'ALL' THEN '🔓 ALL ACCESS'
    ELSE cmd
  END as operation
FROM pg_policies
WHERE tablename IN ('orders', 'order_items', 'messages', 'guest_sessions', 'vendors', 'dishes')
ORDER BY tablename, cmd;

-- ============================================
-- 6. MISSING RLS POLICIES CHECK
-- ============================================
-- Tables that should have guest INSERT policies
SELECT 
  table_name,
  CASE 
    WHEN table_name IN (
      SELECT DISTINCT tablename 
      FROM pg_policies 
      WHERE cmd = 'INSERT' AND tablename = t.table_name
    ) THEN '✓ HAS INSERT POLICY'
    ELSE '⚠️ MISSING INSERT POLICY'
  END as insert_policy_status
FROM information_schema.tables t
WHERE table_schema = 'public' 
  AND table_name IN ('guest_sessions', 'orders', 'order_items', 'messages')
  AND table_type = 'BASE TABLE';

-- ============================================
-- 7. FOREIGN KEY CONSTRAINTS
-- ============================================
SELECT
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name,
  '🔗 FK' as constraint_type
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name IN ('orders', 'order_items', 'messages')
ORDER BY tc.table_name, kcu.column_name;

-- ============================================
-- 8. CHECK CONSTRAINTS (Data Validation)
-- ============================================
SELECT
  tc.table_name,
  tc.constraint_name,
  cc.check_clause,
  '✓ VALIDATION RULE' as type
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc
  ON tc.constraint_name = cc.constraint_name
WHERE tc.table_name IN ('orders', 'vendors', 'dishes', 'messages')
ORDER BY tc.table_name;

-- ============================================
-- 9. COLUMN NAME COMPARISON
-- ============================================
-- Common column name variations that cause issues
SELECT 
  table_name,
  column_name,
  CASE
    WHEN column_name ILIKE '%address%' THEN '📍 ADDRESS FIELD - Check: delivery_address vs pickup_address'
    WHEN column_name ILIKE '%time%' THEN '⏰ TIME FIELD - Check: pickup_time vs estimated_fulfillment_time'
    WHEN column_name ILIKE '%total%' THEN '💰 TOTAL FIELD - Check: total_cents vs total_amount'
    WHEN column_name ILIKE '%sender%' THEN '👤 SENDER FIELD - Check: sender_id vs guest_sender_id'
    WHEN column_name ILIKE '%role%' THEN '🎭 ROLE FIELD - Check: sender_role vs sender_type'
    ELSE '✓ OK'
  END as potential_issue
FROM information_schema.columns
WHERE table_name IN ('orders', 'messages', 'order_items')
  AND (
    column_name ILIKE '%address%' OR
    column_name ILIKE '%time%' OR
    column_name ILIKE '%total%' OR
    column_name ILIKE '%sender%' OR
    column_name ILIKE '%role%'
  )
ORDER BY table_name, column_name;

-- ============================================
-- 10. INDEXES AUDIT (Performance)
-- ============================================
SELECT
  schemaname,
  tablename,
  indexname,
  indexdef,
  '⚡ INDEX' as type
FROM pg_indexes
WHERE tablename IN ('orders', 'order_items', 'messages', 'dishes', 'vendors')
  AND schemaname = 'public'
ORDER BY tablename, indexname;

-- ============================================
-- SUMMARY: CRITICAL FINDINGS
-- ============================================
-- Run this to get a quick summary
SELECT 
  'CRITICAL CHECKS' as category,
  COUNT(*) FILTER (WHERE is_nullable = 'NO' AND column_default IS NULL) as required_fields_count,
  COUNT(*) FILTER (WHERE column_name ILIKE '%guest%') as guest_support_fields,
  COUNT(*) FILTER (WHERE column_name IN ('delivery_address', 'pickup_time', 'sender_role')) as deprecated_columns
FROM information_schema.columns
WHERE table_name IN ('orders', 'messages', 'order_items');
