// supabase/functions/send-otp/index.ts

import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import "https://deno.land/std@0.192.0/dotenv/load.ts"; // ✅ Correct Deno-compatible import

// 🧩 Environment variables
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM_EMAIL = Deno.env.get("FROM_EMAIL") || "no-reply@yourapp.com";

// ✅ Initialize Supabase client
const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);

// ✅ Start the Edge Function server
serve(async (req) => {
  try {
    // Parse request body
    const { email } = await req.json();

    if (!email) {
      return new Response(JSON.stringify({ error: "Missing email" }), { status: 400 });
    }

    // ✅ Check if user exists
    const { data: user, error: fetchError } = await supabase
      .from("users")
      .select("id")
      .eq("email", email)
      .maybeSingle();

    if (fetchError) {
      console.error("Database error:", fetchError);
      return new Response(JSON.stringify({ error: "Database query failed" }), { status: 500 });
    }

    if (!user) {
      return new Response(JSON.stringify({ error: "User not found" }), { status: 404 });
    }

    // ✅ Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    // ✅ Set OTP expiry (10 minutes from now)
    const expiry = new Date(Date.now() + 10 * 60 * 1000).toISOString();

    // ✅ Save OTP and expiry in database
    const { error: updateError } = await supabase
      .from("users")
      .update({
        reset_otp: otp,
        reset_otp_expiry: expiry,
      })
      .eq("email", email);

    if (updateError) {
      console.error("Failed to save OTP:", updateError);
      return new Response(JSON.stringify({ error: "Failed to save OTP" }), { status: 500 });
    }

    // ✅ Send OTP email using Resend API
    const emailResponse = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: FROM_EMAIL,
        to: email,
        subject: "Your MediSafe Password Reset Code",
        html: `
          <div style="font-family: Arial, sans-serif; padding: 20px;">
            <h2>Reset Your MediSafe Password</h2>
            <p>Here is your 6-digit OTP code:</p>
            <h1 style="color: #007BFF; letter-spacing: 4px;">${otp}</h1>
            <p>This code will expire in 10 minutes.</p>
            <p>If you didn’t request this, you can safely ignore this email.</p>
            <hr>
            <p style="font-size: 12px; color: #888;">© ${new Date().getFullYear()} MediSafe</p>
          </div>
        `,
      }),
    });

    if (!emailResponse.ok) {
      const errorText = await emailResponse.text();
      console.error("Failed to send email:", errorText);
      return new Response(JSON.stringify({ error: "Email sending failed" }), { status: 500 });
    }

    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (error) {
    console.error("Error in send-otp function:", error);
    return new Response(JSON.stringify({ error: "Internal Server Error" }), { status: 500 });
  }
});
