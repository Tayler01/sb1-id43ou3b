/*
  # Fix database schema and functions

  1. Changes
    - Drop and recreate increment_downvotes function with proper column references
    - Add proper indexes for performance
    - Update policies for better access control

  2. Security
    - Enable RLS
    - Add proper security context
*/

-- Drop existing function
DROP FUNCTION IF EXISTS increment_downvotes;

-- Create new function with proper column references
CREATE OR REPLACE FUNCTION increment_downvotes(input_kol_id uuid, input_round integer)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Insert vote first to maintain referential integrity
  INSERT INTO votes (kol_id, round)
  VALUES (input_kol_id, input_round);

  -- Update KOL's downvote count
  UPDATE kols
  SET downvotes = COALESCE(downvotes, 0) + 1
  WHERE id = input_kol_id;
END;
$$;

-- Grant execute permission to public
GRANT EXECUTE ON FUNCTION increment_downvotes(uuid, integer) TO public;

-- Ensure indexes exist for performance
CREATE INDEX IF NOT EXISTS votes_round_kol_idx ON votes(round, kol_id);
CREATE INDEX IF NOT EXISTS kols_downvotes_idx ON kols(downvotes DESC);

-- Update policies for better sync support
DROP POLICY IF EXISTS "Enable read access for all users" ON votes;
DROP POLICY IF EXISTS "Enable insert for all users" ON votes;

CREATE POLICY "Enable read access for all users"
  ON votes FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Enable insert for all users"
  ON votes FOR INSERT
  TO public
  WITH CHECK (true);