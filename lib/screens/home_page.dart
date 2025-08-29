import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'custom_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Info Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                InfoCard(icon: Icons.thermostat, label: "22.0", unit: "°C"),
                InfoCard(icon: Icons.battery_full, label: "50", unit: "%"),
                InfoCard(icon: Icons.water_drop, label: "65", unit: "%"),
              ],
            ),
            const SizedBox(height: 16),
            // Temperature Chart
            const Expanded(
              child: StatCard(title: "Temperature"),
            ),
            const SizedBox(height: 16),
            // Humidity Chart
            const Expanded(
              child: StatCard(title: "Humidity"),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String unit;

  const InfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 85,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1), // ✅ Fixed
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 5),
          Text(
            '$label$unit',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;

  const StatCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1), // ✅ Fixed
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: const Color(0xFF4f99c9),
                    dotData: FlDotData(show: true),
                    spots: const [
                      FlSpot(1, 20),
                      FlSpot(2, 21),
                      FlSpot(3, 19),
                      FlSpot(4, 22),
                      FlSpot(5, 24),
                      FlSpot(6, 23),
                      FlSpot(7, 25),
                      FlSpot(8, 24),
                      FlSpot(9, 22),
                      FlSpot(10, 21),
                      FlSpot(11, 23),
                      FlSpot(12, 22),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
