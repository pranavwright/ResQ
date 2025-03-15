import 'package:flutter/material.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({Key? key}) : super(key: key);

  @override
  _VolunteerScreenState createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  
  // Sample data for arriving items
  List<Map<String, dynamic>> arrivingItems = [
    {
      'id': 1,
      'name': 'Canned Food',
      'quantity': 45,
      'status': 'Pending',
      'expectedArrival': DateTime.now().add(const Duration(hours: 2)),
      'source': 'NGO Relief',
    },
    {
      'id': 2,
      'name': 'Water Bottles',
      'quantity': 100,
      'status': 'In Transit',
      'expectedArrival': DateTime.now().add(const Duration(hours: 1)),
      'source': 'Local Donation',
    },
  ];
  
  // Sample data for dispatched items
  List<Map<String, dynamic>> dispatchedItems = [
    {
      'id': 1,
      'name': 'Blankets',
      'quantity': 30,
      'destination': 'Camp A',
      'dispatchDate': DateTime.now().subtract(const Duration(hours: 5)),
      'status': 'Delivered',
    },
    {
      'id': 2,
      'name': 'First Aid Kits',
      'quantity': 20,
      'destination': 'Camp B',
      'dispatchDate': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'In Transit',
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
    _nameController.dispose();
    _quantityController.dispose();
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
      floatingActionButton: FloatingActionButton(
        onPressed: _tabController.index == 0 ? _showAddArrivingDialog : _showAddDispatchDialog,
        child: const Icon(Icons.add),
        tooltip: _tabController.index == 0 ? 'Add Arriving Item' : 'Add Dispatch',
      ),
    );
  }

  Widget _buildArrivingItemsTab() {
    return ListView.builder(
      itemCount: arrivingItems.length,
      itemBuilder: (context, index) {
        final item = arrivingItems[index];
        return Card(
          child: ListTile(
            title: Text(item['name']),
            subtitle: Text('Quantity: ${item['quantity']}, Source: ${item['source']}'),
            trailing: Text(item['status']),
            onTap: () => _showItemDetailsDialog(item),
          ),
        );
      },
    );
  }

  // Method to show item details dialog
  void _showItemDetailsDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quantity: ${item['quantity']}'),
            if (item.containsKey('source')) Text('Source: ${item['source']}'),
            if (item.containsKey('destination')) Text('Destination: ${item['destination']}'),
            if (item.containsKey('status')) Text('Status: ${item['status']}'),
            if (item.containsKey('expectedArrival'))
              Text('Expected Arrival: ${_formatDateTime(item['expectedArrival'])}'),
            if (item.containsKey('dispatchDate'))
              Text('Dispatch Date: ${_formatDateTime(item['dispatchDate'])}'),
          ],
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

  // Helper method to format DateTime
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  Widget _buildDispatchedItemsTab() {
    return ListView.builder(
      itemCount: dispatchedItems.length,
      itemBuilder: (context, index) {
        final item = dispatchedItems[index];
        return Card(
          child: ListTile(
            title: Text(item['name']),
            subtitle: Text('Quantity: ${item['quantity']}, Destination: ${item['destination']}'),
            trailing: Text(item['status']),
            onTap: () => _showItemDetailsDialog(item),
          ),
        );
      },
    );
  }

  void _showAddArrivingDialog() {
    _nameController.clear();
    _quantityController.clear();
    _sourceController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Arriving Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sourceController,
                decoration: const InputDecoration(
                  labelText: 'Source',
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
              if (_validateArrivingInput()) {
                _addArrivingItem();
                Navigator.pop(context);
                _showSuccessMessage('Item added successfully');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddDispatchDialog() {
    _nameController.clear();
    _quantityController.clear();
    _destinationController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Dispatch'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination',
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
              if (_validateDispatchInput()) {
                _addDispatchItem();
                Navigator.pop(context);
                _showSuccessMessage('Dispatch added successfully');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  bool _validateArrivingInput() {
    if (_nameController.text.isEmpty || 
        _quantityController.text.isEmpty ||
        _sourceController.text.isEmpty) {
      _showErrorMessage('Please fill all fields');
      return false;
    }
    if (int.tryParse(_quantityController.text) == null) {
      _showErrorMessage('Please enter a valid quantity');
      return false;
    }
    return true;
  }

  bool _validateDispatchInput() {
    if (_nameController.text.isEmpty || 
        _quantityController.text.isEmpty ||
        _destinationController.text.isEmpty) {
      _showErrorMessage('Please fill all fields');
      return false;
    }
    if (int.tryParse(_quantityController.text) == null) {
      _showErrorMessage('Please enter a valid quantity');
      return false;
    }
    return true;
  }

  void _addArrivingItem() {
    setState(() {
      arrivingItems.add({
        'id': arrivingItems.length + 1,
        'name': _nameController.text,
        'quantity': int.parse(_quantityController.text),
        'status': 'Pending',
        'expectedArrival': DateTime.now().add(const Duration(hours: 2)),
        'source': _sourceController.text,
      });
    });
  }

  void _addDispatchItem() {
    setState(() {
      dispatchedItems.add({
        'id': dispatchedItems.length + 1,
        'name': _nameController.text,
        'quantity': int.parse(_quantityController.text),
        'status': 'In Transit',
        'dispatchDate': DateTime.now(),
        'destination': _destinationController.text,
      });
    });
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}