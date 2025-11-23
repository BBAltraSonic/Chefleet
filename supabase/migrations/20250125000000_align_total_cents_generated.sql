BEGIN;

-- Drop dependent views before altering the orders table
DROP VIEW IF EXISTS order_analytics;
DROP VIEW IF EXISTS database_statistics;
DROP VIEW IF EXISTS orders_v1;
DROP MATERIALIZED VIEW IF EXISTS vendor_performance_metrics;

-- Normalize existing rows so component amounts are never NULL
UPDATE orders
SET
    subtotal_cents = COALESCE(subtotal_cents, 0),
    tax_cents = COALESCE(tax_cents, 0),
    delivery_fee_cents = COALESCE(delivery_fee_cents, 0),
    service_fee_cents = COALESCE(service_fee_cents, 0),
    tip_cents = COALESCE(tip_cents, 0);

-- Enforce NOT NULL + default 0 for all component columns
ALTER TABLE orders
  ALTER COLUMN subtotal_cents SET DEFAULT 0,
  ALTER COLUMN subtotal_cents SET NOT NULL,
  ALTER COLUMN tax_cents SET DEFAULT 0,
  ALTER COLUMN tax_cents SET NOT NULL,
  ALTER COLUMN delivery_fee_cents SET DEFAULT 0,
  ALTER COLUMN delivery_fee_cents SET NOT NULL,
  ALTER COLUMN service_fee_cents SET DEFAULT 0,
  ALTER COLUMN service_fee_cents SET NOT NULL,
  ALTER COLUMN tip_cents SET DEFAULT 0,
  ALTER COLUMN tip_cents SET NOT NULL;

-- Recreate total_cents as a generated column so it is always derived server-side
ALTER TABLE orders
  DROP COLUMN IF EXISTS total_cents;

ALTER TABLE orders
  ADD COLUMN total_cents INTEGER
    GENERATED ALWAYS AS (
      COALESCE(subtotal_cents, 0)
      + COALESCE(tax_cents, 0)
      + COALESCE(delivery_fee_cents, 0)
      + COALESCE(service_fee_cents, 0)
      + COALESCE(tip_cents, 0)
    ) STORED;

-- Recreate dependent views with the current schema
CREATE VIEW order_analytics AS
SELECT
  date_trunc('day', o.created_at) AS order_date,
  v.id AS vendor_id,
  v.business_name,
  COUNT(*) AS total_orders,
  SUM(o.total_cents) AS revenue_cents,
  AVG(o.total_cents) AS avg_order_value_cents,
  COUNT(*) FILTER (WHERE o.status = 'completed') AS completed_orders,
  COUNT(*) FILTER (WHERE o.status = 'cancelled') AS cancelled_orders
FROM orders o
JOIN vendors v ON o.vendor_id = v.id
GROUP BY date_trunc('day', o.created_at), v.id, v.business_name;

CREATE VIEW database_statistics AS
SELECT 'Users'::text AS category,
  jsonb_build_object(
    'total_users', (SELECT count(*) FROM users),
    'public_profiles', (SELECT count(*) FROM users_public),
    'active_vendors', (SELECT count(*) FROM vendors WHERE status = 'active'),
    'buyers', (SELECT count(*) FROM users WHERE role = 'buyer'),
    'vendors', (SELECT count(*) FROM users WHERE role = 'vendor')
  ) AS stats
UNION ALL
SELECT 'Orders'::text AS category,
  jsonb_build_object(
    'total_orders', (SELECT count(*) FROM orders),
    'pending_orders', (SELECT count(*) FROM orders WHERE status = 'pending'),
    'active_orders', (SELECT count(*) FROM orders WHERE status IN ('pending','accepted','preparing','ready')),
    'completed_orders', (SELECT count(*) FROM orders WHERE status = 'completed'),
    'cancelled_orders', (SELECT count(*) FROM orders WHERE status = 'cancelled'),
    'total_revenue_cents', (SELECT COALESCE(sum(total_cents),0) FROM orders WHERE status = 'completed')
  ) AS stats
UNION ALL
SELECT 'Content'::text AS category,
  jsonb_build_object(
    'total_vendors', (SELECT count(*) FROM vendors),
    'active_vendors', (SELECT count(*) FROM vendors WHERE status = 'active'),
    'total_dishes', (SELECT count(*) FROM dishes),
    'available_dishes', (SELECT count(*) FROM dishes WHERE available = true),
    'featured_dishes', (SELECT count(*) FROM dishes WHERE is_featured = true),
    'total_messages', (SELECT count(*) FROM messages)
  ) AS stats
UNION ALL
SELECT 'System'::text AS category,
  jsonb_build_object(
    'total_audit_logs', (SELECT count(*) FROM audit_logs),
    'moderation_reports', (SELECT count(*) FROM moderation_reports),
    'device_tokens', (SELECT count(*) FROM device_tokens),
    'unread_notifications', (SELECT count(*) FROM notifications WHERE read_at IS NULL)
  ) AS stats;

CREATE VIEW orders_v1 AS
SELECT
  id,
  buyer_id,
  vendor_id,
  status,
  total_cents,
  total_amount,
  COALESCE(special_instructions, '') AS special_instructions,
  COALESCE(notes, '') AS notes,
  pickup_code,
  pickup_code_expires_at,
  idempotency_key,
  created_at,
  updated_at,
  COALESCE(subtotal_cents, 0) AS subtotal_cents,
  COALESCE(tax_cents, 0) AS tax_cents,
  COALESCE(delivery_fee_cents, 0) AS delivery_fee_cents,
  COALESCE(service_fee_cents, 0) AS service_fee_cents,
  COALESCE(tip_cents, 0) AS tip_cents,
  COALESCE(fulfillment_method, 'pickup') AS fulfillment_method,
  cancellation_reason,
  cancelled_by,
  cancelled_at,
  COALESCE(cash_payment_confirmed, false) AS cash_payment_confirmed,
  cash_payment_notes
FROM orders;

CREATE MATERIALIZED VIEW vendor_performance_metrics AS
SELECT
  v.id AS vendor_id,
  v.business_name,
  COUNT(DISTINCT o.id) AS total_orders,
  COUNT(DISTINCT o.id) FILTER (WHERE o.status = 'completed') AS completed_orders,
  COUNT(DISTINCT o.id) FILTER (WHERE o.status = 'cancelled') AS cancelled_orders,
  ROUND(
    (COALESCE(COUNT(DISTINCT o.id) FILTER (WHERE o.status = 'completed'),0)::numeric /
     NULLIF(COUNT(DISTINCT o.id), 0)::numeric) * 100,
    2
  ) AS completion_rate_percent,
  AVG(CASE WHEN o.status = 'completed' THEN o.total_cents ELSE NULL END) AS avg_order_value_cents,
  SUM(CASE WHEN o.status = 'completed' THEN o.total_cents ELSE NULL END) AS total_revenue_cents,
  AVG(
    EXTRACT(EPOCH FROM (o.actual_fulfillment_time - o.created_at)) / 60
  ) FILTER (WHERE o.actual_fulfillment_time IS NOT NULL) AS avg_fulfillment_time_minutes,
  v.rating,
  v.review_count,
  v.created_at AS vendor_since
FROM vendors v
LEFT JOIN orders o ON v.id = o.vendor_id
WHERE v.status = 'active'
GROUP BY v.id, v.business_name, v.rating, v.review_count, v.created_at;

COMMIT;
