import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resq/utils/resq_menu.dart'; // Assuming this exists
import 'package:resq/utils/auth/auth_service.dart'; // Assuming this exists
import 'package:resq/utils/menu_list.dart'; // Assuming this exists

// Request History Screen
class RequestHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> requestHistory;

  const RequestHistoryScreen({Key? key, required this.requestHistory})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request History'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: requestHistory.length,
        itemBuilder: (context, index) {
          var request = requestHistory[index];
          String requestType = request['Request Type'];
          String details = '';

          // Show specific details based on the request type
          switch (requestType) {
            case 'Food':
              details =
                  'Food Type: ${request['Food Type']}, Quantity: ${request['Food Quantity']}';
              break;
            case 'Medicine':
              details =
                  'Medicine Type: ${request['Medicine Type']}, Quantity: ${request['Medicine Quantity']}';
              break;
            case 'Essential Items':
              details =
                  'Item: ${request['Item']}, Quantity: ${request['Item Quantity']}';
              if (request['Item'] == 'Other') {
                details += ', Specific Item: ${request['Item Type']}';
              }
              break;
            default:
              details = 'No details available';
              break;
          }

          return ListTile(
            title: Text('Request Type: $requestType'),
            subtitle: Text('Details: $details, Priority: ${request['Priority']}'),
          );
        },
      ),
    );
  }
}

class CampAdminRequestScreen extends StatefulWidget {
  const CampAdminRequestScreen({Key? key}) : super(key: key);

  @override
  State<CampAdminRequestScreen> createState() => _CampAdminRequestScreenState();
}

class _CampAdminRequestScreenState extends State<CampAdminRequestScreen> {
  final AuthService _authService = AuthService(); // Assuming this is for logout
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isMenuLoading = true; // You might not need this here, but I'll keep it
  List<dynamic> filteredMenuItems = []; // You might not need this here
  List<Map<String, dynamic>> requestHistory = []; // Store requests here

  final List<Map<String, TextEditingController>> _requestControllers = [];
  String? _selectedRequestType;
  final List<String> _requestTypes = ['Food', 'Medicine', 'Essential Items'];
  final List<String> _essentialItems = [
    'Bedsheet',
    'Blanket',
    'Cup',
    'Plate',
    'Bucket',
    'Soap',
    'Toothpaste',
    'Toothbrush',
    'Sanitary Pads',
    'Mosquito Net',
    'Other',
  ];
  String? _selectedEssentialItem = 'Bedsheet';
  final List<String> _priorityLevels = ['Low', 'Medium', 'High', 'Critical'];
  String _selectedPriority = 'Medium';

  @override
  void initState() {
    super.initState();
    _loadMenuItems(); //  load menu items is used in the main menu, not here.
  }

  Future<void> _loadMenuItems() async {
    try {
      final items = getFilteredMenuItems(['admin']); // Assuming this function exists
      if (mounted) {
        setState(() {
          filteredMenuItems = items;
          _isMenuLoading = false;
        });
      }
    } catch (e) {
      print('Error loading menu items: $e');
      if (mounted) {
        setState(() {
          _isMenuLoading = false;
        });
      }
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      for (var requestDetails in _requestControllers) {
        Map<String, dynamic> campRequest = {
          'Request Type': _selectedRequestType,
          'Priority': _selectedPriority,
          'Timestamp': DateTime.now().toString(),
        };

        switch (_selectedRequestType) {
          case 'Food':
            campRequest['Food Type'] = requestDetails['foodType']!.text.trim();
            campRequest['Food Quantity'] =
                requestDetails['foodQty']!.text.trim();
            break;
          case 'Medicine':
            campRequest['Medicine Type'] =
                requestDetails['medicineType']!.text.trim();
            campRequest['Medicine Quantity'] =
                requestDetails['medicineQty']!.text.trim();
            break;
          case 'Essential Items':
            campRequest['Item'] = _selectedEssentialItem;
            if (_selectedEssentialItem == 'Other') {
              campRequest['Item Type'] =
                  requestDetails['otherItemType']!.text.trim();
            }
            campRequest['Item Quantity'] =
                requestDetails['otherItemQty']!.text.trim();
            break;
        }

        // Add to the request history list
        setState(() {
          requestHistory.add(campRequest);
        });

        _showConfirmationDialog(campRequest);
      }
      _resetRequestFields();
    }
  }

  void _resetRequestFields() {
    setState(() {
      _requestControllers.clear();
      _selectedRequestType = null;
      _selectedPriority = 'Medium';
    });
  }

  void _showConfirmationDialog(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request Submitted'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your ${request['Request Type']} request has been submitted.',
                ),
                const SizedBox(height: 8),
                Text('Priority: ${request['Priority']}'),
                const SizedBox(height: 8),
                Text('Request ID: ${DateTime.now().millisecondsSinceEpoch}'),
                const SizedBox(height: 16),
                const Text('Collection point admin has been notified.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Make Another Request'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('View All Requests'),
              onPressed: () {
                Navigator.of(context).pop();
                _viewRequestHistory();
              },
            ),
          ],
        );
      },
    );
  }

  void _viewRequestHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestHistoryScreen(requestHistory: requestHistory),
      ),
    );
  }


  Widget _buildRequestTypeSpecificFields(
      Map<String, TextEditingController> requestDetails) {
    switch (_selectedRequestType) {
      case 'Food':
        return Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Food Type',
                border: OutlineInputBorder(),
              ),
              value: requestDetails['foodType']?.text.isNotEmpty ?? false
                  ? requestDetails['foodType']!.text
                  : null,
              hint: const Text('Select Food Type'),
              items: const [
                DropdownMenuItem<String>(value: 'Rice', child: Text('Rice')),
                DropdownMenuItem<String>(value: 'Dal', child: Text('Dal')),
                DropdownMenuItem<String>(value: 'Bread', child: Text('Bread')),
                DropdownMenuItem<String>(value: 'Rava', child: Text('Rava')),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  requestDetails['foodType']?.text = newValue ?? '';
                });
              },
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please specify food type' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: requestDetails['foodQty'],
              decoration: const InputDecoration(
                labelText: 'Food Quantity',
                hintText: 'e.g., 50 kg, 100 packets, etc.',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter food quantity' : null,
            ),
          ],
        );
      case 'Medicine':
        return Column(
          children: [
            TextFormField(
              controller: requestDetails['medicineType'],
              decoration: const InputDecoration(
                labelText: 'Medicine Type',
                hintText: 'e.g., Paracetamol, ORS, Bandages, etc.',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please specify medicine type' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: requestDetails['medicineQty'],
              decoration: const InputDecoration(
                labelText: 'Medicine Quantity',
                hintText: 'e.g., 100 tablets, 50 packets, etc.',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter medicine quantity' : null,
            ),
          ],
        );
      case 'Essential Items':
        return Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Item Type',
                border: OutlineInputBorder(),
              ),
              value: _selectedEssentialItem,
              items: _essentialItems.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEssentialItem = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_selectedEssentialItem == 'Other')
              Column(
                children: [
                  TextFormField(
                    controller: requestDetails['otherItemType'],
                    decoration: const InputDecoration(
                      labelText: 'Specify Item',
                      hintText: 'Enter the item name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_selectedEssentialItem == 'Other' &&
                          (value == null || value.isEmpty)) {
                        return 'Please specify the item';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            TextFormField(
              controller: requestDetails['otherItemQty'],
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter quantity' : null,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camp Supply Requests'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed:
                _viewRequestHistory, // Show request history when clicked
            tooltip: 'View Request History',
          ),
       
        ],
      ),
      drawer: MediaQuery.of(context).size.width < 800
          ? const ResQMenu(roles: ['admin']) // Assuming this is your menu
          : null,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              if (MediaQuery.of(context).size.width >= 800)
                const ResQMenu(
                    roles: ['admin'],
                    showDrawer:
                        false), // Assuming this is your menu for larger screens
              const Divider(),
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        controller: _scrollController,
                        children: [
                          ..._requestControllers.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, TextEditingController> requestDetails =
                                entry.value;
                            return Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Request Details',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            setState(() {
                                              _requestControllers.removeAt(
                                                index,
                                              );
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                        labelText: 'Request Type',
                                        border: OutlineInputBorder(),
                                      ),
                                      value: _selectedRequestType,
                                      hint: const Text('Select what you need'),
                                      items: _requestTypes.map((String type) {
                                        return DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedRequestType = newValue;
                                        });
                                      },
                                      validator: (value) => value == null
                                          ? 'Please select a request type'
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                        labelText: 'Priority',
                                        border: OutlineInputBorder(),
                                      ),
                                      value: _selectedPriority,
                                      items: _priorityLevels.map(
                                        (
                                          String priority,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: priority,
                                            child: Text(priority),
                                          );
                                        }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            _selectedPriority = newValue;
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    if (_selectedRequestType != null)
                                      _buildRequestTypeSpecificFields(
                                        requestDetails,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _requestControllers.add({
                                  'foodType': TextEditingController(),
                                  'foodQty': TextEditingController(),
                                  'medicineType': TextEditingController(),
                                  'medicineQty': TextEditingController(),
                                  'otherItemType': TextEditingController(),
                                  'otherItemQty': TextEditingController(),
                                });
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Another Request'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _submitRequest,
                            icon: const Icon(Icons.check),
                            label: const Text('Submit Request'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main Camp Admin Dashboard
class CampAdminDashboard extends StatelessWidget {
  // Placeholder for the list of family members.  In a real app, this would
  // come from your data source.
    final List<Map<String, dynamic>> familyMembers = [
    {'name': 'John Doe', 'age': 30, 'relationship': 'Head'},
    {'name': 'Jane Doe', 'age': 25, 'relationship': 'Spouse'},
    {'name': 'Peter Pan', 'age': 10, 'relationship': 'Child'},
    {'name': 'Alice Wonderland', 'age': 5, 'relationship': 'Child'},
    {'name': 'Bob The Builder', 'age': 40, 'relationship': 'Other'},
  ];

  CampAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camp Admin Dashboard'),
        centerTitle: true,
        
      ),
      drawer:
          MediaQuery.of(context).size.width < 800
              ? const ResQMenu(roles: ['admin'])
              : null, // Assuming this is your menu
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              if (MediaQuery.of(context).size.width >= 800)
                const ResQMenu(
                    roles: ['admin'],
                    showDrawer:
                        false), // Assuming this is your menu for larger screens
              const Divider(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      const Text(
                        'Welcome, Camp Admin!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Family Members in Camp:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Display the list of family members
                      ...familyMembers.map((member) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name: ${member['name']}'),
                                Text('Age: ${member['age']}'),
                                Text('Relationship: ${member['relationship']}'),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20),
                      // Button to navigate to the request screen
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CampAdminRequestScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Request Supplies',
                            style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RequestHistoryScreen(
                                  requestHistory: const []), // Pass the request history
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('View Request History',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
