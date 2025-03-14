import 'package:flutter/material.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({Key? key}) : super(key: key);

  @override
  _VolunteerScreenState createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Sample data
  List<Map<String, dynamic>> rooms = [
    {'id': 1, 'name': 'Storage Room A', 'capacity': '100 sq ft', 'items': 24},
    {'id': 2, 'name': 'Warehouse B', 'capacity': '500 sq ft', 'items': 156},
    {'id': 3, 'name': 'Office Storage', 'capacity': '50 sq ft', 'items': 38},
  ];
  
  List<Map<String, dynamic>> inventory = [
    {'id': 1, 'name': 'Canned Food', 'quantity': 45, 'roomId': 1},
    {'id': 2, 'name': 'Blankets', 'quantity': 23, 'roomId': 1},
    {'id': 3, 'name': 'Water Bottles', 'quantity': 78, 'roomId': 2},
    {'id': 4, 'name': 'First Aid Kits', 'quantity': 12, 'roomId': 2},
    {'id': 5, 'name': 'Clothing', 'quantity': 34, 'roomId': 3},
    {'id': 6, 'name': 'Hygiene Kits', 'quantity': 18, 'roomId': 3},
  ];
  
  int? selectedRoomFilter;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _showRoomAllocationDialog() {
    final nameController = TextEditingController();
    final capacityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allocate New Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Room Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacity',
                border: OutlineInputBorder(),
                suffixText: 'sq ft',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && capacityController.text.isNotEmpty) {
                setState(() {
                  final newId = rooms.isNotEmpty ? rooms.map((r) => r['id']).reduce((a, b) => a > b ? a : b) + 1 : 1;
                  rooms.add({
                    'id': newId,
                    'name': nameController.text,
                    'capacity': '${capacityController.text} sq ft',
                    'items': 0,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Room allocated successfully')),
                );
              }
            },
            child: const Text('Allocate'),
          ),
        ],
      ),
    );
  }
  
  void _showItemAllocationDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    int? selectedRoom;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Allocate New Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Select Room',
                  border: OutlineInputBorder(),
                ),
                value: selectedRoom,
                items: rooms.map((room) {
                  return DropdownMenuItem<int>(
                    value: room['id'],
                    child: Text(room['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRoom = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && 
                    quantityController.text.isNotEmpty &&
                    selectedRoom != null) {
                  this.setState(() {
                    final newId = inventory.isNotEmpty 
                        ? inventory.map((i) => i['id']).reduce((a, b) => a > b ? a : b) + 1 
                        : 1;
                    
                    inventory.add({
                      'id': newId,
                      'name': nameController.text,
                      'quantity': int.parse(quantityController.text),
                      'roomId': selectedRoom,
                    });
                    
                    // Update room item count
                    for (var room in rooms) {
                      if (room['id'] == selectedRoom) {
                        room['items'] = (room['items'] as int) + 1;
                        break;
                      }
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item allocated successfully')),
                  );
                }
              },
              child: const Text('Allocate'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showTransferItemDialog(Map<String, dynamic> item) {
    int? targetRoomId = item['roomId'];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Transfer ${item['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current location: ${rooms.firstWhere((room) => room['id'] == item['roomId'])['name']}'),
              const SizedBox(height: 16),
              const Text('Select new location:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Target Room',
                  border: OutlineInputBorder(),
                ),
                value: targetRoomId,
                items: rooms.map((room) {
                  return DropdownMenuItem<int>(
                    value: room['id'],
                    child: Text(room['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    targetRoomId = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (targetRoomId != null && targetRoomId != item['roomId']) {
                  this.setState(() {
                    // Update source room item count
                    for (var room in rooms) {
                      if (room['id'] == item['roomId']) {
                        room['items'] = (room['items'] as int) - 1;
                      }
                      if (room['id'] == targetRoomId) {
                        room['items'] = (room['items'] as int) + 1;
                      }
                    }
                    
                    // Update item room
                    item['roomId'] = targetRoomId;
                  });
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item transferred successfully')),
                  );
                } else if (targetRoomId == item['roomId']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item is already in this room')),
                  );
                }
              },
              child: const Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _updateItemQuantity(Map<String, dynamic> item, int change) {
    setState(() {
      final newQuantity = (item['quantity'] as int) + change;
      if (newQuantity >= 0) {
        item['quantity'] = newQuantity;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(change > 0 
              ? '${item['name']} quantity increased to ${item['quantity']}'
              : '${item['name']} quantity decreased to ${item['quantity']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quantity cannot be negative')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Inventory', icon: Icon(Icons.inventory)),
            Tab(text: 'Rooms', icon: Icon(Icons.meeting_room)),
            Tab(text: 'Quick Actions', icon: Icon(Icons.flash_on)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Inventory Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter by room
                Row(
                  children: [
                    const Text('Filter by Room: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: selectedRoomFilter,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All Rooms'),
                          ),
                          ...rooms.map((room) {
                            return DropdownMenuItem<int?>(
                              value: room['id'],
                              child: Text(room['name']),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedRoomFilter = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Inventory list
                Expanded(
                  child: ListView.builder(
                    itemCount: inventory.where((item) => 
                      selectedRoomFilter == null || item['roomId'] == selectedRoomFilter
                    ).length,
                    itemBuilder: (context, index) {
                      final filteredItems = inventory.where((item) => 
                        selectedRoomFilter == null || item['roomId'] == selectedRoomFilter
                      ).toList();
                      final item = filteredItems[index];
                      final roomName = rooms.firstWhere((room) => room['id'] == item['roomId'])['name'];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Quantity: ${item['quantity']}'),
                                    Text('Location: $roomName'),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.swap_horiz),
                                tooltip: 'Transfer Item',
                                onPressed: () => _showTransferItemDialog(item),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    color: Colors.red,
                                    onPressed: () => _updateItemQuantity(item, -1),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Colors.green,
                                    onPressed: () => _updateItemQuantity(item, 1),
                                  ),
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
          ),
          
          // Rooms Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Storage Rooms',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    room['name'],
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${room['items']} items',
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Capacity: ${room['capacity']}'),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.visibility),
                                label: const Text('View Items'),
                                onPressed: () {
                                  setState(() {
                                    selectedRoomFilter = room['id'];
                                    _tabController.animateTo(0); // Switch to inventory tab
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                ),
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
          ),
          
          // Quick Actions Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Frequently Used Items',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: inventory.length,
                    itemBuilder: (context, index) {
                      final item = inventory[index];
                      final roomName = rooms.firstWhere((room) => room['id'] == item['roomId'])['name'];
                      
                      return Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${item['quantity']} | $roomName',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _updateItemQuantity(item, -1),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.all(0),
                                      minimumSize: const Size(40, 36),
                                    ),
                                    child: const Icon(Icons.remove, color: Colors.white),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: () => _updateItemQuantity(item, 1),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.all(0),
                                      minimumSize: const Size(40, 36),
                                    ),
                                    child: const Icon(Icons.add, color: Colors.white),
                                  ),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add New',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue.shade200,
                            child: IconButton(
                              icon: const Icon(Icons.meeting_room, size: 30),
                              color: Colors.blue.shade800,
                              onPressed: () {
                                Navigator.pop(context);
                                _showRoomAllocationDialog();
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Allocate Room'),
                        ],
                      ),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.green.shade200,
                            child: IconButton(
                              icon: const Icon(Icons.inventory_2, size: 30),
                              color: Colors.green.shade800,
                              onPressed: () {
                                Navigator.pop(context);
                                _showItemAllocationDialog();
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Allocate Item'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}