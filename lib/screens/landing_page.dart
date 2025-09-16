import 'package:flutter/material.dart';
import 'login_page.dart';
import 'create_account_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';

// (NEW) Facebook login package
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  /// Google Sign-In instance
  static final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: ['email', 'profile']);

  /// Google Sign-In method
  Future<void> _googleLogin() async {
    try {
      final account = await _googleSignIn.signIn();

      if (!mounted) return;

      if (account != null) {
        debugPrint("✅ Google Sign-In Success: ${account.email}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        debugPrint("⚠️ Google Sign-In canceled by user");
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("❌ Google Sign-In error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google Sign-In failed")),
      );
    }
  }

  /// Facebook Sign-In method
  Future<void> _facebookLogin() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (!mounted) return;

      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();
        debugPrint("✅ Facebook Sign-In Success: ${userData['email']}");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else if (result.status == LoginStatus.cancelled) {
        debugPrint("⚠️ Facebook Sign-In canceled by user");
      } else {
        debugPrint("❌ Facebook Sign-In failed: ${result.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Facebook Sign-In failed")),
        );
      }
    } catch (e) {
      debugPrint("❌ Facebook Sign-In error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Facebook Sign-In error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/med_team.png',
                height: 250,
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome to MediSafe',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              // Normal Login Button
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
                      MaterialPageRoute(builder: (_) => const LoginPage()),
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

              // Google Sign-In button
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

              // Facebook Sign-In button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2), // FB Blue
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Image.asset(
                    "assets/images/facebook.png", // add fb logo to assets
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

              // Create account
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CreateAccountPage()),
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
