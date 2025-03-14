import 'package:flutter/material.dart';
// Import your existing dependencies here

class CollectionPointDashboard extends StatefulWidget {
  const CollectionPointDashboard({Key? key}) : super(key: key);

  @override
  _CollectionPointDashboardState createState() => _CollectionPointDashboardState();
}

class _CollectionPointDashboardState extends State<CollectionPointDashboard> {
  // Add these properties to your existing dashboard state
  List<Map<String, dynamic>> donations = [];
  bool isLoading = true;
  
  // Controllers for editing donation details
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Keep your existing initState code
    
    // Add this to load donations data
    _loadDonations();
  }
  
  // Method to load donations data from your backend
  Future<void> _loadDonations() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Replace this with your actual API call to fetch donations
      // For now, we'll use mock data
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      setState(() {
        donations = [
          {
            'id': 'DON001',
            'camp_id': 'CAMP123',
            'camp_name': 'Relief Camp Alpha',
            'item_name': 'Blankets',
            'requested_quantity': 50,
            'allotted_quantity': 30,
            'room_number': '',
            'pickup_date': '',
            'pickup_time': '',
            'status': 'Pending',
            'donor_name': 'John Doe',
            'donation_date': '10-03-2025',
          },
          {
            'id': 'DON002',
            'camp_id': 'CAMP456',
            'camp_name': 'Shelter Beta',
            'item_name': 'Water Bottles (1L)',
            'requested_quantity': 200,
            'allotted_quantity': 200,
            'room_number': 'Room A1',
            'pickup_date': '15-03-2025',
            'pickup_time': '10:00 AM',
            'status': 'Ready for Pickup',
            'donor_name': 'Community Aid Group',
            'donation_date': '09-03-2025',
          },
          {
            'id': 'DON003',
            'camp_id': 'CAMP789',
            'camp_name': 'Medical Camp',
            'item_name': 'First Aid Kits',
            'requested_quantity': 80,
            'allotted_quantity': 50,
            'room_number': 'Room 219',
            'pickup_date': '14-03-2025',
            'pickup_time': '2:00 PM',
            'status': 'Ready for Pickup',
            'donor_name': 'Local Hospital',
            'donation_date': '11-03-2025',
          },
          {
            'id': 'DON004',
            'camp_id': 'CAMP123',
            'camp_name': 'Relief Camp Alpha',
            'item_name': 'Food Packets',
            'requested_quantity': 300,
            'allotted_quantity': 0,
            'room_number': '',
            'pickup_date': '',
            'pickup_time': '',
            'status': 'Pending',
            'donor_name': 'Food Relief NGO',
            'donation_date': '12-03-2025',
          },
        ];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading donations: $e')),
      );
    }
  }
  
  // Method to update donation details
  Future<void> _updateDonation(Map<String, dynamic> donation) async {
    try {
      // Replace with your actual API call to update the donation
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      // Update local state
      setState(() {
        final index = donations.indexWhere((d) => d['id'] == donation['id']);
        if (index != -1) {
          donations[index] = donation;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating donation: $e')),
      );
    }
  }
  
  // Method to show dialog for assigning room and adjusting quantity
  void _showDonationDetailsDialog(Map<String, dynamic> donation) {
    // Initialize controllers with current values
    _roomController.text = donation['room_number'] ?? '';
    _quantityController.text = donation['allotted_quantity'].toString();
    _dateController.text = donation['pickup_date'] ?? '';
    _timeController.text = donation['pickup_time'] ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Donation - ${donation['id']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display donation information
              Text('Item: ${donation['item_name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Camp: ${donation['camp_name']}'),
              const SizedBox(height: 8),
              Text('Requested Quantity: ${donation['requested_quantity']}'),
              const SizedBox(height: 16),
              
              // Room number input
              TextField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Room Number',
                  hintText: 'e.g., Room A1, Room 219',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Quantity adjustment
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Allotted Quantity',
                  hintText: 'Maximum: ${donation['requested_quantity']}',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Pickup date
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Pickup Date',
                  hintText: 'DD-MM-YYYY',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text = '${pickedDate.day.toString().padLeft(2, '0')}-'
                        '${pickedDate.month.toString().padLeft(2, '0')}-'
                        '${pickedDate.year}';
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Pickup time
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Pickup Time',
                  hintText: 'HH:MM AM/PM',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  
                  if (pickedTime != null) {
                    final hour = pickedTime.hourOfPeriod;
                    final minute = pickedTime.minute;
                    final period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
                    
                    setState(() {
                      _timeController.text = '${hour == 0 ? 12 : hour}:${minute.toString().padLeft(2, '0')} $period';
                    });
                  }
                },
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
              // Update donation details
              final updatedDonation = Map<String, dynamic>.from(donation);
              updatedDonation['room_number'] = _roomController.text;
              updatedDonation['allotted_quantity'] = int.tryParse(_quantityController.text) ?? 0;
              updatedDonation['pickup_date'] = _dateController.text;
              updatedDonation['pickup_time'] = _timeController.text;
              
              // Update status if all required fields are filled
              if (_roomController.text.isNotEmpty && 
                  _dateController.text.isNotEmpty && 
                  _timeController.text.isNotEmpty &&
                  updatedDonation['allotted_quantity'] > 0) {
                updatedDonation['status'] = 'Ready for Pickup';
              } else {
                updatedDonation['status'] = 'Pending';
              }
              
              _updateDonation(updatedDonation);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  // Add this widget to your existing build method where appropriate
  Widget _buildDonationsManagementSection() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Donations Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Manage donation storage and pickup schedules',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  onPressed: _loadDonations,
                ),
              ],
            ),
          ),
          const Divider(),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (donations.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No donations found'),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Item')),
                  DataColumn(label: Text('Camp')),
                  DataColumn(label: Text('Requested')),
                  DataColumn(label: Text('Allotted')),
                  DataColumn(label: Text('Room')),
                  DataColumn(label: Text('Pickup Date/Time')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: donations.map((donation) {
                  return DataRow(
                    cells: [
                      DataCell(Text(donation['id'])),
                      DataCell(Text(donation['item_name'])),
                      DataCell(Text(donation['camp_name'])),
                      DataCell(Text(donation['requested_quantity'].toString())),
                      DataCell(Text(donation['allotted_quantity'].toString())),
                      DataCell(
                        donation['room_number'].isEmpty
                        ? const Text('Not Assigned', style: TextStyle(color: Colors.red))
                        : Text(donation['room_number'])
                      ),
                      DataCell(
                        donation['pickup_date'].isEmpty
                        ? const Text('Not Scheduled', style: TextStyle(color: Colors.red))
                        : Text('${donation['pickup_date']}\n${donation['pickup_time']}')
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: donation['status'] == 'Ready for Pickup' ? Colors.green.shade100 : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            donation['status'],
                            style: TextStyle(
                              color: donation['status'] == 'Ready for Pickup' ? Colors.green.shade800 : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Manage Donation',
                              onPressed: () => _showDonationDetailsDialog(donation),
                            ),
                          ],
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
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Point Dashboard'),
        // Your existing AppBar code
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Keep your existing dashboard widgets here
            
            // Add the donations management section
            _buildDonationsManagementSection(),
            
            // Any other existing sections
          ],
        ),
      ),
      // Keep your existing bottom navigation or drawer if present
    );
  }
  
  @override
  void dispose() {
    _roomController.dispose();
    _quantityController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}