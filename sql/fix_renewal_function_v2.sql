-- =====================================================
-- FIX RENEWAL FLAG FUNCTION (VERSION 2)
-- =====================================================
-- This script fixes the check_renewal_flag function with proper type handling
-- =====================================================

-- Drop the existing function if it exists
DROP FUNCTION IF EXISTS public.check_renewal_flag();

-- Create the fixed function with proper type handling
CREATE OR REPLACE FUNCTION public.check_renewal_flag()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.end_date IS NOT NULL THEN
        -- Fix: Explicitly cast the date difference to interval for comparison
        NEW.renewal_flag := ((NEW.end_date - CURRENT_DATE)::interval) <= INTERVAL '60 days';
    END IF;
    RETURN NEW;
END;
$$;

-- Grant permissions
ALTER FUNCTION public.check_renewal_flag() OWNER TO postgres;

-- Check if the function was created successfully
SELECT 'Function check_renewal_flag fixed successfully' as status;
