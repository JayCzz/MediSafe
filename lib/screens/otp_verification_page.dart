import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final bool isSupabaseAuth;

  const OtpVerificationPage({
    super.key,
    required this.email,
    this.isSupabaseAuth = true,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  // ---------------------------------------------------
  // 🔵 Verify OTP (Supabase Auth Email OTP)
  // ---------------------------------------------------
  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 6-digit OTP")),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final res = await _supabase.auth.verifyOTP(
        email: widget.email,
        token: otp,
        type: OtpType.email,
      );

      if (res.session != null) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid OTP")),
        );
      }
    } catch (e) {
      debugPrint("OTP Verification Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error verifying OTP: $e")),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  // ---------------------------------------------------
  // 🔁 Resend OTP
  // ---------------------------------------------------
  Future<void> _resendOtp() async {
    setState(() => _isResending = true);

    try {
      await _supabase.auth.signInWithOtp(
        email: widget.email,
        shouldCreateUser: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP resent to your email")),
      );
    } catch (e) {
      debugPrint("Resend OTP Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to resend OTP: $e")),
      );
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF05318a);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Enter the 6-digit code sent to:\n${widget.email}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _otpController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: "OTP Code",
                border: OutlineInputBorder(),
                counterText: "",
              ),
            ),

            const SizedBox(height: 30),

            _isVerifying
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Verify"),
                  ),

            const SizedBox(height: 20),

            _isResending
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: _resendOtp,
                    child: const Text(
                      "Resend OTP",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
