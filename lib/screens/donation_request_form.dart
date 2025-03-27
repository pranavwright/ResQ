import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resq/screens/items_list.dart';
import 'package:resq/utils/http/token_less_http.dart';

class DonationRequestForm extends StatefulWidget {
  final String disasterId;
  const DonationRequestForm({Key? key, required this.disasterId})
    : super(key: key);

  @override
  _DonationRequestFormState createState() => _DonationRequestFormState();
}

class _DonationRequestFormState extends State<DonationRequestForm> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Donation types
  final List<String> _donationTypes = [
    'Utilities',
    'Food',
    'Medicine',
    'Other',
  ];

  List<Map<String, dynamic>> _foodItemsData = [];
  List<Map<String, dynamic>> _utilityItemsData = [];
  List<Map<String, dynamic>> _medicineItemsData = [];

  // Predefined options
  List<String> _utilityItems = [];
  List<String> _medicineItems = [];
  List<String> _foodItems = []; // To be fetched from API
  List<String> _enteredFoodItems = []; // Track all entered food items
  String? _tempFoodItem; // Track temporary food item input

  // List to store all donations
  List<Map<String, dynamic>> _donations = [];

  // Current donation being edited
  Map<String, dynamic> _currentDonation = {
    'type': null,
    'utilityItem': null,
    'utilityQty': '',
    'foodItem': null,
    'foodQty': '',
    'foodUnit': 'kg', // Fixed unit for food
    'medicineItem': null,
    'medicineQty': '',
    'otherDetails': '',
  };

  // Controllers for current donation
  final TextEditingController _utilityQtyController = TextEditingController();
  final TextEditingController _foodQtyController = TextEditingController();
  final TextEditingController _foodItemController = TextEditingController();
  final TextEditingController _medicineQtyController = TextEditingController();
  final TextEditingController _otherDonationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      if (widget.disasterId.isEmpty) {
        Navigator.of(context).pushReplacementNamed('/disaster');
        return;
      }
      final response = await TokenLessHttp().get(
        '/donation/items',
        queryParameters: {'disasterId': widget.disasterId},
      );
      if (response != null && response['list'] is List) {
        List<String> foodItemsFromServer = [];
        List<Map<String, dynamic>> foodItemsData = [];
        List<String> utilityItemsFromServer = [];
        List<Map<String, dynamic>> utilityItemsData = [];
        List<String> medicineItemsFromServer = [];
        List<Map<String, dynamic>> medicineItemsData = [];

        for (var item in response['list']) {
          if (item['category'] == 'Food') {
            foodItemsFromServer.add(item['name']);
            foodItemsData.add({
              'name': item['name'],
              '_id': item['_id'],
              'category': item['category'],
              'unit': item['unit'] ?? 'kg',
            });
          } else if (item['category'] == 'Utilities') {
            utilityItemsFromServer.add(item['name']);
            utilityItemsData.add({
              'name': item['name'],
              '_id': item['_id'],
              'category': item['category'],
              'unit': item['unit'] ?? 'pieces',
            });
          } else if (item['category'] == 'Medicine') {
            medicineItemsFromServer.add(item['name']);
            medicineItemsData.add({
              'name': item['name'],
              '_id': item['_id'],
              'category': item['category'],
              'unit': item['unit'] ?? 'pieces',
            });
          }
        }

        setState(() {
          _foodItems = [...foodItemsFromServer, 'Other'];
          _utilityItems = [...utilityItemsFromServer, 'Other'];
          _medicineItems = [...medicineItemsFromServer, 'Other'];

          _foodItemsData = foodItemsData;
          _utilityItemsData = utilityItemsData;
          _medicineItemsData = medicineItemsData;
        });
      }
    } catch (e) {
      print('Error fetching items: $e');
      // Handle error, maybe show a snackbar
    }
  }

  void _addDonation() {
    if (_validateCurrentDonation()) {
      setState(() {
        // For food items, if it's a new item, add it to the list
        if (_currentDonation['type'] == 'Food') {
          String foodItem =
              _currentDonation['foodItem'] == 'Other'
                  ? _tempFoodItem ?? ''
                  : _currentDonation['foodItem']!;

          if (foodItem.isNotEmpty &&
              !_enteredFoodItems.contains(foodItem) &&
              !_foodItems.contains(foodItem)) {
            _enteredFoodItems.add(foodItem);
            // Update dropdown items - show all entered items + "Other"
            _foodItems = [
              ..._foodItems.where((item) => item != 'Other'),
              ..._enteredFoodItems,
              'Other',
            ];
          }

          // Set the actual food item in the donation
          _currentDonation['foodItem'] = foodItem;
        }

        _donations.add({
          'type': _currentDonation['type'],
          'details': _getDonationDetails(_currentDonation['type']),
        });
        _resetCurrentDonation();
        _tempFoodItem = null; // Reset temporary food item
      });
    }
  }

  bool _validateCurrentDonation() {
    if (_currentDonation['type'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a donation type')),
      );
      return false;
    }

    switch (_currentDonation['type']) {
      case 'Utilities':
        if (_currentDonation['utilityItem'] == null ||
            _utilityQtyController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill all utility donation details'),
            ),
          );
          return false;
        }
        break;
      case 'Food':
        if (_currentDonation['foodItem'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select or enter a food item')),
          );
          return false;
        }
        if (_currentDonation['foodItem'] == 'Other' &&
            (_tempFoodItem == null || _tempFoodItem!.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please specify the food item')),
          );
          return false;
        }
        if (_foodQtyController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter the quantity')),
          );
          return false;
        }
        break;
      case 'Medicine':
        if (_currentDonation['medicineItem'] == null ||
            _medicineQtyController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill all medicine donation details'),
            ),
          );
          return false;
        }
        break;
      case 'Other':
        if (_otherDonationController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please describe your donation')),
          );
          return false;
        }
        break;
    }
    return true;
  }

  Map<String, dynamic> _getDonationDetails(String? type) {
    switch (type) {
      case 'Utilities':
        return {
          'item': _currentDonation['utilityItem'],
          'quantity': _utilityQtyController.text,
          'itemId':
              _currentDonation['utilityItem_id'] ??
              '', // Use the item's ID or empty string
          'category': 'Utilities',
          'unit': 'pieces',
        };
      case 'Food':
        return {
          'item':
              _currentDonation['foodItem'] == 'Other'
                  ? _tempFoodItem ?? ''
                  : _currentDonation['foodItem']!,
          'quantity': _foodQtyController.text,
          'itemId':
              _currentDonation['foodItem_id'] ??
              '', // Use the item's ID or empty string
          'category': 'Food',
          'unit': _currentDonation['foodUnit'],
        };
      case 'Medicine':
        return {
          'item': _currentDonation['medicineItem'],
          'quantity': _medicineQtyController.text,
          'itemId':
              _currentDonation['medicineItem_id'] ??
              '', // Use the item's ID or empty string
          'category': 'Medicine',
          'unit': 'pieces',
        };
      case 'Other':
        return {
          'details': _otherDonationController.text,
          'item':
              'Other - ' +
              _otherDonationController.text.substring(
                0,
                Math.min(20, _otherDonationController.text.length),
              ),
          'quantity': '1',
          'itemId': '', // No ID for other items
          'category': 'Other',
          'unit': 'pieces',
        };
      default:
        return {};
    }
  }

  void _resetCurrentDonation() {
    setState(() {
      _currentDonation = {
        'type': null,
        'utilityItem': null,
        'utilityQty': '',
        'foodItem': null,
        'foodQty': '',
        'foodUnit': 'kg', // Keep unit fixed
        'medicineItem': null,
        'medicineQty': '',
        'otherDetails': '',
      };
      _utilityQtyController.clear();
      _foodQtyController.clear();
      _foodItemController.clear();
      _medicineQtyController.clear();
      _otherDonationController.clear();
      _tempFoodItem = null; // Reset temporary food item
    });
  }

  void _removeDonation(int index) {
    setState(() {
      _donations.removeAt(index);
    });
  }

  Future<void> _submitDonationRequest() async {
    if (_formKey.currentState!.validate() && _donations.isNotEmpty) {
      // Prepare complete donation request with properly structured donations
      Map<String, dynamic> donationRequest = {
        'disasterId': widget.disasterId,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'items':
            _donations.map((donation) {
              final details = donation['details'];
              return {
                'type': donation['type'],
                'name': details['item'],
                'quantity': details['quantity'],
                'itemId':
                    details['itemId'] ?? '', // Send itemId or empty string
                'category': details['category'],
                'unit': details['unit'],
                'description':
                    donation['type'] == 'Other' ? details['details'] : '',
              };
            }).toList(),
      };

      try {
        final response = await TokenLessHttp().post(
          '/donation/generalDonation',
          donationRequest,
        );
        if (response != null &&
            response['message'] == 'Donation request submitted successfully') {
          // Show success confirmation dialog
          _showConfirmationDialog(donationRequest);

          // Reset form
          _resetCurrentDonation();
          _nameController.clear();
          _emailController.clear();
          _phoneController.clear();
          _donations.clear();
          _enteredFoodItems.clear(); // Clear entered food items
          _foodItems =
              _foodItems
                  .where(
                    (item) =>
                        _utilityItems.contains(item) ||
                        _medicineItems.contains(item),
                  )
                  .toList();
          if (!_foodItems.contains('Other')) {
            _foodItems.add('Other'); // Reset to include "Other" option
          }
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to submit donation request. Please try again.',
              ),
            ),
          );
        }
      } catch (e) {
        print('Error submitting donation: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An error occurred while submitting. Please try again later.',
            ),
          ),
        );
      }
    } else if (_donations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one donation')),
      );
    }
  }

  void _showConfirmationDialog(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Donation Request Submitted'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thank you, ${request['name']}!'),
                const SizedBox(height: 16),
                const Text(
                  'We have received your donation request for:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...(request['donations'] as List).map<Widget>((donation) {
                  //Explicitly cast request['donations'] to List
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '• ${donation['type']}: ${_formatDetailsForDialog(donation['details'])}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                const Text(
                  'We will contact you shortly at:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(request['email']),
                Text(request['phone']),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ItemsList()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDetailsForDialog(Map<String, dynamic> details) {
    if (details.containsKey('item') && details.containsKey('quantity')) {
      String unit = details['unit'] ?? '';
      return '${details['item']} (${details['quantity']}${unit.isNotEmpty ? ' $unit' : ''})';
    } else if (details.containsKey('details')) {
      return details['details'];
    }
    return '';
  }

  Widget _buildDonationTypeSpecificFields() {
    switch (_currentDonation['type']) {
      case 'Utilities':
        return Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Utility Item',
                border: OutlineInputBorder(),
              ),
              value: _currentDonation['utilityItem'],
              items:
                  _utilityItems.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _currentDonation['utilityItem'] = newValue;
                  // Find and store the ID of the selected item
                  if (newValue != 'Other') {
                    final selectedItem = _utilityItemsData.firstWhere(
                      (item) => item['name'] == newValue,
                      orElse: () => {'_id': ''},
                    );
                    _currentDonation['utilityItem_id'] = selectedItem['_id'];
                  } else {
                    _currentDonation['utilityItem_id'] = '';
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _utilityQtyController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                setState(() {
                  _currentDonation['utilityQty'] = value;
                });
              },
            ),
          ],
        );
      case 'Food':
        return Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Food Item',
                border: OutlineInputBorder(),
              ),
              value:
                  _currentDonation['foodItem'] == 'Other' &&
                          _tempFoodItem != null
                      ? 'Other'
                      : _currentDonation['foodItem'],
              items:
                  _foodItems.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _currentDonation['foodItem'] = newValue;
                  if (newValue != 'Other') {
                    final selectedItem = _foodItemsData.firstWhere(
                      (item) => item['name'] == newValue,
                      orElse: () => {'_id': ''},
                    );
                    _currentDonation['foodItem_id'] = selectedItem['_id'];
                    _tempFoodItem = null;
                  } else {
                    _currentDonation['foodItem_id'] = '';
                  }
                });
              },
            ),

            if (_currentDonation['foodItem'] == 'Other') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _foodItemController,
                decoration: const InputDecoration(
                  labelText: 'Specify Food Item',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _tempFoodItem = value; // Store the typed value separately
                  });
                },
              ),
            ],

            if (_currentDonation['foodItem'] != null) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _foodQtyController,
                decoration: const InputDecoration(
                  labelText: 'Quantity (kg)',
                  border: OutlineInputBorder(),
                  suffixText: 'kg', // Fixed unit display
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    _currentDonation['foodQty'] = value;
                  });
                },
              ),
            ],
          ],
        );
      case 'Medicine':
        return Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Medicine Item',
                border: OutlineInputBorder(),
              ),
              value: _currentDonation['medicineItem'],
              items:
                  _medicineItems.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _currentDonation['medicineItem'] = newValue;
                  if (newValue != 'Other') {
                    final selectedItem = _medicineItemsData.firstWhere(
                      (item) => item['name'] == newValue,
                      orElse: () => {'_id': ''},
                    );
                    _currentDonation['medicineItem_id'] = selectedItem['_id'];
                  } else {
                    _currentDonation['medicineItem_id'] = '';
                  }
                });
              },
            ),
            if (_currentDonation['medicineItem'] != null) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicineQtyController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    _currentDonation['medicineQty'] = value;
                  });
                },
              ),
            ],
          ],
        );
      case 'Other':
        return TextFormField(
          controller: _otherDonationController,
          decoration: const InputDecoration(
            labelText: 'Donation Details',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _currentDonation['otherDetails'] = value;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDonationList() {
    if (_donations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Donations:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ..._donations.asMap().entries.map((entry) {
          final index = entry.key;
          final donation = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(donation['type']),
              subtitle: Text(_formatDonationDetails(donation)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeDonation(index),
              ),
            ),
          );
        }).toList(),
        const Divider(),
      ],
    );
  }

  String _formatDonationDetails(Map<String, dynamic> donation) {
    switch (donation['type']) {
      case 'Utilities':
        return '${donation['details']['item']} (Qty: ${donation['details']['quantity']})';
      case 'Food':
        return '${donation['details']['item']} (${donation['details']['quantity']} ${donation['details']['unit']})';
      case 'Medicine':
        return '${donation['details']['item']} (Qty: ${donation['details']['quantity']})';
      case 'Other':
        return donation['details']['details'];
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Request'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Personal Information Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Your Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length < 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Display current donations
              _buildDonationList(),

              // Add Donation Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Donation:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Donation Type Dropdown
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Donation Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        value: _currentDonation['type'],
                        items:
                            _donationTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _currentDonation['type'] = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Conditional Fields based on Donation Type
                      if (_currentDonation['type'] != null)
                        _buildDonationTypeSpecificFields(),
                      const SizedBox(height: 16),

                      // Add Donation Button
                      ElevatedButton(
                        onPressed: _addDonation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Add Donation'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitDonationRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Submit Donation Request',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _utilityQtyController.dispose();
    _foodQtyController.dispose();
    _foodItemController.dispose();
    _medicineQtyController.dispose();
    _otherDonationController.dispose();
    super.dispose();
  }
}

// Wrapper for easy usage in routes
class DonationRequestPage extends StatelessWidget {
  final String disasterId;
  DonationRequestPage({required this.disasterId});
  @override
  Widget build(BuildContext context) {
    return DonationRequestForm(disasterId: disasterId);
  }
}
