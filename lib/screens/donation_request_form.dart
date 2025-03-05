import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DonationRequestForm extends StatefulWidget {
  const DonationRequestForm({Key? key}) : super(key: key);

  @override
  _DonationRequestFormState createState() => _DonationRequestFormState();
}

class _DonationRequestFormState extends State<DonationRequestForm> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _moneyAmountController = TextEditingController();
  final TextEditingController _foodTypeController = TextEditingController();
  final TextEditingController _foodQtyController = TextEditingController();
  final TextEditingController _otherDonationController = TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Donation type selection
  String? _selectedDonationType;

  // Donation types
  final List<String> _donationTypes = ['Money', 'Food', 'Other'];

  void _submitDonationRequest() {
    if (_formKey.currentState!.validate()) {
      // Prepare donation request object
      Map<String, dynamic> donationRequest = {
        'Name': _nameController.text.trim(),
        'Donation Type': _selectedDonationType,
      };

      // Add specific details based on donation type
      switch (_selectedDonationType) {
        case 'Money':
          donationRequest['Amount (INR)'] = _moneyAmountController.text.trim();
          break;
        case 'Food':
          donationRequest['Food Type'] = _foodTypeController.text.trim();
          donationRequest['Food Quantity'] = _foodQtyController.text.trim();
          break;
        case 'Other':
          donationRequest['Other Donation Details'] = _otherDonationController.text.trim();
          break;
      }

      // TODO: Send donation request to backend
      print('Donation Request: $donationRequest');

      // Show confirmation dialog
      _showConfirmationDialog(donationRequest);

      // Reset form
      _resetForm();
    }
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _selectedDonationType = null;
      _moneyAmountController.clear();
      _foodTypeController.clear();
      _foodQtyController.clear();
      _otherDonationController.clear();
    });
  }

  void _showConfirmationDialog(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Donation Request Submitted'),
          content: Text('Thank you, ${request['Name']}! Your ${request['Donation Type']} donation has been received.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDonationTypeSpecificFields() {
    switch (_selectedDonationType) {
      case 'Money':
        return TextFormField(
          controller: _moneyAmountController,
          decoration: const InputDecoration(
            labelText: 'Amount (INR)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter donation amount';
            }
            return null;
          },
        );
      case 'Food':
        return Column(
          children: [
            TextFormField(
              controller: _foodTypeController,
              decoration: const InputDecoration(
                labelText: 'Food Type',
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
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter food quantity';
                }
                return null;
              },
            ),
          ],
        );
      case 'Other':
        return TextFormField(
          controller: _otherDonationController,
          decoration: const InputDecoration(
            labelText: 'Other Donation Details',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please describe your donation';
            }
            return null;
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Request'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Donation Type Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Donation Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDonationType,
                items: _donationTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDonationType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a donation type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Conditional Fields based on Donation Type
              if (_selectedDonationType != null)
                _buildDonationTypeSpecificFields(),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: _submitDonationRequest,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Submit Donation Request'),
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
    _moneyAmountController.dispose();
    _foodTypeController.dispose();
    _foodQtyController.dispose();
    _otherDonationController.dispose();
    super.dispose();
  }
}

// Wrapper for easy usage in routes
class DonationRequestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const DonationRequestForm();
  }
}