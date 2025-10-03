import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';
import 'screens/custom_alert_page.dart';
import 'screens/about_us_page.dart';
import 'screens/guide_page.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase
  await Supabase.initialize(
    url: 'https://elhshkzfiqmyisxavnsh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVsaHNoa3pmaXFteWlzeGF2bnNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3MDg1OTIsImV4cCI6MjA3NDI4NDU5Mn0.0AaxR_opZSkwz2rRwJ21kmuZ7lrOPglLUIgb8nSnr1k',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF05318a); // ✅ Your brand color

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediSafe',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: primaryColor, // Typing cursor color
          selectionColor: Color(0x3305318a), // Highlighted text background (semi-transparent)
          selectionHandleColor: primaryColor, // Drag handle color (the "drop")
        ),
        checkboxTheme: CheckboxThemeData(
          side: const BorderSide(color: primaryColor, width: 2),
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor;
            }
            return Colors.transparent;
          }),
          checkColor: MaterialStateProperty.all(Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          labelStyle: const TextStyle(color: primaryColor),
        ),
      ),

      // ✅ Define routes
      routes: {
        '/': (context) => const SplashScreen(),
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/custom-alert': (context) => const CustomAlertPage(),
        '/about': (context) => const AboutUsPage(),
        '/guide': (context) => const GuidePage(),
      },
    );
  }
}
