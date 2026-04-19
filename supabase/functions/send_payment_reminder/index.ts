import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

serve(async (req) => {
  try {
    console.log("1. Webhook received! Parsing payload...");
    const payload = await req.json()
    const record = payload.record

    if (record.status !== 'Missed') {
      console.log("Status is not Missed. Exiting.");
      return new Response("Not missed", { status: 200 })
    }

    console.log(`2. Attempting to fetch user email for ID: ${record.user_id}`);
    const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!)
    const { data: { user }, error } = await supabase.auth.admin.getUserById(record.user_id)

    if (error) {
      console.error("Auth fetch error:", error);
      throw error;
    }
    if (!user?.email) throw new Error("User has no email");

    console.log(`3. User found! Email: ${user.email}. Sending to Resend...`);

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`
      },
      body: JSON.stringify({
        from: 'Nudge App <onboarding@resend.dev>',
        to: user.email,
        subject: `⚠️ Action Required: ${record.service_name} Payment Missed`,
        html: `<p>Please pay your ${record.service_name} bill of Rs ${record.amount}.</p>`
      })
    })

    console.log("4. Resend API responded! Parsing response...");
    const data = await res.json()
    console.log("5. Success! Function complete.", data);

    return new Response(JSON.stringify(data), { status: 200, headers: { 'Content-Type': 'application/json' } })

  } catch (err) {
    console.error("CRITICAL ERROR CAUGHT:", err);
    return new Response(String(err), { status: 500 })
  }
})
