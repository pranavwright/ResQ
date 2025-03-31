import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Notice {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String priority;
  String status;
  final String createdBy;

  Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.priority,
    required this.status,
    required this.createdBy,
  });
}

class ViewNotice extends StatefulWidget {
  final String noticeId;
  const ViewNotice({Key? key, required this.noticeId}) : super(key: key);
  @override
  State<ViewNotice> createState() => _ViewNoticeState();
}

class _ViewNoticeState extends State<ViewNotice> {
  List<Notice> notices = [];
  List<Notice> filteredNotices = [];
  String currentFilter = 'All';
  String currentSort = 'Newest';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading data
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        notices = _getSampleNotices();
        filteredNotices = notices;
        isLoading = false;
      });
    });
  }

  List<Notice> _getSampleNotices() {
    return [
      Notice(
        id: '1',
        title: 'Water supply interruption',
        description: 'Water supply will be interrupted in sector 5 for maintenance work',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        priority: 'high',
        status: 'pending',
        createdBy: 'Admin',
      ),
      Notice(
        id: '2',
        title: 'Medical camp setup',
        description: 'Setting up temporary medical camp near central park for affected residents',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        priority: 'medium',
        status: 'in_progress',
        createdBy: 'Health Dept',
      ),
      Notice(
        id: '3',
        title: 'Road clearance',
        description: 'Main road to hospital has been cleared of debris',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        priority: 'low',
        status: 'completed',
        createdBy: 'Public Works',
      ),
      Notice(
        id: '4',
        title: 'Emergency shelter',
        description: 'Additional emergency shelter opened at community center',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        priority: 'high',
        status: 'in_progress',
        createdBy: 'Red Cross',
      ),
    ];
  }

  void _filterNotices(String filter) {
    setState(() {
      currentFilter = filter;
      if (filter == 'All') {
        filteredNotices = notices;
      } else {
        filteredNotices = notices.where((notice) => notice.status == filter.toLowerCase()).toList();
      }
      _sortNotices(currentSort);
    });
  }

  void _sortNotices(String sort) {
    setState(() {
      currentSort = sort;
      filteredNotices.sort((a, b) {
        if (sort == 'Newest') {
          return b.createdAt.compareTo(a.createdAt);
        } else {
          return a.createdAt.compareTo(b.createdAt);
        }
      });
    });
  }

  void _updateNoticeStatus(Notice notice, String newStatus) {
    setState(() {
      notice.status = newStatus;
      _filterNotices(currentFilter); // Reapply filters
    });
    // In a real app, you would also call your API here to update the backend
  }

  void _showStatusUpdateDialog(Notice notice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedStatus = notice.status;

        return AlertDialog(
          title: const Text('Update Notice Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: const Text('Pending'),
                value: 'pending',
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value as String?;
                  });
                },
              ),
              RadioListTile(
                title: const Text('In Progress'),
                value: 'in_progress',
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value as String?;
                  });
                },
              ),
              RadioListTile(
                title: const Text('Completed'),
                value: 'completed',
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value as String?;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedStatus != null) {
                  _updateNoticeStatus(notice, selectedStatus!);
                }
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Notices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: currentFilter,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Notices')),
                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _filterNotices(value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Filter by',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: currentSort,
                    items: const [
                      DropdownMenuItem(value: 'Newest', child: Text('Newest First')),
                      DropdownMenuItem(value: 'Oldest', child: Text('Oldest First')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _sortNotices(value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Sort by',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNotices.isEmpty
                    ? const Center(child: Text('No notices found'))
                    : ListView.builder(
                        itemCount: filteredNotices.length,
                        itemBuilder: (context, index) {
                          final notice = filteredNotices[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notice.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getPriorityColor(notice.priority),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          notice.priority.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    notice.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(notice.status),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          notice.status.replaceAll('_', ' ').toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        DateFormat('MMM dd, yyyy - hh:mm a')
                                            .format(notice.createdAt),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Posted by: ${notice.createdBy}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => _showStatusUpdateDialog(notice),
                                    child: const Text('Update Status'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}