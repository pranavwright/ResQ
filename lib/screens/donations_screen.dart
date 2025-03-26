import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({Key? key}) : super(key: key);

  @override
  _DonationsScreenState createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _donorNameController = TextEditingController();
  final _donorEmailController = TextEditingController();
  final _donorPhoneController = TextEditingController();
  final _donorAddressController = TextEditingController();
  final _valueController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _itemQuantityController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  
  String _selectedType = 'money';
  String _selectedPaymentMethod = 'cash';
  DateTime? _donationDate;
  TimeOfDay? _donationTime;
  bool _requiresPickup = false;
  bool _anonymousDonation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Relief Donation'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Donor Information Section
                _buildSectionHeader('Donor Information'),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Anonymous Donation Toggle
                        SwitchListTile(
                          title: const Text('Anonymous Donation'),
                          value: _anonymousDonation,
                          onChanged: (value) {
                            setState(() {
                              _anonymousDonation = value;
                            });
                          },
                        ),
                        
                        if (!_anonymousDonation) ...[
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _donorNameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (!_anonymousDonation && (value == null || value.isEmpty)) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _donorEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (!_anonymousDonation && (value == null || value.isEmpty)) {
                                return 'Please enter your email';
                              }
                              if (value != null && value.isNotEmpty && !value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _donorPhoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (!_anonymousDonation && (value == null || value.isEmpty)) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _donorAddressController,
                            decoration: const InputDecoration(
                              labelText: 'Address (Optional)',
                              prefixIcon: Icon(Icons.location_on),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Donation Details Section
                _buildSectionHeader('Donation Details'),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Donation Type Selector
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Monetary'),
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
                                title: const Text('Goods/Items'),
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
                        const SizedBox(height: 16),

                        // Value/Quantity Input
                        if (_selectedType == 'money') ...[
                          TextFormField(
                            controller: _valueController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Donation Amount',
                              prefixIcon: Icon(Icons.attach_money),
                              border: OutlineInputBorder(),
                              suffixText: 'USD',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter donation amount';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedPaymentMethod,
                            decoration: const InputDecoration(
                              labelText: 'Payment Method',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.payment),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'cash', child: Text('Cash')),
                              DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                              DropdownMenuItem(value: 'card', child: Text('Credit/Debit Card')),
                              DropdownMenuItem(value: 'online', child: Text('Online Payment')),
                              DropdownMenuItem(value: 'check', child: Text('Check')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select payment method';
                              }
                              return null;
                            },
                          ),
                        ] else ...[
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Item Description',
                              prefixIcon: Icon(Icons.description),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please describe the items';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _itemQuantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              prefixIcon: Icon(Icons.format_list_numbered),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter quantity';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _valueController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Estimated Value (Optional)',
                              prefixIcon: Icon(Icons.attach_money),
                              border: OutlineInputBorder(),
                              suffixText: 'USD',
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Requires Pickup'),
                            value: _requiresPickup,
                            onChanged: (value) {
                              setState(() {
                                _requiresPickup = value;
                              });
                            },
                          ),
                          if (_requiresPickup) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _pickupAddressController,
                              decoration: const InputDecoration(
                                labelText: 'Pickup Address',
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                              validator: (value) {
                                if (_requiresPickup && (value == null || value.isEmpty)) {
                                  return 'Please provide pickup address';
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Donation Date/Time Section
                _buildSectionHeader('Donation Schedule'),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            _donationDate == null
                                ? 'Select Donation Date'
                                : 'Date: ${DateFormat('MMM dd, yyyy').format(_donationDate!)}',
                          ),
                          trailing: const Icon(Icons.arrow_drop_down),
                          onTap: () => _selectDate(context),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(
                            _donationTime == null
                                ? 'Select Donation Time'
                                : 'Time: ${_donationTime!.format(context)}',
                          ),
                          trailing: const Icon(Icons.arrow_drop_down),
                          onTap: () => _selectTime(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Additional Notes
                _buildSectionHeader('Additional Information'),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Special Instructions (Optional)',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'SUBMIT DONATION',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _donationDate) {
      setState(() {
        _donationDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _donationTime) {
      setState(() {
        _donationTime = picked;
      });
    }
  }

  void _submitDonation() {
    if (_formKey.currentState!.validate()) {
      // Prepare donation data for API submission
      final donationData = {
        'donor': {
          'name': _anonymousDonation ? 'Anonymous' : _donorNameController.text,
          'email': _anonymousDonation ? null : _donorEmailController.text,
          'phone': _anonymousDonation ? null : _donorPhoneController.text,
          'address': _anonymousDonation ? null : _donorAddressController.text,
          'isAnonymous': _anonymousDonation,
        },
        'donation': {
          'type': _selectedType,
          'description': _descriptionController.text,
          if (_selectedType == 'money') ...{
            'amount': double.parse(_valueController.text),
            'paymentMethod': _selectedPaymentMethod,
          },
          if (_selectedType == 'items') ...{
            'quantity': int.parse(_itemQuantityController.text),
            'estimatedValue': _valueController.text.isNotEmpty 
                ? double.parse(_valueController.text) 
                : null,
            'requiresPickup': _requiresPickup,
            'pickupAddress': _requiresPickup ? _pickupAddressController.text : null,
          },
        },
        'schedule': {
          'date': _donationDate != null 
              ? DateFormat('yyyy-MM-dd').format(_donationDate!) 
              : null,
          'time': _donationTime != null 
              ? _donationTime!.format(context) 
              : null,
        },
        'submittedAt': DateTime.now().toIso8601String(),
      };

      // TODO: Implement API call to submit donationData
      print('Donation Data: $donationData');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your donation!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Optionally: Clear form or navigate away
      // _resetForm();
    }
  }

  @override
  void dispose() {
    _donorNameController.dispose();
    _donorEmailController.dispose();
    _donorPhoneController.dispose();
    _donorAddressController.dispose();
    _valueController.dispose();
    _descriptionController.dispose();
    _itemQuantityController.dispose();
    _pickupAddressController.dispose();
    super.dispose();
  }
}