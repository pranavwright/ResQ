import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class StatisticsDepartmentHouseDonationForm extends StatefulWidget {
  const StatisticsDepartmentHouseDonationForm({super.key});

  @override
  State<StatisticsDepartmentHouseDonationForm> createState() =>
      _StatisticsDepartmentHouseDonationFormState();
}

class _StatisticsDepartmentHouseDonationFormState
    extends State<StatisticsDepartmentHouseDonationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _donorNameController = TextEditingController();
  final TextEditingController _houseLocationController =
      TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _documentReferenceController =
      TextEditingController();

  String _selectedHouseType = 'Apartment';
  String _selectedStatus = 'Available';
  String _selectedDonationType = 'Government';

  final List<String> _houseTypes = ['Apartment', 'House', 'Villa', 'Dormitory'];
  final List<String> _statusOptions = ['Available', 'Occupied', 'Maintenance'];
  final List<String> _donationTypes = [
    'Government',
    'NGO',
    'Private Donor',
    'International Aid',
  ];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> houseDetails = {
        'donorName': _donorNameController.text,
        'houseLocation': _houseLocationController.text,
        'houseType': _selectedHouseType,
        'capacity': int.parse(_capacityController.text),
        'status': _selectedStatus,
        'donationType': _selectedDonationType,
        'documentReference': _documentReferenceController.text,
        'submissionTimestamp': DateTime.now().toIso8601String(),
      };

      try {
        // await HouseDonationService.submitHouseDonation(houseDetails);
        _showSuccessDialog();
        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting donation: $e')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Donation Recorded'),
            content: const Text(
              'House donation details have been successfully logged.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _donorNameController.clear();
    _houseLocationController.clear();
    _capacityController.clear();
    _documentReferenceController.clear();
    setState(() {
      _selectedHouseType = 'Apartment';
      _selectedStatus = 'Available';
      _selectedDonationType = 'Government';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Dept: House Donation Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                _donorNameController,
                'Donor/Organization Name',
                Icons.person,
              ),
              _buildDropdown(
                _donationTypes,
                _selectedDonationType,
                'Donation Type',
                Icons.category,
                (val) => setState(() => _selectedDonationType = val!),
              ),
              _buildTextField(
                _documentReferenceController,
                'Document Reference Number',
                Icons.numbers,
              ),
              _buildTextField(
                _houseLocationController,
                'House Location',
                Icons.location_on,
              ),
              _buildDropdown(
                _houseTypes,
                _selectedHouseType,
                'House Type',
                Icons.home,
                (val) => setState(() => _selectedHouseType = val!),
              ),
              _buildTextField(
                _capacityController,
                'Capacity (Number of People)',
                Icons.people,
                isNumeric: true,
              ),
              _buildDropdown(
                _statusOptions,
                _selectedStatus,
                'House Status',
                Icons.check_circle,
                (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Log House Donation',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        inputFormatters:
            isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter $label';
          if (isNumeric && int.tryParse(value) == null)
            return 'Enter a valid number';
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String selectedValue,
    String label,
    IconData icon,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

  @override
  void dispose() {
    _donorNameController.dispose();
    _houseLocationController.dispose();
    _capacityController.dispose();
    _documentReferenceController.dispose();
    super.dispose();
  }
}
