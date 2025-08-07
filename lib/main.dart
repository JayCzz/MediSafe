import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';
import 'screens/custom_alert_page.dart';
import 'screens/about_us_page.dart';
import 'screens/guide_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediSafe',
      theme: ThemeData(
        primaryColor: const Color(0xFF9B1B30), // Maroon theme color
        scaffoldBackgroundColor: const Color(0xFFF5F5F7), // iOS-style background
        useMaterial3: true,
      ),
      // Define routes here
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/custom-alert': (context) => const CustomAlertPage(),
        '/about': (context) => const AboutUsPage(),
        '/guide': (context) => const GuidePage()
      },
    );
  }
}