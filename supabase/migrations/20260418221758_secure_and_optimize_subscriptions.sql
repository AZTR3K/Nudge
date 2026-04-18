-- 1. Enable Row Level Security (if not already enabled)
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- 2. Create UPDATE Policy
-- Allows users to modify their own bills (needed for Snooze/Edit/Mark as Paid)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'subscriptions'
        AND policyname = 'Users can update their own subscriptions'
    ) THEN
        CREATE POLICY "Users can update their own subscriptions"
        ON public.subscriptions
        FOR UPDATE
        TO authenticated
        USING (auth.uid() = user_id);
    END IF;
END $$;

-- 3. Create DELETE Policy
-- Allows users to remove bills
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'subscriptions'
        AND policyname = 'Users can delete their own subscriptions'
    ) THEN
        CREATE POLICY "Users can delete their own subscriptions"
        ON public.subscriptions
        FOR DELETE
        TO authenticated
        USING (auth.uid() = user_id);
    END IF;
END $$;

-- 4. Set Replica Identity to FULL
-- CRITICAL: Forces Postgres to send the old AND new values for all columns.
-- This is what allows your Flutter Stream to detect the status change.
ALTER TABLE public.subscriptions REPLICA IDENTITY FULL;

-- 5. Data Sanitization
-- Ensure no NULL statuses exist before we lock the column down
UPDATE public.subscriptions SET status = 'Pending' WHERE status IS NULL;

-- 6. Enforce Status Integrity
ALTER TABLE public.subscriptions
    ALTER COLUMN status SET NOT NULL,
    ALTER COLUMN status SET DEFAULT 'Pending';
