/*
  # Add votes table to track votes per round

  1. New Tables
    - `votes`
      - `id` (uuid, primary key)
      - `kol_id` (uuid, references kols.id)
      - `round` (integer)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS
    - Add policies for public access
*/

CREATE TABLE IF NOT EXISTS votes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  kol_id uuid REFERENCES kols(id) ON DELETE CASCADE,
  round integer NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX votes_round_idx ON votes(round);
CREATE INDEX votes_kol_id_idx ON votes(kol_id);
CREATE INDEX votes_created_at_idx ON votes(created_at);

-- Enable RLS
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users"
  ON votes FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Enable insert for all users"
  ON votes FOR INSERT
  TO public
  WITH CHECK (true);