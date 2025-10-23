import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'reset_password_page.dart';

class VerifyOtpPage extends StatefulWidget {
  final String? email;
  final String? phoneNumber;

  const VerifyOtpPage({
    super.key,
    this.email,
    this.phoneNumber,
  });

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _otpController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty || otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Decide if verifying email or phone
      final identifier = widget.email != null ? 'email' : 'phone_number';
      final value = widget.email ?? widget.phoneNumber;

      if (value == null || value.isEmpty) {
        throw 'Missing email or phone number.';
      }

      final res = await supabase
          .from('users')
          .select('reset_otp, reset_otp_expiry')
          .eq(identifier, value)
          .maybeSingle();

      if (res == null || res.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final data = res;
      final storedOtp = data['reset_otp'] as String?;
      final expiry = data['reset_otp_expiry'] != null
          ? DateTime.parse(data['reset_otp_expiry'])
          : null;

      if (storedOtp == null || expiry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No OTP found. Please request again.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (DateTime.now().isAfter(expiry)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP expired. Please request again.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (storedOtp != otp) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Please try again.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // ✅ OTP verified successfully
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP verified! You can now reset your password.'),
        ),
      );

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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying OTP: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Enter OTP',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.email != null
                  ? 'We’ve sent a 6-digit OTP to your email.'
                  : 'We’ve sent a 6-digit OTP to your phone number.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter 6-digit OTP',
                counterText: '',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _verifyOtp,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Verify OTP',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
