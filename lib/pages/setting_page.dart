import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int dailyTarget = 8; // Default target

  @override
  void initState() {
    super.initState();
    loadTarget();
  }

  Future<void> loadTarget() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyTarget = prefs.getInt('dailyTarget') ?? 8;
    });
  }

  Future<void> saveTarget(int newTarget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyTarget', newTarget);
    setState(() {
      dailyTarget = newTarget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Target Minum Harian (gelas):', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: dailyTarget.toDouble(),
                    min: 4,
                    max: 15,
                    divisions: 11,
                    label: dailyTarget.toString(),
                    onChanged: (value) {
                      saveTarget(value.toInt());
                    },
                  ),
                ),
                Text('$dailyTarget gelas', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
