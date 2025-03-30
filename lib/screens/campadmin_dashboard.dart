import 'package:flutter/material.dart';
import 'package:resq/widgets/stats_card.dart';
import 'package:resq/utils/resq_menu.dart';
import 'package:resq/utils/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:resq/screens/camp_supply_request.dart';
import 'package:resq/screens/camp_settings.dart'; // Import your CampSettingsScreen

class CampAdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Greenfield Camp (Zone 3)'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CampSettingsScreen()),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CampSupplyRequestScreen(campId: 'greenfield_zone3'),
                  ),
                );
                
                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Supply request submitted successfully!')),
                  );
                }
              },
              icon: Icon(Icons.add, size: 20),
              label: Text('Request Supplies'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ResQMenu(
            roles: ['campAdmin'],
            showDrawer: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats Row
                  Row(
                    children: [
                      Expanded(child: StatsCard(title: 'Total Residents', value: '1,242')),
                      Expanded(child: StatsCard(title: 'Shelter Capacity', value: '82%')),
                      Expanded(child: StatsCard(title: 'Supplies Delivered', value: '87%')),
                    ],
                  ),
                  SizedBox(height: 24),
                  
                  // Supply Distribution Graph
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Supply Distribution',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            height: 250,
                            child: BarChart(
                              BarChartData(
                                barGroups: _generateBarData(),
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final types = ['Water', 'Food', 'Med', 'Blankets', 'Hygiene'];
                                        return Padding(
                                          padding: EdgeInsets.only(top: 8),
                                          child: Text(
                                            types[value.toInt()],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        );
                                      },
                                      reservedSize: 28,
                                    ),
                                  ),
                                ),
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipColor: (group) => AppColors.primary.withOpacity(0.8),
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      final types = ['Water', 'Food', 'Med', 'Blankets', 'Hygiene'];
                                      return BarTooltipItem(
                                        '${types[group.x.toInt()]}\n',
                                        TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '${rod.toY.toInt()} units',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Additional Metrics
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Camp Metrics',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildMetricRow('Medical Cases', '24', Icons.medical_services),
                          _buildMetricRow('New Arrivals', '18', Icons.group_add),
                          _buildMetricRow('Meals Served', '1,850', Icons.restaurant),
                          _buildMetricRow('Water Distributed', '2,400L', Icons.water_drop),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBarData() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [BarChartRodData(toY: 180, color: Colors.blue.shade400, width: 22)],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [BarChartRodData(toY: 140, color: Colors.green.shade400, width: 22)],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [BarChartRodData(toY: 90, color: Colors.red.shade400, width: 22)],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [BarChartRodData(toY: 120, color: Colors.orange.shade400, width: 22)],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [BarChartRodData(toY: 75, color: Colors.purple.shade400, width: 22)],
      ),
    ];
  }

  Widget _buildMetricRow(String title, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          SizedBox(width: 12),
          Text(title, style: TextStyle(fontSize: 16)),
          Spacer(),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}