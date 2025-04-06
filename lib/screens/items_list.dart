import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resq/utils/http/token_less_http.dart';
import 'dart:async';

class ItemsList extends StatefulWidget {
  final String? disasterId;
  const ItemsList({super.key, this.disasterId});

  @override
  _ItemsListState createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _selectedStatus;
  String? _selectedDisasterId;
  List<Map<String, dynamic>> _disasters = [];
  bool _loading = true;
  bool _loadingDetails = false;
  bool _loadingAnalysis = false;
  String? _error;
  List<Map<String, dynamic>> _itemsList = [];
  
  // Disaster details
  String _disasterName = "Loading...";
  String _disasterDescription = "";
  String _disasterLocation = "";
  String _disasterState = "";
  String _disasterDistrict = "";
  String _disasterType = "";
  String _disasterSeverity = "";
  String _disasterStatus = "";
  DateTime? _startDate;
  DateTime? _endDate;
  int _campsCount = 0;
  int _collectionPointsCount = 0;
  int _aliveCount = 0;
  int _deadCount = 0;
  int _missingCount = 0;
  
  // Resource analysis data
  List<String> _movingResources = [];
  List<String> _lessMovingResources = [];
  List<String> _wastageResources = [];
  String _resourceSummary = "";

  @override
  void initState() {
    super.initState();
    if (widget.disasterId != null && widget.disasterId!.isNotEmpty) {
      _selectedDisasterId = widget.disasterId;
      _fetchInitialData();
    } else {
      _fetchDisasters();
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _loadingDetails = true;
      _loadingAnalysis = true;
    });
    try {
      await Future.wait([
        _fetchDisasterDetails(),
        _fetchResourceAnalysis(),
      ]);
    } catch (e) {
      setState(() => _error = 'Failed to load data. Showing sample data.');
      _loadMockData();
    } finally {
      setState(() {
        _loadingDetails = false;
        _loadingAnalysis = false;
      });
    }
  }

  Future<void> _fetchDisasters() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await TokenLessHttp().get('/disaster/getDisasters')
          .timeout(const Duration(seconds: 10));
      
      if (response is Map && response['_id'] != null) {
        // Single disaster response
        setState(() => _disasters = [Map<String, dynamic>.from(response)]);
      } else if (response is List) {
        // List of disasters
        setState(() => _disasters = List<Map<String, dynamic>>.from(response));
      } else if (response is Map && response['list'] is List) {
        // Response with 'list' field
        setState(() => _disasters = List<Map<String, dynamic>>.from(response['list']));
      } else {
        throw Exception('Invalid response format');
      }
    } on TimeoutException {
      setState(() => _error = 'Request timed out. Please check your connection');
    } catch (e) {
      setState(() {
        _error = 'Error loading disasters. Showing sample data.';
        _loadMockDisasters();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchDisasterDetails() async {
    if (_selectedDisasterId == null) return;
    
    try {
      final response = await TokenLessHttp().get(
        '/disaster/getDisasterData?disasterId=$_selectedDisasterId'
      ).timeout(const Duration(seconds: 10));
      
      if (response is Map) {
        setState(() {
          _disasterName = response['name'] ?? 'Unnamed Disaster';
          _disasterDescription = response['description'] ?? '';
          _disasterLocation = response['location'] ?? '';
          _disasterState = response['state'] ?? '';
          _disasterDistrict = response['district'] ?? '';
          _disasterType = response['type'] ?? '';
          _disasterSeverity = response['severity'] ?? '';
          _disasterStatus = response['status'] ?? '';
          _startDate = tryParseDate(response['startDate']);
          _endDate = tryParseDate(response['endDate']);
          _campsCount = response['campsCount'] ?? 0;
          _collectionPointsCount = response['collectionPointsCount'] ?? 0;
          _aliveCount = response['alive'] ?? 0;
          _deadCount = response['dead'] ?? 0;
          _missingCount = response['missing'] ?? 0;
          
          _itemsList = (response['items'] is List) 
            ? List<Map<String, dynamic>>.from(response['items'])
            : [];
        });
      }
    } catch (e) {
      print('Error fetching disaster details: $e');
      _loadMockDisasterDetails();
    }
  }

  Future<void> _fetchResourceAnalysis() async {
    if (_selectedDisasterId == null) return;
    
    try {
      final response = await TokenLessHttp().get(
        '/ai/analyze-resources?disasterId=$_selectedDisasterId'
      ).timeout(const Duration(seconds: 10));
      
      if (response is Map && response['data'] is Map) {
        final data = response['data'] as Map<String, dynamic>;
        setState(() {
          _movingResources = List<String>.from(data['moving'] ?? []);
          _lessMovingResources = List<String>.from(data['lessMoving'] ?? []);
          _wastageResources = List<String>.from(data['wastage'] ?? []);
          _resourceSummary = data['summary'] ?? 'No analysis available';
        });
      }
    } catch (e) {
      print('Error fetching resource analysis: $e');
      _loadMockResourceData();
    }
  }

  DateTime? tryParseDate(dynamic date) {
    if (date == null) return null;
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  // Mock data loaders
  void _loadMockData() {
    _loadMockDisasters();
    if (_selectedDisasterId != null) {
      _loadMockDisasterDetails();
      _loadMockResourceData();
    }
  }

  void _loadMockDisasters() {
    setState(() {
      _disasters = [
        {
          '_id': '1',
          'name': 'Sample Flood Disaster',
          'description': 'Coastal flooding emergency response',
          'location': 'Mumbai',
          'state': 'Maharashtra',
          'district': 'Mumbai Suburban',
          'type': 'Flood',
          'severity': 'High',
          'status': 'Active',
          'startDate': DateTime.now().subtract(const Duration(days: 3)).toString(),
          'items': []
        },
        {
          '_id': '2', 
          'name': 'Earthquake Relief',
          'description': 'Northern region earthquake response',
          'location': 'Uttarakhand',
          'state': 'Uttarakhand',
          'district': 'Rudraprayag',
          'type': 'Earthquake',
          'severity': 'Critical',
          'status': 'Active',
          'startDate': DateTime.now().subtract(const Duration(days: 1)).toString(),
          'items': []
        }
      ];
    });
  }

  void _loadMockDisasterDetails() {
    setState(() {
      _disasterName = "Sample Flood Disaster";
      _disasterDescription = "Severe flooding affecting coastal regions";
      _disasterLocation = "Mumbai";
      _disasterState = "Maharashtra";
      _disasterDistrict = "Mumbai Suburban";
      _disasterType = "Flood";
      _disasterSeverity = "High";
      _disasterStatus = "Active";
      _startDate = DateTime.now().subtract(const Duration(days: 3));
      _endDate = null;
      _campsCount = 5;
      _collectionPointsCount = 8;
      _aliveCount = 1200;
      _deadCount = 12;
      _missingCount = 5;
      _itemsList = [
        {
          '_id': '1',
          'name': 'Water Bottles', 
          'description': '1L mineral water bottles',
          'category': 'Drinking Water',
          'unit': 'liters',
          'quantity': '15',
          'disasterId': _selectedDisasterId,
          'room': 'Storage A'
        },
        {
          '_id': '2',
          'name': 'Blankets', 
          'description': 'Woolen blankets',
          'category': 'Shelter',
          'unit': 'pieces',
          'quantity': '45',
          'disasterId': _selectedDisasterId,
          'room': 'Storage B'
        },
      ];
    });
  }

  void _loadMockResourceData() {
    setState(() {
      _movingResources = ['Water', 'Medicines', 'Ready-to-eat meals'];
      _lessMovingResources = ['Blankets', 'Clothes', 'Tents'];
      _wastageResources = ['Expired medicines', 'Damaged goods'];
      _resourceSummary = 'Water demand remains high while shelter items are sufficiently stocked.';
    });
  }

  String getPriority(int quantity) {
    if (quantity < 10) return 'High';
    if (quantity <= 50) return 'Medium';
    return 'Low';
  }

  Widget _buildDisasterInfoCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _disasterName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_disasterDescription),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Chip(label: Text('Location: $_disasterLocation')),
                Chip(label: Text('State: $_disasterState')),
                Chip(label: Text('District: $_disasterDistrict')),
                Chip(label: Text('Type: $_disasterType')),
                Chip(label: Text('Severity: $_disasterSeverity')),
                Chip(label: Text('Status: $_disasterStatus')),
              ],
            ),
            if (_startDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Started: ${DateFormat('MMM dd, yyyy').format(_startDate!)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            if (_endDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Ended: ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceAnalysisCard() {
    if (_loadingAnalysis) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resource Movement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            if (_movingResources.isNotEmpty) ...[
              _buildResourceSection('Urgently Needed', _movingResources, Colors.red.shade700),
              const SizedBox(height: 8),
            ],
            
            if (_lessMovingResources.isNotEmpty) ...[
              _buildResourceSection('Adequate Stock', _lessMovingResources, Colors.orange.shade700),
              const SizedBox(height: 8),
            ],
            
            if (_wastageResources.isNotEmpty) ...[
              _buildResourceSection('Potential Wastage', _wastageResources, Colors.amber.shade700),
              const SizedBox(height: 8),
            ],
            
            if (_resourceSummary.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text('Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_resourceSummary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResourceSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: items.map((item) => Chip(
            label: Text(item),
            backgroundColor: color.withOpacity(0.2),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Impact Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Camps', _campsCount),
                  const VerticalDivider(),
                  _buildStatItem('Collection Points', _collectionPointsCount),
                  const VerticalDivider(),
                  _buildStatItem('Alive', _aliveCount),
                  const VerticalDivider(),
                  _buildStatItem('Dead', _deadCount),
                  const VerticalDivider(),
                  _buildStatItem('Missing', _missingCount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _disasters.isEmpty && _itemsList.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading disaster data...'),
            ],
          ),
        ),
      );
    }

    if (_error != null && _disasters.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_selectedDisasterId != null) {
                    _fetchInitialData();
                  } else {
                    _fetchDisasters();
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Management'),
        actions: [_buildSearchField()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchInitialData,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDisasterDropdown(),
              if (_selectedDisasterId != null) ...[
                if (_loadingDetails)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  _buildDisasterInfoCard(),
                  _buildStatsCard(),
                  _buildResourceAnalysisCard(),
                  _buildItemsTableSection(),
                ],
              ] else if (_disasters.isEmpty) ...[
                const Center(child: Text('No disasters available')),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: 200,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search items...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onChanged: (query) => setState(() => _searchQuery = query.toLowerCase()),
        ),
      ),
    );
  }

  Widget _buildDisasterDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Disaster:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDisasterId,
          items: _disasters.map((disaster) => DropdownMenuItem<String>(
            value: disaster['_id']?.toString() ?? '',
            child: Text(disaster['name']?.toString() ?? 'Unknown'),
          )).toList(),
          onChanged: (value) => setState(() {
            _selectedDisasterId = value;
            if (value != null) _fetchInitialData();
          }),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildItemsTableSection() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Inventory Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildStatusFilter(),
          ],
        ),
        const SizedBox(height: 12),
        if (_itemsList.isEmpty)
          const Center(child: Text('No items found')),
        if (_itemsList.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Item')),
                DataColumn(label: Text('Qty'), numeric: true),
                DataColumn(label: Text('Unit')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Priority')),
              ],
              rows: _filteredItems.map((item) {
                final quantity = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
                final status = quantity < 10 ? 'Needed' : 'Sufficient';
                return DataRow(
                  cells: [
                    DataCell(Text(item['name']?.toString() ?? 'Unknown')),
                    DataCell(Text(quantity.toString())),
                    DataCell(Text(item['unit']?.toString() ?? '')),
                    DataCell(
                      Text(status),
                      onTap: () => _showItemDetails(item),
                    ),
                    DataCell(Text(getPriority(quantity))),
                  ],
                );
              }).toList(),
            ),
          ),
        _buildActionButtons(),
      ],
    );
  }

  List<Map<String, dynamic>> get _filteredItems {
    return _itemsList.where((item) {
      final name = item['name']?.toString().toLowerCase() ?? '';
      final matchesSearch = name.contains(_searchQuery);
      final quantity = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      final status = quantity < 10 ? 'Needed' : 'Sufficient';
      final matchesStatus = _selectedStatus == null || _selectedStatus == 'All' || _selectedStatus == status;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Widget _buildStatusFilter() {
    return DropdownButton<String>(
      value: _selectedStatus,
      hint: const Text('Filter'),
      items: const [
        DropdownMenuItem(value: 'All', child: Text('All Items')),
        DropdownMenuItem(value: 'Needed', child: Text('Needed')),
        DropdownMenuItem(value: 'Sufficient', child: Text('Sufficient')),
      ],
      onChanged: (value) => setState(() => _selectedStatus = value),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton('Special Donations', Icons.star, () {
            Navigator.pushNamed(context, '/donations');
          }),
          _buildActionButton('Donate', Icons.volunteer_activism, () {
            if (_selectedDisasterId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a disaster first')),
              );
            } else {
              Navigator.pushNamed(
                context,
                '/public-donation',
                arguments: {'disasterId': _selectedDisasterId},
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onPressed,
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['name']?.toString() ?? 'Item Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Description', item['description']),
              _buildDetailRow('Category', item['category']),
              _buildDetailRow('Quantity', '${item['quantity']} ${item['unit']}'),
              _buildDetailRow('Storage Location', item['room']),
              if (item['disasterId'] != null)
                _buildDetailRow('Disaster ID', item['disasterId']),
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

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value ?? 'Not specified'),
          ],
        ),
      ),
    );
  }
}