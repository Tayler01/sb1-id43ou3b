/*
  # Fix ambiguous kol_id reference

  1. Changes
    - Drop and recreate increment_downvotes function with properly qualified column references
    - Add explicit table aliases to avoid ambiguous column references
    - Ensure atomic transaction for vote insertion and downvote increment
  
  2. Security
    - Maintain existing security context
    - Function remains accessible to all authenticated users
*/

-- Drop the existing function if it exists
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_proc WHERE proname = 'increment_downvotes'
  ) THEN
    DROP FUNCTION increment_downvotes;
  END IF;
END $$;

-- Recreate the function with proper column qualification
CREATE OR REPLACE FUNCTION increment_downvotes(kol_id_param uuid, round_number integer)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Insert vote record
  INSERT INTO votes (kol_id, round)
  VALUES (kol_id_param, round_number);

  -- Update downvotes count with properly qualified column reference
  UPDATE kols k
  SET downvotes = k.downvotes + 1
  WHERE k.id = kol_id_param;
END;
$$;