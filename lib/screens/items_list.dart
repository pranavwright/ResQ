import 'package:flutter/material.dart';
import 'package:resq/screens/donation_request_form.dart';
import 'package:resq/screens/donations_screen.dart';

class ItemsList extends StatefulWidget {
  const ItemsList({super.key});

  @override
  _ItemsListState createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _selectedStatus; // Initially null
  String? _selectedLocation; // Initially null

  // Sample data for Churalmala and Assam
  final Map<String, List<Map<String, String>>> _itemsData = {
    'Churalmala': [
      {'item': 'Item 1', 'quantity': '9'},
      {'item': 'Item 2', 'quantity': '5'},
      {'item': 'Item 3', 'quantity': '8'},
      {'item': 'Item 4', 'quantity': '7'},
    ],
    'Assam': [
      {'item': 'Item A', 'quantity': '12'},
      {'item': 'Item B', 'quantity': '15'},
      {'item': 'Item C', 'quantity': '20'},
      {'item': 'Item D', 'quantity': '25'},
    ],
  };

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
        backgroundColor: Colors.green.shade300, // Light green color for the AppBar
        title: const Text(
          "Items List",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28), // Adjusted size
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
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.yellow.withOpacity(0.2), // Yellow background for the search field
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
                'Select Location:',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              DropdownButton<String>(
                value: _selectedLocation,
                hint: const Text("Select Location"),
                isExpanded: true, // Makes the dropdown fill the available width
                style: TextStyle(color: Colors.black, fontSize: 18), // Increased font size
                items: const [
                  DropdownMenuItem<String>(
                    value: "Churalmala",
                    child: Text("Churalmala"),
                  ),
                  DropdownMenuItem<String>(
                    value: "Assam",
                    child: Text("Assam"),
                  ),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLocation = newValue;
                  });
                },
                icon: const Icon(
                  Icons.arrow_drop_down,
                  size: 28, // Adjusted icon size
                  color: Colors.green, // Green color for dropdown icon
                ),
                iconSize: 28,
                elevation: 16, // Dropdown elevation for better UI
                dropdownColor: Colors.white, // Dropdown background color
              ),
              if (_selectedLocation != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Items List in the Camp',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      hint: const Text("Select Status"),
                      style: TextStyle(color: Colors.black),
                      items: const [
                        DropdownMenuItem<String>(value: "All", child: Text("All")),
                        DropdownMenuItem<String>(value: "Not Necessary", child: Text("Not Necessary")),
                        DropdownMenuItem<String>(value: "Needed", child: Text("Needed")),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStatus = newValue;
                        });
                      },
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        size: 28, // Adjusted icon size
                        color: Colors.green, // Green color for dropdown icon
                      ),
                      iconSize: 28,
                      elevation: 16, // Dropdown elevation for better UI
                      dropdownColor: Colors.white, // Dropdown background color
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Table(
                  border: TableBorder.all(
                    color: Colors.black,
                    width: 1.5,
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(
                        color: Colors.green, // Green background for the header row
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Not Necessary/Needed', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                    ...(_itemsData[_selectedLocation] ?? [])
                        .where((item) {
                          bool matchesSearch = item['item']!.toLowerCase().contains(_searchQuery);
                          int quantity = int.tryParse(item['quantity']!) ?? 0;
                          String status = quantity < 10 ? 'Needed' : 'Not Necessary';
                          bool matchesStatus = _selectedStatus == null ||
                              _selectedStatus == "All" ||
                              (_selectedStatus == "Not Necessary" && status == "Not Necessary") ||
                              (_selectedStatus == "Needed" && status == "Needed");
                          return matchesSearch && matchesStatus;
                        })
                        .map((item) {
                          int quantity = int.tryParse(item['quantity']!) ?? 0;
                          String status = quantity < 10 ? 'Needed' : 'Not Necessary';
                          String priority = getPriority(quantity);

                          return TableRow(
                            decoration: BoxDecoration(
                              color: (quantity < 10) ? Colors.green.shade100 : Colors.yellow.shade100, // Light green or yellow for rows
                            ),
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
                const SizedBox(height: 20),
                // Navigation Button to go to second screen
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DonationsScreen()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green.shade400), // Green color for button
                  ),
                  child: const Text('Special Donations'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DonationRequestForm()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green.shade400), // Green color for button
                  ),
                  child: const Text('Donations'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
