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

-- Create or replace the notify_vote_changes function
CREATE OR REPLACE FUNCTION notify_vote_changes()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify(
    'votes_changes',
    json_build_object(
      'table', TG_TABLE_NAME,
      'type', TG_OP,
      'round', NEW.round,
      'kol_id', NEW.kol_id,
      'id', NEW.id
    )::text
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS votes_changes_trigger ON votes;

-- Create new trigger for vote changes
CREATE TRIGGER votes_changes_trigger
AFTER INSERT OR DELETE OR UPDATE ON votes
FOR EACH ROW
EXECUTE FUNCTION notify_vote_changes();