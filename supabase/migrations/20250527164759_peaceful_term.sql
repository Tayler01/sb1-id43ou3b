/*
  # Fix LARP table structure and policies

  1. Changes
    - Ensure unique round constraint
    - Update foreign key relationship
    - Simplify policies for better access control
    - Add indexes for performance

  2. Security
    - Enable RLS
    - Add policies for public access
*/

-- Drop existing constraints if they exist
ALTER TABLE larps DROP CONSTRAINT IF EXISTS unique_round;
ALTER TABLE larps DROP CONSTRAINT IF EXISTS larps_kol_id_fkey;

-- Add constraints
ALTER TABLE larps ADD CONSTRAINT unique_round UNIQUE (round);
ALTER TABLE larps ADD CONSTRAINT larps_kol_id_fkey 
  FOREIGN KEY (kol_id) 
  REFERENCES kols(id) 
  ON DELETE CASCADE;

-- Add index for round queries
CREATE INDEX IF NOT EXISTS idx_larps_round ON larps(round);

-- Enable RLS
ALTER TABLE larps ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON larps;
DROP POLICY IF EXISTS "Enable insert for all users" ON larps;
DROP POLICY IF EXISTS "Enable update for all users" ON larps;

-- Create new policies
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