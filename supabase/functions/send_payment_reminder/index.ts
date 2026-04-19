import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Grab the environment variables Supabase provides automatically
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

serve(async (req) => {
  try {
    // 1. Read the payload coming from the Database Webhook
    const payload = await req.json()
    const record = payload.record

    // 2. We only care if the status is actually 'Missed'
    if (record.status !== 'Missed') {
      return new Response("Not a missed payment, ignoring.", { status: 200 })
    }

    // 3. Initialize the Supabase admin client to find the user's email
    const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!)
    const { data: { user }, error } = await supabase.auth.admin.getUserById(record.user_id)

    if (error || !user?.email) throw new Error("Could not find user email")

    // 4. Send the Email via Resend
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`
      },
      body: JSON.stringify({
        from: 'Nudge App <onboarding@resend.dev>', // resend.dev is allowed for testing!
        to: user.email, // Sends to whichever email you logged into the app with
        subject: `⚠️ Action Required: ${record.service_name} Payment Missed`,
        html: `
          <div style="font-family: sans-serif; padding: 20px;">
            <h2>Payment Reminder</h2>
            <p>Hi there,</p>
            <p>Your scheduled payment of <strong>Rs ${record.amount}</strong> for <strong>${record.service_name}</strong> requires your attention.</p>
            <p>Please open the Nudge app to update your payment status or reschedule this bill.</p>
            <br/>
            <p>Stay on track,</p>
            <p><strong>The Nudge Team</strong></p>
          </div>
        `
      })
    })

    const data = await res.json()
    return new Response(JSON.stringify(data), { status: 200, headers: { 'Content-Type': 'application/json' } })

  } catch (err) {
    return new Response(String(err), { status: 500 })
  }
})
