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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Donation types
  final List<String> _donationTypes = ['Money', 'Food', 'Medicine', 'Other'];

  // List to store all donations
  List<Map<String, dynamic>> _donations = [];

  // Current donation being edited
  Map<String, dynamic> _currentDonation = {
    'type': null,
    'moneyAmount': '',
    'foodType': '',
    'foodQty': '',
    'medicineType': '',
    'medicineQty': '',
    'otherDetails': '',
  };

  // Controllers for current donation
  final TextEditingController _moneyAmountController = TextEditingController();
  final TextEditingController _foodTypeController = TextEditingController();
  final TextEditingController _foodQtyController = TextEditingController();
  final TextEditingController _medicineTypeController = TextEditingController();
  final TextEditingController _medicineQtyController = TextEditingController();
  final TextEditingController _otherDonationController = TextEditingController();

  void _addDonation() {
    if (_validateCurrentDonation()) {
      setState(() {
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
      case 'Money':
        if (_moneyAmountController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter donation amount')),
          );
          return false;
        }
        break;
      case 'Food':
        if (_foodTypeController.text.isEmpty || _foodQtyController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill all food donation details')),
          );
          return false;
        }
        break;
      case 'Medicine':
        if (_medicineTypeController.text.isEmpty || _medicineQtyController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill all medicine donation details')),
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
      case 'Money':
        return {'amount': _moneyAmountController.text};
      case 'Food':
        return {
          'type': _foodTypeController.text,
          'quantity': _foodQtyController.text,
        };
      case 'Medicine':
        return {
          'type': _medicineTypeController.text,
          'quantity': _medicineQtyController.text,
        };
      case 'Other':
        return {'details': _otherDonationController.text};
      default:
        return {};
    }
  }

  void _resetCurrentDonation() {
    setState(() {
      _currentDonation = {
        'type': null,
        'moneyAmount': '',
        'foodType': '',
        'foodQty': '',
        'medicineType': '',
        'medicineQty': '',
        'otherDetails': '',
      };
      _moneyAmountController.clear();
      _foodTypeController.clear();
      _foodQtyController.clear();
      _medicineTypeController.clear();
      _medicineQtyController.clear();
      _otherDonationController.clear();
    });
  }

  void _removeDonation(int index) {
    setState(() {
      _donations.removeAt(index);
    });
  }

  void _submitDonationRequest() {
    if (_formKey.currentState!.validate() && _donations.isNotEmpty) {
      // Prepare complete donation request with properly structured donations
      Map<String, dynamic> donationRequest = {
        'Name': _nameController.text.trim(),
        'Donations': _donations.map((donation) {
          return {
            'Type': donation['type'],
            'Details': donation['details'],
          };
        }).toList(),
      };

      // Debug print to verify the structure
      debugPrint('Complete Donation Request: ${donationRequest.toString()}');

      // Show confirmation dialog with all donations
      _showConfirmationDialog(donationRequest);

      // Reset form
      _resetCurrentDonation();
      _nameController.clear();
      _donations.clear();
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thank you, ${request['Name']}!'),
              const SizedBox(height: 10),
              const Text('Your donations:'),
              ...request['Donations'].map<Widget>((donation) {
                return Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '- ${donation['Type']}: ${_formatDetailsForDialog(donation['Details'])}',
                  ),
                );
              }).toList(),
            ],
          ),
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

  String _formatDetailsForDialog(Map<String, dynamic> details) {
    if (details.containsKey('amount')) {
      return '₹${details['amount']}';
    } else if (details.containsKey('type') && details.containsKey('quantity')) {
      return '${details['type']} (Qty: ${details['quantity']})';
    } else if (details.containsKey('details')) {
      return details['details'];
    }
    return '';
  }

  Widget _buildDonationTypeSpecificFields() {
    switch (_currentDonation['type']) {
      case 'Money':
        return TextFormField(
          controller: _moneyAmountController,
          decoration: const InputDecoration(
            labelText: 'Amount (INR)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            setState(() {
              _currentDonation['moneyAmount'] = value;
            });
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
              onChanged: (value) {
                setState(() {
                  _currentDonation['foodType'] = value;
                });
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
            TextFormField(
              controller: _medicineTypeController,
              decoration: const InputDecoration(
                labelText: 'Medicine Type',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _currentDonation['medicineType'] = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _medicineQtyController,
              decoration: const InputDecoration(
                labelText: 'Medicine Quantity',
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
        );
      case 'Other':
        return TextFormField(
          controller: _otherDonationController,
          decoration: const InputDecoration(
            labelText: 'Other Donation Details',
            border: OutlineInputBorder(),
          ),
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
      case 'Money':
        return 'Amount: ₹${donation['details']['amount']}';
      case 'Food':
        return '${donation['details']['type']} (Qty: ${donation['details']['quantity']})';
      case 'Medicine':
        return '${donation['details']['type']} (Qty: ${donation['details']['quantity']})';
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
              const SizedBox(height: 24),

              // Display current donations
              _buildDonationList(),

              // Add Donation Section
              const Text(
                'Add Donation:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Donation Type Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Donation Type',
                  border: OutlineInputBorder(),
                ),
                value: _currentDonation['type'],
                items: _donationTypes.map((String type) {
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
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Add Donation'),
              ),
              const SizedBox(height: 24),

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
    _medicineTypeController.dispose();
    _medicineQtyController.dispose();
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