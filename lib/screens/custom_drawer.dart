import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current route name
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 80),
          _buildDrawerItem(
            context,
            Icons.person,
            'Profile',
            '/profile',
            currentRoute,
          ),
          _buildDrawerItem(
            context,
            Icons.dashboard,
            'Home',
            '/home',
            currentRoute,
          ),
          _buildDrawerItem(
            context,
            Icons.notifications_active,
            'Custom alert',
            '/custom-alert',
            currentRoute,
          ),
          _buildDrawerItem(
            context,
            Icons.info_outline,
            'About',
            '/about',
            currentRoute,
          ),
          _buildDrawerItem(
            context,
            Icons.menu_book,
            'Guide',
            '/guide',
            currentRoute,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
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
          ? const Color(0xFF05318a).withValues(alpha: 0.1) // ✅ Fixed
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
            Navigator.pop(context); // just close the drawer if already selected
          }
        },
      ),
    );
  }
}
