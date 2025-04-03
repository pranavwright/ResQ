import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resq/utils/http/token_less_http.dart';

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
  String? _error;
  List<Map<String, dynamic>> _itemsList = [];
  
  // New state variables
  String _disasterDescription = "Loading...";
  int _affectedFamilies = 0;
  int _totalMembers = 0;
  DateTime? _lastUpdated;

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
    await _fetchItems();
    await _fetchDisasterDetails();
    await _fetchFamilyData();
  }

  Future<void> _fetchDisasters() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await TokenLessHttp().get('/disaster/getDisasters');
      if (response is List) {
        setState(() {
          _disasters = List<Map<String, dynamic>>.from(response);
        });
      } else {
        throw Exception('Expected list response but got: ${response.runtimeType}');
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching disasters: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

// TEMPORARY MOCK DATA - REMOVE WHEN BACKEND IS READY
Future<void> _fetchDisasterDetails() async {
  // Try real API first
  try {
    final response = await TokenLessHttp().get('/disaster/getDetails?id=$_selectedDisasterId');
    if (response is Map) {
      setState(() {
        _disasterDescription = response['description'] ?? 'No description available';
        _lastUpdated = DateTime.parse(response['updatedAt'] ?? DateTime.now().toString());
      });
      return; // Success - exit early
    }
  } catch (e) {
    print('API Error: $e'); // Log but continue to mock data
  }

  // Fallback to mock data if API fails
  setState(() {
    _disasterDescription = "Severe flooding affecting coastal regions. Immediate need for blankets and food supplies.";
    _lastUpdated = DateTime.now().subtract(const Duration(hours: 2));
  });
}

Future<void> _fetchFamilyData() async {
  // Try real API first
  try {
    final response = await TokenLessHttp().get('/family/getByDisaster?disasterId=$_selectedDisasterId');
    if (response is List) {
      setState(() {
        _affectedFamilies = response.length;
        _totalMembers = response.fold<int>(0, (sum, family) => sum + ((family['memberCount'] ?? 0) as num).toInt());
      });
      return; // Success - exit early
    }
  } catch (e) {
    print('API Error: $e'); // Log but continue to mock data
  }

  // Fallback to mock data
  setState(() {
    _affectedFamilies = 24;
    _totalMembers = 87;
  });
}

  Future<void> _fetchItems() async {
    if (_selectedDisasterId == null) {
      setState(() {
        _itemsList = [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await TokenLessHttp().get('/donation/items?disasterId=$_selectedDisasterId');
      if (response is Map && response.containsKey('list') && response['list'] is List) {
        setState(() {
          _itemsList = List<Map<String, dynamic>>.from(response['list']);
          _lastUpdated = DateTime.now(); // Update timestamp when items are fetched
        });
      } else {
        throw Exception('Expected map with list response but got: ${response.runtimeType}');
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching items: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
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
              _disasters.firstWhere(
                (d) => d['_id'] == _selectedDisasterId,
                orElse: () => {'name': 'Disaster Details'},
              )['name'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _disasterDescription,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (_lastUpdated != null)
              Text(
                'Last updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format(_lastUpdated!)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyDataCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Affected Families',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Families: $_affectedFamilies'),
                Text('Total Members: $_totalMembers'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: const Text(
          "Items List",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              width: 200,
              child: TextField(
                controller: _searchController,
                onChanged: (query) => setState(() => _searchQuery = query.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.yellow.withOpacity(0.2),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Disaster:',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              DropdownButton<String>(
                value: _selectedDisasterId,
                hint: const Text("Select Disaster"),
                isExpanded: true,
                style: const TextStyle(color: Colors.black, fontSize: 18),
                items: _disasters.map((disaster) {
                  return DropdownMenuItem<String>(
                    value: disaster['_id'],
                    child: Text(disaster['name'] ?? ''),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDisasterId = newValue;
                    if (newValue != null) {
                      _fetchInitialData();
                    }
                  });
                },
                icon: const Icon(Icons.arrow_drop_down, size: 28, color: Colors.green),
              ),

              if (_selectedDisasterId != null) ...[
                _buildDisasterInfoCard(),
                _buildFamilyDataCard(),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Items List in the Camp',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      hint: const Text("Filter Status"),
                      items: const [
                        DropdownMenuItem(value: "All", child: Text("All")),
                        DropdownMenuItem(value: "Not Necessary", child: Text("Not Necessary")),
                        DropdownMenuItem(value: "Needed", child: Text("Needed")),
                      ],
                      onChanged: (String? newValue) => setState(() => _selectedStatus = newValue),
                    ),
                  ],
                ),

                if (_itemsList.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _itemsList.where((item) {
                        final name = item['project']?['name']?.toString().toLowerCase() ?? '';
                        final matchesSearch = name.contains(_searchQuery);
                        final quantity = int.tryParse(item['project']?['quantity']?.toString() ?? '0') ?? 0;
                        final status = quantity < 10 ? 'Needed' : 'Not Necessary';
                        final matchesStatus = _selectedStatus == null || 
                                            _selectedStatus == "All" || 
                                            _selectedStatus == status;
                        return matchesSearch && matchesStatus;
                      }).map((item) {
                        final project = item['project'] ?? {};
                        final quantity = int.tryParse(project['quantity']?.toString() ?? '0') ?? 0;
                        final status = quantity < 10 ? 'Needed' : 'Not Necessary';
                        final priority = getPriority(quantity);

                        return DataRow(
                          cells: [
                            DataCell(Text(project['name']?.toString() ?? '')),
                            DataCell(Text(quantity.toString())),
                            DataCell(Text(status)),
                            DataCell(Text(priority)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text('No items found for this disaster.', style: TextStyle(fontSize: 16)),
                  ),
                ],

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/donations'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade400),
                      child: const Text('Special Donations'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedDisasterId != null) {
                          Navigator.pushNamed(
                            context,
                            '/public-donation',
                            arguments: {'disasterId': _selectedDisasterId},
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a disaster first.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade400),
                      child: const Text('Donations'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}