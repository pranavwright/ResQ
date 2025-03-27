import 'package:flutter/material.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({Key? key}) : super(key: key);

  @override
  _VolunteerScreenState createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for editable fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  // Sample data for arriving items
  List<Map<String, dynamic>> arrivingItems = [
    {
      'id': 1,
      'name': 'Vehicle',
      'items': [
        {'item': 'bed', 'room': 3, 'quantity': 2},
        {'item': 'blanket', 'room': 3, 'quantity': 1}
      ],
      'status': 'Pending',
      'expectedArrival': DateTime.now().add(const Duration(hours: 2)),
      'source': 'NGO Relief',
    },
    {
      'id': 4,
      'name': 'vehicle 2',
      'items': [
        {'item': 'bed', 'room': 3, 'quantity': 2},
        {'item': 'blanket', 'room': 3, 'quantity': 1}
      ],
      'status': 'Pending',
      'expectedArrival': DateTime.now().add(const Duration(hours: 4)),
      'source': 'Local Charity',
    },
  ];

  // Sample data for dispatched items
  List<Map<String, dynamic>> dispatchedItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _itemController.dispose();
    _quantityController.dispose();
    _roomController.dispose();
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Point Volunteer'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Arriving Items', icon: Icon(Icons.arrow_downward)),
            Tab(text: 'Dispatched Items', icon: Icon(Icons.arrow_upward)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildArrivingItemsTab(),
          _buildDispatchedItemsTab(),
        ],
      ),
    );
  }

  // Method to build the Arriving Items tab
  Widget _buildArrivingItemsTab() {
    return ListView.builder(
      itemCount: arrivingItems.length,
      itemBuilder: (context, index) {
        final arrival = arrivingItems[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(arrival['name']),
            subtitle: Text('Source: ${arrival['source']}'),
            trailing: Text(arrival['status']),
            onTap: () => _showArrivalDetailsDialog(arrival, index),
          ),
        );
      },
    );
  }

  // Method to build the Dispatched Items tab
  Widget _buildDispatchedItemsTab() {
    return ListView.builder(
      itemCount: dispatchedItems.length,
      itemBuilder: (context, index) {
        final item = dispatchedItems[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(item['item']),
            subtitle: Text('Quantity: ${item['quantity']}, Destination: ${item['destination']}'),
            trailing: Text(item['status']),
          ),
        );
      },
    );
  }

  // Method to show details of an arriving item with its individual items
  void _showArrivalDetailsDialog(Map<String, dynamic> arrival, int arrivalIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Arriving: ${arrival['name']}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_car, size: 20), // Vehicle icon
                  const SizedBox(width: 8),
                  Text('Vehicle: ${arrival['name']}'),
                  const Icon(Icons.arrow_forward, size: 20), // Arrow icon (Vehicle -> Source)
                  const SizedBox(width: 8),
                  Text('Source: ${arrival['source']}'),
                ],
              ),
              const SizedBox(height: 8.0),
              Text('Expected Arrival: ${_formatDateTime(arrival['expectedArrival'])}'),
              const SizedBox(height: 8.0),
              Text('Items:'),
              Column(
                children: arrival['items'].map<Widget>((item) {
                  return ListTile(
                    title: Text('${item['item']}'),
                    subtitle: Text('(Room): ${item['room']}, Quantity: ${item['quantity']}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _dispatchItem(arrivalIndex, item); // Dispatch item individually
                        Navigator.pop(context);
                      },
                      child: const Text('Dispatch'),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to format DateTime
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  // Method to dispatch a single item
  void _dispatchItem(int arrivalIndex, Map<String, dynamic> item) {
    setState(() {
      item['status'] = 'Dispatched'; // Change the status of the item
      item['destination'] = _destinationController.text.isEmpty ? 'Unknown' : _destinationController.text;

      // Move the dispatched item to dispatched items list
      dispatchedItems.add(item);

      // Remove the item from the arriving list
      arrivingItems[arrivalIndex]['items'].remove(item);

      // If no items are left in the arrival, remove the entire arrival entry
      if (arrivingItems[arrivalIndex]['items'].isEmpty) {
        arrivingItems.removeAt(arrivalIndex);
      }
    });

    _showSuccessMessage('Item dispatched successfully');
  }

  // Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
