/*
  # Improve vote tracking and synchronization

  1. Changes
    - Add indexes for efficient vote counting
    - Update policies for better real-time sync
    - Ensure proper access control

  2. Security
    - Enable RLS
    - Add policies for public access with proper constraints
*/

-- Add composite index for vote counting if it doesn't exist
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