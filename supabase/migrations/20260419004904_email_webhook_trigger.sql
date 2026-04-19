-- 1. Create the webhook function
CREATE OR REPLACE FUNCTION public.handle_missed_payment()
RETURNS trigger AS $$
BEGIN
  -- We only fire the webhook if the status changed specifically TO 'Missed'
  IF NEW.status = 'Missed' AND OLD.status != 'Missed' THEN

    -- Send the payload to our local Edge Function
    -- Note: 'host.docker.internal' is how the database talks to your local machine
    PERFORM net.http_post(
        url := 'http://host.docker.internal:54321/functions/v1/send_payment_reminder',
        headers := '{"Content-Type": "application/json"}'::jsonb,
        body := json_build_object('record', row_to_json(NEW))::jsonb
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Attach the trigger to the subscriptions table
DROP TRIGGER IF EXISTS on_payment_missed ON public.subscriptions;
CREATE TRIGGER on_payment_missed
  AFTER UPDATE ON public.subscriptions
  FOR EACH ROW EXECUTE FUNCTION public.handle_missed_payment();
