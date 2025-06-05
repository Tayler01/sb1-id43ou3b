/*
  # Add increment_downvotes function
  
  1. New Functions
    - `increment_downvotes(kol_id UUID, round_number INTEGER)`
      - Increments the downvote counter for a KOL in a specific round
      - Returns the updated downvote count
      - Handles both the `kols` and `larps` tables
  
  2. Security
    - Function is set as SECURITY DEFINER to run with elevated privileges
    - Access is granted to public role for authenticated and anonymous users
*/

-- Create the increment_downvotes function
CREATE OR REPLACE FUNCTION public.increment_downvotes(kol_id UUID, round_number INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  new_downvotes INTEGER;
BEGIN
  -- Update downvotes in kols table
  UPDATE public.kols
  SET downvotes = COALESCE(downvotes, 0) + 1
  WHERE id = kol_id
  RETURNING downvotes INTO new_downvotes;

  -- Update downvotes in larps table for the specific round
  UPDATE public.larps
  SET downvotes = COALESCE(downvotes, 0) + 1
  WHERE kol_id = kol_id AND round = round_number;

  RETURN new_downvotes;
END;
$$;

-- Grant execute permission to public
GRANT EXECUTE ON FUNCTION public.increment_downvotes(UUID, INTEGER) TO public;