-- Drop and recreate the increment_downvotes function
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

  -- Notify clients about the update
  NOTIFY kols_changes;
END;
$$;

-- Grant execute permission to public
GRANT EXECUTE ON FUNCTION increment_downvotes(uuid, integer) TO public;

-- Create trigger for vote changes
CREATE OR REPLACE FUNCTION notify_vote_changes()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify('votes_changes', json_build_object(
    'round', NEW.round,
    'kol_id', NEW.kol_id
  )::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER votes_changes_trigger
AFTER INSERT OR UPDATE OR DELETE ON votes
FOR EACH ROW
EXECUTE FUNCTION notify_vote_changes();