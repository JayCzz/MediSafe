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
  late final AnimationController _controller;
  late final Animation<double> _animation;
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

    // Start animation and run session check when animation finishes
    _startAndCheckSession();
  }

  Future<void> _startAndCheckSession() async {
    await _controller.forward();
    // Small extra delay for smoother UX
    await Future.delayed(const Duration(milliseconds: 300));
    await _checkSession();
  }

  /// ✅ Check if user is already logged in
  Future<void> _checkSession() async {
    try {
      // Optional: try to refresh session if possible
      try {
        await _supabase.auth.refreshSession();
      } catch (e) {
        debugPrint('Info: refreshSession() threw: $e');
      }

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
