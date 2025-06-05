/*
  # Fix LARP table for real-time updates

  1. Changes
    - Drop and recreate larps table with proper structure
    - Add proper constraints and indexes
    - Update RLS policies for real-time sync

  2. Security
    - Enable RLS with proper policies
    - Allow public read/write access
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

-- Create policies for real-time sync
CREATE POLICY "Enable read access for all users"
  ON larps FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Enable insert for all users"
  ON larps FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Enable update for all users"
  ON larps FOR UPDATE
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Enable delete for all users"
  ON larps FOR DELETE
  TO public
  USING (true);