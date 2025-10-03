import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'landing_page.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      // ✅ Google Sign-Out
      await GoogleSignIn().signOut();

      // ✅ Facebook Sign-Out
      await FacebookAuth.instance.logOut();

      // ✅ Clear any stored login session
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

    } catch (e) {
      debugPrint("⚠️ Logout error: $e");
    }

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LandingPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 80),
          _buildDrawerItem(context, Icons.person, 'Profile', '/profile', currentRoute),
          _buildDrawerItem(context, Icons.dashboard, 'Home', '/home', currentRoute),
          _buildDrawerItem(context, Icons.notifications_active, 'Custom alert', '/custom-alert', currentRoute),
          _buildDrawerItem(context, Icons.info_outline, 'About', '/about', currentRoute),
          _buildDrawerItem(context, Icons.menu_book, 'Guide', '/guide', currentRoute),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF05318a),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(45),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String label,
    String routeName,
    String? currentRoute,
  ) {
    final bool isSelected = currentRoute == routeName;

    return Container(
      color: isSelected
          ? const Color(0xFF05318a).withValues(alpha: 0.1)
          : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF05318a) : Colors.black87,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF05318a) : Colors.black87,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          if (!isSelected) {
            Navigator.pushNamed(context, routeName);
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
