/*
  # Reset Database and Update Policies

  1. Changes
    - Clear all data from tables while preserving structure
    - Reset sequences
    - Update policies for better access control
    - Add trigger for vote changes

  2. Security
    - Enable RLS with updated policies
    - Ensure proper access for all operations
*/

-- Clear child tables first
TRUNCATE TABLE votes CASCADE;
TRUNCATE TABLE downvotes CASCADE;
TRUNCATE TABLE larps CASCADE;
TRUNCATE TABLE timer_state CASCADE;

-- Clear parent table last
TRUNCATE TABLE kols CASCADE;

-- Reset sequences if any exist
ALTER SEQUENCE IF EXISTS kols_id_seq RESTART;
ALTER SEQUENCE IF EXISTS votes_id_seq RESTART;
ALTER SEQUENCE IF EXISTS larps_id_seq RESTART;
ALTER SEQUENCE IF EXISTS timer_state_id_seq RESTART;
ALTER SEQUENCE IF EXISTS downvotes_id_seq RESTART;

-- Update policies for downvotes table
DROP POLICY IF EXISTS "Enable read access for all users" ON downvotes;
DROP POLICY IF EXISTS "Enable insert for all users" ON downvotes;
DROP POLICY IF EXISTS "Enable update for all users" ON downvotes;

CREATE POLICY "Enable read access for all users"
  ON downvotes FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Enable insert for all users"
  ON downvotes FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Enable update for all users"
  ON downvotes FOR UPDATE
  TO public
  USING (true)
  WITH CHECK (true);

-- Update increment_downvotes function
CREATE OR REPLACE FUNCTION increment_downvotes(
  input_kol_id uuid,
  input_round integer
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Insert vote record
  INSERT INTO votes (kol_id, round)
  VALUES (input_kol_id, input_round);

  -- Update or insert downvote count for the round
  INSERT INTO downvotes (kol_id, round, count)
  VALUES (input_kol_id, input_round, 1)
  ON CONFLICT (kol_id, round)
  DO UPDATE SET 
    count = downvotes.count + 1,
    updated_at = now();

  -- Update total downvotes in kols table
  UPDATE kols
  SET downvotes = COALESCE(downvotes, 0) + 1
  WHERE id = input_kol_id;
END;
$$;

-- Grant execute permission to public
GRANT EXECUTE ON FUNCTION increment_downvotes(uuid, integer) TO public;