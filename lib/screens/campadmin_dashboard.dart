import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utlis/auth/auth_service.dart';


class CampAdminRequestScreen extends StatefulWidget {
  const CampAdminRequestScreen({Key? key}) : super(key: key);

  @override
  _CampAdminRequestScreenState createState() => _CampAdminRequestScreenState();
}

class _CampAdminRequestScreenState extends State<CampAdminRequestScreen> {
  // Add reference to your AuthService
  final AuthService _authService = AuthService();

  // Scroll controller to enable programmatic scrolling
  final ScrollController _scrollController = ScrollController();

  // Form controllers
  final TextEditingController _campNameController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  // Request item controllers
  final TextEditingController _foodTypeController = TextEditingController();
  final TextEditingController _foodQtyController = TextEditingController();
  final TextEditingController _medicineTypeController = TextEditingController();
  final TextEditingController _medicineQtyController = TextEditingController();
  final TextEditingController _otherItemTypeController =
      TextEditingController();
  final TextEditingController _otherItemQtyController = TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Request type selection
  String? _selectedRequestType;

  // Request types
  final List<String> _requestTypes = ['Food', 'Medicine', 'Essential Items'];

  // Essential items list
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

  // Priority levels
  final List<String> _priorityLevels = ['Low', 'Medium', 'High', 'Critical'];
  String _selectedPriority = 'Medium';

  // People count at camp
  final TextEditingController _peopleCountController = TextEditingController();

  // Handle logout using your existing AuthService
  Future<void> _handleLogout() async {
    await _authService.logout();

    // Navigate to login screen after logout
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      // Prepare request object
      Map<String, dynamic> campRequest = {
        'Camp Name': _campNameController.text.trim(),
        'Admin Name': _adminNameController.text.trim(),
        'Contact Number': _contactNumberController.text.trim(),
        'People Count': _peopleCountController.text.trim(),
        'Request Type': _selectedRequestType,
        'Priority': _selectedPriority,
        'Timestamp': DateTime.now().toString(),
      };

      // Add specific details based on request type
      switch (_selectedRequestType) {
        case 'Food':
          campRequest['Food Type'] = _foodTypeController.text.trim();
          campRequest['Food Quantity'] = _foodQtyController.text.trim();
          break;
        case 'Medicine':
          campRequest['Medicine Type'] = _medicineTypeController.text.trim();
          campRequest['Medicine Quantity'] = _medicineQtyController.text.trim();
          break;
        case 'Essential Items':
          campRequest['Item'] = _selectedEssentialItem;
          if (_selectedEssentialItem == 'Other') {
            campRequest['Item Type'] = _otherItemTypeController.text.trim();
          }
          campRequest['Item Quantity'] = _otherItemQtyController.text.trim();
          break;
      }

      // TODO: Send request to backend
      print('Camp Request: $campRequest');

      // Show confirmation dialog
      _showConfirmationDialog(campRequest);

      // Reset form fields for next request
      _resetRequestFields();
    } else {
      // Scroll to the first error
      _scrollToFirstError();
    }
  }

  void _scrollToFirstError() {
    // This will help scroll to show validation errors
    final FormState? formState = _formKey.currentState;
    if (formState != null) {
      final ScrollPosition position = _scrollController.position;
      _scrollController.animateTo(
        0, // Start from the top to find the first error
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _resetRequestFields() {
    setState(() {
      _selectedRequestType = null;
      _foodTypeController.clear();
      _foodQtyController.clear();
      _medicineTypeController.clear();
      _medicineQtyController.clear();
      _selectedEssentialItem = 'Bedsheet';
      _otherItemTypeController.clear();
      _otherItemQtyController.clear();
      _selectedPriority = 'Medium';
    });
  }

  void _resetAllFields() {
    setState(() {
      _campNameController.clear();
      _adminNameController.clear();
      _contactNumberController.clear();
      _peopleCountController.clear();
      _resetRequestFields();
    });

    // Scroll back to top after reset
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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

  // Show logout confirmation dialog
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
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout(); // Use the method that calls your AuthService
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequestTypeSpecificFields() {
    switch (_selectedRequestType) {
      case 'Food':
        return Column(
          children: [
            TextFormField(
              controller: _foodTypeController,
              decoration: const InputDecoration(
                labelText: 'Food Type',
                hintText: 'e.g., Rice, Dal, Bread, etc.',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please specify food type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _foodQtyController,
              decoration: const InputDecoration(
                labelText: 'Food Quantity',
                hintText: 'e.g., 50 kg, 100 packets, etc.',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter food quantity';
                }
                return null;
              },
            ),
          ],
        );
      case 'Medicine':
        return Column(
          children: [
            TextFormField(
              controller: _medicineTypeController,
              decoration: const InputDecoration(
                labelText: 'Medicine Type',
                hintText: 'e.g., Paracetamol, ORS, Bandages, etc.',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please specify medicine type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _medicineQtyController,
              decoration: const InputDecoration(
                labelText: 'Medicine Quantity',
                hintText: 'e.g., 100 tablets, 50 packets, etc.',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter medicine quantity';
                }
                return null;
              },
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
              items:
                  _essentialItems.map((String item) {
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
                    controller: _otherItemTypeController,
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
              controller: _otherItemQtyController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                return null;
              },
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
          // Scroll indicator button
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () {
              // Scroll down to show more content
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            },
            tooltip: 'Scroll Down',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Navigate to request history
            },
            tooltip: 'View Request History',
          ),
          // Add logout button
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
        // Allow tapping outside fields to dismiss keyboard
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Scrollbar(
                // Add visible scrollbar to make scrolling more obvious
                thumbVisibility: true,
                trackVisibility: true,
                controller: _scrollController,
                child: ListView(
                  controller: _scrollController,
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Force scrollable even when content fits
                  children: [
                    // Scroll hint text
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Scroll down to see more fields',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ),

                    // Camp Information Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Camp Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _campNameController,
                              decoration: const InputDecoration(
                                labelText: 'Camp Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter camp name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _adminNameController,
                              decoration: const InputDecoration(
                                labelText: 'Admin Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter admin name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _contactNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Contact Number',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter contact number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _peopleCountController,
                              decoration: const InputDecoration(
                                labelText: 'Number of People in Camp',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter number of people';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Scroll indicator
                    Center(
                      child: Icon(
                        Icons.arrow_downward,
                        color: Colors.grey[400],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Request Details Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Request Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                              items:
                                  _requestTypes.map((String type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedRequestType = newValue;
                                });

                                // Scroll down to show the newly displayed fields
                                if (newValue != null) {
                                  Future.delayed(
                                    const Duration(milliseconds: 100),
                                    () {
                                      _scrollController.animateTo(
                                        _scrollController
                                            .position
                                            .maxScrollExtent,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeOut,
                                      );
                                    },
                                  );
                                }
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a request type';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Priority Selection
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Priority',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedPriority,
                              items:
                                  _priorityLevels.map((String priority) {
                                    return DropdownMenuItem<String>(
                                      value: priority,
                                      child: Text(priority),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedPriority = newValue!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Conditional Fields based on Request Type
                            if (_selectedRequestType != null)
                              _buildRequestTypeSpecificFields(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submitRequest,
                            icon: const Icon(Icons.send),
                            label: const Text('Submit Request'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Reset Button
                    TextButton.icon(
                      onPressed: _resetAllFields,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Form'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),

                    // Extra padding at the bottom to ensure the last elements are visible
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // Add floating action button for quick scroll to top
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        child: const Icon(Icons.keyboard_arrow_up),
        tooltip: 'Scroll to Top',
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    _scrollController.dispose();
    _campNameController.dispose();
    _adminNameController.dispose();
    _contactNumberController.dispose();
    _peopleCountController.dispose();
    _foodTypeController.dispose();
    _foodQtyController.dispose();
    _medicineTypeController.dispose();
    _medicineQtyController.dispose();
    _otherItemTypeController.dispose();
    _otherItemQtyController.dispose();
    super.dispose();
  }
}
