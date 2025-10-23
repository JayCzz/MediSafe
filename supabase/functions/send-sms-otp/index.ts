// supabase/functions/send-sms-otp/index.ts

import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import "https://deno.land/std@0.192.0/dotenv/load.ts";

// 🧩 Environment variables
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const TWILIO_ACCOUNT_SID = Deno.env.get("TWILIO_ACCOUNT_SID");
const TWILIO_AUTH_TOKEN = Deno.env.get("TWILIO_AUTH_TOKEN");
const TWILIO_PHONE_NUMBER = Deno.env.get("TWILIO_PHONE_NUMBER");

// ✅ Validate env vars before anything else
if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error("❌ Missing Supabase credentials in environment variables");
}

if (!TWILIO_ACCOUNT_SID || !TWILIO_AUTH_TOKEN || !TWILIO_PHONE_NUMBER) {
  console.error("❌ Missing Twilio credentials in environment variables");
}

// ✅ Initialize Supabase client
const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);

// ✅ Edge Function logic
serve(async (req) => {
  try {
    const { phone_number } = await req.json();

    if (!phone_number) {
      return new Response(JSON.stringify({ error: "Missing phone number" }), { status: 400 });
    }

    // ✅ Check if user exists
    const { data: user, error: fetchError } = await supabase
      .from("users")
      .select("id")
      .eq("phone_number", phone_number)
      .maybeSingle();

    if (fetchError) {
      console.error("Database error:", fetchError);
      return new Response(JSON.stringify({ error: "Database query failed" }), { status: 500 });
    }

    if (!user) {
      return new Response(JSON.stringify({ error: "User not found" }), { status: 404 });
    }

    // ✅ Generate a 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiry = new Date(Date.now() + 10 * 60 * 1000).toISOString(); // 10 mins expiry

    // ✅ Update the user with OTP
    const { error: updateError } = await supabase
      .from("users")
      .update({
        reset_otp: otp,
        reset_otp_expiry: expiry,
      })
      .eq("phone_number", phone_number);

    if (updateError) {
      console.error("Failed to save OTP:", updateError);
      return new Response(JSON.stringify({ error: "Failed to save OTP" }), { status: 500 });
    }

    // ✅ Send the OTP using Twilio API
    const twilioUrl = `https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID!}/Messages.json`;
    const params = new URLSearchParams();
    params.append("To", phone_number);
    params.append("From", TWILIO_PHONE_NUMBER!);
    params.append("Body", `Your MediSafe OTP code is: ${otp}. It will expire in 10 minutes.`);

    const smsResponse = await fetch(twilioUrl, {
      method: "POST",
      headers: {
        Authorization: "Basic " + btoa(`${TWILIO_ACCOUNT_SID!}:${TWILIO_AUTH_TOKEN!}`),
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: params.toString(),
    });

    if (!smsResponse.ok) {
      const errText = await smsResponse.text();
      console.error("Twilio SMS failed:", errText);
      return new Response(JSON.stringify({ error: "SMS sending failed" }), { status: 500 });
    }

    return new Response(JSON.stringify({ success: true, message: "OTP sent successfully" }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Error in send-sms-otp:", err);
    return new Response(JSON.stringify({ error: "Internal server error" }), { status: 500 });
  }
});
