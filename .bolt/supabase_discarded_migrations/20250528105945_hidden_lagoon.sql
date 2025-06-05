/*
  # Clear all data from tables

  1. Changes
    - Clear all data from kols, larps, votes, and timer_state tables
    - Reset sequences
*/

-- Clear all data
TRUNCATE TABLE votes CASCADE;
TRUNCATE TABLE larps CASCADE;
TRUNCATE TABLE kols CASCADE;
TRUNCATE TABLE timer_state CASCADE;