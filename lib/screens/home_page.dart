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
        title: const Text('Home', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView( // ✅ makes dashboard scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Info Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                InfoCard(
                  icon: Icons.thermostat,
                  label: "22.0",
                  unit: "°C",
                  title: "Temperature",
                  color: Colors.red, // ✅ red for temperature
                ),
                InfoCard(
                  icon: Icons.battery_full,
                  label: "50",
                  unit: "%",
                  title: "Battery",
                  color: Colors.green, // ✅ green for battery
                ),
                InfoCard(
                  icon: Icons.water_drop,
                  label: "65",
                  unit: "%",
                  title: "Humidity",
                  color: Colors.blue, // ✅ blue for humidity
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Temperature Section
            const Text(
              "Temperature",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const StatCard(
              title: "Temperature",
              yLabel: "Temperature (°C)",
              color: Colors.red,
              height: 280,
            ),
            const SizedBox(height: 20),

            // Humidity Section
            const Text(
              "Humidity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const StatCard(
              title: "Humidity",
              yLabel: "Humidity (%)",
              color: Colors.blue,
              height: 280,
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
  final String title;
  final Color color;

  const InfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.unit,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color), // ✅ colorful icon
          const SizedBox(height: 6),
          Text(
            '$label$unit', // ✅ value on top
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black, // ✅ black value text
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title, // ✅ label below
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey, // ✅ gray label
            ),
          ),
        ],
      ),
    );
  }
}


class StatCard extends StatelessWidget {
  final String title;
  final String yLabel;
  final Color color;
  final double height;

  const StatCard({
    super.key,
    required this.title,
    required this.yLabel,
    required this.color,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: AxisTitles( // ✅ remove top numbers
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles( // ✅ remove right numbers
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
              axisNameWidget: Text(yLabel, style: const TextStyle(fontSize: 12)),
              axisNameSize: 20,
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text("${value.toInt()}m",
                      style: const TextStyle(fontSize: 12));
                },
              ),
              axisNameWidget: const Text("Minutes", style: TextStyle(fontSize: 12)),
              axisNameSize: 20,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: color,
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
    );
  }
}
