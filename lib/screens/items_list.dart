import 'package:flutter/material.dart';

class ItemsList extends StatefulWidget {
  const ItemsList({super.key});

  @override
  _ItemsListState createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedStatus = "All"; // Default option for filtering

  // Sample data
  final List<Map<String, String>> _items = [
    {'item': 'Item 1', 'quantity': '9'},
    {'item': 'Item 2', 'quantity': '5'},
    {'item': 'Item 3', 'quantity': '8'},
    {'item': 'Item 4', 'quantity': '7'},
  ];

  // Determine the priority based on quantity
  String getPriority(int quantity) {
    if (quantity < 10) {
      return 'High'; // Priority High for quantity less than 10
    } else if (quantity <= 50) {
      return 'Medium'; // Priority Medium for quantity between 10 and 50
    } else {
      return 'Low'; // Priority Low for quantity greater than 50
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Items List"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              width: 200,
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search items...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(  // Wrap the body in a SingleChildScrollView to handle overflow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(':items list in the camp'),
                  DropdownButton<String>(
                    value: _selectedStatus,
                    items: const [
                      DropdownMenuItem<String>(
                        value: "All",
                        child: Text("All"),
                      ),
                      DropdownMenuItem<String>(
                        value: "Indispensable",
                        child: Text("Indispensable"),
                      ),
                      DropdownMenuItem<String>(
                        value: "Needed",
                        child: Text("Needed"),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FlexColumnWidth(2), // first column takes 2 parts of the space
                  1: FlexColumnWidth(3), // second column takes 3 parts of the space
                  2: FlexColumnWidth(2), // third column takes 2 parts of the space
                  3: FlexColumnWidth(2), // fourth column takes 2 parts of the space (for priority)
                },
                children: [
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Indispensable/Needed', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  ..._items
                      .where((item) {
                        // Filter based on search query
                        bool matchesSearch = item['item']!.toLowerCase().contains(_searchQuery);

                        // Parse quantity from string to integer
                        int quantity = int.tryParse(item['quantity']!) ?? 0;

                        // Determine item status based on quantity
                        String status = quantity < 10 ? 'Needed' : 'Indispensable';

                        // Filter based on dropdown status (Indispensable or Needed)
                        bool matchesStatus = _selectedStatus == "All" ||
                            (_selectedStatus == "Indispensable" && status == "Indispensable") ||
                            (_selectedStatus == "Needed" && status == "Needed");

                        return matchesSearch && matchesStatus;
                      })
                      .map((item) {
                        // Parse quantity from string to integer
                        int quantity = int.tryParse(item['quantity']!) ?? 0;

                        // Determine item status based on quantity
                        String status = quantity < 10 ? 'Needed' : 'Indispensable';

                        // Determine the priority
                        String priority = getPriority(quantity);

                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(item['item']!),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(item['quantity']!),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(status),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(priority),
                            ),
                          ],
                        );
                      }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
