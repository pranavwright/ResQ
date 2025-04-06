import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:resq/models/notice.dart';
import 'package:resq/utils/resq_menu.dart';
import 'package:resq/utils/http/token_http.dart';
import 'package:resq/utils/auth/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  String? _errorMessage;
  Notice? _criticalNotice;
  List<Notice> _priorityNotices = [];
  Map<String, dynamic> _disasterStats = {
    'affected': 0,
    'reliefCamps': 0,
    'hospitalised': 0,
    'volunteers': 0,
  };
  List<Map<String, dynamic>> _resourceDistribution = [];
  List<Map<String, dynamic>> _disasterTimeline = [];

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    int successCount = 0;
    final fetches = [
      _fetchNotices().then((_) => successCount++).catchError((e) {
        debugPrint('Error fetching notices: $e');
      }),
      _fetchOfficerMetrics().then((_) => successCount++).catchError((e) {
        debugPrint('Error fetching metrics: $e');
      }),
      _fetchResourceDistribution().then((_) => successCount++).catchError((e) {
        debugPrint('Error fetching resource distribution: $e');
      }),
      _fetchDisasterTimeline().then((_) => successCount++).catchError((e) {
        debugPrint('Error fetching timeline: $e');
      }),
    ];

    try {
      await Future.wait(fetches);
      
      if (successCount == 0) {
        setState(() {
          _errorMessage = 'Failed to load initial data. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchNotices() async {
    try {
      final response = await TokenHttp().get('/notice/allNotice?disasterId=${AuthService().getDisasterId()}');
      
      if (response is Map && response.containsKey('error')) {
        if (response['statusCode'] == 404) {
          debugPrint('Notices endpoint not found');
          return;
        }
        throw Exception(response['message'] ?? 'Failed to load notices');
      }

      List<dynamic> noticesList = [];
      if (response is List) {
        noticesList = response;
      } else if (response != null && response['list'] is List) {
        noticesList = response['list'];
      } else {
        throw Exception('Invalid notices format');
      }

      final notices = noticesList.map<Notice>((json) {
        try {
          return Notice.fromJson(json);
        } catch (e) {
          return Notice(
            id: 'error',
            title: 'Invalid Notice',
            content: 'Could not parse notice data',
            createdAt: DateTime.now(),
            urgency: NoticeUrgency.low,
          );
        }
      }).toList();
      
      setState(() {
        _priorityNotices = notices;
        _criticalNotice = notices.firstWhere(
          (notice) => notice.urgency == NoticeUrgency.critical,
          orElse: () => notices.isNotEmpty ? notices.first : Notice(
            id: 'default',
            title: 'No notices available',
            content: 'There are currently no notices',
            createdAt: DateTime.now(),
            urgency: NoticeUrgency.low,
          ),
        );
      });
    } catch (e) {
      setState(() {
        _priorityNotices = [];
        _criticalNotice = Notice(
          id: 'error',
          title: 'Error loading notices',
          content: 'Could not load notices',
          createdAt: DateTime.now(),
          urgency: NoticeUrgency.critical,
        );
      });
      rethrow;
    }
  }

  Future<void> _fetchOfficerMetrics() async {
    try {
      final response = await TokenHttp().get('/settings/getOfficerMetrics?disasterId=${AuthService().getDisasterId()}');
      
      if (response is Map && response.containsKey('error')) {
        if (response['statusCode'] == 404) {
          debugPrint('Officer metrics endpoint not found, using defaults');
          setState(() {
            _disasterStats = {
              'affected': 0,
              'reliefCamps': 0,
              'hospitalised': 0,
              'volunteers': 0,
            };
          });
          return;
        }
        throw Exception(response['message'] ?? 'Failed to load metrics');
      }

      if (response == null) throw Exception('No response from server');

      setState(() {
        _disasterStats = {
          'affected': _parseInt(response['affected']),
          'reliefCamps': _parseInt(response['reliefCamps']),
          'hospitalised': _parseInt(response['hospitalised']),
          'volunteers': _parseInt(response['volunteers']),
        };
      });
    } catch (e) {
      if (!e.toString().contains('404')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading metrics: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _disasterStats = {
          'affected': 0,
          'reliefCamps': 0,
          'hospitalised': 0,
          'volunteers': 0,
        };
      });
    }
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _fetchResourceDistribution() async {
    try {
      final response = await TokenHttp().get('/settings/getResourceDistribution?disasterId=${AuthService().getDisasterId()}');
      
      if (response is Map && response.containsKey('error')) {
        if (response['statusCode'] == 404) {
          debugPrint('Resource distribution endpoint not found');
          return;
        }
        throw Exception(response['message'] ?? 'Failed to load resource distribution');
      }

      if (response == null) throw Exception('No response from server');

      List<dynamic> distributionList = [];
      if (response is List) {
        distributionList = response;
      } else if (response['list'] is List) {
        distributionList = response['list'];
      } else {
        throw Exception('Invalid resource distribution format');
      }

      setState(() {
        _resourceDistribution = distributionList.map<Map<String, dynamic>>((item) {
          return {
            'day': _parseInt(item['day']),
            'incoming': _parseInt(item['incoming']),
            'outgoing': _parseInt(item['outgoing']),
          };
        }).toList();
      });
    } catch (e) {
      if (!e.toString().contains('404')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading resource data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _resourceDistribution = []);
    }
  }

  Future<void> _fetchDisasterTimeline() async {
    try {
      final response = await TokenHttp().get('/settings/getDisasterTimeLine?disasterId=${AuthService().getDisasterId()}');
      
      if (response is Map && response.containsKey('error')) {
        if (response['statusCode'] == 404) {
          debugPrint('Disaster timeline endpoint not found');
          return;
        }
        throw Exception(response['message'] ?? 'Failed to load timeline');
      }

      if (response == null) throw Exception('No response from server');

      List<dynamic> timelineList = [];
      if (response is List) {
        timelineList = response;
      } else if (response['list'] is List) {
        timelineList = response['list'];
      } else {
        throw Exception('Invalid timeline format');
      }

      setState(() {
        _disasterTimeline = timelineList.map<Map<String, dynamic>>((item) {
          return {
            'day': _parseInt(item['day']),
            'alive': _parseInt(item['alive']),
            'missing': _parseInt(item['missing']),
            'deceased': _parseInt(item['deceased']),
          };
        }).toList();
      });
    } catch (e) {
      if (!e.toString().contains('404')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading timeline: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _disasterTimeline = []);
    }
  }

  Widget _buildEmergencyAlertBanner() {
    if (_criticalNotice == null) return const SizedBox();
    
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
                Text(
                  _criticalNotice!.title, 
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _criticalNotice!.content,
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showNoticeDetails(_criticalNotice!),
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
              if (notice.affectedAreas != null && notice.affectedAreas!.isNotEmpty) ...[
                Text(
                  'Affected Areas:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEmptyState(String message, {VoidCallback? onRetry}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Command Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAllData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      drawer: !isDesktop ? const ResQMenu(roles: ['admin']) : null,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && 
            _priorityNotices.isEmpty && 
            _resourceDistribution.isEmpty && 
            _disasterTimeline.isEmpty
              ? Center(
                  child: _buildEmptyState(
                    _errorMessage!,
                    onRetry: _fetchAllData,
                  ),
                )
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
                        if (_criticalNotice != null) _buildEmergencyAlertBanner(),

                        const SizedBox(height: 24),

                        // Disaster Overview
                        const Text(
                          'Disaster Overview', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          children: [
                            _StatCard(
                              icon: Icons.people_outlined,
                              title: 'AFFECTED',
                              value: _disasterStats['affected'].toString(),
                            ),
                            _StatCard(
                              icon: Icons.home_outlined,
                              title: 'RELIEF CAMPS',
                              value: _disasterStats['reliefCamps'].toString(),
                            ),
                            _StatCard(
                              icon: Icons.medical_services_outlined,
                              title: 'HOSPITALISED',
                              value: _disasterStats['hospitalised'].toString(),
                            ),
                            _StatCard(
                              icon: Icons.person_outlined,
                              title: 'VOLUNTEERS',
                              value: _disasterStats['volunteers'].toString(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Charts Section
                        const Text(
                          'Resource Distribution', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _resourceDistribution.isEmpty
                            ? _buildEmptyState('No resource distribution data available')
                            : _buildResourceDistributionChart(),

                        const SizedBox(height: 24),

                        const Text(
                          'Disaster Timeline', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _disasterTimeline.isEmpty
                            ? _buildEmptyState('No timeline data available')
                            : _buildDayTimelineChart(),

                        const SizedBox(height: 24),

                        // Priority Notices
                        const Text(
                          'Priority Notices', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _priorityNotices.isEmpty
                            ? _buildEmptyState('No priority notices available')
                            : Column(
                                children: _priorityNotices
                                    .map((notice) => _NoticeCard(notice: notice))
                                    .toList(),
                              ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildResourceDistributionChart() {
    final incomingData = _resourceDistribution
        .map((e) => (e['incoming'] as int).toDouble())
        .toList();
    final outgoingData = _resourceDistribution
        .map((e) => (e['outgoing'] as int).toDouble())
        .toList();
    
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
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  groupsSpace: 30,
                  barGroups: List.generate(_resourceDistribution.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: incomingData[index],
                          color: Colors.blue[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: outgoingData[index],
                          color: Colors.green[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final day = _resourceDistribution[value.toInt()]['day'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Day $day',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _calculateInterval(incomingData),
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
    final aliveData = _disasterTimeline
        .map((e) => (e['alive'] as int).toDouble())
        .toList();
    final missingData = _disasterTimeline
        .map((e) => (e['missing'] as int).toDouble())
        .toList();
    final deceasedData = _disasterTimeline
        .map((e) => (e['deceased'] as int).toDouble())
        .toList();
    
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
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  groupsSpace: 20,
                  barGroups: List.generate(_disasterTimeline.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: aliveData[index],
                          color: Colors.green[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: missingData[index],
                          color: Colors.orange[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: deceasedData[index],
                          color: Colors.red[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final day = _disasterTimeline[value.toInt()]['day'];
                          return SideTitleWidget(
                            angle: 0,
                            space: 4,
                            meta: meta,
                            child: Text(
                              'Day $day',
                              style: const TextStyle(
                                fontSize: 12,
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
                        interval: _calculateInterval(aliveData),
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

  double _calculateInterval(List<double> data) {
    if (data.isEmpty) return 10;
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 10) return 2;
    if (maxValue <= 50) return 10;
    if (maxValue <= 100) return 20;
    if (maxValue <= 500) return 50;
    return 100;
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
            Text(
              title, 
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value, 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
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