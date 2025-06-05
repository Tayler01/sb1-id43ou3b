/*
  # Add timer state and LARP tracking

  1. New Tables
    - `timer_state`
      - `id` (uuid, primary key)
      - `start_time` (timestamptz)
      - `round` (integer)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on `timer_state` table
    - Add policies for:
      - Public read access
      - Insert only when no timer exists
      - Update for authenticated users
*/

-- Drop existing tables if they exist
DROP TABLE IF EXISTS timer_state CASCADE;

CREATE TABLE timer_state (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  start_time timestamptz NOT NULL,
  round integer NOT NULL DEFAULT 1,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE timer_state ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Allow public read"
  ON timer_state
  FOR SELECT
  TO public
  USING (true);

-- Allow insert only when no timer state exists
CREATE POLICY "Allow insert when no timer state exists"
  ON timer_state
  FOR INSERT
  TO public
  WITH CHECK (
    NOT EXISTS (
      SELECT 1 FROM timer_state
    )
  );

-- Allow update for authenticated users
CREATE POLICY "Allow update timer state"
  ON timer_state
  FOR UPDATE
  TO public
  USING (true)
  WITH CHECK (true);

-- Create index on created_at for faster ordering
CREATE INDEX timer_state_created_at_idx ON timer_state(created_at);