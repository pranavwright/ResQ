import 'package:flutter/material.dart';
import '../models/supply_request.dart';
import '../utils/colors.dart';

class SupplyRequestDialog extends StatefulWidget {
  final String campId;
  final SupplyRequest? request;
  final Function(SupplyRequest) onSubmitted;

  const SupplyRequestDialog({
    Key? key,
    required this.campId,
    this.request,
    required this.onSubmitted,
  }) : super(key: key);
  @override
  _SupplyRequestDialogState createState() => _SupplyRequestDialogState();
}

class _SupplyRequestDialogState extends State<SupplyRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  late String _unit;
  late int _priority;
  late bool _isUrgent;

  final List<String> _commonSupplies = [
    'Water',
    'Food',
    'Blankets',
    'Medicines',
    'First Aid Kits',
    'Tents',
    'Hygiene Kits',
    'Baby Supplies',
    'Clothing',
    'Flashlights',
    'Batteries',
    'Cooking Fuel',
  ];

  @override
  void initState() {
    super.initState();
    final request = widget.request;
    _typeController = TextEditingController(text: request?.type ?? '');
    _quantityController = TextEditingController(text: request?.quantity.toString() ?? '');
    _notesController = TextEditingController(text: request?.notes ?? '');
    _unit = request?.unit ?? 'units';
    _priority = request?.priority ?? 2; // Default to High priority
    _isUrgent = request?.isUrgent ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.request == null ? 'New Supply Request' : 'Edit Request',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return _commonSupplies.where((String option) {
                    return option.toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  _typeController.text = selection;
                  // Auto-set units based on selection
                  if (selection == 'Water') _unit = 'liters';
                  if (selection == 'Food') _unit = 'packets';
                  if (selection == 'Medicines') _unit = 'boxes';
                  setState(() {});
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController fieldController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return TextFormField(
                    controller: _typeController,
                    decoration: InputDecoration(
                      labelText: 'Item Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an item type';
                      }
                      return null;
                    },
                  );
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
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
                      items: ['units', 'liters', 'kg', 'boxes', 'pairs', 'kits']
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
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Critical'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.orange),
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
                title: Text('Urgent Request'),
                subtitle: Text('Mark if immediate attention is needed'),
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
                decoration: InputDecoration(
                  labelText: 'Additional Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Specific details, brand preferences, etc.',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submitRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: Text(widget.request == null ? 'Submit Request' : 'Update'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      final request = SupplyRequest(
        id: widget.request?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        campId: widget.campId,
        type: _typeController.text,
        itemName: _typeController.text,
        quantity: int.parse(_quantityController.text),
        unit: _unit,
        requestedAt: widget.request?.requestedAt ?? DateTime.now(),
        isUrgent: _isUrgent,
        priority: _priority,
        notes: _notesController.text,
        status: widget.request?.status ?? 'pending',
      );

      widget.onSubmitted(request);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}