import 'package:flutter/material.dart';
import 'package:resq/utils/resq_menu.dart';

class VerificationVolunteerDashboard extends StatefulWidget {
  const VerificationVolunteerDashboard({Key? key}) : super(key: key);

  @override
  State<VerificationVolunteerDashboard> createState() => _VerificationVolunteerDashboardState();
}

class _VerificationVolunteerDashboardState extends State<VerificationVolunteerDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedArea;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data
  final List<String> areas = [
    'Area 1', 'Area 2', 'Area 3', 'Area 4', 'Area 5',
    'Region A', 'Region B', 'Region C'
  ];

  List<Map<String, dynamic>> recentVerifications = [
    {
      'houseId': 'H001',
      'area': 'Area 1',
      'familyName': 'Smith',
      'verifiedDate': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'Verified',
      'familyMembers': 4,
      'contactNumber': '555-1234',
      'damageLevel': 'Moderate'
    },
    {
      'houseId': 'H002',
      'area': 'Area 2',
      'familyName': 'Johnson',
      'verifiedDate': DateTime.now().subtract(const Duration(hours: 5)),
      'status': 'Pending Review',
      'familyMembers': 3,
      'contactNumber': '555-5678',
      'damageLevel': 'Severe'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  List<String> get filteredAreas {
    return areas.where((area) {
      final matchesSearch = area.toLowerCase().contains(_searchQuery);
      final matchesFilter = _selectedArea == null || area == _selectedArea;
      return matchesSearch && matchesFilter;
    }).toList();
  }

// Update the _updateVerificationStatus method
void _updateVerificationStatus(int index) {
  setState(() {
    final currentStatus = recentVerifications[index]['status'];
    recentVerifications[index]['status'] = 
        currentStatus == 'Verified' ? 'Pending Review' : 'Verified';
    recentVerifications[index]['verifiedDate'] = DateTime.now();
  });
}


  void _showAreaDetails(String area) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Area Details: $area'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Total Houses', '42'),
                _buildDetailRow('Verified', '35'),
                _buildDetailRow('Pending', '7'),
                _buildDetailRow('Last Verified', _formatDate(DateTime.now().subtract(const Duration(hours: 3)))),
                const Text('Volunteers Assigned:', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildDetailRow('John Doe', 'Primary'),
                _buildDetailRow('Jane Smith', 'Secondary'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showVerificationDetails(Map<String, dynamic> verification) {
  final index = recentVerifications.indexWhere((v) => v['houseId'] == verification['houseId']);
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Verification Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('House ID', verification['houseId']),
              // ... other detail rows ...
            ],
          ),
        ),
        actions: [
          if (verification['status'] == 'Pending Review')
            ElevatedButton(
              child: const Text('Mark as Verified'),
              onPressed: () {
                setState(() {
                  recentVerifications[index]['status'] = 'Verified';
                  recentVerifications[index]['verifiedDate'] = DateTime.now();
                });
                Navigator.of(context).pop();
              },
            ),
          if (verification['status'] == 'Verified')
            ElevatedButton(
              child: const Text('Revert to Pending'),
              onPressed: () {
                setState(() {
                  recentVerifications[index]['status'] = 'Pending Review';
                  recentVerifications[index]['verifiedDate'] = DateTime.now();
                });
                Navigator.of(context).pop();
              },
            ),
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 800
          ? const ResQMenu(roles: ['volunteer'])
          : null,
      appBar: AppBar(
        title: const Text('Verification Dashboard'),
        backgroundColor: Colors.blueGrey[800],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Areas'),
            Tab(text: 'Recent Verifications'),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              if (MediaQuery.of(context).size.width >= 800)
                const ResQMenu(roles: ['volunteer'], showDrawer: false),
              const Divider(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAreasTab(),
                    _buildRecentVerificationsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreasTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search areas...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              DropdownButton<String>(
                value: _selectedArea,
                hint: const Text('Filter by region'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Regions'),
                  ),
                  ...areas.map((String area) {
                    return DropdownMenuItem<String>(
                      value: area,
                      child: Text(area),
                    );
                  }).toList(),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedArea = newValue;
                  });
                },
              ),
            ],
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            itemCount: filteredAreas.length,
            itemBuilder: (context, index) {
              final area = filteredAreas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(area),
                  trailing: ElevatedButton(
                    onPressed: () => _showAreaDetails(area),
                    child: const Text('View Details'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentVerificationsTab() {
    return ListView.builder(
      itemCount: recentVerifications.length,
      itemBuilder: (context, index) {
        final verification = recentVerifications[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(
              verification['status'] == 'Verified' 
                ? Icons.verified 
                : Icons.pending,
              color: verification['status'] == 'Verified'
                ? Colors.green
                : Colors.orange,
            ),
            title: Text('House ID: ${verification['houseId']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Family: ${verification['familyName']}'),
                Text('Area: ${verification['area']}'),
                Text(
                  '${verification['status'] == 'Verified' ? 'Verified' : 'Last Updated'}: ${_formatDate(verification['verifiedDate'])}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Chip(
      label: Text(verification['status']),
      backgroundColor: verification['status'] == 'Verified'
        ? Colors.green[100]
        : Colors.orange[100],
    ),
    IconButton(
      icon: Icon(
        verification['status'] == 'Verified'
          ? Icons.undo
          : Icons.check_circle,
        color: verification['status'] == 'Verified'
          ? Colors.orange
          : Colors.green,
      ),
      onPressed: () => _updateVerificationStatus(index), // Changed to use _updateVerificationStatus
    ),
  ],
),
onTap: () => _showVerificationDetails(verification),
          ),
        );
      },
    );
  }
}