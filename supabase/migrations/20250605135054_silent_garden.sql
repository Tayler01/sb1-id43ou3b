-- Drop and recreate the increment_downvotes function with improved notification
CREATE OR REPLACE FUNCTION increment_downvotes(
  input_kol_id uuid,
  input_round integer
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  vote_id uuid;
BEGIN
  -- Insert vote and get the ID
  INSERT INTO votes (kol_id, round)
  VALUES (input_kol_id, input_round)
  RETURNING id INTO vote_id;

  -- Update KOL's downvote count
  UPDATE kols
  SET downvotes = COALESCE(downvotes, 0) + 1
  WHERE id = input_kol_id;

  -- Explicitly notify about both changes
  PERFORM pg_notify(
    'realtime',
    json_build_object(
      'type', 'INSERT',
      'table', 'votes',
      'schema', 'public',
      'record', json_build_object(
        'id', vote_id,
        'kol_id', input_kol_id,
        'round', input_round
      )
    )::text
  );

  PERFORM pg_notify(
    'realtime',
    json_build_object(
      'type', 'UPDATE',
      'table', 'kols',
      'schema', 'public',
      'old_record', NULL,
      'record', (SELECT row_to_json(k) FROM kols k WHERE id = input_kol_id)
    )::text
  );
END;
$$;

-- Grant execute permission to public
GRANT EXECUTE ON FUNCTION increment_downvotes(uuid, integer) TO public;