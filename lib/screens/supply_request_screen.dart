// screens/supply_request_screen.dart
import 'package:flutter/material.dart';
import '../models/supply_request.dart';
import '../utils/colors.dart';

class SupplyRequestScreen extends StatefulWidget {
  final String campId;

  const SupplyRequestScreen({Key? key, required this.campId}) : super(key: key);

  @override
  _SupplyRequestScreenState createState() => _SupplyRequestScreenState();
}

class _SupplyRequestScreenState extends State<SupplyRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _supplyTypes = [
    'Water', 'Food', 'Blankets', 'Medicines', 
    'First Aid Kits', 'Tents', 'Hygiene Kits'
  ];
  
  String _selectedType = 'Water';
  final TextEditingController _quantityController = TextEditingController();
  String _unit = 'units';
  int _priority = 2; // Default to high priority
  final TextEditingController _notesController = TextEditingController();
  bool _isUrgent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Supply Request'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: _supplyTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    // Auto-set units based on type
                    if (_selectedType == 'Water') _unit = 'liters';
                    if (_selectedType == 'Food') _unit = 'packets';
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Supply Type',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
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
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _unit,
                      items: ['units', 'liters', 'kg', 'boxes', 'pairs']
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _unit = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _priority,
                items: [
                  DropdownMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Critical'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('High'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('Medium'),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Text('Low'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                    _isUrgent = value <= 2;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Mark as Urgent'),
                value: _isUrgent,
                onChanged: (value) {
                  setState(() {
                    _isUrgent = value;
                    if (value && _priority > 2) {
                      _priority = 2;
                    }
                  });
                },
                activeColor: AppColors.alert,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Additional Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Specific details about this request...',
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitRequest,
                child: Text('Submit Request'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      // Create new request
      final newRequest = SupplyRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        campId: widget.campId,
        type: _selectedType,
        itemName: _selectedType,
        quantity: int.parse(_quantityController.text),
        unit: _unit,
        requestedAt: DateTime.now(),
        isUrgent: _isUrgent,
        priority: _priority,
        notes: _notesController.text,
      );

      // In a real app, you would save to Firestore here
      // For now, just return to previous screen with the new request
      Navigator.pop(context, newRequest);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}