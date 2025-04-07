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
  // Replace single loading state with individual loading states
  bool _isLoadingNotices = true;
  bool _isLoadingOfficerMetrics = true;
  bool _isLoadingResourceDistribution = true;
  bool _isLoadingDisasterTimeline = true;

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
    // No need for a single loading state
    setState(() {
      _errorMessage = null;
    });

    // Start all fetches in parallel
    await Future.wait([
      _fetchNotices(),
      _fetchOfficerMetrics(),
      _fetchResourceDistribution(),
      _fetchDisasterTimeline(),
    ]);
  }

  Future<void> _fetchNotices() async {
    setState(() {
      _isLoadingNotices = true;
    });

    try {
      final response = await TokenHttp().get(
        '/notice/allNotice?disasterId=${AuthService().getDisasterId()}',
      );

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

      final notices =
          noticesList.map<Notice>((json) {
            try {
              // Map API fields to Notice fields
              return Notice(
                id: json['_id'] ?? 'unknown',
                title: json['title'] ?? 'Untitled Notice',
                content: json['description'] ?? 'No description available',
                status: json['status'] ?? 'pending',
                priority: _mapPriorityToEnum(json['priority'] ?? 'Medium'),
                createdAt:
                    json['createdAt'] != null
                        ? DateTime.parse(json['createdAt'])
                        : DateTime.now(),
              );
            } catch (e) {
              debugPrint('Error parsing notice: $e');
              return Notice(
                id: 'error',
                title: 'Invalid Notice',
                content: 'Could not parse notice data',
                status: 'error',
                priority: NoticeUrgency.low,
                createdAt: DateTime.now(),
              );
            }
          }).toList();

      setState(() {
        // Sort notices by priority (critical first)
        _priorityNotices =
            notices
              ..sort((a, b) => b.priority.index.compareTo(a.priority.index));

        _criticalNotice = notices.firstWhere(
          (notice) =>
              (notice.priority == NoticeUrgency.critical &&
              notice.status.toLowerCase() != 'completed'),
          orElse:
              () =>
                  notices.isNotEmpty
                      ? notices.first
                      : Notice(
                        id: 'default',
                        title: 'No notices available',
                        status: 'no-notices',
                        content: 'There are currently no notices',
                        createdAt: DateTime.now(),
                        priority: NoticeUrgency.low,
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
          status: 'error',
          createdAt: DateTime.now(),
          priority: NoticeUrgency.critical,
        );
      });
      debugPrint('Error fetching notices: $e');
    } finally {
      setState(() => _isLoadingNotices = false);
    }
  }

  NoticeUrgency _mapPriorityToEnum(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return NoticeUrgency.critical;
      case 'high':
        return NoticeUrgency.high;
      case 'medium':
        return NoticeUrgency.medium;
      case 'low':
        return NoticeUrgency.low;
      default:
        return NoticeUrgency.medium;
    }
  }

  Future<void> _fetchOfficerMetrics() async {
    setState(() {
      _isLoadingOfficerMetrics = true;
    });

    try {
      final response = await TokenHttp().get(
        '/settings/getOfficerMetrics?disasterId=${AuthService().getDisasterId()}',
      );

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
          'volunteers': _parseInt(
            response['officers'].firstWhere(
              (officer) => officer['_id'] == "Volunteer",
            )['count'],
          ),
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
      debugPrint('Error fetching officer metrics: $e');
    } finally {
      setState(() => _isLoadingOfficerMetrics = false);
    }
  }

  Future<void> _fetchResourceDistribution() async {
    setState(() {
      _isLoadingResourceDistribution = true;
    });

    try {
      final response = await TokenHttp().get(
        '/settings/getResourceDistribution?disasterId=${AuthService().getDisasterId()}',
      );

      if (response is Map && response.containsKey('error')) {
        if (response['statusCode'] == 404) {
          debugPrint('Resource distribution endpoint not found');
          return;
        }
        throw Exception(
          response['message'] ?? 'Failed to load resource distribution',
        );
      }

      if (response == null) throw Exception('No response from server');

      List<dynamic> distributionList = [];
      if (response is List) {
        distributionList = response;
      } else if (response['overview'] is List) {
        distributionList = response['overview'];
      } else {
        throw Exception('Invalid resource distribution format');
      }

      setState(() {
        _resourceDistribution =
            distributionList.map<Map<String, dynamic>>((item) {
              return {
                'day': _parseInt(item['day']),
                'inComming': _parseInt(item['inComming']),
                'outGoning': _parseInt(item['outGoning']),
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
      debugPrint('Error fetching resource distribution: $e');
    } finally {
      setState(() => _isLoadingResourceDistribution = false);
    }
  }

  Future<void> _fetchDisasterTimeline() async {
    setState(() {
      _isLoadingDisasterTimeline = true;
    });

    try {
      final response = await TokenHttp().get(
        '/settings/getDisasterTimeLine?disasterId=${AuthService().getDisasterId()}',
      );

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
      } else if (response["overview"] is List) {
        timelineList = response["overview"];
      } else {
        throw Exception('Invalid timeline format');
      }

      setState(() {
        _disasterTimeline =
            timelineList.map<Map<String, dynamic>>((item) {
              return {
                'day': _parseInt(item['day']),
                'alive': _parseInt(item['alive']),
                'missing': _parseInt(item['died']),
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
      debugPrint('Error fetching disaster timeline: $e');
    } finally {
      setState(() => _isLoadingDisasterTimeline = false);
    }
  }

  // Update the build method and section widgets with individual loading states:

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
            tooltip: 'Refresh All Data',
          ),
        ],
      ),
      drawer: !isDesktop ? const ResQMenu(roles: ['admin']) : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop)
                const ResQMenu(roles: ['admin'], showDrawer: false),

              const SizedBox(height: 16),

              // Emergency Alert Banner - Show loading state for notices
              _buildNoticesSection(),

              const SizedBox(height: 24),

              // Disaster Overview
              const Text(
                'Disaster Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Section header with refresh button
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Overview Statistics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  if (_isLoadingOfficerMetrics)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _fetchOfficerMetrics,
                      tooltip: 'Refresh Stats',
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Stats Cards
              _buildStatsSection(isDesktop),

              const SizedBox(height: 24),

              // Resource Distribution Chart
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Resource Distribution',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isLoadingResourceDistribution)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _fetchResourceDistribution,
                      tooltip: 'Refresh Resource Data',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildResourceSection(),

              const SizedBox(height: 24),

              // Disaster Timeline Chart
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Disaster Timeline',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isLoadingDisasterTimeline)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _fetchDisasterTimeline,
                      tooltip: 'Refresh Timeline',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTimelineSection(),

              const SizedBox(height: 24),

              // Priority Notices
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Priority Notices',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isLoadingNotices)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _fetchNotices,
                      tooltip: 'Refresh Notices',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildPriorityNoticesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticesSection() {
    if (_isLoadingNotices && _criticalNotice == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_criticalNotice == null) return const SizedBox();

    return _buildEmergencyAlertBanner();
  }

  Widget _buildStatsSection(bool isDesktop) {
    if (_isLoadingOfficerMetrics) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading statistics...'),
            ],
          ),
        ),
      );
    }

    return GridView.count(
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
    );
  }

  Widget _buildResourceSection() {
    if (_isLoadingResourceDistribution && _resourceDistribution.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading resource data...'),
            ],
          ),
        ),
      );
    }

    return _resourceDistribution.isEmpty
        ? _buildEmptyState('No resource distribution data available')
        : _buildResourceDistributionChart();
  }

  Widget _buildTimelineSection() {
    if (_isLoadingDisasterTimeline && _disasterTimeline.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading timeline data...'),
            ],
          ),
        ),
      );
    }

    return _disasterTimeline.isEmpty
        ? _buildEmptyState('No timeline data available')
        : _buildDayTimelineChart();
  }

  Widget _buildPriorityNoticesSection() {
    if (_isLoadingNotices && _priorityNotices.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading notices...'),
            ],
          ),
        ),
      );
    }

    return _priorityNotices.isEmpty
        ? _buildEmptyState('No priority notices available')
        : Column(
          children:
              _priorityNotices
                  .map((notice) => _NoticeCard(notice: notice))
                  .toList(),
        );
  }

  // Rest of the existing code remains unchanged...

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
      builder:
          (context) => AlertDialog(
            title: Text(notice.title),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(notice.content),
                  const SizedBox(height: 16),
                  Text(
                    'Created At: ${_formatDate(notice.createdAt)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${notice.status}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Priority: ${notice.priority.toString().split('.').last}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${notice.id}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
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
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResourceDistributionChart() {
    final incomingData =
        _resourceDistribution
            .map((e) => (_parseInt(e['inComming'] ?? 0)).toDouble())
            .toList();
    final outgoingData =
        _resourceDistribution
            .map((e) => (_parseInt(e['outGoning'] ?? 0)).toDouble())
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
                  barGroups: List.generate(_resourceDistribution.length, (
                    index,
                  ) {
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
                  // Rest of chart configuration remains unchanged
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
    final aliveData =
        _disasterTimeline.map((e) => (e['alive'] as int).toDouble()).toList();
    final missingData =
        _disasterTimeline.map((e) => (e['missing'] as int).toDouble()).toList();
    final deceasedData =
        _disasterTimeline
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

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color),
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
    switch (notice.priority) {
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
