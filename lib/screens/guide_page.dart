import 'package:flutter/material.dart';
import 'custom_drawer.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _guideData = [
    {
      "image": "assets/images/temp_icon.png",
      "title": "How to monitor the temperature?",
      "description":
          "Ensure your MediSafe device is connected. Open the dashboard to view real-time temperature readings."
    },
    {
      "image": "assets/images/humidity_icon.png",
      "title": "How to monitor the Humidity?",
      "description":
          "Check the dashboard for real-time humidity levels and historical trends for better insights."
    },
    {
      "image": "assets/images/sms_icon.png",
      "title": "How does the SMS work?",
      "description":
          "Enable SMS notifications in settings to receive alerts when thresholds are exceeded."
    },
    {
      "image": "assets/images/navigation_icon.png",
      "title": "How to navigate the MediSafe app?",
      "description":
          "Use the side menu to access Dashboard, Custom Alerts, Profile, About, and more."
    },
    {
      "image": "assets/images/alert_icon.png",
      "title": "How to custom alerts?",
      "description":
          "Go to the Custom Alert page and toggle ON alerts for temperature, humidity, or other thresholds."
    },
    {
      "image": "assets/images/profile_icon.png",
      "title": "How to Update Profile detail?",
      "description":
          "Navigate to the Profile page and edit your information to keep your details up-to-date."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text("User Guide", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _guideData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final item = _guideData[index];
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = (_pageController.page! - index).abs();
                      value = (1 - (value * 0.2)).clamp(0.8, 1.0);
                    }
                    return Center(
                      child: Transform.scale(
                        scale: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          item["image"]!,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          item["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB53158), // Vivid Burgundy
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          item["description"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildDotsIndicator(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _guideData.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 20 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFFB53158)
                : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}