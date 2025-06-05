/*
  # Drop larps table

  1. Changes
    - Drop the larps table and all associated objects
*/

-- Drop the table and all dependent objects (constraints, indexes, etc.)
DROP TABLE IF EXISTS larps CASCADE;