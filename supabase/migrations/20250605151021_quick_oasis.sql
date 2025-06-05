/*
  # Add downvotes tracking table

  1. New Tables
    - `downvotes`
      - `id` (uuid, primary key)
      - `kol_id` (uuid, references kols.id)
      - `round` (integer)
      - `count` (integer)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS
    - Add policies for public access
    - Add trigger for updated_at timestamp
*/

-- Create downvotes table if it doesn't exist
CREATE TABLE IF NOT EXISTS downvotes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  kol_id uuid REFERENCES kols(id) ON DELETE CASCADE,
  round integer NOT NULL,
  count integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT downvotes_kol_id_round_key UNIQUE (kol_id, round)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS downvotes_kol_id_idx ON downvotes(kol_id);
CREATE INDEX IF NOT EXISTS downvotes_round_idx ON downvotes(round);
CREATE INDEX IF NOT EXISTS downvotes_count_idx ON downvotes(count DESC);

-- Enable RLS
ALTER TABLE downvotes ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Enable read access for all users" ON downvotes;
DROP POLICY IF EXISTS "Enable insert for all users" ON downvotes;
DROP POLICY IF EXISTS "Enable update for all users" ON downvotes;

-- Create policies
CREATE POLICY "Enable read access for all users"
  ON downvotes FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Enable insert for all users"
  ON downvotes FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Enable update for all users"
  ON downvotes FOR UPDATE
  TO public
  USING (true)
  WITH CHECK (true);

-- Create updated increment_downvotes function
CREATE OR REPLACE FUNCTION increment_downvotes(
  input_kol_id uuid,
  input_round integer
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Insert vote record
  INSERT INTO votes (kol_id, round)
  VALUES (input_kol_id, input_round);

  -- Update or insert downvote count for the round
  INSERT INTO downvotes (kol_id, round, count)
  VALUES (input_kol_id, input_round, 1)
  ON CONFLICT (kol_id, round)
  DO UPDATE SET 
    count = downvotes.count + 1,
    updated_at = now();

  -- Update total downvotes in kols table
  UPDATE kols
  SET downvotes = COALESCE(downvotes, 0) + 1
  WHERE id = input_kol_id;
END;
$$;

-- Grant execute permission to public
GRANT EXECUTE ON FUNCTION increment_downvotes(uuid, integer) TO public;

-- Create trigger function for timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
DROP TRIGGER IF EXISTS set_timestamp ON downvotes;
CREATE TRIGGER set_timestamp
  BEFORE UPDATE ON downvotes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();