/*
  # Optimize vote tracking and add indexes

  1. Changes
    - Add composite index for efficient vote counting
    - Add index for round-based queries
    - Update RLS policies for better real-time sync

  2. Security
    - Maintain RLS policies for public access
    - Ensure proper access control
*/

-- Add composite index for vote counting
CREATE INDEX IF NOT EXISTS votes_round_kol_idx ON votes(round, kol_id);

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON votes;
DROP POLICY IF EXISTS "Enable insert for all users" ON votes;

-- Create new policies with better sync support
CREATE POLICY "Enable read access for all users"
  ON votes FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Enable insert for all users"
  ON votes FOR INSERT
  TO public
  WITH CHECK (true);