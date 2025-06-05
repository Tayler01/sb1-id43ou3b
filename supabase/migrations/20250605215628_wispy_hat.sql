/*
  # Reset Database

  1. Changes
    - Clear all data from tables while preserving structure
    - Reset sequences
    - Keep table structure and policies intact

  2. Order
    - Clear child tables first to respect foreign keys
    - Clear parent tables last
*/

-- Clear child tables first
TRUNCATE TABLE votes CASCADE;
TRUNCATE TABLE downvotes CASCADE;
TRUNCATE TABLE larps CASCADE;
TRUNCATE TABLE timer_state CASCADE;

-- Clear parent table last
TRUNCATE TABLE kols CASCADE;

-- Reset sequences if any exist
ALTER SEQUENCE IF EXISTS kols_id_seq RESTART;
ALTER SEQUENCE IF EXISTS votes_id_seq RESTART;
ALTER SEQUENCE IF EXISTS larps_id_seq RESTART;
ALTER SEQUENCE IF EXISTS timer_state_id_seq RESTART;
ALTER SEQUENCE IF EXISTS downvotes_id_seq RESTART;