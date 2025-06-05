-- Create function for atomic vote increment
CREATE OR REPLACE FUNCTION increment_downvotes(
  input_kol_id uuid,
  input_round integer
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Insert vote first to maintain referential integrity
  INSERT INTO votes (kol_id, round)
  VALUES (input_kol_id, input_round);

  -- Update KOL's downvote count
  UPDATE kols
  SET downvotes = COALESCE(downvotes, 0) + 1
  WHERE id = input_kol_id;
END;
$$;

-- Grant execute permission to public
GRANT EXECUTE ON FUNCTION increment_downvotes(uuid, integer) TO public;