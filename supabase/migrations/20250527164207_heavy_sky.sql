/*
  # Update LARP policies and constraints

  1. Changes
    - Add unique constraint on round to prevent duplicates
    - Update RLS policies for better access control
    - Add cascading delete for KOL references

  2. Security
    - Enable RLS
    - Allow public read access
    - Allow public insert/update for LARP tracking
*/

-- Add unique constraint on round
ALTER TABLE larps ADD CONSTRAINT unique_round UNIQUE (round);

-- Drop existing policies
DROP POLICY IF EXISTS "Allow public read" ON larps;
DROP POLICY IF EXISTS "Allow insert for authenticated users" ON larps;

-- Update foreign key to cascade
ALTER TABLE larps DROP CONSTRAINT IF EXISTS larps_kol_id_fkey;
ALTER TABLE larps ADD CONSTRAINT larps_kol_id_fkey 
  FOREIGN KEY (kol_id) 
  REFERENCES kols(id) 
  ON DELETE CASCADE;

-- New policies
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