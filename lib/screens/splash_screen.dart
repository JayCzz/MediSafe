import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'landing_page.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    // 🔹 Fade-in animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    // 🔹 Wait for splash animation before checking session
    Future.delayed(const Duration(milliseconds: 3500), _checkSession);
  }

  /// ✅ Check if user is already logged in
  Future<void> _checkSession() async {
    try {
      // Refresh the session to ensure it's still valid
      await _supabase.auth.refreshSession();

      final session = _supabase.auth.currentSession;

      if (!mounted) return;

      if (session != null) {
        debugPrint("✅ Active session found for ${session.user.email}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        debugPrint("🚪 No active session found. Redirecting to LandingPage.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LandingPage()),
        );
      }
    } catch (e) {
      debugPrint("⚠️ Error checking session: $e");

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LandingPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _animation,
              child: Image.asset(
                'assets/images/med_team.png',
                height: 250,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF05318a)),
            ),
          ],
        ),
      ),
    );
  }
}
