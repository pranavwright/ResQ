import 'package:flutter/material.dart';
import 'package:resq/screens/items_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({Key? key}) : super(key: key);

  @override
  _DonationsScreenState createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _otherItemController = TextEditingController();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();
  final _squareMetersController = TextEditingController();
  final _roomsController = TextEditingController();

  String _selectedType = 'money';
  String? _selectedItem;
  bool _isAnonymous = false;
  bool _showOtherItemField = false;
  
  // House donation specific fields
  String _houseDonationType = 'donate'; // 'donate' or 'rent'
  int _rentDurationMonths = 1;
  bool _isFurnished = false;
  bool _hasUtilities = false;

  final List<String> _donationItems = [
    'House',
    
    'Other',
  ];

  void _showQRCodeDialog(BuildContext context) {
    final amount = double.tryParse(_valueController.text) ?? 0.0;
    final qrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data='
        'upi://pay?pa=pranavpspranav2005@okhdfcbank&pn=Pranav%20PS'
        '&am=${amount.toStringAsFixed(2)}&cu=INR&aid=uGICAgIC31N2IIg';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scan to Complete Donation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(qrUrl),
              const SizedBox(height: 20),
              Text(
                'Amount: ₹${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please scan this QR code to complete your payment',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close QR dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ItemsList()),
                );
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHouseDonationFields() {
    return Column(
      children: [
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Full Address',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          validator: (value) {
            if (_selectedItem == 'House' && (value == null || value.isEmpty)) {
              return 'Please enter the address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _squareMetersController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Area (square meters)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.square_foot),
          ),
          validator: (value) {
            if (_selectedItem == 'House' && (value == null || value.isEmpty)) {
              return 'Please enter the area';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _roomsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Number of Rooms',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.king_bed),
          ),
          validator: (value) {
            if (_selectedItem == 'House' && (value == null || value.isEmpty)) {
              return 'Please enter room count';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Donate Permanently'),
                value: 'donate',
                groupValue: _houseDonationType,
                onChanged: (value) {
                  setState(() {
                    _houseDonationType = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Rent Temporarily'),
                value: 'rent',
                groupValue: _houseDonationType,
                onChanged: (value) {
                  setState(() {
                    _houseDonationType = value!;
                  });
                },
              ),
            ),
          ],
        ),
        if (_houseDonationType == 'rent') ...[
          const SizedBox(height: 16),
          TextFormField(
            keyboardType: TextInputType.number,
            initialValue: _rentDurationMonths.toString(),
            decoration: const InputDecoration(
              labelText: 'Duration (months)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            onChanged: (value) {
              _rentDurationMonths = int.tryParse(value) ?? 1;
            },
            validator: (value) {
              if (_houseDonationType == 'rent' && (value == null || value.isEmpty)) {
                return 'Please enter rental duration';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Fully Furnished'),
            value: _isFurnished,
            onChanged: (value) {
              setState(() {
                _isFurnished = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Includes Utilities'),
            value: _hasUtilities,
            onChanged: (value) {
              setState(() {
                _hasUtilities = value!;
              });
            },
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Donation'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Donation Type Selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Donation Type',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Money'),
                                value: 'money',
                                groupValue: _selectedType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedType = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Items'),
                                value: 'items',
                                groupValue: _selectedType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedType = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Donor Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _isAnonymous,
                              onChanged: (value) {
                                setState(() {
                                  _isAnonymous = value!;
                                });
                              },
                            ),
                            const Text(
                              'Donate Anonymously (your name won\'t be shown publicly)',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (!_isAnonymous) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (!_isAnonymous && (value == null || value.isEmpty)) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email Address (required for receipt)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email for donation receipt';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We need your email to send a donation receipt',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Value Input (for money) or Item Selection (for items)
                if (_selectedType == 'money')
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _valueController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Enter amount in ₹',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Item Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedItem,
                            decoration: const InputDecoration(
                              labelText: 'Select Item',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: _donationItems.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedItem = value;
                                _showOtherItemField = value == 'Other';
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an item';
                              }
                              return null;
                            },
                          ),
                          if (_showOtherItemField) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _otherItemController,
                              decoration: const InputDecoration(
                                labelText: 'Specify Item',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.edit),
                              ),
                              validator: (value) {
                                if (_showOtherItemField && (value == null || value.isEmpty)) {
                                  return 'Please specify the item';
                                }
                                return null;
                              },
                            ),
                          ],
                          if (_selectedItem == 'House') ...[
                            const SizedBox(height: 16),
                            _buildHouseDonationFields(),
                          ] else if (_selectedItem != null && _selectedItem != 'House') ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.format_list_numbered),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter quantity';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Description Input
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedType == 'money'
                              ? 'Purpose of Donation'
                              : 'Additional Notes',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Enter description',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: () => _submitDonation(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Submit Donation',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitDonation(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        final donationData = {
          'type': _selectedType,
          'donor_email': _emailController.text,
          'donor_name': _isAnonymous ? 'Anonymous' : _nameController.text,
          'is_anonymous': _isAnonymous,
          'description': _descriptionController.text,
          'submission_date': DateTime.now().toIso8601String(),
          'item_details': _selectedType == 'items' ? {
            'category': _selectedItem,
            'quantity': _selectedItem == 'House' ? 1 : int.parse(_quantityController.text),
            if (_selectedItem == 'House') ...{
              'address': _addressController.text,
              'square_meters': int.parse(_squareMetersController.text),
              'rooms': int.parse(_roomsController.text),
              'donation_type': _houseDonationType,
              'is_furnished': _isFurnished,
              'has_utilities': _hasUtilities,
              if (_houseDonationType == 'rent') 'duration_months': _rentDurationMonths,
            },
            if (_showOtherItemField) 'custom_item': _otherItemController.text,
          } : null,
          'monetary_details': _selectedType == 'money' ? {
            'amount': double.parse(_valueController.text),
            'currency': 'INR',
          } : null,
        };

        // Simulate API call (replace with actual HTTP request)
        debugPrint('Submitting donation: ${jsonEncode(donationData)}');
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog

          if (_selectedType == 'money') {
            _showQRCodeDialog(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ItemsList()),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Donation submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Clear form
          _valueController.clear();
          _descriptionController.clear();
          _emailController.clear();
          _nameController.clear();
          _otherItemController.clear();
          _quantityController.clear();
          _addressController.clear();
          _squareMetersController.clear();
          _roomsController.clear();
          setState(() {
            _selectedItem = null;
            _showOtherItemField = false;
            _isAnonymous = false;
            _houseDonationType = 'donate';
            _isFurnished = false;
            _hasUtilities = false;
          });
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting donation: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _otherItemController.dispose();
    _quantityController.dispose();
    _addressController.dispose();
    _squareMetersController.dispose();
    _roomsController.dispose();
    super.dispose();
  }
}