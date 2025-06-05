/*
  # Fix timer_state RLS policies

  1. Changes
    - Update RLS policies for timer_state table to allow proper insertion
    - Remove restrictive insert policy that only allowed inserts when no records exist
    - Add new policies to allow:
      - Public read access to timer state
      - Public insert access (needed for initialization)
      - Public update access (needed for round updates)

  2. Security
    - Maintains RLS enabled on timer_state table
    - Allows public access for essential timer functionality
    - Note: This is intentionally public as the timer state is a global application state
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Allow insert when no timer state exists" ON timer_state;
DROP POLICY IF EXISTS "Allow public read" ON timer_state;
DROP POLICY IF EXISTS "Allow update timer state" ON timer_state;

-- Create new policies
CREATE POLICY "Enable read access for all users"
ON timer_state
FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable insert for all users"
ON timer_state
FOR INSERT
TO public
WITH CHECK (true);

CREATE POLICY "Enable update for all users"
ON timer_state
FOR UPDATE
TO public
USING (true)
WITH CHECK (true);