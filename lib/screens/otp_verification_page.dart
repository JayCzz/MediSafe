import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _supabase = Supabase.instance.client;
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  /// ✅ Verify the OTP and sign the user in
  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 6-digit OTP")),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.email,
        email: widget.email,
        token: _otpController.text.trim(),
      );

      if (response.session != null && response.user != null) {
        // ✅ Successfully verified — session saved automatically by Supabase
        debugPrint("✅ OTP verified for ${response.user?.email}");
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid or expired OTP")),
        );
      }
    } catch (e) {
      debugPrint("❌ OTP Verification failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP verification failed")),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  /// 🔁 Resend OTP
  Future<void> _resendOtp() async {
    setState(() => _isResending = true);

    try {
      await _supabase.auth.signInWithOtp(
        email: widget.email,
        shouldCreateUser: true,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP has been resent to your email")),
      );
    } catch (e) {
      debugPrint("❌ OTP resend failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to resend OTP")),
      );
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF05318a),
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Enter the 6-digit OTP sent to ${widget.email}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "OTP Code",
                counterText: "",
              ),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),

            const SizedBox(height: 30),

            _isVerifying
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF05318a),
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
                        color: Color(0xFF05318a),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
