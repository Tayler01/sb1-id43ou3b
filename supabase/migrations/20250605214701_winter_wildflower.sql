-- Drop and recreate the increment_downvotes function with improved notification
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