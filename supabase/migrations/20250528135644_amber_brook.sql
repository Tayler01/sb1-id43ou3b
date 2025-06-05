/*
  # Add atomic vote increment function

  1. Changes
    - Add function to handle atomic vote increments
    - Ensure transaction safety for vote counting
    - Prevent race conditions

  2. Security
    - Enable function for public access
    - Maintain RLS policies
*/

-- Create function for atomic vote increment
CREATE OR REPLACE FUNCTION increment_downvotes(
  kol_id uuid,
  round_number integer
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Update KOL's total downvotes
  UPDATE kols
  SET downvotes = downvotes + 1
  WHERE id = kol_id;

  -- Record the vote
  INSERT INTO votes (kol_id, round)
  VALUES (kol_id, round_number);
END;
$$;

-- Grant execute permission to public
GRANT EXECUTE ON FUNCTION increment_downvotes TO public;

-- Create index for better performance if it doesn't exist
CREATE INDEX IF NOT EXISTS votes_round_kol_idx ON votes(round, kol_id);