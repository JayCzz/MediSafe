import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'otp_verification_page.dart';
import 'login_page.dart';
import 'create_account_page.dart';
import 'home_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    if (_supabase.auth.currentSession != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  // --------------------------------------------------------
  // 🌟 Custom Google → Email OTP Authentication Flow
  // --------------------------------------------------------
  Future<void> _googleCustomOtpLogin() async {
    setState(() => _isLoading = true);

    try {
      // 1️⃣ Native Google Sign-In popup
      final googleUser = await GoogleSignIn(
        clientId: "283853584357-fb41gt6pi1b1dka3tl0ip5p3n4jne7n6.apps.googleusercontent.com",
        scopes: ["email", "profile"],
      ).signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final email = googleUser.email;

      // 2️⃣ Send OTP to Google email (Supabase Auth OTP)
      await _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );

      if (!mounted) return;

      // 3️⃣ Navigate to OTP screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationPage(
            email: email,
            isSupabaseAuth: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Google → OTP Login Error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google login failed. Try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/med_team.png", height: 250),
                    const SizedBox(height: 30),

                    const Text(
                      "Welcome to MediSafe",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Login button
                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const LoginPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF05318a),
                        ),
                        child: const Text("Login",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("OR"),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Google Button
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _googleCustomOtpLogin,
                        icon: Image.asset("assets/images/google.png", height: 24),
                        label: const Text("Sign in with Google"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CreateAccountPage()),
                        );
                      },
                      child: const Text(
                        "Create an account",
                        style: TextStyle(
                          color: Color(0xFF05318a),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
