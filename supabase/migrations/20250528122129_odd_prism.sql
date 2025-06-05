/*
  # Add indexes for vote tracking

  1. Changes
    - Add indexes to votes table for better performance
    - Update RLS policies for better access control

  2. Security
    - Enable RLS
    - Add policies for public access
*/

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS votes_round_kol_idx ON votes(round, kol_id);

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON votes;
DROP POLICY IF EXISTS "Enable insert for all users" ON votes;

-- Create new policies
CREATE POLICY "Enable read access for all users"
  ON votes FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Enable insert for all users"
  ON votes FOR INSERT
  TO public
  WITH CHECK (true);