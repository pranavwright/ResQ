import 'package:flutter/material.dart';

class CamproleCreation extends StatefulWidget {
  const CamproleCreation({super.key});

  @override
  _CamproleCreationState createState() => _CamproleCreationState();
}

class _CamproleCreationState extends State<CamproleCreation> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  List<Map<String, String>> roles = [];
  int? editingIndex;

  bool _showForm = false;

  String assignedTo = '';
  String location = '';
  String validationMessage = '';

  List<String> roleOptions = [
    'Statistics',
    'Camp Admin',
    'Collection Point Admin',
    'Survey Officials',
    'Verify Officials',
  ];
  List<String> locationOptions = ['St. Joseph', 'SKMJ', 'DePaul'];

  void _submitForm() {
    final name = nameController.text;
    final phone = phoneController.text;

    if (name.isEmpty || phone.isEmpty || assignedTo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields!')),
      );
      return;
    }

    if ((assignedTo == 'Camp Admin' ||
            assignedTo == 'Collection Point Admin') &&
        location.isEmpty) {
      setState(() {
        validationMessage = 'Please select a Location.';
      });
      return;
    }

    setState(() {
      if (editingIndex == null) {
        roles.add({
          'name': name,
          'phone': phone,
          'assignedTo': assignedTo,
          'location': location,
        });
      } else {
        roles[editingIndex!] = {
          'name': name,
          'phone': phone,
          'assignedTo': assignedTo,
          'location': location,
        };
        editingIndex = null; // Reset editing mode
      }
    });

    nameController.clear();
    phoneController.clear();
    assignedTo = '';
    location = '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          editingIndex == null
              ? 'Role added successfully!'
              : 'Role updated successfully!',
        ),
      ),
    );
    printRoles();
  }

  void printRoles() {
    print('Current Roles:');
    for (var role in roles) {
      print(
        'Name: ${role['name']}, Phone Number: ${role['phone']}, Assigned To: ${role['assignedTo']}, Location: ${role['location']}',
      );
    }
  }

  // Method to delete a role
  void _deleteRole(int index) {
    setState(() {
      roles.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Role deleted successfully!')),
    );
  }

  // Method to edit a role
  void _editRole(int index) {
    setState(() {
      editingIndex = index;
      nameController.text = roles[index]['name']!;
      phoneController.text = roles[index]['phone']!;
      assignedTo = roles[index]['assignedTo']!;
      location = roles[index]['location']!;
    });
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_showForm) ...[
                _buildTextField(
                  controller: nameController,
                  label: 'Name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                ),
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
                if (assignedTo == 'Camp Admin' ||
                    assignedTo == 'Collection Point Admin')
                  _buildDropdownField(
                    label: 'Location',
                    value: location,
                    items: locationOptions,
                    onChanged: (value) {
                      setState(() {
                        location = value!;
                      });
                    },
                    icon: Icons.location_on,
                  ),
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
                const SizedBox(height: 20),
              ],
              const Text(
                'All Roles:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
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
                        subtitle: Text(
                          'Assigned to: ${roles[index]['assignedTo']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editRole(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showForm = !_showForm;
          });
        },
        child: Icon(
          _showForm ? Icons.cancel : Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        tooltip: _showForm ? 'Cancel' : 'Add Collection Point',
      ),
    );
  }

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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon ?? Icons.assignment),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          items.map((String option) {
            return DropdownMenuItem<String>(value: option, child: Text(option));
          }).toList(),
    );
  }
}
