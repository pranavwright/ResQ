import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:resq/models/notice.dart';
import 'package:resq/utils/resq_menu.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = false;
  
  // Mock notice data
  final Notice _mockCriticalNotice = Notice(
    id: 'mock1',
    title: 'Flood Warning: Riverside District',
    content: 'Water levels exceeding danger marks. Evacuate immediately.',
    createdAt: DateTime.now(),
    urgency: NoticeUrgency.critical,
    affectedAreas: ['Downtown', 'Riverside'],
  );

  // Updated stats without percentages
  final Map<String, Map<String, dynamic>> _disasterStats = {
    'affected': {'count': 1245, 'icon': Icons.people_outlined},
    'relief_camps': {'count': 18, 'icon': Icons.home_outlined},
    'hospitalised': {'count': 7, 'icon': Icons.medical_services_outlined},
    'volunteers': {'count': 342, 'icon': Icons.person_outlined},
  };

  // Priority tasks will show notices
  late final List<Notice> _priorityNotices = [
    Notice(
      id: 'notice1',
      title: 'Food Donations Needed',
      content: 'Camp #3 requires immediate food supplies for 200 people',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      urgency: NoticeUrgency.high,
    ),
    Notice(
      id: 'notice2',
      title: 'Medical Supplies Shortage',
      content: 'Critical shortage of bandages and antiseptics at Central Camp',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      urgency: NoticeUrgency.critical,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _priorityNotices.add(_mockCriticalNotice); // Add the banner notice
  }

  Widget _buildEmergencyAlertBanner() {
    return Container(
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
                Text(_mockCriticalNotice.title, 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(_mockCriticalNotice.content,
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showNoticeDetails(_mockCriticalNotice),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  void _showNoticeDetails(Notice notice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notice.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notice.content),
              const SizedBox(height: 16),
              if (notice.affectedAreas != null) ...[
                Text('Affected Areas:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(notice.affectedAreas!.join(', ')),
              ],
              const SizedBox(height: 16),
              Text('Issued: ${_formatDate(notice.createdAt)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildEmergencyAlertBanner(),

                    const SizedBox(height: 24),

                    // Disaster Overview
                    const Text('Disaster Overview', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Stats Cards (without percentages)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isDesktop ? 4 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: _disasterStats.entries.map((entry) {
                        return _StatCard(
                          icon: entry.value['icon'],
                          title: entry.key.replaceAll('_', ' ').toUpperCase(),
                          value: entry.value['count'].toString(),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Charts Row - Only show side by side on desktop
                    isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildResourceDistributionChart(),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDayTimelineChart(),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _buildResourceDistributionChart(),
                              const SizedBox(height: 16),
                              _buildDayTimelineChart(),
                            ],
                          ),

                    const SizedBox(height: 24),

                    // Priority Tasks (now showing notices)
                    const Text('Priority Notices', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._priorityNotices.map((notice) => _NoticeCard(notice: notice)).toList(),

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
            const Text(
              'Resource Distribution',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  groupsSpace: 30,
                  barGroups: [
                    // Day 1
                    BarChartGroupData(
                      x: 0,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 1200,
                          color: Colors.blue[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: 850,
                          color: Colors.green[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ],
                    ),
                    // Day 2
                    BarChartGroupData(
                      x: 1,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 900,
                          color: Colors.blue[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: 700,
                          color: Colors.green[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ],
                    ),
                    // Day 3
                    BarChartGroupData(
                      x: 2,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 600,
                          color: Colors.blue[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: 500,
                          color: Colors.green[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                 bottomTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    getTitlesWidget: (value, meta) {
      final titles = ['Day 1', 'Day 2', 'Day 3'];
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          titles[value.toInt()],
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
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
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendItem(Colors.blue[400]!, 'Incoming Donations'),
                _buildLegendItem(Colors.green[400]!, 'Outgoing Donations'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTimelineChart() {
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
          const Text(
            'Disaster Timeline', 
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                groupsSpace: 20, // Space between day groups
                barGroups: [
                  // Day 1
                  BarChartGroupData(
                    x: 0,
                    barsSpace: 4, // Space between bars in same group
                    barRods: [
                      BarChartRodData(
                        toY: 30, // Alive
                        color: Colors.green[400]!,
                        width: 12,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      BarChartRodData(
                        toY: 10, // Missing (40-30)
                        color: Colors.orange[400]!,
                        width: 12,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      BarChartRodData(
                        toY: 5, // Deceased (45-40)
                        color: Colors.red[400]!,
                        width: 12,
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ],
                  ),
                  // Day 2
                  BarChartGroupData(
                    x: 1,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: 18, // Alive
                        color: Colors.green[400]!,
                        width: 12,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      BarChartRodData(
                        toY: 7, // Missing (25-18)
                        color: Colors.orange[400]!,
                        width: 12,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      BarChartRodData(
                        toY: 3, // Deceased (28-25)
                        color: Colors.red[400]!,
                        width: 12,
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ],
                  ),
                  // Day 3
                  BarChartGroupData(
                    x: 2,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: 8, // Alive
                        color: Colors.green[400]!,
                        width: 12,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      BarChartRodData(
                        toY: 5, // Missing (13-8)
                        color: Colors.orange[400]!,
                        width: 12,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      BarChartRodData(
                        toY: 2, // Deceased (15-13)
                        color: Colors.red[400]!,
                        width: 12,
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ],
                  ),
                ],
                titlesData: FlTitlesData(
                  show: true,
               bottomTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    getTitlesWidget: (value, meta) {
      final titles = ['Day 1', 'Day 2', 'Day 3'];
      return SideTitleWidget(
        angle: 0,
        space: 4,  // Space from the axis
        meta: meta,
        child: Text(
          titles[value.toInt()],
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    },
  ),
),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString());
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildLegendItem(Colors.green[400]!, 'Alive'),
              _buildLegendItem(Colors.orange[400]!, 'Missing'),
              _buildLegendItem(Colors.red[400]!, 'Deceased'),
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
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final Notice notice;

  const _NoticeCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    Color urgencyColor;
    switch (notice.urgency) {
      case NoticeUrgency.critical:
        urgencyColor = Colors.red;
        break;
      case NoticeUrgency.high:
        urgencyColor = Colors.orange;
        break;
      default:
        urgencyColor = Colors.blue;
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
                color: urgencyColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title, 
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notice.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Chip(
              label: const Text('In Progress'),
              backgroundColor: Colors.blue[50],
              labelStyle: const TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}