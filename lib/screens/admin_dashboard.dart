import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:resq/screens/campadmin_dashboard.dart';
import 'package:resq/screens/camprole_creation.dart';
import 'package:resq/screens/collection_point.dart';
import 'package:resq/screens/create_notice.dart';
import 'package:resq/utils/menu_list.dart';
import 'package:resq/utils/resq_menu.dart';
import '../utils/auth/auth_service.dart';
import 'family_data_download.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late List<Map<String, dynamic>> _recentActivities;
  late Map<String, List<FlSpot>> _chartData;
  bool _isLoading = true;
  String? _errorMessage;
  final List<String> _timeFrames = ['24h', '7d', '30d', 'All'];
  int _selectedTimeFrame = 0;

  // Updated with Material icons
  final Map<String, Map<String, dynamic>> _disasterStats = {
    'affected': {'count': 1245, 'trend': 12.5, 'icon': Icons.people_outlined},
    'relief_camps': {'count': 18, 'trend': -2.0, 'icon': Icons.home_outlined},
    'medical': {'count': 7, 'trend': 0.0, 'icon': Icons.medical_services_outlined},
    'volunteers': {'count': 342, 'trend': 25.3, 'icon': Icons.person_outlined},
  };

  final List<Map<String, dynamic>> _priorityTasks = [
    {'title': 'Arrange food for Camp #3', 'priority': 'High', 'status': 'Pending'},
    {'title': 'Medical team deployment', 'priority': 'Critical', 'status': 'In Progress'},
    {'title': 'Damage assessment report', 'priority': 'Medium', 'status': 'Completed'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Command Center'),
        
      ),
      drawer: !isDesktop ? const ResQMenu(roles: ['admin']) : null,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDesktop)
                      const ResQMenu(roles: ['admin'], showDrawer: false),

                    const SizedBox(height: 16),

                    // Emergency Alert Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_outlined, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ALERT: Flood warning for 3 districts', 
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Next 48 hours - Evacuations in progress', 
                                    style: TextStyle(color: Colors.grey[700])),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {}, 
                            child: const Text('View Details'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Time frame selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Disaster Overview', 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            children: List.generate(_timeFrames.length, (index) {
                              return InkWell(
                                onTap: () => setState(() => _selectedTimeFrame = index),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedTimeFrame == index 
                                        ? theme.primaryColor.withOpacity(0.2) 
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(_timeFrames[index]),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Stats Cards
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isDesktop ? 4 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: _disasterStats.entries.map((entry) {
                        final bool isPositive = entry.value['trend'] > 0;
                        return _StatCard(
                          icon: entry.value['icon'],
                          title: entry.key.replaceAll('_', ' ').toUpperCase(),
                          value: entry.value['count'].toString(),
                          trend: entry.value['trend'],
                          isPositive: isPositive,
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Charts Row
                    isDesktop 
                        ? Row(
                            children: [
                              Expanded(child: _buildAffectedPeopleChart()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildResourceDistributionChart()),
                            ],
                          )
                        : Column(
                            children: [
                              _buildAffectedPeopleChart(),
                              const SizedBox(height: 16),
                              _buildResourceDistributionChart(),
                            ],
                          ),

                    const SizedBox(height: 24),

                    // Priority Tasks
                    const Text('Priority Tasks', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._priorityTasks.map((task) => _TaskCard(task: task)).toList(),

                    const SizedBox(height: 24),

                    // Recent Activity
                    const Text('Recent Activity', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildRecentActivity(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _StatCard({
    required IconData icon,
    required String title,
    required String value,
    required double trend,
    required bool isPositive,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.blue),
                ),
                Text(
                  '$trend%',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, 
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(value, 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAffectedPeopleChart() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Affected Population', 
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1000,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const districts = ['D1', 'D2', 'D3', 'D4', 'D5'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(districts[value.toInt()]),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 200,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 800,
                          color: Colors.blue[400],
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: 500,
                          color: Colors.blue[400],
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 950,
                          color: Colors.blue[400],
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: 300,
                          color: Colors.blue[400],
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 600,
                          color: Colors.blue[400],
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {}, 
                  child: const Text('View Details'),
                ),
                TextButton(
                  onPressed: () {}, 
                  child: const Text('Export Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceDistributionChart() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resource Distribution', 
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      value: 35,
                      color: Colors.blue,
                      title: '35%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: 25,
                      color: Colors.green,
                      title: '25%',
                      radius: 55,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: 20,
                      color: Colors.orange,
                      title: '20%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: 15,
                      color: Colors.red,
                      title: '15%',
                      radius: 45,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: 5,
                      color: Colors.purple,
                      title: '5%',
                      radius: 40,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendItem(Colors.blue, 'Food'),
                _buildLegendItem(Colors.green, 'Water'),
                _buildLegendItem(Colors.orange, 'Medicine'),
                _buildLegendItem(Colors.red, 'Shelter'),
                _buildLegendItem(Colors.purple, 'Other'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'action': 'New relief camp added', 'time': '10 min ago', 'icon': Icons.home_outlined},
      {'action': 'Medical team dispatched', 'time': '25 min ago', 'icon': Icons.medical_services_outlined},
      {'action': 'Food supplies delivered', 'time': '1 hour ago', 'icon': Icons.inventory_outlined},
      {'action': 'Damage assessment completed', 'time': '2 hours ago', 'icon': Icons.assignment_outlined},
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: activities.map((activity) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(activity['icon'] as IconData, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity['action'] as String),
                      Text(
                        activity['time'] as String,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    switch (task['priority']) {
      case 'Critical':
        priorityColor = Colors.red;
        break;
      case 'High':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task['title'], 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(task['priority'], 
                      style: TextStyle(color: priorityColor, fontSize: 12)),
                ],
              ),
            ),
            Chip(
              label: Text(task['status']),
              backgroundColor: task['status'] == 'Completed' 
                  ? Colors.green[50] 
                  : task['status'] == 'In Progress'
                      ? Colors.blue[50]
                      : Colors.grey[200],
              labelStyle: TextStyle(
                color: task['status'] == 'Completed' 
                    ? Colors.green 
                    : task['status'] == 'In Progress'
                        ? Colors.blue
                        : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 