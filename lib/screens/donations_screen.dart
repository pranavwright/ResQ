import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({Key? key}) : super(key: key);

  @override
  _DonationsScreenState createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'money';

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
                                title: const Text('Assets'),
                                value: 'assets',
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
                
                // Value Input
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedType == 'money' ? 'Amount' : 'Asset Value',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _valueController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: _selectedType == 'money' 
                                ? 'Enter amount in \$' 
                                : 'Enter asset value in \$',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.attach_money),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a value';
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
                              : 'Asset Description',
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
                  onPressed: _submitDonation,
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

  void _submitDonation() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement donation submission to backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donation submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear form
      _valueController.clear();
      _descriptionController.clear();
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}