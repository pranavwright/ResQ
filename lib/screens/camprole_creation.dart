import 'package:flutter/material.dart';

class CamproleCreation extends StatefulWidget {
  const CamproleCreation({super.key});

  @override
  _CamproleCreationState createState() => _CamproleCreationState();
}

class _CamproleCreationState extends State<CamproleCreation> {
  // Define controllers for each text field
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // List to store added roles
  List<Map<String, String>> roles = [];

  // Flag to track if we are editing a role
  int? editingIndex;

  // Variables for additional role fields
  String assignedTo = '';
  String location = '';
  String validationMessage = '';

  // List for dropdowns
  List<String> roleOptions = ['Statistics', 'Camp Admin', 'Collection Point Admin', 'Survey Officials', 'Verify Officials'];
  List<String> locationOptions = ['St. Joseph', 'SKMJ', 'DePaul'];

  // Function to handle form submission
  void _submitForm() {
    final name = nameController.text;
    final phone = phoneController.text;

    if (name.isEmpty || phone.isEmpty || assignedTo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields!')),
      );
      return; // Exit the function if fields are empty
    }

    if ((assignedTo == 'Camp Admin' || assignedTo == 'Collection Point Admin') && location.isEmpty) {
      setState(() {
        validationMessage = 'Please select a Location.';
      });
      return;
    }

    setState(() {
      if (editingIndex == null) {
        // Add new role
        roles.add({
          'name': name,
          'phone': phone,
          'assignedTo': assignedTo,
          'location': location,
        });
      } else {
        // Update existing role
        roles[editingIndex!] = {
          'name': name,
          'phone': phone,
          'assignedTo': assignedTo,
          'location': location,
        };
        editingIndex = null; // Reset editing mode
      }
    });

    // Clear the form fields after submission
    nameController.clear();
    phoneController.clear();
    assignedTo = '';
    location = '';

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(editingIndex == null ? 'Role added successfully!' : 'Role updated successfully!')),
    );

    // Call print function to output the current roles
    printRoles();
  }

  // Function to handle editing a role
  void _editRole(int index) {
    setState(() {
      editingIndex = index;
      final role = roles[index];
      nameController.text = role['name']!;
      phoneController.text = role['phone']!;
      assignedTo = role['assignedTo']!;
      location = role['location']!;
    });
  }

  void _deleteRole(int index) {
    setState(() {
      roles.removeAt(index);
    });
  }

  // Function to print the current list of roles (simulating the "print" functionality)
  void printRoles() {
    print('Current Roles:');
    for (var role in roles) {
      print('Name: ${role['name']},Phone Number:${role['phone']} Assigned To: ${role['assignedTo']}, Location: ${role['location']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Role Creation',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Set the arrow icon to white
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Text Fields for Role Details
              _buildTextField(controller: nameController, label: 'Name', icon: Icons.person),
              const SizedBox(height: 16),
              _buildTextField(controller: phoneController, label: 'Phone Number', icon: Icons.phone),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Assigned To',
                value: assignedTo,
                items: roleOptions,
                onChanged: (value) {
                  setState(() {
                    assignedTo = value!;
                    location = ''; // Reset location if assignedTo changes
                  });
                },
              ),
              const SizedBox(height: 16),
              // Location Dropdown appears if "Camp Admin" or "Collection Point Admin" is selected
              if (assignedTo == 'Camp Admin' || assignedTo == 'Collection Point Admin')
                _buildDropdownField(
                  label: 'Location',
                  value: location,
                  items: locationOptions,
                  onChanged: (value) {
                    setState(() {
                      location = value!;
                    });
                  },
                  icon: Icons.location_on, // Updated icon for location
                ),
              
              // Validation message
              if (validationMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red[50],
                  child: Text(
                    validationMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'All Roles:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Display the list of roles
              if (roles.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        title: Text(roles[index]['name']!),
                        subtitle: Text('Assigned to: ${roles[index]['assignedTo']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editRole(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteRole(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build TextField widgets with icons and styles
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Helper method to build Dropdown fields
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    IconData? icon, // Optional icon parameter for dropdown
  }) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon ?? Icons.assignment), // Use passed icon or default icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
    );
  }
}
