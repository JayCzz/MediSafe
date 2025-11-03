import 'package:flutter/material.dart';
import 'login_page.dart';
import 'create_account_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'otp_verification_page.dart';

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
    _checkUserSession();
  }

  /// ✅ Skip landing page if already signed in
  Future<void> _checkUserSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  /// 🟢 Google Login with OTP verification
  Future<void> _googleLogin() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      final account = await googleSignIn.signIn();

      if (account != null) {
        final googleEmail = account.email;
        final googleName = account.displayName ?? 'Google User';

        // ✅ Make sure user is saved in your custom table
        await _supabase.from('users').upsert({
          'username': googleName,
          'email': googleEmail,
          'auth_provider': 'google',
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'email');

        // ✅ Trigger Supabase Auth email OTP
        await _supabase.auth.signInWithOtp(
          email: googleEmail,
          shouldCreateUser: true,
        );

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationPage(
              email: googleEmail,
              isSupabaseAuth: true, // 👈 use built-in auth flow
            ),
          ),
        );
      } else {
        debugPrint("⚠️ Google Sign-In canceled by user");
      }
    } catch (e) {
      debugPrint("❌ Google Sign-In error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Google Sign-In failed")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 🔵 Facebook Login
  Future<void> _facebookLogin() async {
    setState(() => _isLoading = true);
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (!mounted) return;
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();
        final fbName = userData['name'] ?? 'fb_user';
        final fbEmail = userData['email'] ?? '${userData['id']}@facebook.com';

        await _supabase.from('users').upsert({
          'username': fbName,
          'email': fbEmail,
          'auth_provider': 'facebook',
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'email');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else if (result.status == LoginStatus.cancelled) {
        debugPrint("⚠️ Facebook Sign-In canceled");
      } else {
        debugPrint("❌ Facebook Sign-In failed: ${result.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Facebook Sign-In failed")),
        );
      }
    } catch (e) {
      debugPrint("❌ Facebook Sign-In error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Facebook Sign-In error")));
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/med_team.png', height: 250),
                    const SizedBox(height: 30),
                    const Text(
                      'Welcome to MediSafe',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Normal Login
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF05318a),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Divider
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
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        icon: Image.asset(
                          "assets/images/google.png",
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          "Sign in with Google",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onPressed: _googleLogin,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Facebook Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1877F2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Image.asset(
                          "assets/images/facebook.png",
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          "Sign in with Facebook",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onPressed: _facebookLogin,
                      ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateAccountPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Create an account',
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
