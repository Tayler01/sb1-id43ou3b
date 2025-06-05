/*
  # Add timer table for global synchronization

  1. New Tables
    - `timer_state`
      - `id` (uuid, primary key)
      - `start_time` (timestamptz, when the timer started)
      - `round` (integer, current round number)
      - `created_at` (timestamptz, when this record was created)

  2. Security
    - Enable RLS
    - Add policies for public read access
*/

CREATE TABLE IF NOT EXISTS timer_state (
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

-- Create index on created_at for faster ordering
CREATE INDEX IF NOT EXISTS timer_state_created_at_idx ON timer_state(created_at);