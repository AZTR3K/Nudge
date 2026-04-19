-- Ensure the network extension is actually turned on
CREATE EXTENSION IF NOT EXISTS pg_net;

CREATE OR REPLACE FUNCTION public.handle_missed_payment()
RETURNS trigger AS $$
BEGIN
  IF NEW.status = 'Missed' AND OLD.status != 'Missed' THEN
    
    -- Using your direct Linux IP instead of host.docker.internal
    PERFORM net.http_post(
        url := 'http://192.168.0.185/:54321/functions/v1/send_payment_reminder',
        headers := '{"Content-Type": "application/json"}'::jsonb,
        body := json_build_object('record', row_to_json(NEW))::jsonb
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;