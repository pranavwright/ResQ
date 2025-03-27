import 'dart:math' as Math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController _donationDateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Date selection
  DateTime? _selectedDonationDate;

  // Donation types
  final List<String> _donationTypes = [
    'Utilities',
    'Food',
    'Medicine',
    'Other',
  ];

  // Lists to store all items with their units
  List<Map<String, dynamic>> _allFoodItems = [];
  List<Map<String, dynamic>> _allUtilityItems = [];
  List<Map<String, dynamic>> _allMedicineItems = [];

  // Current donation being edited
  Map<String, dynamic> _currentDonation = {
    'type': null,
    'utilityItem': null,
    'utilityQty': '',
    'foodItem': null,
    'foodQty': '',
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

  // Temporary variables for new items
  String? _tempFoodItem;
  String? _tempUtilityItem;
  String? _tempMedicineItem;
  String? _tempFoodUnit;
  String? _tempUtilityUnit;
  String? _tempMedicineUnit;

  // List to store all donations
  List<Map<String, dynamic>> _donations = [];

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
        List<Map<String, dynamic>> foodItemsData = [];
        List<Map<String, dynamic>> utilityItemsData = [];
        List<Map<String, dynamic>> medicineItemsData = [];

        for (var item in response['list']) {
          if (item['category'] == 'Food') {
            foodItemsData.add({
              'name': item['name'],
              '_id': item['_id'],
              'category': item['category'],
              'unit': item['unit'] ?? 'kg',
              'isCustom': false,
            });
          } else if (item['category'] == 'Utilities') {
            utilityItemsData.add({
              'name': item['name'],
              '_id': item['_id'],
              'category': item['category'],
              'unit': item['unit'] ?? 'pieces',
              'isCustom': false,
            });
          } else if (item['category'] == 'Medicine') {
            medicineItemsData.add({
              'name': item['name'],
              '_id': item['_id'],
              'category': item['category'],
              'unit': item['unit'] ?? 'tablets',
              'isCustom': false,
            });
          }
        }

        setState(() {
          _allFoodItems = [...foodItemsData];
          _allUtilityItems = [...utilityItemsData];
          _allMedicineItems = [...medicineItemsData];
        });
      }
    } catch (e) {
      print('Error fetching items: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading items: $e')));
    }
  }

  Future<void> _selectDonationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDonationDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDonationDate) {
      setState(() {
        _selectedDonationDate = picked;
        _donationDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _addDonation() {
    if (_validateCurrentDonation()) {
      setState(() {
        // Add the new item to the appropriate list if it's a custom entry
        if (_currentDonation['type'] == 'Food' && _tempFoodItem != null) {
          // Check if item already exists before adding
          if (!_allFoodItems.any((item) => item['name'] == _tempFoodItem)) {
            _allFoodItems.add({
              'name': _tempFoodItem!,
              'unit': _tempFoodUnit ?? 'kg',
              'isCustom': true,
            });
          }
          _currentDonation['foodItem'] = _tempFoodItem;
          _currentDonation['foodItemId'] =
              _allFoodItems.firstWhere(
                (item) => item['name'] == _tempFoodItem,
                orElse: () => {'_id': ''},
              )['_id'];
          _tempFoodItem = null;
          _tempFoodUnit = null;
        } else if (_currentDonation['type'] == 'Utilities' &&
            _tempUtilityItem != null) {
          // Check if item already exists before adding
          if (!_allUtilityItems.any(
            (item) => item['name'] == _tempUtilityItem,
          )) {
            _allUtilityItems.add({
              'name': _tempUtilityItem!,
              'unit': _tempUtilityUnit ?? 'pieces',
              'isCustom': true,
            });
          }
          _currentDonation['utilityItem'] = _tempUtilityItem;
          _currentDonation['utilityItemId'] =
              _allUtilityItems.firstWhere(
                (item) => item['name'] == _tempUtilityItem,
                orElse: () => {'_id': ''},
              )['_id'];
          _tempUtilityItem = null;
          _tempUtilityUnit = null;
        } else if (_currentDonation['type'] == 'Medicine' &&
            _tempMedicineItem != null) {
          // Check if item already exists before adding
          if (!_allMedicineItems.any(
            (item) => item['name'] == _tempMedicineItem,
          )) {
            _allMedicineItems.add({
              'name': _tempMedicineItem!,
              'unit': _tempMedicineUnit ?? 'tablets',
              'isCustom': true,
            });
          }
          _currentDonation['medicineItem'] = _tempMedicineItem;
          _currentDonation['medicineItemId'] =
              _allMedicineItems.firstWhere(
                (item) => item['name'] == _tempMedicineItem,
                orElse: () => {'_id': ''},
              )['_id'];
          _tempMedicineItem = null;
          _tempMedicineUnit = null;
        }

        _donations.add({
          'type': _currentDonation['type'],
          'details': _getDonationDetails(_currentDonation['type']),
        });
        _resetCurrentDonation();
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
        if ((_currentDonation['utilityItem'] == null &&
                _tempUtilityItem == null) ||
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
        if ((_currentDonation['foodItem'] == null && _tempFoodItem == null) ||
            _foodQtyController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill all food donation details'),
            ),
          );
          return false;
        }
        break;
      case 'Medicine':
        if ((_currentDonation['medicineItem'] == null &&
                _tempMedicineItem == null) ||
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
        final itemName = _currentDonation['utilityItem'] ?? _tempUtilityItem;
        final existingItem = _allUtilityItems.firstWhere(
          (item) => item['name'] == itemName,
          orElse: () => {'unit': 'pieces', '_id': ''},
        );
        return {
          'item': itemName,
          'quantity': _utilityQtyController.text,
          'itemId': existingItem['_id'] ?? '',
          'category': 'Utilities',
          'unit': existingItem['unit'],
        };
      case 'Food':
        final itemName = _currentDonation['foodItem'] ?? _tempFoodItem;
        final existingItem = _allFoodItems.firstWhere(
          (item) => item['name'] == itemName,
          orElse: () => {'unit': 'kg', '_id': ''},
        );
        return {
          'item': itemName,
          'quantity': _foodQtyController.text,
          'itemId': existingItem['_id'] ?? '',
          'category': 'Food',
          'unit': existingItem['unit'],
        };
      case 'Medicine':
        final itemName = _currentDonation['medicineItem'] ?? _tempMedicineItem;
        final existingItem = _allMedicineItems.firstWhere(
          (item) => item['name'] == itemName,
          orElse: () => {'unit': 'tablets', '_id': ''},
        );
        return {
          'item': itemName,
          'quantity': _medicineQtyController.text,
          'itemId': existingItem['_id'] ?? '',
          'category': 'Medicine',
          'unit': existingItem['unit'],
        };
      case 'Other':
        return {
          'details': _otherDonationController.text,
          'item':
              'Other - ' +
              _otherDonationController.text.substring(
                0,
                10,
              ), // Limit to 10 chars
          'quantity': '1',
          'itemId': '',
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
        'medicineItem': null,
        'medicineQty': '',
        'otherDetails': '',
      };
      _utilityQtyController.clear();
      _foodQtyController.clear();
      _foodItemController.clear();
      _medicineQtyController.clear();
      _otherDonationController.clear();
    });
  }

  void _removeDonation(int index) {
    setState(() {
      _donations.removeAt(index);
    });
  }

  Future<void> _submitDonationRequest() async {
    if (_formKey.currentState!.validate() && _donations.isNotEmpty) {
      if (_selectedDonationDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a donation date')),
        );
        return;
      }

      Map<String, dynamic> donationRequest = {
        'disasterId': widget.disasterId,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'donationDate': _selectedDonationDate?.toIso8601String(),
        'items':
            _donations.map((donation) {
              final details = donation['details'];
              return {
                'type': donation['type'],
                'name': details['item'],
                'quantity': details['quantity'],
                'itemId': details['itemId'] ?? '', // Send item ID here
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
        if (response != null) {
          _showConfirmationDialog(donationRequest);
          _resetForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit donation request')),
          );
        }
      } catch (e) {
        print('Error submitting donation: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while submitting')),
        );
      }
    } else if (_donations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one donation')),
      );
    }
  }

  void _resetForm() {
    _resetCurrentDonation();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _donationDateController.clear();
    _selectedDonationDate = null;
    _donations.clear();
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
                ...(request['items'] as List).map<Widget>((item) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '• ${item['type']}: ${_formatDetailsForDialog(item)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                const Text(
                  'Preferred Donation Date:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(_donationDateController.text),
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
                Navigator.of(context).pop();
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

  String _formatDonationDetails(Map<String, dynamic> donation) {
    final details = donation['details'];
    if (donation['type'] == 'Other') {
      return details['details'];
    }
    return '${details['item']} - ${details['quantity']} ${details['unit']}';
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
              items: [
                ..._allUtilityItems.map(
                  (item) => DropdownMenuItem<String>(
                    value: item['name'],
                    child: Text(item['name']),
                  ),
                ),
                const DropdownMenuItem<String>(
                  value: 'Other',
                  child: Text('Other (Specify)'),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue == 'Other') {
                    _currentDonation['utilityItem'] = null;
                    _tempUtilityItem = '';
                    _tempUtilityUnit = 'pieces';
                  } else {
                    _currentDonation['utilityItem'] = newValue;
                    _tempUtilityItem = null;
                  }
                });
              },
            ),
            if (_currentDonation['utilityItem'] == null &&
                _tempUtilityItem != null) ...[
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Specify Utility Item',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _tempUtilityItem = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                ),
                value: _tempUtilityUnit,
                items:
                    ['pieces', 'kg', 'liters', 'boxes', 'sets'].map((
                      String unit,
                    ) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tempUtilityUnit = newValue;
                  });
                },
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _utilityQtyController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: const OutlineInputBorder(),
                suffixText:
                    _currentDonation['utilityItem'] != null
                        ? _allUtilityItems.firstWhere(
                          (item) =>
                              item['name'] == _currentDonation['utilityItem'],
                          orElse: () => {'unit': 'pieces'},
                        )['unit']
                        : _tempUtilityUnit ?? 'pieces',
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
              value: _currentDonation['foodItem'],
              items: [
                ..._allFoodItems.map(
                  (item) => DropdownMenuItem<String>(
                    value: item['name'],
                    child: Text(item['name']),
                  ),
                ),
                const DropdownMenuItem<String>(
                  value: 'Other',
                  child: Text('Other (Specify)'),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue == 'Other') {
                    _currentDonation['foodItem'] = null;
                    _tempFoodItem = '';
                    _tempFoodUnit = 'kg';
                  } else {
                    _currentDonation['foodItem'] = newValue;
                    _tempFoodItem = null;
                  }
                });
              },
            ),
            if (_currentDonation['foodItem'] == null &&
                _tempFoodItem != null) ...[
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Specify Food Item',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _tempFoodItem = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                ),
                value: _tempFoodUnit,
                items:
                    ['kg', 'g', 'liters', 'ml', 'packets', 'boxes'].map((
                      String unit,
                    ) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tempFoodUnit = newValue;
                  });
                },
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _foodQtyController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: const OutlineInputBorder(),
                suffixText:
                    _currentDonation['foodItem'] != null
                        ? _allFoodItems.firstWhere(
                          (item) =>
                              item['name'] == _currentDonation['foodItem'],
                          orElse: () => {'unit': 'kg'},
                        )['unit']
                        : _tempFoodUnit ?? 'kg',
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
              items: [
                ..._allMedicineItems.map(
                  (item) => DropdownMenuItem<String>(
                    value: item['name'],
                    child: Text(item['name']),
                  ),
                ),
                const DropdownMenuItem<String>(
                  value: 'Other',
                  child: Text('Other (Specify)'),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue == 'Other') {
                    _currentDonation['medicineItem'] = null;
                    _tempMedicineItem = '';
                    _tempMedicineUnit = 'tablets';
                  } else {
                    _currentDonation['medicineItem'] = newValue;
                    _tempMedicineItem = null;
                  }
                });
              },
            ),
            if (_currentDonation['medicineItem'] == null &&
                _tempMedicineItem != null) ...[
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Specify Medicine Item',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _tempMedicineItem = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                ),
                value: _tempMedicineUnit,
                items:
                    [
                      'tablets',
                      'bottles',
                      'boxes',
                      'strips',
                      'vials',
                      'pieces',
                    ].map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tempMedicineUnit = newValue;
                  });
                },
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _medicineQtyController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: const OutlineInputBorder(),
                suffixText:
                    _currentDonation['medicineItem'] != null
                        ? _allMedicineItems.firstWhere(
                          (item) =>
                              item['name'] == _currentDonation['medicineItem'],
                          orElse: () => {'unit': 'tablets'},
                        )['unit']
                        : _tempMedicineUnit ?? 'tablets',
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _donationDateController,
                        decoration: const InputDecoration(
                          labelText: 'Preferred Donation Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _selectDonationDate(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a donation date';
                          }
                          if (_selectedDonationDate!.isBefore(
                            DateTime.now().subtract(const Duration(days: 1)),
                          )) {
                            return 'Please select a date in the future';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildDonationList(),
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
                                value:
                                    type, // Ensure each item has a unique value
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
                      if (_currentDonation['type'] != null)
                        _buildDonationTypeSpecificFields(),
                      const SizedBox(height: 16),
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _donationDateController.dispose();
    _utilityQtyController.dispose();
    _foodQtyController.dispose();
    _foodItemController.dispose();
    _medicineQtyController.dispose();
    _otherDonationController.dispose();
    super.dispose();
  }
}

class DonationRequestPage extends StatelessWidget {
  final String disasterId;
  const DonationRequestPage({required this.disasterId, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DonationRequestForm(disasterId: disasterId);
  }
}
