import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:resq/screens/campadmin_dashboard.dart';
import 'package:resq/screens/camprole_creation.dart';
import 'package:resq/screens/collection_point.dart';
import 'package:resq/screens/create_notice.dart';
import 'family_data_download.dart';
import 'login_screen.dart';
import '../utils/auth/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedStatus = 'Alive';

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

  void _logout() {
    AuthService().logout().then((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: MediaQuery.of(context).size.width < 800 // Hamburger menu for smaller screen sizes (mobile)
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(child: Text('Admin Menu')),
                  buildDrawerItem(Icons.people, 'Families', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FamilyDataDownloadScreen()),
                    );
                    print("Families tapped");
                  }),
                  buildDrawerItem(Icons.home_work, 'Camp Status', () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CampAdminRequestScreen()),
                    );
                    // Add navigation for Camp Status
                    print("Camp Status tapped");
                  }),
                  buildDrawerItem(Icons.announcement, 'Role Based Notice Board', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateNoticeScreen()),
                    );
                    // Add navigation for Role Based Notice Board
                    print("Role Based Notice Board tapped");
                  }),
                  buildDrawerItem(Icons.assignment_ind, 'Role Creation', () {
                    // Navigate to Role Creation Screen when clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CamproleCreation()),
                    );
                     print("camprole creation");
                  }),
                  buildDrawerItem(Icons.add_location, 'Add Collection Points', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CollectionPoint()),
                    );
                     print("collection ponit");
                  }),
                ],
              ),
            )
          : null, // No Drawer on Web/Desktop
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Show navigation bar on Web/Desktop
              if (MediaQuery.of(context).size.width >= 800)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildNavItem(Icons.people, 'Families', () {
                        print("Families tapped");
                      }),
                      buildNavItem(Icons.home_work, 'Camp Status', () {
                        print("Camp Status tapped");
                      }),
                      buildNavItem(Icons.announcement, 'Role Based Notice Board', () {
                        print("Role Based Notice Board tapped");
                      }),
                      buildNavItem(Icons.assignment_ind, 'Role Creation', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CamproleCreation()),
                        );
                      }),
                      buildNavItem(Icons.add_location, 'Add Collection Points', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CollectionPoint()),
                        );
                      }),
                    ],
                  ),
                ),

              const Divider(),

              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          spots: statusData[selectedStatus] ?? [],
                          isCurved: true,
                          color: statusColors[selectedStatus]!,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

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

  Widget buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
        ],
      ),
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

  Widget buildDrawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}
