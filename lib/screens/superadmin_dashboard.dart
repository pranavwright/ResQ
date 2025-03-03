import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuperAdmin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const SuperAdminDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  String selectedStatus = 'Alive';
  
  // Sample data for each status
  final Map<String, List<FlSpot>> statusData = {
    'Alive': [
      const FlSpot(0, 0),
      const FlSpot(1, 3),
      const FlSpot(2, 5),
      const FlSpot(3, 2),
      const FlSpot(4, 6),
    ],
    'Missing': [
      const FlSpot(0, 0),
      const FlSpot(1, 2),
      const FlSpot(2, 4),
      const FlSpot(3, 3),
      const FlSpot(4, 1),
    ],
    'Deceased': [
      const FlSpot(0, 0),
      const FlSpot(1, 1),
      const FlSpot(2, 2),
      const FlSpot(3, 1),
      const FlSpot(4, 3),
    ],
  };

  final Map<String, Color> statusColors = {
    'Alive': Colors.green,
    'Missing': Colors.amber,
    'Deceased': Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Admin Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.menu),
                    const Spacer(),
                    const Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              
              // Navigation Icons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildNavItem(Icons.people, 'Families'),
                    buildNavItem(Icons.home_work, 'Camp Status'),
                    buildNavItem(Icons.announcement, 'Role Based\nNotice Board', isSelected: true),
                    buildNavItem(Icons.assignment_ind, 'Role Creation'),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Overview Title
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Chart
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          axisNameWidget: const Text('Families'),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value == 0 || value == 4) {
                                return Text(
                                  value == 0 ? 'Weeks' : 'Families',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                          left: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      minX: 0,
                      maxX: 4,
                      minY: 0,
                      maxY: 7,
                      lineBarsData: [
                        LineChartBarData(
                          spots: statusData[selectedStatus]!,
                          isCurved: true,
                          color: statusColors[selectedStatus],
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Status Toggles
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildStatusButton('Alive', Colors.green),
                    const SizedBox(width: 16),
                    buildStatusButton('Missing', Colors.amber),
                    const SizedBox(width: 16),
                    buildStatusButton('Deceased', Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.black,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        if (isSelected)
          Container(
            height: 2,
            width: 40,
            color: Colors.green,
          ),
      ],
    );
  }

  Widget buildStatusButton(String status, Color color) {
    final isSelected = selectedStatus == status;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = status;
        });
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}