import 'package:flutter/material.dart';
import 'package:resq/screens/family_data_download.dart'; 
// Import the new screen
import 'package:resq/screens/family_mock_data.dart';

class FamiliesScreen extends StatefulWidget {
  const FamiliesScreen({super.key});

  @override
  _FamiliesScreenState createState() => _FamiliesScreenState();
}

class _FamiliesScreenState extends State<FamiliesScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> families = [
    {
      'Family ID': '1',
      'House Name': 'Family House 1',
      'Location': 'New York',
      'Status': 'Active',
      'Age Category': 'Adult',
    },
    {
      'Family ID': '2',
      'House Name': 'Family House 2',
      'Location': 'Los Angeles',
      'Status': 'Inactive',
      'Age Category': 'Senior',
    },
    {
      'Family ID': '3',
      'House Name': 'Family House 3',
      'Location': 'Chicago',
      'Status': 'Active',
      'Age Category': 'Adult',
    },
  ];

  List<Map<String, String>> filteredFamilies = [];
  String selectedAgeCategory = '';

  @override
  void initState() {
    super.initState();
    filteredFamilies = families;
    searchController.addListener(_filterFamilies);
  }

  void _filterFamilies() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredFamilies =
          families.where((family) {
            bool matchesQuery =
                family['House Name']!.toLowerCase().contains(query) ||
                family['Location']!.toLowerCase().contains(query);
            bool matchesAgeCategory =
                selectedAgeCategory.isEmpty ||
                family['Age Category'] == selectedAgeCategory;
            return matchesQuery && matchesAgeCategory;
          }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _navigateToDownloadScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FamilyDataDownloadScreen(families: families)),
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
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _navigateToDownloadScreen, // Navigate to download page
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
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
                  borderSide: BorderSide(
                    color: Colors.deepPurpleAccent,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                elevation: 5,
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
                    TableRow(
                      decoration: BoxDecoration(color: Colors.deepPurpleAccent),
                      children: [
                        _buildHeaderCell('Family ID'),
                        _buildHeaderCell('House Name'),
                        _buildHeaderCell('Location'),
                        _buildHeaderCell('Status'),
                      ],
                    ),
                    ...filteredFamilies.map((family) {
                      return TableRow(
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
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _navigateToDownloadScreen,
            icon: Icon(Icons.download),
            label: Text("Download Family Data"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color:
              isStatus
                  ? (text == 'Active' ? Colors.green : Colors.red)
                  : Colors.black,
        ),
      ),
    );
  }

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
                    _filterFamilies();
                  });
                  Navigator.pop(context);
                },
                items:
                    <String>[
                      '',
                      'Adult',
                      'Senior',
                    ].map<DropdownMenuItem<String>>((String value) {
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
}
