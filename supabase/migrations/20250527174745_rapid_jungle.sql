/*
  # Create larps table

  1. New Tables
    - `larps`
      - `id` (uuid, primary key)
      - `round` (integer)
      - `kol_id` (uuid, references kols.id)
      - `twitter_handle` (text)
      - `name` (text)
      - `profile_img` (text)
      - `twitter_url` (text)
      - `reason` (text)
      - `downvotes` (integer)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on `larps` table
    - Add policies for:
      - Public read access
      - Public insert access
*/

CREATE TABLE IF NOT EXISTS larps (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  round integer NOT NULL,
  kol_id uuid REFERENCES kols(id),
  twitter_handle text NOT NULL,
  name text,
  profile_img text,
  twitter_url text,
  reason text,
  downvotes integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE larps ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Allow public read"
  ON larps
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow public insert"
  ON larps
  FOR INSERT
  TO public
  WITH CHECK (true);

-- Create index on round for faster queries
CREATE INDEX IF NOT EXISTS larps_round_idx ON larps(round);

-- Create index on created_at for faster ordering
CREATE INDEX IF NOT EXISTS larps_created_at_idx ON larps(created_at);