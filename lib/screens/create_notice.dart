import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class CreateNoticeScreen extends StatefulWidget {
  const CreateNoticeScreen({super.key});

  @override
  State<CreateNoticeScreen> createState() => CreateNoticeScreenState();
}

class CreateNoticeScreenState extends State<CreateNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String _selectedRole = 'Admin';
  String _selectedUrgency = 'Normal';

  final List<String> roles = ['Admin', 'Teacher', 'Student'];
  final List<String> urgencyLevels = ['Low', 'Normal', 'High'];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Process the form data
      developer.log("Title: ${_titleController.text}");
      developer.log("Description: ${_descriptionController.text}");
      developer.log("Role: $_selectedRole");
      developer.log("Urgency: $_selectedUrgency");
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice Created Successfully')),
      );
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

              const Text('Select Role', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: roles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) => setState(() => _selectedRole = value!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
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
    );
  }
}