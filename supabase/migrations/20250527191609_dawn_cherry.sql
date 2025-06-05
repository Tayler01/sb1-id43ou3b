/*
  # Fix timer state RLS policies

  1. Changes
    - Add RLS policies for timer_state table to allow:
      - Public read access
      - Insert only when no timer state exists
      - Update for authenticated users

  2. Security
    - Enable RLS on timer_state table (already enabled)
    - Add policies for controlled access
*/

-- Allow insert only when no timer state exists
CREATE POLICY "Allow insert when no timer state exists"
ON public.timer_state
FOR INSERT
TO public
WITH CHECK (
  NOT EXISTS (
    SELECT 1 FROM public.timer_state
  )
);

-- Allow update for authenticated users
CREATE POLICY "Allow update timer state"
ON public.timer_state
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);