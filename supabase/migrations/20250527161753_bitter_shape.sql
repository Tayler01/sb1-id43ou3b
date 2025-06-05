/*
  # Create larps table for storing round winners

  1. New Tables
    - `larps`
      - `id` (uuid, primary key)
      - `round` (int, not null) - Round number when crowned
      - `kol_id` (uuid, references kols.id) - Winner's KOL ID
      - `twitter_handle` (text) - Denormalized for quick access
      - `name` (text) - Denormalized for quick access
      - `profile_img` (text) - Denormalized for quick access
      - `twitter_url` (text) - Denormalized for quick access
      - `reason` (text) - Denormalized for quick access
      - `downvotes` (int) - Snapshot of downvotes when crowned
      - `created_at` (timestamptz) - When crowned

  2. Security
    - Enable RLS on `larps` table
    - Add policies for:
      - Public read access
      - Insert access for authenticated users only
*/

CREATE TABLE IF NOT EXISTS larps (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  round int NOT NULL,
  kol_id uuid REFERENCES kols(id),
  twitter_handle text,
  name text,
  profile_img text,
  twitter_url text,
  reason text,
  downvotes int,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE larps ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read"
  ON larps
  FOR SELECT
  USING (true);

-- Allow insert for authenticated users
CREATE POLICY "Allow insert for authenticated users"
  ON larps
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');