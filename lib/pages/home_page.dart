import 'package:flutter/material.dart';
import 'package:pengingat_air/pages/setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../widgets/water_chart.dart';
// import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int dailyTarget = 8; // Target harian
  Map<String, int> waterData = {}; // Data jumlah air
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Tanggal terpilih

  @override
  void initState() {
    super.initState();
    loadWaterData();
  }

  Future<void> loadWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    String? dataString = prefs.getString('waterData');
    if (dataString != null) {
      setState(() {
        waterData = Map<String, int>.from(jsonDecode(dataString));
      });
    }
  }

  Future<void> updateWaterCount(int change) async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      int currentValue = waterData[selectedDate] ?? 0;
      int newValue = currentValue + change;
      waterData[selectedDate] = newValue < 0 ? 0 : newValue; // Tidak boleh negatif
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
            // TOMBOL PILIH TANGGAL
            ElevatedButton.icon(
              onPressed: pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(DateFormat('EEEE, dd MMM yyyy').format(DateTime.parse(selectedDate)), // Format tanggal lebih rapi
                  style: const TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(child: WaterChart(waterData: waterData, target: dailyTarget)), // GRAFIK

            const SizedBox(height: 20),
            // TOMBOL TAMBAH & KURANGI
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => updateWaterCount(-1), // Kurangi
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
                  onPressed: () => updateWaterCount(1), // Tambah
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
