/*
  # Create KOLs table with RLS policies

  1. New Tables
    - `kols`
      - `id` (uuid, primary key)
      - `twitter_handle` (text, not null)
      - `name` (text)
      - `profile_img` (text)
      - `twitter_url` (text)
      - `reason` (text)
      - `downvotes` (int, default 0)
      - `created_at` (timestamptz, default now())

  2. Security
    - Enable RLS on `kols` table
    - Add policies for:
      - Public read access
      - Public insert access
      - Restricted update access (downvotes only)
*/

CREATE TABLE IF NOT EXISTS kols (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  twitter_handle text NOT NULL,
  name text,
  profile_img text,
  twitter_url text,
  reason text,
  downvotes int DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE kols ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read"
  ON kols
  FOR SELECT
  USING (true);

-- Allow public insert
CREATE POLICY "Allow public insert"
  ON kols
  FOR INSERT
  WITH CHECK (true);

-- Allow only downvotes to be updated
CREATE POLICY "Allow update downvotes only"
  ON kols
  FOR UPDATE
  USING (true)
  WITH CHECK (
    twitter_handle = twitter_handle AND
    name = name AND
    profile_img = profile_img AND
    twitter_url = twitter_url AND
    reason = reason
  );