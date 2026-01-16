-- Migration: Add notification_preferences to users_public
-- Date: 2025-02-13
-- Description: Ensures notification_preferences column exists with proper defaults

-- Add notification_preferences column if it doesn't exist
ALTER TABLE users_public
ADD COLUMN IF NOT EXISTS notification_preferences JSONB 
DEFAULT '{"order_updates": true, "chat_messages": true, "promotions": false, "vendor_updates": false, "push_enabled": true, "email_enabled": true, "sms_enabled": false}'::jsonb;

-- Backfill existing rows that might have NULL values
UPDATE users_public
SET notification_preferences = '{"order_updates": true, "chat_messages": true, "promotions": false, "vendor_updates": false, "push_enabled": true, "email_enabled": true, "sms_enabled": false}'::jsonb
WHERE notification_preferences IS NULL;

-- Add comment for documentation
COMMENT ON COLUMN users_public.notification_preferences IS 'User notification preferences for different notification types and delivery methods';
