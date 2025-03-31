import 'package:flutter/material.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'dart:developer' as developer;
import 'package:resq/utils/http/token_http.dart';

class CreateNoticeScreen extends StatefulWidget {
  const CreateNoticeScreen({super.key});

  @override
  State<CreateNoticeScreen> createState() => CreateNoticeScreenState();
}

class CreateNoticeScreenState extends State<CreateNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Changed from String to List<String> for multi-select
  List<String> _selectedRoles = ['admin']; // Default selection
  String _selectedUrgency = 'Normal';

  final List<String> roles = ['admin', 'superAdmin', 'stat', 'collectionPointAdmin', 'campAdmin', 'collectionpointvolunteer', 'surveyOfficial', 'verifyOfficial'];
  final List<String> urgencyLevels = ['Low', 'Normal', 'High'];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Process the form data
      developer.log("Title: ${_titleController.text}");
      developer.log("Description: ${_descriptionController.text}");
      developer.log("Roles: $_selectedRoles");
      developer.log("Urgency: $_selectedUrgency");
      await TokenHttp().post('/notice/addNotice', {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'roles': _selectedRoles, // Send array of roles
        'priority': _selectedUrgency,
        'disasterId': AuthService().getDisasterId()
      }).then((response) {
        developer.log("Response: $response");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice Created Successfully')),
        );
      }).catchError((error) {
        developer.log("Error: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create notice: ${error.toString()}')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Notice')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notice Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Notice Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Title cannot be empty' : null,
                ),
                const SizedBox(height: 16),
                
                const Text('Notice Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Notice Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) => value!.isEmpty ? 'Description cannot be empty' : null,
                ),
                const SizedBox(height: 16),

                // Replace dropdown with multi-select UI
                const Text('Select Roles (Multi-Select)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: roles.map((role) {
                      return CheckboxListTile(
                        title: Text(role),
                        value: _selectedRoles.contains(role),
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedRoles.add(role);
                            } else {
                              _selectedRoles.remove(role);
                            }
                            // Make sure at least one role is selected
                            if (_selectedRoles.isEmpty) {
                              _selectedRoles.add('admin');
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Select Urgency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: _selectedUrgency,
                  items: urgencyLevels.map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedUrgency = value!),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),

                // Role summary for better user feedback
                const Text('Selected Roles:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_selectedRoles.join(', ')),
                const SizedBox(height: 16),

                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Create Notice'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}