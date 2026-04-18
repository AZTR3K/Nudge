-- 1. First, ensure no NULLs exist so we can safely apply the NOT NULL constraint
UPDATE subscriptions SET status = 'Pending' WHERE status IS NULL;

-- 2. Make the 'status' column mandatory and set the default for future rows
ALTER TABLE subscriptions
  ALTER COLUMN status SET NOT NULL,
  ALTER COLUMN status SET DEFAULT 'Pending';

-- 3. CRITICAL for Flutter Realtime:
-- This ensures Supabase sends the full row data on every update.
ALTER TABLE subscriptions REPLICA IDENTITY FULL;

-- 4. Double-check that this table is actually in the realtime publication
-- (Doing this again here is a "safety first" move)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
    AND schemaname = 'public'
    AND tablename = 'subscriptions'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE subscriptions;
  END IF;
END $$;
