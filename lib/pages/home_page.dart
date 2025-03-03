import 'package:flutter/material.dart';
import 'package:pengingat_air/pages/setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../widgets/water_chart.dart';
  
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int dailyTarget = 8; // Target harian default
  Map<String, int> waterData = {}; // Data jumlah air
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    loadWaterData();
    loadDailyTarget();
  }

  Future<void> loadWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    String? dataString = prefs.getString('waterData');
    if (dataString != null) {
      setState(() {
        waterData = Map<String, int>.from(jsonDecode(dataString))
            .map((key, value) => MapEntry(key, value < 0 ? 0 : value));
      });
    }
  }

  Future<void> loadDailyTarget() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyTarget = prefs.getInt('dailyTarget') ?? 8;
    });
  }

  Future<void> updateWaterCount(int change) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      int currentValue = waterData[selectedDate] ?? 0;
      int newValue = currentValue + change;
      waterData[selectedDate] = newValue < 0 ? 0 : newValue;
    });
    await prefs.setString('waterData', jsonEncode(waterData));
  }

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 6)),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        waterData[selectedDate] = waterData[selectedDate] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengingat Minum Air 💧', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(DateFormat('EEEE, dd MMM yyyy').format(DateTime.parse(selectedDate)),
                  style: const TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(child: WaterChart(waterData: waterData, target: dailyTarget)),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => updateWaterCount(-1),
                  icon: const Icon(Icons.remove),
                  label: const Text('Kurangi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () => updateWaterCount(1),
                  icon: const Icon(Icons.local_drink),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
