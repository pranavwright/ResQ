import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:resq/screens/create_notice.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';

// Models
class Notice {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final NoticeType type;
  final NoticeUrgency urgency;
  final List<String>? attachments;
  final List<String>? affectedAreas;
  final bool isOfficial;
  final int viewCount;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.expiresAt,
    required this.type,
    required this.urgency,
    this.attachments,
    this.affectedAreas,
    required this.isOfficial,
    this.viewCount = 0,
  });
}

enum NoticeType { alert, update, resource, evacuation, general }

enum NoticeUrgency { critical, high, medium, low }

// Main Screen
class NoticeScreen extends StatefulWidget {
  final String userId;

  const NoticeScreen({Key? key, this.userId = 'admin'}) : super(key: key);

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Notice> _allNotices = [];
  List<Notice> _myNotices = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  TextEditingController _searchController = TextEditingController();
  List<Notice> _filteredNotices = [];
  NoticeType? _selectedTypeFilter;
  NoticeUrgency? _selectedUrgencyFilter;
  bool _showExpiredNotices = false;
  Timer? _refreshTimer;
  bool _isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotices();
    // Auto-refresh every 2 minutes
    _refreshTimer = Timer.periodic(Duration(minutes: 2), (timer) {
      if (!_isOfflineMode) {
        _loadNotices();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadNotices() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final notice = await TokenHttp().get(
        '/notice/allNotice?disasterId=${AuthService().getDisasterId()}',
      );
      final myNotice = await TokenHttp().get(
        '/notice/myNotice?disasterId=${AuthService().getDisasterId()}',
      );

      setState(() {
        // Convert JSON data to Notice objects
        _allNotices =
            (notice as List).map((item) => _convertToNotice(item)).toList();
        _myNotices =
            (myNotice as List).map((item) => _convertToNotice(item)).toList();
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load notices. Please try again.';
      });
    }
  }

  // Helper method to convert JSON to Notice object
  Notice _convertToNotice(Map<String, dynamic> json) {
    return Notice(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      type: _parseNoticeType(json['type']),
      urgency: _parseNoticeUrgency(json['urgency']),
      attachments:
          json['attachments'] != null
              ? List<String>.from(json['attachments'])
              : null,
      affectedAreas:
          json['affectedAreas'] != null
              ? List<String>.from(json['affectedAreas'])
              : null,
      isOfficial: json['isOfficial'] ?? false,
      viewCount: json['viewCount'] ?? 0,
    );
  }

  // Helper methods to parse enums
  NoticeType _parseNoticeType(String? type) {
    if (type == null) return NoticeType.general;
    try {
      return NoticeType.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == type.toLowerCase(),
      );
    } catch (_) {
      return NoticeType.general;
    }
  }

  NoticeUrgency _parseNoticeUrgency(String? urgency) {
    if (urgency == null) return NoticeUrgency.medium;
    try {
      return NoticeUrgency.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() == urgency.toLowerCase(),
      );
    } catch (_) {
      return NoticeUrgency.medium;
    }
  }

  void _applyFilters() {
    List<Notice> notices = _tabController.index == 0 ? _allNotices : _myNotices;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      String searchTerm = _searchController.text.toLowerCase();
      notices =
          notices
              .where(
                (notice) =>
                    notice.title.toLowerCase().contains(searchTerm) ||
                    notice.content.toLowerCase().contains(searchTerm) ||
                    notice.authorName.toLowerCase().contains(searchTerm) ||
                    (notice.affectedAreas?.any(
                          (area) => area.toLowerCase().contains(searchTerm),
                        ) ??
                        false),
              )
              .toList();
    }

    // Apply type filter
    if (_selectedTypeFilter != null) {
      notices =
          notices
              .where((notice) => notice.type == _selectedTypeFilter)
              .toList();
    }

    // Apply urgency filter
    if (_selectedUrgencyFilter != null) {
      notices =
          notices
              .where((notice) => notice.urgency == _selectedUrgencyFilter)
              .toList();
    }

    // Filter out expired notices if needed
    if (!_showExpiredNotices) {
      notices =
          notices
              .where(
                (notice) =>
                    notice.expiresAt == null ||
                    notice.expiresAt!.isAfter(DateTime.now()),
              )
              .toList();
    }

    // Sort by urgency and then by date
    notices.sort((a, b) {
      int urgencyCompare = b.urgency.index.compareTo(a.urgency.index);
      if (urgencyCompare != 0) return urgencyCompare;
      return b.createdAt.compareTo(a.createdAt);
    });

    setState(() {
      _filteredNotices = notices;
    });
  }

  void _navigateToCreateNotice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateNoticeScreen()),
    ).then((_) => _loadNotices()); // Refresh notices after returning
  }

  void _navigateToNoticeDetails(Notice notice) {
    // TODO: Navigate to Notice Detail screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => NoticeDetailScreen(notice: notice)),
    // );
  }

  Future<void> _refreshNotices() async {
    await _loadNotices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disaster Notices'),
        actions: [
          IconButton(
            icon: Icon(_isOfflineMode ? Icons.cloud_off : Icons.cloud_done),
            onPressed: () {
              setState(() {
                _isOfflineMode = !_isOfflineMode;
                if (!_isOfflineMode) {
                  _loadNotices();
                }
              });
            },
            tooltip: _isOfflineMode ? 'Offline Mode' : 'Online Mode',
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              _applyFilters();
            });
          },
          tabs: [Tab(text: 'All Notices'), Tab(text: 'My Notices')],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notices...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        )
                        : null,
              ),
              onChanged: (value) {
                _applyFilters();
              },
            ),
          ),

          // Filters chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                if (_selectedTypeFilter != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text(
                        'Type: ${_selectedTypeFilter.toString().split('.').last}',
                      ),
                      onDeleted: () {
                        setState(() {
                          _selectedTypeFilter = null;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                if (_selectedUrgencyFilter != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text(
                        'Urgency: ${_selectedUrgencyFilter.toString().split('.').last}',
                      ),
                      backgroundColor: _getUrgencyColor(
                        _selectedUrgencyFilter!,
                      ).withOpacity(0.3),
                      onDeleted: () {
                        setState(() {
                          _selectedUrgencyFilter = null;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                FilterChip(
                  label: Text('Show Expired'),
                  selected: _showExpiredNotices,
                  onSelected: (selected) {
                    setState(() {
                      _showExpiredNotices = selected;
                      _applyFilters();
                    });
                  },
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _hasError
                    ? _buildErrorView()
                    : _filteredNotices.isEmpty
                    ? _buildEmptyView()
                    : RefreshIndicator(
                      onRefresh: _refreshNotices,
                      child: ListView.builder(
                        itemCount: _filteredNotices.length,
                        itemBuilder: (context, index) {
                          return _buildNoticeCard(_filteredNotices[index]);
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: AuthService().userRoles != null && 
                          AuthService().userRoles.isNotEmpty && 
                          (['admin', 'stat', 'collectionPointAdmin', 'campAdmin'].any((role) => AuthService().userRoles.contains(role)))
        ? FloatingActionButton(
            onPressed: _navigateToCreateNotice,
            child: Icon(Icons.add),
            tooltip: 'Add New Notice',
          )
        : null,
    );
  }

  Widget _buildNoticeCard(Notice notice) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: _getUrgencyColor(notice.urgency).withOpacity(0.5),
          width: notice.urgency == NoticeUrgency.critical ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToNoticeDetails(notice),
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: _getUrgencyColor(notice.urgency).withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getNoticeTypeIcon(notice.type),
                    size: 20,
                    color: _getUrgencyColor(notice.urgency),
                  ),
                  SizedBox(width: 8),
                  Text(
                    notice.type.toString().split('.').last,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  if (notice.isOfficial)
                    Tooltip(
                      message: 'Official Source',
                      child: Icon(Icons.verified, size: 20, color: Colors.blue),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    notice.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  if (notice.affectedAreas != null &&
                      notice.affectedAreas!.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children:
                          notice.affectedAreas!
                              .map(
                                (area) => Chip(
                                  label: Text(area),
                                  labelStyle: TextStyle(fontSize: 10),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                    ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        notice.authorName,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                      Spacer(),
                      Text(
                        _formatDate(notice.createdAt),
                        style: TextStyle(fontSize: 12),
                      ),
                      if (notice.attachments != null &&
                          notice.attachments!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.attach_file, size: 14),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    bool isSearchFiltered =
        _searchController.text.isNotEmpty ||
        _selectedTypeFilter != null ||
        _selectedUrgencyFilter != null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchFiltered ? Icons.search_off : Icons.notifications_none,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            isSearchFiltered
                ? 'No notices match your filters'
                : _tabController.index == 0
                ? 'No notices available'
                : 'You haven\'t created any notices yet',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          if (isSearchFiltered)
            ElevatedButton.icon(
              icon: Icon(Icons.clear_all),
              label: Text('Clear Filters'),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedTypeFilter = null;
                  _selectedUrgencyFilter = null;
                  _showExpiredNotices = false;
                  _applyFilters();
                });
              },
            )
          else if (_tabController.index == 1)
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Create Your First Notice'),
              onPressed: _navigateToCreateNotice,
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red),
          SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
            onPressed: _loadNotices,
          ),
          if (!_isOfflineMode)
            TextButton.icon(
              icon: Icon(Icons.cloud_off),
              label: Text('Switch to Offline Mode'),
              onPressed: () {
                setState(() {
                  _isOfflineMode = true;
                });
              },
            ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Filter Notices',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Notice Type:'),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        NoticeType.values.map((type) {
                          return FilterChip(
                            label: Text(type.toString().split('.').last),
                            selected: _selectedTypeFilter == type,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedTypeFilter = selected ? type : null;
                              });
                            },
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 16),
                  Text('Urgency Level:'),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        NoticeUrgency.values.map((urgency) {
                          return FilterChip(
                            label: Text(urgency.toString().split('.').last),
                            selected: _selectedUrgencyFilter == urgency,
                            backgroundColor: _getUrgencyColor(
                              urgency,
                            ).withOpacity(0.2),
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedUrgencyFilter =
                                    selected ? urgency : null;
                              });
                            },
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          child: Text('Apply Filters'),
                          onPressed: () {
                            Navigator.pop(context);
                            _applyFilters();
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      OutlinedButton(
                        child: Text('Reset'),
                        onPressed: () {
                          setModalState(() {
                            _selectedTypeFilter = null;
                            _selectedUrgencyFilter = null;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getUrgencyColor(NoticeUrgency urgency) {
    switch (urgency) {
      case NoticeUrgency.critical:
        return Colors.red;
      case NoticeUrgency.high:
        return Colors.orange;
      case NoticeUrgency.medium:
        return Colors.amber;
      case NoticeUrgency.low:
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getNoticeTypeIcon(NoticeType type) {
    switch (type) {
      case NoticeType.alert:
        return Icons.warning;
      case NoticeType.update:
        return Icons.update;
      case NoticeType.resource:
        return Icons.local_grocery_store;
      case NoticeType.evacuation:
        return Icons.directions_run;
      case NoticeType.general:
        return Icons.info;
      default:
        return Icons.notification_important;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final noticeDate = DateTime(date.year, date.month, date.day);

    if (noticeDate == today) {
      return 'Today, ${DateFormat.jm().format(date)}';
    } else if (noticeDate == yesterday) {
      return 'Yesterday, ${DateFormat.jm().format(date)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }
}
