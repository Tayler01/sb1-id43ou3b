-- Create or replace notify function for downvotes
CREATE OR REPLACE FUNCTION notify_downvote_changes()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify(
    'realtime',
    json_build_object(
      'type', TG_OP,
      'table', 'downvotes',
      'schema', 'public',
      'record', row_to_json(NEW)
    )::text
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for downvotes
DROP TRIGGER IF EXISTS downvotes_changes_trigger ON downvotes;
CREATE TRIGGER downvotes_changes_trigger
AFTER INSERT OR UPDATE ON downvotes
FOR EACH ROW
EXECUTE FUNCTION notify_downvote_changes();

-- Update increment_downvotes function with proper count handling
CREATE OR REPLACE FUNCTION increment_downvotes(
  input_kol_id uuid,
  input_round integer
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_count integer;
BEGIN
  -- Get current count
  SELECT count INTO current_count
  FROM downvotes
  WHERE kol_id = input_kol_id AND round = input_round;

  -- Insert vote record
  INSERT INTO votes (kol_id, round)
  VALUES (input_kol_id, input_round);

  -- Update or insert downvote count for the round
  INSERT INTO downvotes (kol_id, round, count)
  VALUES (input_kol_id, input_round, 1)
  ON CONFLICT (kol_id, round)
  DO UPDATE SET 
    count = COALESCE(current_count, 0) + 1,
    updated_at = now();

  -- Update total downvotes in kols table
  UPDATE kols
  SET downvotes = COALESCE(downvotes, 0) + 1
  WHERE id = input_kol_id;
END;
$$;

-- Grant execute permission to public
GRANT EXECUTE ON FUNCTION increment_downvotes(uuid, integer) TO public;