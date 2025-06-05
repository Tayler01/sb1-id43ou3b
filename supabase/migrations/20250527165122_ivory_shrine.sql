/*
  # Consolidate larps table structure and policies

  1. Table Structure
    - Ensure proper constraints and indexes
    - Add cascade deletion for related KOLs
    - Maintain unique round constraint

  2. Security
    - Enable RLS
    - Set up proper policies for all operations
*/

-- Recreate larps table with proper structure
DROP TABLE IF EXISTS larps;

CREATE TABLE larps (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  round integer NOT NULL,
  kol_id uuid REFERENCES kols(id) ON DELETE CASCADE,
  twitter_handle text,
  name text,
  profile_img text,
  twitter_url text,
  reason text,
  downvotes integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Add constraints and indexes
ALTER TABLE larps ADD CONSTRAINT unique_round UNIQUE (round);
CREATE INDEX idx_larps_round ON larps(round);

-- Enable RLS
ALTER TABLE larps ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users"
  ON larps FOR SELECT
  USING (true);

CREATE POLICY "Enable insert for all users"
  ON larps FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable update for all users"
  ON larps FOR UPDATE
  USING (true)
  WITH CHECK (true);