import 'package:flutter/material.dart';

class CollectionPoint extends StatefulWidget {
  const CollectionPoint({super.key});

  @override
  _CollectionPointState createState() => _CollectionPointState();
}

class _CollectionPointState extends State<CollectionPoint> {
  // Define controllers for each text field
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();

  // List to store added collection points
  List<Map<String, String>> collectionPoints = [];

  // Flag to track if we are editing a collection point
  int? editingIndex;

  // Flag to control the visibility of the form
  bool _showForm = false;

  // Function to handle form submission
  void _submitForm() {
    final name = nameController.text;
    final location = locationController.text;
    final description = descriptionController.text;
    final capacity = capacityController.text;

    if (name.isEmpty ||
        location.isEmpty ||
        description.isEmpty ||
        capacity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields!')),
      );
      return; // Exit the function if fields are empty
    }

    setState(() {
      if (editingIndex == null) {
        collectionPoints.add({
          'name': name,
          'location': location,
          'description': description,
          'capacity': capacity,
        });
      } else {
        collectionPoints[editingIndex!] = {
          'name': name,
          'location': location,
          'description': description,
          'capacity': capacity,
        };
        editingIndex = null; // Reset editing mode
      }
    });

    // Clear the form fields after submission
    nameController.clear();
    locationController.clear();
    descriptionController.clear();
    capacityController.clear();

    // Print the data to the debug console
    printCollectionPoints();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          editingIndex == null
              ? 'Collection Point added successfully!'
              : 'Collection Point updated successfully!',
        ),
      ),
    );
  }

  void _editCollectionPoint(int index) {
    setState(() {
      editingIndex = index;
      nameController.text = collectionPoints[index]['name']!;
      locationController.text = collectionPoints[index]['location']!;
      descriptionController.text = collectionPoints[index]['description']!;
      capacityController.text = collectionPoints[index]['capacity']!;
    });
  }

  void _deleteCollectionPoint(int index) {
    setState(() {
      collectionPoints.removeAt(index);
    });
    printCollectionPoints();
  }

  void printCollectionPoints() {
    print('Current Collection Points:');
    for (var point in collectionPoints) {
      print(
        'Name: ${point['name']}, Location: ${point['location']}, Description: ${point['description']}, Capacity: ${point['capacity']}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Black background for the app bar
        title: const Text(
          'Add Collection Point',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // White color for text
          ),
        ),
        centerTitle: true, // Center the title
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // White arrow icon
          onPressed: () {
            Navigator.pop(context); // Handle back button press
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Use SingleChildScrollView to prevent overflow on small screens
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Show the form when _showForm is true
              if (_showForm) ...[
                // Collection Point Name Field
                _buildTextField(
                  controller: nameController,
                  label: 'Collection Point Name',
                  icon: Icons.location_city,
                ),
                const SizedBox(height: 16),

                // Location Field
                _buildTextField(
                  controller: locationController,
                  label: 'Location',
                  icon: Icons.place,
                ),
                const SizedBox(height: 16),

                // Description Field
                _buildTextField(
                  controller: descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                ),
                const SizedBox(height: 16),

                // Capacity Field
                _buildTextField(
                  controller: capacityController,
                  label: 'Capacity',
                  icon: Icons.people,
                  keyboardType:
                      TextInputType.number, // Only numbers for capacity
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
                const SizedBox(height: 20),
              ],

              // Display the added collection points
              const Text(
                'Collection Points:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (collectionPoints.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: collectionPoints.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                          collectionPoints[index]['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Location: ${collectionPoints[index]['location']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editCollectionPoint(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCollectionPoint(index),
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
      // Floating Action Button to add a new collection point
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showForm = !_showForm; // Toggle form visibility
          });
        },
        child: Icon(
          _showForm ? Icons.cancel : Icons.add, // Show a plus or cancel icon
          color: Colors.white, // Set the icon color to white
        ),
        backgroundColor:
            Colors.black, // Set the button background color to black
        tooltip: _showForm ? 'Cancel' : 'Add Collection Point',
      ),
    );
  }

  // Helper method to build TextField widgets with icons and styles
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );
  }
}
