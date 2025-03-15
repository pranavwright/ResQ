import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:url_launcher/url_launcher.dart';

class CollectionPointDashboard extends StatefulWidget {
  const CollectionPointDashboard({Key? key}) : super(key: key);

  @override
  _CollectionPointDashboardState createState() =>
      _CollectionPointDashboardState();
}

class _CollectionPointDashboardState extends State<CollectionPointDashboard>
    with SingleTickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;

  // Data lists
  List<Map<String, dynamic>> inventory = [];
  List<Map<String, dynamic>> donationRequests = [];
  List<Map<String, dynamic>> campRequests = [];

  // Loading states
  bool isLoadingInventory = true;
  bool isLoadingDonations = true;
  bool isLoadingCampRequests = true;

  // Controllers for editing
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load data for all tabs
    _loadInventory();
    _loadDonationRequests();
    _loadCampRequests();
  }

  // Method to load inventory data
  Future<void> _loadInventory() async {
    setState(() {
      isLoadingInventory = true;
    });

    try {
      // Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        inventory = [
          {
            'id': 'INV001',
            'item': 'Blankets',
            'quantity': 50,
            'room': 'Room A1',
          },
          {
            'id': 'INV002',
            'item': 'Water Bottles (1L)',
            'quantity': 200,
            'room': 'Room B2',
          },
          {
            'id': 'INV003',
            'item': 'First Aid Kits',
            'quantity': 30,
            'room': 'Room C3',
          },
          {
            'id': 'INV004',
            'item': 'Food Packets',
            'quantity': 150,
            'room': 'Room D4',
          },
        ];
        isLoadingInventory = false;
      });
    } catch (e) {
      setState(() {
        isLoadingInventory = false;
      });
      _showErrorSnackBar('Error loading inventory: $e');
    }
  }

  // Method to load donation requests
  Future<void> _loadDonationRequests() async {
    setState(() {
      isLoadingDonations = true;
    });

    try {
      // Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        donationRequests = [
          {
            'id': 'DON001',
            'donor': 'John Doe',
            'contact_info': '+1-555-123-4567',
            'item': 'Blankets',
            'quantity': 50,
            'arriving_date': '16-03-2025',
            'arriving_time': '10:00 AM',
            'status': 'Scheduled',
            'room': 'Room A1',
          },
          {
            'id': 'DON002',
            'donor': 'Community Aid Group',
            'contact_info': 'contact@communityaid.org',
            'item': 'Water Bottles (1L)',
            'quantity': 200,
            'arriving_date': '15-03-2025',
            'arriving_time': '2:00 PM',
            'status': 'Arrived',
            'room': 'Room B2',
          },
          {
            'id': 'DON003',
            'donor': 'Local Hospital',
            'contact_info': '+1-555-789-0123',
            'item': 'First Aid Kits',
            'quantity': 30,
            'arriving_date': '17-03-2025',
            'arriving_time': '11:30 AM',
            'status': 'Scheduled',
            'room': '', // Empty room to test editable condition
          },
        ];
        isLoadingDonations = false;
      });
    } catch (e) {
      setState(() {
        isLoadingDonations = false;
      });
      _showErrorSnackBar('Error loading donation requests: $e');
    }
  }

  // Method to load camp requests
  Future<void> _loadCampRequests() async {
    setState(() {
      isLoadingCampRequests = true;
    });

    try {
      // Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        campRequests = [
          {
            'id': 'CR001',
            'camp': 'Relief Camp Alpha',
            'camp_contact': '+1-555-987-6543',
            'pickup_date': '18-03-2025',
            'pickup_time': '9:00 AM',
            'status': 'Pending',
            'items': [
              {
                'item': 'Blankets',
                'quantity': 20,
                'id': 'INV001',
                'room': 'Room A1',
              },
              {
                'item': 'Water Bottles (1L)',
                'quantity': 50,
                'id': 'INV002',
                'room': 'Room B2',
              },
            ],
          },
          {
            'id': 'CR002',
            'camp': 'Medical Camp Beta',
            'camp_contact': '+1-555-456-7890',
            'pickup_date': '19-03-2025',
            'pickup_time': '11:00 AM',
            'status': 'Scheduled',
            'items': [
              {
                'item': 'First Aid Kits',
                'quantity': 10,
                'id': 'INV003',
                'room': 'Room C3',
              },
              {
                'item': 'Food Packets',
                'quantity': 30,
                'id': 'INV004',
                'room': 'Room D4',
              },
            ],
          },
          {
            'id': 'CR003',
            'camp': 'Shelter Gamma',
            'camp_contact': '+1-555-234-5678',
            'pickup_date': '20-03-2025',
            'pickup_time': '2:30 PM',
            'status': 'Pending',
            'items': [
              {
                'item': 'Blankets',
                'quantity': 15,
                'id': 'INV001',
                'room': 'Room A1',
              },
              {
                'item': 'Food Packets',
                'quantity': 40,
                'id': 'INV004',
                'room': 'Room D4',
              },
            ],
          },
        ];
        isLoadingCampRequests = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCampRequests = false;
      });
      _showErrorSnackBar('Error loading camp requests: $e');
    }
  }

  // Utility method to show error messages
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Method to show inventory item edit dialog - MODIFIED to only allow room editing
  void _showInventoryItemDialog(Map<String, dynamic> item) {
    _roomController.text = item['room'] ?? '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Inventory Item - ${item['id']}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${item['id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Item: ${item['item']}'),
                  const SizedBox(height: 8),
                  Text('Quantity: ${item['quantity']}'),
                  const SizedBox(height: 16),

                  // Room input (only editable field)
                  TextField(
                    controller: _roomController,
                    decoration: const InputDecoration(
                      labelText: 'Storage Room',
                      hintText: 'e.g., Room A1, Room 219',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Update inventory item room only
                  setState(() {
                    final index = inventory.indexWhere(
                      (i) => i['id'] == item['id'],
                    );
                    if (index != -1) {
                      inventory[index]['room'] = _roomController.text;
                    }
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inventory item room updated'),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showDonationRequestDialog(Map<String, dynamic> donation) {
    _roomController.text = donation['room'] ?? '';
    _statusController.text = donation['status'] ?? '';

   showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Donation Details - ${donation['id']}'),
        const SizedBox(height: 4),
        Text(
          '${donation['donor']} | ${donation['contact_info']}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        ),
      ],
    ),
            content: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(
                    label: Text(
                      'ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Item',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Quantity',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                
                  DataColumn(
                    label: Text(
                      'Room',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text(donation['id'].toString())),
                      DataCell(Text(donation['item'])),
                      DataCell(Text(donation['quantity'].toString())),
                      DataCell(
                        TextField(
                          controller: _roomController,
                          decoration: const InputDecoration(
                            hintText: 'Enter room',
                            border: InputBorder.none,
                          ),
                          enabled:
                              donation['room'] == null ||
                              donation['room'].isEmpty,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedDonation = Map<String, dynamic>.from(donation);
                  updatedDonation['room'] = _roomController.text;
                  updatedDonation['status'] = _statusController.text;

                  setState(() {
                    final index = donationRequests.indexWhere(
                      (d) => d['id'] == donation['id'],
                    );
                    if (index != -1) {
                      donationRequests[index] = updatedDonation;
                    }
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Donation details updated')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
bool isEmail(String contact) {
  return contact.contains('@') && contact.contains('.');
}

void _handleContactPress(String contact) {
  if (isEmail(contact)) {
    // Launch email
    launchUrl(Uri.parse('mailto:$contact'));
  } else {
    // Launch phone call
    launchUrl(Uri.parse('tel:$contact'));
  }
}
  // Method to show camp request details dialog
  void _showCampRequestDialog(Map<String, dynamic> campRequest) {
    _dateController.text = campRequest['pickup_date'] ?? '';
    _timeController.text = campRequest['pickup_time'] ?? '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(campRequest['camp']),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact: ${campRequest['camp_contact']}'),
                  const SizedBox(height: 16),

                  // Editable pickup date with date picker
                  TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Pickup Date',
                      hintText: 'DD-MM-YYYY',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true, // Make the text field read-only
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());

                      // Show date picker
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );

                      if (picked != null) {
                        // Format date as DD-MM-YYYY
                        final day = picked.day.toString().padLeft(2, '0');
                        final month = picked.month.toString().padLeft(2, '0');
                        final year = picked.year.toString();
                        _dateController.text = '$day-$month-$year';
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Editable pickup time with time picker
                  TextField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Pickup Time',
                      hintText: 'HH:MM AM/PM',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    readOnly: true, // Make the text field read-only
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());

                      // Show time picker
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (picked != null) {
                        // Format time in 12-hour format with AM/PM
                        final hour =
                            picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
                        final minute = picked.minute.toString().padLeft(2, '0');
                        final period =
                            picked.period == DayPeriod.am ? 'AM' : 'PM';
                        _timeController.text = '$hour:$minute $period';
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Status dropdown
                  DropdownButtonFormField<String>(
                    value: campRequest['status'],
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ['Pending', 'Scheduled', 'Completed', 'Canceled'].map((
                          status,
                        ) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          campRequest['status'] = value;
                        });
                      }
                    },
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Requested Items:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // List of items with editable quantities but non-editable rooms
                  ...List.generate(campRequest['items'].length, (index) {
                    final item = campRequest['items'][index];
                    final itemController = TextEditingController(
                      text: item['quantity'].toString(),
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Item: ${item['item']}'),
                          const SizedBox(height: 4),
                          Text('ID: ${item['id']}'),
                          const SizedBox(height: 4),
                          // Display room as text, not editable
                          Text(
                            'Room: ${item['room']}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Quantity: '),
                              Expanded(
                                child: TextField(
                                  controller: itemController,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    // Update quantity in the data model
                                    setState(() {
                                      campRequest['items'][index]['quantity'] =
                                          int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save the updated values
                  setState(() {
                    final index = campRequests.indexWhere(
                      (c) => c['id'] == campRequest['id'],
                    );
                    if (index != -1) {
                      // Update pickup date and time
                      campRequests[index]['pickup_date'] = _dateController.text;
                      campRequests[index]['pickup_time'] = _timeController.text;
                      // The status and item details are already updated through the state changes
                    }
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camp request updated')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  // Tab 1: Inventory
  Widget _buildInventoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Current Inventory',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    onPressed: _loadInventory,
                  ),
                ],
              ),
            ),
            const Divider(),
            if (isLoadingInventory)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (inventory.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No inventory found'),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Item')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Room')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows:
                      inventory.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(Text(item['id'])),
                            DataCell(Text(item['item'])),
                            DataCell(Text(item['quantity'].toString())),
                            DataCell(Text(item['room'])),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showInventoryItemDialog(item),
                                tooltip: 'Edit Room',
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Tab 2: Donation Requests
  Widget _buildDonationRequestsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Donation Requests',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    onPressed: _loadDonationRequests,
                  ),
                ],
              ),
            ),
            const Divider(),
            if (isLoadingDonations)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (donationRequests.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No donation requests found'),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Donor')),
                    DataColumn(label: Text('Contact Info')),
                    // DataColumn(label: Text('Item')),
                    // DataColumn(label: Text('Room')),
                    DataColumn(label: Text('Arriving Date/Time')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows:
                      donationRequests.map((donation) {
                        return DataRow(
                          onSelectChanged:
                              (_) => _showDonationRequestDialog(donation),
                          cells: [
                            DataCell(Text(donation['id'])),
                            DataCell(Text(donation['donor'])),
                            DataCell(
  InkWell(
    onTap: () => _handleContactPress(donation['contact_info']),
    child: Text(
      donation['contact_info'],
      style: TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
    ),
  ),
),
                            // DataCell(Text(donation['item'])),
                            // DataCell(
                            //   donation['room'] != null &&
                            //           donation['room'].isNotEmpty
                            //       ? Text(donation['room'])
                            //       : const Text(
                            //         'Not assigned',
                            //         style: TextStyle(color: Colors.red),
                            //       ),
                            // ),
                            DataCell(
                              Text(
                                '${donation['arriving_date']}\n${donation['arriving_time']}',
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(donation['status']),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  donation['status'],
                                  style: TextStyle(
                                    color: _getStatusTextColor(
                                      donation['status'],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Arrived':
        return Colors.green.shade100;
      case 'Dispatched':
        return Colors.blue.shade100;
      default:
        return Colors.orange.shade100;
    }
  }

  // Helper method to get status text color
  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Arrived':
        return Colors.green.shade800;
      case 'Dispatched':
        return Colors.blue.shade800;
      default:
        return Colors.orange.shade800;
    }
  }

  // Tab 3: Camp Requests
  Widget _buildCampRequestsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Camp Requests',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    onPressed: _loadCampRequests,
                  ),
                ],
              ),
            ),
            const Divider(),
            if (isLoadingCampRequests)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (campRequests.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No camp requests found'),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Camp')),
                    DataColumn(label: Text('Pickup Date/Time')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Items')),
                  ],
                  rows:
                      campRequests.map((request) {
                        return DataRow(
                          onSelectChanged:
                              (_) => _showCampRequestDialog(request),
                          cells: [
                            DataCell(Text(request['id'])),
                            DataCell(Text(request['camp'])),
                            DataCell(
                              Text(
                                '${request['pickup_date']}\n${request['pickup_time']}',
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      request['status'] == 'Scheduled'
                                          ? Colors.green.shade100
                                          : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  request['status'],
                                  style: TextStyle(
                                    color:
                                        request['status'] == 'Scheduled'
                                            ? Colors.green.shade800
                                            : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text('${request['items'].length} items')),
                          ],
                        );
                      }).toList(),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Point Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Inventory'),
            Tab(text: 'Donation Requests'),
            Tab(text: 'Camp Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Inventory
          SingleChildScrollView(child: _buildInventoryTab()),

          // Tab 2: Donation Requests
          SingleChildScrollView(child: _buildDonationRequestsTab()),

          // Tab 3: Camp Requests
          SingleChildScrollView(child: _buildCampRequestsTab()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _roomController.dispose();
    _quantityController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _statusController.dispose();
    super.dispose();
  }
}
