import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'reset_password_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String? email;
  final String? phoneNumber;

  const OtpVerificationPage({
    super.key,
    this.email,
    this.phoneNumber,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _supabase = Supabase.instance.client;
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  /// ✅ Verify the OTP (email or phone)
  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 6-digit OTP")),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final isEmailFlow = widget.email != null && widget.email!.isNotEmpty;
      final identifier = isEmailFlow ? 'email' : 'phone_number';
      final value = isEmailFlow ? widget.email! : (widget.phoneNumber ?? '');

      // 🔍 Fetch stored OTP + expiry
      final response = await _supabase
          .from('users')
          .select('reset_otp, reset_otp_expiry')
          .eq(identifier, value)
          .maybeSingle();

      if (response == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found")),
        );
        return;
      }

      final storedOtp = response['reset_otp'] as String?;
      final expiryRaw = response['reset_otp_expiry'];
      final expiry =
          expiryRaw != null ? DateTime.tryParse(expiryRaw.toString()) : null;

      if (storedOtp == null || expiry == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP not found, request a new one")),
        );
        return;
      }

      if (DateTime.now().isAfter(expiry)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP expired, request again")),
        );
        return;
      }

      if (storedOtp != otp) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid OTP")),
        );
        return;
      }

      // ✅ OTP verified — navigate to reset password
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(
            email: widget.email,
            phoneNumber: widget.phoneNumber,
          ),
        ),
      );
    } catch (e) {
      debugPrint("❌ OTP verification error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error verifying OTP: $e")),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  /// 🔁 Resend OTP (via Edge Function)
  Future<void> _resendOtp() async {
    setState(() => _isResending = true);

    try {
      final isEmailFlow = widget.email != null && widget.email!.isNotEmpty;
      final functionName = isEmailFlow ? 'send-otp' : 'send-sms-otp';
      final body = isEmailFlow
          ? {'email': widget.email}
          : {'phone_number': widget.phoneNumber};

      final res = await _supabase.functions.invoke(functionName, body: body);

      if (!mounted) return;
      if (res.status == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEmailFlow
                ? "OTP resent to your email"
                : "OTP resent to your phone"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${res.data}")),
        );
      }
    } catch (e) {
      debugPrint("❌ OTP resend error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error resending OTP: $e")),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF05318a);
    final contactInfo =
        widget.email ?? widget.phoneNumber ?? 'your registered contact';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Enter the 6-digit OTP sent to $contactInfo",
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
}
