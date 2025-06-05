-- Create votes table if it doesn't exist
CREATE TABLE IF NOT EXISTS votes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  kol_id uuid REFERENCES kols(id) ON DELETE CASCADE,
  round integer NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create indexes if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'votes_round_idx') THEN
    CREATE INDEX votes_round_idx ON votes(round);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'votes_kol_id_idx') THEN
    CREATE INDEX votes_kol_id_idx ON votes(kol_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'votes_created_at_idx') THEN
    CREATE INDEX votes_created_at_idx ON votes(created_at);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'votes_round_kol_idx') THEN
    CREATE INDEX votes_round_kol_idx ON votes(round, kol_id);
  END IF;
END $$;

-- Enable RLS
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Enable read access for all users" ON votes;
DROP POLICY IF EXISTS "Enable insert for all users" ON votes;

-- Create policies
CREATE POLICY "Enable read access for all users"
  ON votes FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Enable insert for all users"
  ON votes FOR INSERT
  TO public
  WITH CHECK (true);