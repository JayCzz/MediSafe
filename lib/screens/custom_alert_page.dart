import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'custom_drawer.dart';

class CustomAlertPage extends StatefulWidget {
  const CustomAlertPage({super.key});

  @override
  State<CustomAlertPage> createState() => _CustomAlertPageState();
}

class _CustomAlertPageState extends State<CustomAlertPage> {
  // Switch states
  bool enableAlerts = true;
  bool enablePush = true;

  // Checkbox states
  bool tempThreshold = true;
  bool humidityThreshold = true;
  bool lightThreshold = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Custom Alert', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCard("Main ON/OFF", [
              _buildCupertinoSwitchTile("Enable alerts", enableAlerts, (val) {
                setState(() => enableAlerts = val);
              }),
              _buildCupertinoSwitchTile("Enable push notification", enablePush, (val) {
                setState(() => enablePush = val);
              }),
            ]),
            const SizedBox(height: 16),
            _buildCard("Alert Type Notification", [
              _buildCheckboxTile("Temperature threshold", tempThreshold, (val) {
                setState(() => tempThreshold = val ?? false);
              }),
              _buildCheckboxTile("Humidity threshold", humidityThreshold, (val) {
                setState(() => humidityThreshold = val ?? false);
              }),
              _buildCheckboxTile("Light Exposure threshold", lightThreshold, (val) {
                setState(() => lightThreshold = val ?? false);
              }),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCupertinoSwitchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF05318a), // Vivid Burgundy
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(String label, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF05318a), // Vivid Burgundy
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}