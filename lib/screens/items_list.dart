import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:resq/screens/donation_request_form.dart';
import 'package:resq/screens/donations_screen.dart';
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
  String? _selectedStatus; // Initially null
  String? _selectedDisasterId;
  List<Map<String, dynamic>> _disasters =
      []; // To store disaster data, use dynamic
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _itemsList = []; // To store the fetched items

  @override
  void initState() {
    super.initState();
    if (widget.disasterId!='') {
      _selectedDisasterId = widget.disasterId;
      _fetchItems();
    } else {
      _fetchDisasters();
    }
  }

  // In _fetchDisasters method:
  Future<void> _fetchDisasters() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dynamic response = await TokenLessHttp().get(
        '/disaster/getDisasters',
      );

      if (response is List) {
        setState(() {
          _disasters = List<Map<String, dynamic>>.from(
            response.map((item) => item as Map<String, dynamic>),
          );
        });
      } else {
        throw Exception(
          'Expected list response but got: ${response.runtimeType}',
        );
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

  // In _fetchItems method:
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
      final dynamic response = await TokenLessHttp().get(
        '/donation/items?disasterId=$_selectedDisasterId',
      );

      if (response is Map &&
          response.containsKey('list') &&
          response['list'] is List) {
        setState(() {
          _itemsList = List<Map<String, dynamic>>.from(
            response['list'].map((item) => item as Map<String, dynamic>),
          );
        });
      } else {
        throw Exception(
          'Expected map with list response but got: ${response.runtimeType}',
        );
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
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Use a proper loading indicator
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error: $_error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.green.shade300, // Light green color for the AppBar
        title: const Text(
          "Items List",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 28,
            color: Colors.white,
          ), // Adjusted size
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
                  fillColor: Colors.yellow.withOpacity(
                    0.2,
                  ), // Yellow background for the search field
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
                'Select Disaster:', // Changed from 'Select Location'
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              DropdownButton<String>(
                value: _selectedDisasterId,
                hint: const Text("Select Disaster"),
                isExpanded: true,
                style: const TextStyle(color: Colors.black, fontSize: 18),
                items:
                    _disasters.map((disaster) {
                      return DropdownMenuItem<String>(
                        value: disaster['_id'],
                        child: Text(
                          disaster['name'] ?? '',
                        ), // Use the 'name' from disaster
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDisasterId =
                        newValue; // Update the selected disaster ID
                    _fetchItems();
                  });
                },
                icon: const Icon(
                  Icons.arrow_drop_down,
                  size: 28,
                  color: Colors.green,
                ),
                iconSize: 28,
                elevation: 16,
                dropdownColor: Colors.white,
              ),
              if (_selectedDisasterId != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Items List in the Camp',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      hint: const Text("Select Status"),
                      style: const TextStyle(color: Colors.black),
                      items: const [
                        DropdownMenuItem<String>(
                          value: "All",
                          child: Text("All"),
                        ),
                        DropdownMenuItem<String>(
                          value: "Not Necessary",
                          child: Text("Not Necessary"),
                        ),
                        DropdownMenuItem<String>(
                          value: "Needed",
                          child: Text("Needed"),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStatus = newValue;
                        });
                      },
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        size: 28,
                        color: Colors.green,
                      ),
                      iconSize: 28,
                      elevation: 16,
                      dropdownColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_itemsList.isNotEmpty)
                  Table(
                    border: TableBorder.all(color: Colors.black, width: 1.5),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color:
                              Colors
                                  .green, // Green background for the header row
                        ),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Item',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Quantity',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Not Necessary/Needed',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Priority',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ..._itemsList
                          .where((item) {
                            final project = item['project'];
                            if (project == null) return false;
                            String itemName = project['name'] ?? '';
                            bool matchesSearch = itemName
                                .toLowerCase()
                                .contains(_searchQuery);
                            // Assuming you want to filter based on some quantity logic.
                            // You might need to adjust this based on your actual data structure.
                            // For example, if you have a 'quantityNeeded' or similar field.
                            // Here, we're using a placeholder logic.
                            int quantity = 0;
                            // Attempt to parse a quantity field if it exists.
                            // Replace 'someQuantityField' with the actual field name if available.
                            // if (project.containsKey('someQuantityField')) {
                            //   quantity = int.tryParse(project['someQuantityField']?.toString() ?? '0') ?? 0;
                            // }
                            String status =
                                quantity < 10 ? 'Needed' : 'Not Necessary';
                            bool matchesStatus =
                                _selectedStatus == null ||
                                _selectedStatus == "All" ||
                                (_selectedStatus == "Not Necessary" &&
                                    status == "Not Necessary") ||
                                (_selectedStatus == "Needed" &&
                                    status == "Needed");
                            return matchesSearch && matchesStatus;
                          })
                          .map((item) {
                            final project = item['project'];
                            if (project == null) {
                              // Handle the case where project is null, maybe return an empty row or skip.
                              return TableRow(
                                children: const [
                                  Text(''),
                                  Text(''),
                                  Text(''),
                                  Text(''),
                                ],
                              );
                            }
                            // Replace with your actual quantity logic if available
                            int quantity = 0;
                            // if (project.containsKey('someQuantityField')) {
                            //   quantity = int.tryParse(project['someQuantityField']?.toString() ?? '0') ?? 0;
                            // }
                            String status =
                                quantity < 10 ? 'Needed' : 'Not Necessary';
                            String priority = getPriority(quantity);

                            return TableRow(
                              decoration: BoxDecoration(
                                color:
                                    (quantity < 10)
                                        ? Colors
                                            .green
                                            .shade100 // Lighter shade for 'Needed'
                                        : Colors
                                            .yellow
                                            .shade100, // Lighter shade for 'Not Necessary'
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(project['name'] ?? ''),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    project['quantity']?.toString() ?? '',
                                  ),
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
                          })
                          .toList(),
                    ],
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'No items found for this disaster.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                   Navigator.pushNamed(context, '/donations');
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.green.shade400,
                    ), // Green color for button
                  ),
                  child: const Text('Special Donations'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedDisasterId != null) {
                      Navigator.pushNamed(
                        context,
                        '/public-donation',
                        arguments: {
                          'disasterId': _selectedDisasterId,
                        }, 
                      );
                    } else {
                      // Optionally show a message if no disaster is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a disaster first.'),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.green.shade400,
                    ), // Green color for button
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
