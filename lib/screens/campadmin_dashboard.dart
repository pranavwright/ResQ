import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/auth/auth_service.dart';

class CampAdminRequestScreen extends StatefulWidget {
  const CampAdminRequestScreen({Key? key}) : super(key: key);

  @override
  State<CampAdminRequestScreen> createState() => _CampAdminRequestScreenState();
}

class _CampAdminRequestScreenState extends State<CampAdminRequestScreen> {
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for each request detail (used in the list)
  final List<Map<String, TextEditingController>> _requestControllers = [];

  // Request options
  String? _selectedRequestType;
  final List<String> _requestTypes = ['Food', 'Medicine', 'Essential Items'];

  final List<String> _essentialItems = [
    'Bedsheet', 'Blanket', 'Cup', 'Plate', 'Bucket', 'Soap',
    'Toothpaste', 'Toothbrush', 'Sanitary Pads', 'Mosquito Net', 'Other',
  ];
  String? _selectedEssentialItem = 'Bedsheet';

  final List<String> _priorityLevels = ['Low', 'Medium', 'High', 'Critical'];
  String _selectedPriority = 'Medium';

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      // Loop through each request and handle submission
      for (var requestDetails in _requestControllers) {
        Map<String, dynamic> campRequest = {
          'Request Type': _selectedRequestType,
          'Priority': _selectedPriority,
          'Timestamp': DateTime.now().toString(),
        };

        // Add specific details based on request type
        switch (_selectedRequestType) {
          case 'Food':
            campRequest['Food Type'] = requestDetails['foodType']!.text.trim();
            campRequest['Food Quantity'] = requestDetails['foodQty']!.text.trim();
            break;
          case 'Medicine':
            campRequest['Medicine Type'] = requestDetails['medicineType']!.text.trim();
            campRequest['Medicine Quantity'] = requestDetails['medicineQty']!.text.trim();
            break;
          case 'Essential Items':
            campRequest['Item'] = _selectedEssentialItem;
            if (_selectedEssentialItem == 'Other') {
              campRequest['Item Type'] = requestDetails['otherItemType']!.text.trim();
            }
            campRequest['Item Quantity'] = requestDetails['otherItemQty']!.text.trim();
            break;
        }

        // Send request to backend (placeholder)
        print('Camp Request: $campRequest');

        // Show confirmation dialog
        _showConfirmationDialog(campRequest);
      }

      // Reset request fields after submission
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
                Text('Your ${request['Request Type']} request has been submitted.'),
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
                // TODO: Navigate to requests list page
              },
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequestTypeSpecificFields(Map<String, TextEditingController> requestDetails) {
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
                  // Update the foodType controller's value based on the selected item
                  requestDetails['foodType']?.text = newValue ?? '';
                });
              },
              validator: (value) => value == null || value.isEmpty
                  ? 'Please specify food type'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: requestDetails['foodQty'],
              decoration: const InputDecoration(
                labelText: 'Food Quantity',
                hintText: 'e.g., 50 kg, 100 packets, etc.',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true
                ? 'Please enter food quantity'
                : null,
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
              validator: (value) => value?.isEmpty ?? true
                ? 'Please specify medicine type'
                : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: requestDetails['medicineQty'],
              decoration: const InputDecoration(
                labelText: 'Medicine Quantity',
                hintText: 'e.g., 100 tablets, 50 packets, etc.',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true
                ? 'Please enter medicine quantity'
                : null,
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
                return DropdownMenuItem<String>(value: item, child: Text(item));
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
              validator: (value) => value?.isEmpty ?? true
                ? 'Please enter quantity'
                : null,
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
            onPressed: () {
              // TODO: Navigate to request history
            },
            tooltip: 'View Request History',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Text(
                'Camp Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Manage Requests'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to manage requests page
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Camp Details'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to camp details page
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmationDialog();
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: _scrollController,
                children: [
                  // Loop through each request
                  ..._requestControllers.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, TextEditingController> requestDetails = entry.value;
                    return Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      _requestControllers.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Request Type Dropdown
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Request Type',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedRequestType,
                              hint: const Text('Select what you need'),
                              items: _requestTypes.map((String type) {
                                return DropdownMenuItem<String>(value: type, child: Text(type));
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

                            // Priority Selection
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Priority',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedPriority,
                              items: _priorityLevels.map((String priority) {
                                return DropdownMenuItem<String>(value: priority, child: Text(priority));
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

                            // Conditional Fields based on Request Type
                            if (_selectedRequestType != null)
                              _buildRequestTypeSpecificFields(requestDetails),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 24),

                  // Add Another Request Button
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
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Submit Button
                  ElevatedButton.icon(
                    onPressed: _submitRequest,
                    icon: const Icon(Icons.send),
                    label: const Text('Submit Request'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Reset Button
                  TextButton.icon(
                    onPressed: _resetRequestFields,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Form'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    _scrollController.dispose();
    for (var request in _requestControllers) {
      request['foodType']?.dispose();
      request['foodQty']?.dispose();
      request['medicineType']?.dispose();
      request['medicineQty']?.dispose();
    request['otherItemType']?.dispose();
      request['otherItemQty']?.dispose();
    }
    super.dispose();
  }
}
