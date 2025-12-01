-- Add missing open_hours column to vendors table
-- This column was defined in base_schema but may be missing in production

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'vendors' 
        AND column_name = 'open_hours'
    ) THEN
        ALTER TABLE public.vendors ADD COLUMN open_hours JSONB DEFAULT '{}'::JSONB;
        RAISE NOTICE 'Added open_hours column to vendors table';
    ELSE
        RAISE NOTICE 'open_hours column already exists';
    END IF;
END $$;
