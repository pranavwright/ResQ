import 'package:flutter/material.dart';

class FamiliesScreen extends StatefulWidget {
  const FamiliesScreen({super.key});

  @override
  _FamiliesScreenState createState() => _FamiliesScreenState();
}

class _FamiliesScreenState extends State<FamiliesScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> families = [
    {'Family ID': '1', 'House Name': 'Family House 1', 'Location': 'New York', 'Status': 'Active', 'Age Category': 'Adult'},
    {'Family ID': '2', 'House Name': 'Family House 2', 'Location': 'Los Angeles', 'Status': 'Inactive', 'Age Category': 'Senior'},
    {'Family ID': '3', 'House Name': 'Family House 3', 'Location': 'Chicago', 'Status': 'Active', 'Age Category': 'Adult'},
  ];

  List<Map<String, String>> filteredFamilies = [];
  String selectedAgeCategory = '';  // Store selected age category for filtering

  @override
  void initState() {
    super.initState();
    filteredFamilies = families;
    searchController.addListener(_filterFamilies);
  }

  void _filterFamilies() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredFamilies = families
          .where((family) {
            // Filter based on the search query and the selected age category
            bool matchesQuery = family['House Name']!.toLowerCase().contains(query) ||
                family['Location']!.toLowerCase().contains(query);
            bool matchesAgeCategory = selectedAgeCategory.isEmpty || family['Age Category'] == selectedAgeCategory;
            return matchesQuery && matchesAgeCategory;
          })
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Show filter dialog to select the age category
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter by Age Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedAgeCategory.isEmpty ? null : selectedAgeCategory,
                hint: Text('Select Age Category'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAgeCategory = newValue ?? '';
                    filteredFamilies = families;
                    _filterFamilies();  // Apply filtering after selection
                  });
                  Navigator.pop(context);  // Close the dialog
                },
                items: <String>['', 'Adult', 'Senior'] // Define the available categories
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Families'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,  // Show the filter dialog
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // Set the background color to white
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar with modern styling
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search by House Name or Location',
                prefixIcon: Icon(Icons.search, color: Colors.deepPurpleAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.deepPurpleAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
                ),
              ),
            ),
            SizedBox(height: 20), // Space between search bar and table
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 5, // Add shadow to the card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Table(
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    columnWidths: {
                      0: FixedColumnWidth(100),
                      1: FixedColumnWidth(150),
                      2: FixedColumnWidth(150),
                      3: FixedColumnWidth(100),
                    },
                    children: [
                      // Table Header
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        children: [
                          _buildHeaderCell('Family ID'),
                          _buildHeaderCell('House Name'),
                          _buildHeaderCell('Location'),
                          _buildHeaderCell('Status'),
                        ],
                      ),
                      // Table Content (Filtered Rows)
                      ...filteredFamilies.map((family) {
                        return TableRow(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          children: [
                            _buildTableCell(family['Family ID']!),
                            _buildTableCell(family['House Name']!),
                            _buildTableCell(family['Location']!),
                            _buildTableCell(family['Status']!, isStatus: true),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isStatus = false}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isStatus
                ? (text == 'Active' ? Colors.green : Colors.red)
                : Colors.black,
          ),
        ),
      ),
    );
  }
}
