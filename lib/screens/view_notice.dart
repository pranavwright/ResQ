import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';

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
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    try {
      setState(() {
        isLoading = true;
      });

      // First, check if we're viewing a specific notice or all notices
      final String disasterId = AuthService().getDisasterId();
      final Map<String, dynamic> responseData;

      if (widget.noticeId.isNotEmpty) {
        // Fetch specific notice by ID
        responseData = await TokenHttp().get(
          '/notice/getNotice?noticeId=${widget.noticeId}&disasterId=$disasterId',
        );
        if (responseData != null) {
          // Handle single notice
          final notice = _parseNotice(responseData);
          if (notice != null) {
            notices = [notice];
            filteredNotices = notices;
          }
        }
      } else {
        // Fetch all notices
        final myNotice = await TokenHttp().get(
          '/notice/myNotice?disasterId=$disasterId',
        );
        if (myNotice is List) {
          notices =
              myNotice
                  .map((element) => _parseNotice(element))
                  .where((n) => n != null)
                  .cast<Notice>()
                  .toList();
          filteredNotices = notices;
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load notices: $e')));
    }
  }

  Notice? _parseNotice(Map<String, dynamic> element) {
    try {
      return Notice(
        id: element['_id'] ?? '', // MongoDB uses _id, not id
        title: element['title'] ?? 'Untitled',
        description: element['description'] ?? '',
        createdAt:
            element['createdAt'] != null
                ? DateTime.parse(element['createdAt'])
                : DateTime.now(),
        priority: element['priority'] ?? 'medium',
        status: element['status'] ?? 'pending',
        createdBy: element['createdBy'] ?? 'Unknown',
      );
    } catch (e) {
      print('Error parsing notice: $e');
      return null;
    }
  }

  void _filterNotices(String filter) {
    setState(() {
      currentFilter = filter;
      if (filter == 'All') {
        filteredNotices = notices;
      } else {
        filteredNotices =
            notices
                .where((notice) => notice.status == filter.toLowerCase())
                .toList();
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

  void _updateNoticeStatus(Notice notice, String newStatus) async {
    try {
      // Call API to update notice status
      final String disasterId = AuthService().getDisasterId();
      final response = await TokenHttp().post('/notice/updateNotice', {
        'noticeId': notice.id,
        'disasterId': disasterId,
        'status': newStatus,
      });

      if (response != null ) {
        setState(() {
          notice.status = newStatus;
          _filterNotices(currentFilter); 
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Notice status updated')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update notice status')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating notice status: $e')),
      );
    }
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
        return Colors.amber;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
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
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All Notices'),
                      ),
                      DropdownMenuItem(
                        value: 'Pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'In Progress',
                        child: Text('In Progress'),
                      ),
                      DropdownMenuItem(
                        value: 'Completed',
                        child: Text('Completed'),
                      ),
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
                      DropdownMenuItem(
                        value: 'Newest',
                        child: Text('Newest First'),
                      ),
                      DropdownMenuItem(
                        value: 'Oldest',
                        child: Text('Oldest First'),
                      ),
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
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredNotices.isEmpty
                    ? const Center(child: Text('No notices found'))
                    : ListView.builder(
                      itemCount: filteredNotices.length,
                      itemBuilder: (context, index) {
                        final notice = filteredNotices[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(
                                          notice.priority,
                                        ),
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
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(notice.status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        notice.status
                                            .replaceAll('_', ' ')
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      DateFormat(
                                        'MMM dd, yyyy - hh:mm a',
                                      ).format(notice.createdAt),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (notice.status == 'pending') ...[
                                      ElevatedButton(
                                        onPressed:
                                            () => _updateNoticeStatus(
                                              notice,
                                              'in_progress',
                                            ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Start Progress'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed:
                                            () => _updateNoticeStatus(
                                              notice,
                                              'cancelled',
                                            ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                    ] else if (notice.status ==
                                        'in_progress') ...[
                                      ElevatedButton(
                                        onPressed:
                                            () => _updateNoticeStatus(
                                              notice,
                                              'completed',
                                            ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Mark Complete'),
                                      ),
                                    ] else if (notice.status ==
                                        'completed') ...[
                                      // Optionally show a "Reopen" button or other actions for completed notices
                                      Text(
                                        'Completed',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ] else if (notice.status ==
                                        'cancelled') ...[
                                      // Optionally show a "Reopen" button for cancelled notices
                                      ElevatedButton(
                                        onPressed:
                                            () => _updateNoticeStatus(
                                              notice,
                                              'pending',
                                            ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                        ),
                                        child: const Text('Reopen'),
                                      ),
                                    ],
                                  ],
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
