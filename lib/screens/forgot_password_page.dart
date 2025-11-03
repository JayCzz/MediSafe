import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'reset_verify_otp_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String _selectedMethod = 'email'; // 'email' or 'phone'
  final supabase = Supabase.instance.client;

  /// 🚀 Send OTP via Email
  Future<void> _sendEmailOtp() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await supabase.functions.invoke(
        'send-otp',
        body: {'email': email},
      );

      if (res.status == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent to your email.')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyOtpPage(email: email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${res.data}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending OTP: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 📱 Send OTP via SMS
  Future<void> _sendSmsOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty || phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await supabase.functions.invoke(
        'send-sms-otp',
        body: {'phone_number': phone},
      );

      if (res.status == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent to your phone.')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyOtpPage(phoneNumber: phone),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${res.data}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending SMS: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔄 Dropdown for method selection
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              items: const [
                DropdownMenuItem(value: 'email', child: Text('Use Email')),
                DropdownMenuItem(value: 'phone', child: Text('Use Phone Number')),
              ],
              onChanged: (value) => setState(() => _selectedMethod = value!),
              decoration: InputDecoration(
                labelText: 'Reset Method',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📨 Email input field
            if (_selectedMethod == 'email')
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

            // 📞 Phone input field
            if (_selectedMethod == 'phone')
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+1 555 555 5555',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // 🚀 Send OTP button
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
                onPressed: _isLoading
                    ? null
                    : () => _selectedMethod == 'email'
                        ? _sendEmailOtp()
                        : _sendSmsOtp(),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send OTP', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
