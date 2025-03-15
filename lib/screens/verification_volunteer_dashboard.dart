import 'package:flutter/material.dart';

class VerificationVolunteerDashboard extends StatefulWidget {
  const VerificationVolunteerDashboard({Key? key}) : super(key: key);

  @override
  State<VerificationVolunteerDashboard> createState() => _VerificationVolunteerDashboardState();
}

class _VerificationVolunteerDashboardState extends State<VerificationVolunteerDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedArea;
  final TextEditingController _searchController = TextEditingController();

  // Mock data - Replace with your backend data
  final List<String> areas = [
    'Area 1', 'Area 2', 'Area 3', 'Area 4', 'Area 5',
    'Region A', 'Region B', 'Region C'
  ];

  final List<Map<String, dynamic>> recentVerifications = [
    {
      'houseId': 'H001',
      'area': 'Area 1',
      'familyName': 'Smith',
      'verifiedDate': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'Verified'
    },
    {
      'houseId': 'H002',
      'area': 'Area 2',
      'familyName': 'Johnson',
      'verifiedDate': DateTime.now().subtract(const Duration(hours: 5)),
      'status': 'Pending Review'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Areas'),
            Tab(text: 'Recent Verifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAreasTab(),
          _buildRecentVerificationsTab(),
        ],
      ),
    );
  }

  Widget _buildAreasTab() {
    return Column(
      children: [
        // Search and Filter Section
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
                  onChanged: (value) {
                    setState(() {
                      // Implement search functionality
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedArea,
                hint: const Text('Filter by region'),
                items: areas.map((String area) {
                  return DropdownMenuItem<String>(
                    value: area,
                    child: Text(area),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedArea = newValue;
                  });
                },
              ),
            ],
          ),
        ),
        
        // Areas List
        Expanded(
          child: ListView.builder(
            itemCount: areas.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(areas[index]),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Navigate to area details/verification screen
                    },
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
                  'Verified: ${_formatDate(verification['verifiedDate'])}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Chip(
              label: Text(verification['status']),
              backgroundColor: verification['status'] == 'Verified'
                ? Colors.green[100]
                : Colors.orange[100],
            ),
            onTap: () {
              // Navigate to verification details
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}