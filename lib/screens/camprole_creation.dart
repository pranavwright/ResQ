import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CamproleCreation extends StatefulWidget {
  const CamproleCreation({super.key});

  @override
  _CamproleCreationState createState() => _CamproleCreationState();
}

class _CamproleCreationState extends State<CamproleCreation> {
  // Create text controllers for each TextField
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController assignedToController = TextEditingController();
  
  // Additional text controllers for camp data
  TextEditingController campNameController = TextEditingController();
  TextEditingController campLocationController = TextEditingController();

  // Variables to store submitted data
  String name = '';
  String phone = '';
  String assignedTo = '';
  String campName = '';
  String campLocation = '';

  // List to store multiple roles
  List<Map<String, String>> roles = [];

  // Flag to toggle between the form and the data display
  bool isSubmitted = false;
  int? editingIndex; // To store the index of the role being edited
  String validationMessage = ''; // To show validation errors

  // Function to add a new role or update an existing role
  void saveRole() {
    // Check if the role is "camp" and validate the additional fields
    if (assignedToController.text.toLowerCase() == 'camp') {
      if (campNameController.text.isEmpty || campLocationController.text.isEmpty) {
        // Show validation error if camp fields are empty
        setState(() {
          validationMessage = 'Please fill in both Camp Name and Camp Location.';
        });
        return; // Don't submit if validation fails
      }
    }

    // If validation passes, proceed with saving the role
    setState(() {
      if (editingIndex == null) {
        // Add a new role
        roles.add({
          'name': nameController.text,
          'phone': phoneController.text,
          'assignedTo': assignedToController.text,
          'campName': campNameController.text,
          'campLocation': campLocationController.text,
        });
        print('New Role Added:');
        print('Name: ${nameController.text}');
        print('Phone: ${phoneController.text}');
        print('Assigned To: ${assignedToController.text}');
        print('Camp Name: ${campNameController.text}');
        print('Camp Location: ${campLocationController.text}');
      } else {
        // Update the existing role
        roles[editingIndex!] = {
          'name': nameController.text,
          'phone': phoneController.text,
          'assignedTo': assignedToController.text,
          'campName': campNameController.text,
          'campLocation': campLocationController.text,
        };
        print('Role Updated:');
        print('Name: ${nameController.text}');
        print('Phone: ${phoneController.text}');
        print('Assigned To: ${assignedToController.text}');
        print('Camp Name: ${campNameController.text}');
        print('Camp Location: ${campLocationController.text}');
        editingIndex = null; // Reset editing mode after update
      }

      // Clear the form after saving
      nameController.clear();
      phoneController.clear();
      assignedToController.clear();
      campNameController.clear();
      campLocationController.clear();
      isSubmitted = false;
      validationMessage = ''; // Clear validation message on successful submit
    });
  }

  // Function to edit an existing role
  void editRole(int index) {
    setState(() {
      // Load the role data into the form for editing
      editingIndex = index;
      nameController.text = roles[index]['name']!;
      phoneController.text = roles[index]['phone']!;
      assignedToController.text = roles[index]['assignedTo']!;
      campNameController.text = roles[index]['campName']!;
      campLocationController.text = roles[index]['campLocation']!;
      isSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text('Role Creation',
        style:TextStyle(
          
        ),
        ),
      ),
      body: SingleChildScrollView(  // Wrap the entire body in SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Role',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: Color.fromARGB(255, 0, 0, 0)),
            ),
            const SizedBox(height: 20),

            // Display form or data depending on the state
            if (!isSubmitted) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // TextField 1: Role Name
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TextField 2: Phone Number
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TextField 3: Assigned To
                      TextField(
                        controller: assignedToController,
                        decoration: InputDecoration(
                          labelText: 'Assigned To',
                          prefixIcon: Icon(Icons.assignment),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Show additional fields if "camp" is selected as the role
                      if (assignedToController.text.toLowerCase() == 'camp') ...[
                        TextField(
                          controller: campNameController,
                          decoration: InputDecoration(
                            labelText: 'Camp Name',
                            prefixIcon: Icon(Icons.location_city),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: campLocationController,
                          decoration: InputDecoration(
                            labelText: 'Camp Location',
                            prefixIcon: Icon(Icons.location_on),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Validation message display
                      if (validationMessage.isNotEmpty) 
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.red[50],
                          child: Text(
                            validationMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: saveRole,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Display the entered data
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Name: $name', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Phone: $phone', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Assigned To: $assignedTo', style: TextStyle(fontSize: 18)),
                      if (assignedTo.toLowerCase() == 'camp') ...[
                        const SizedBox(height: 8),
                        Text('Camp Name: $campName', style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Camp Location: $campLocation', style: TextStyle(fontSize: 18)),
                      ],
                      const SizedBox(height: 24),

                      // Edit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Allow user to edit the data again
                              isSubmitted = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Edit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Display the list of all roles added so far
            const Text(
              'All Roles:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Color.fromARGB(255, 0, 0, 0)),
            ),
            const SizedBox(height: 8),
            if (roles.isNotEmpty)
              for (var i = 0; i < roles.length; i++)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${roles[i]['name']}'),
                        Text('Phone: ${roles[i]['phone']}'),
                        Text('Assigned To: ${roles[i]['assignedTo']}'),
                        if (roles[i]['assignedTo']!.toLowerCase() == 'camp') ...[
                          Text('Camp Name: ${roles[i]['campName']}'),
                          Text('Camp Location: ${roles[i]['campLocation']}'),
                        ],
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => editRole(i),
                              child: const Text('Edit'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  roles.removeAt(i); // Remove role at index i
                                });
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
