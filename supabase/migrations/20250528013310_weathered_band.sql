/*
  # Update larps table for global tracking

  1. Changes
    - Recreate larps table with proper structure
    - Add constraints for global uniqueness
    - Update policies for proper access control
    - Add indexes for performance

  2. Security
    - Enable RLS
    - Add policies for public read/write with proper constraints
*/

-- Drop existing table
DROP TABLE IF EXISTS larps CASCADE;

-- Create new larps table
CREATE TABLE larps (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  round integer NOT NULL,
  kol_id uuid REFERENCES kols(id) ON DELETE CASCADE,
  twitter_handle text NOT NULL,
  name text,
  profile_img text,
  twitter_url text,
  reason text,
  downvotes integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT unique_round UNIQUE (round)
);

-- Create indexes
CREATE INDEX larps_round_idx ON larps(round);
CREATE INDEX larps_created_at_idx ON larps(created_at);

-- Enable RLS
ALTER TABLE larps ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow public read" ON larps;
DROP POLICY IF EXISTS "Allow public insert" ON larps;
DROP POLICY IF EXISTS "Enable read access for all users" ON larps;
DROP POLICY IF EXISTS "Enable insert for all users" ON larps;
DROP POLICY IF EXISTS "Enable update for all users" ON larps;

-- Create new policies
CREATE POLICY "Allow public read"
  ON larps FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow public insert"
  ON larps FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Allow public update"
  ON larps FOR UPDATE
  TO public
  USING (true)
  WITH CHECK (true);