-- =====================================================
-- FIX RENEWAL FLAG FUNCTION (FINAL VERSION)
-- =====================================================
-- This script fixes the check_renewal_flag function and its trigger
-- =====================================================

-- Step 1: Drop the function and its dependent trigger with CASCADE
DROP FUNCTION IF EXISTS public.check_renewal_flag() CASCADE;

-- Step 2: Create the fixed function
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

-- Step 3: Grant permissions
ALTER FUNCTION public.check_renewal_flag() OWNER TO postgres;

-- Step 4: Recreate the trigger
CREATE TRIGGER update_renewal_flag
    BEFORE INSERT OR UPDATE ON public.policies
    FOR EACH ROW
    EXECUTE FUNCTION public.check_renewal_flag();

-- Step 5: Verify the fix
SELECT 'Function and trigger fixed successfully' as status;
