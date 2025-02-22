import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WaterChart extends StatelessWidget {
  final Map<String, int> waterData;
  final int target;

  const WaterChart({super.key, required this.waterData, required this.target});

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    List<String> last7Days = List.generate(7, (index) {
      return DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: 6 - index)));
    });

    List<String> dayLabels = List.generate(7, (index) {
      return DateFormat('E').format(DateTime.now().subtract(Duration(days: 6 - index))); // Nama hari (Sen, Sel, dst.)
    });

    for (int i = 0; i < last7Days.length; i++) {
      String date = last7Days[i];
      int waterCount = waterData[date] ?? 0;

      // Cegah nilai Infinity atau negatif
      double safeWaterCount = waterCount.isFinite && waterCount >= 0 ? waterCount.toDouble() : 0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: safeWaterCount,
              color: safeWaterCount >= target ? Colors.green : Colors.blue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Tambahkan teks keterangan
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: Colors.blue),
              const SizedBox(width: 8),
              const Text("Belum cukup minum air"),
              const SizedBox(width: 20),
              Container(width: 16, height: 16, color: Colors.green),
              const SizedBox(width: 8),
              const Text("Sudah cukup minum air"),
            ],
          ),
        ),
        
        // Grafik batang air minum
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(dayLabels[value.toInt()], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
                      },
                    ),
                  ),
                ),
                barGroups: barGroups,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
