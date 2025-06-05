-- Drop existing policies
DROP POLICY IF EXISTS "Allow public read" ON larps;
DROP POLICY IF EXISTS "Allow public insert" ON larps;
DROP POLICY IF EXISTS "Allow public update" ON larps;

-- Create new policies with proper access control
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

-- Ensure indexes exist for performance
CREATE INDEX IF NOT EXISTS larps_round_idx ON larps(round);
CREATE INDEX IF NOT EXISTS larps_created_at_idx ON larps(created_at);

-- Drop and recreate unique constraint
ALTER TABLE larps DROP CONSTRAINT IF EXISTS unique_round;
ALTER TABLE larps ADD CONSTRAINT unique_round UNIQUE (round);