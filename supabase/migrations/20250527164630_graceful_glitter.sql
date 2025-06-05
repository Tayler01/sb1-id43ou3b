/*
  # Update LARP table constraints and policies

  1. Changes
    - Add unique constraint on round column
    - Update foreign key to cascade on delete
    - Simplify RLS policies for better access control

  2. Security
    - Enable public read/write access with appropriate constraints
    - Ensure data integrity with proper foreign key relationships
*/

-- Add unique constraint on round if it doesn't exist
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'unique_round'
  ) THEN
    ALTER TABLE larps ADD CONSTRAINT unique_round UNIQUE (round);
  END IF;
END $$;

-- Update foreign key to cascade
ALTER TABLE larps DROP CONSTRAINT IF EXISTS larps_kol_id_fkey;
ALTER TABLE larps ADD CONSTRAINT larps_kol_id_fkey 
  FOREIGN KEY (kol_id) 
  REFERENCES kols(id) 
  ON DELETE CASCADE;

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