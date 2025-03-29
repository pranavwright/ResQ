import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/supply_request.dart';

class RequestChart extends StatelessWidget {
  final List<SupplyRequest> requests;

  const RequestChart({required this.requests});

  @override
  Widget build(BuildContext context) {
    // Group requests by type and day (simplified)
    Map<String, int> requestCounts = {
      'Food': requests.where((r) => r.type == 'Food').length,
      'Water': requests.where((r) => r.type == 'Water').length,
      'Medicine': requests.where((r) => r.type == 'Medicine').length,
    };

    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(toY: requestCounts['Food']?.toDouble() ?? 0, color: Colors.orange),
              BarChartRodData(toY: requestCounts['Water']?.toDouble() ?? 0, color: Colors.blue),
              BarChartRodData(toY: requestCounts['Medicine']?.toDouble() ?? 0, color: Colors.red),
            ],
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0: return Text('Requests');
                  default: return const Text('');
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}