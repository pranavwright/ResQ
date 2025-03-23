import 'package:flutter/material.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';

class CollectionPointScreen extends StatefulWidget {
  const  CollectionPointScreen({super.key});

  @override
  _CollectionPointScreenState createState() => _CollectionPointScreenState();
}

class _CollectionPointScreenState extends State<CollectionPointScreen> {
  // Define controllers for each text field
  final TextEditingController collectionPointNameController = TextEditingController();
  final TextEditingController collectionPointStatusController = TextEditingController();
  final TextEditingController collectionPointLocationController = TextEditingController();
  final TextEditingController collectionPointIdController = TextEditingController();

  List<Map<String, String>> collectionPoints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchcollectionPoints().then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Flag to track if we are editing a collectionPoint
  int? editingIndex;

  // Flag to control the visibility of the form
  bool _showForm = false;

  Future<void> _fetchcollectionPoints() async {
    try {
      final response = await TokenHttp().get(
        '/disaster/getCollectionPoints?disasterId=${AuthService().getDisasterId()}',
      );
      print(response);
      if (mounted) {
        setState(() {
          collectionPoints = List<Map<String, String>>.from(
            response.map(
              (collectionPoint) => {
                'name': collectionPoint['name']?.toString() ?? '',
                'status': collectionPoint['status']?.toString() ?? '',
                'location': collectionPoint['location']?.toString() ?? '',
                '_id': collectionPoint['_id']?.toString() ?? '',
                'capacity': collectionPoint['capacity']?.toString() ?? '',
              },
            ),
          );
        });
      }
    } catch (e) {
      print('Error fetching collectionPoints: $e');
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching collectionPoints: $e')));
      }

    }
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });
    final collectionPointName = collectionPointNameController.text;
    final collectionPointStatus = collectionPointStatusController.text;
    final collectionPointLocation = collectionPointLocationController.text;
    final collectionPointId = collectionPointIdController.text;

    if (collectionPointName.isEmpty || collectionPointStatus.isEmpty || collectionPointLocation.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill out all fields!')),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await TokenHttp().post('/disaster/postCollectionPoint', {
        'name': collectionPointName,
        '_id': collectionPointId,
        'status': collectionPointStatus,
        'location': collectionPointLocation,
        'disasterId': AuthService().getDisasterId(),
      });

      if (mounted) {
        collectionPointNameController.clear();
        collectionPointStatusController.clear();
        collectionPointLocationController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              editingIndex == null
                  ? 'collectionPoint added successfully!'
                  : 'collectionPoint updated successfully!',
            ),
          ),
        );
         _fetchcollectionPoints().then((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    } catch (e) {
      print('Error saving collectionPoint: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() {
          _isLoading = false;
        });
      }

    }
  }

  void _inActivecollectionPoint(int index) async {
    final collectionPointId = collectionPoints[index]['_id'];
    setState(() {
      _isLoading = true;
    });
    try {
      await TokenHttp().post('/disaster/postCollectionPoint', {
        '_id': collectionPointId,
        'status': 'inactive',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('collectionPoint inactivated successfully!')),
        );
        _fetchcollectionPoints().then((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    } catch (e) {
      print('Error deleting collectionPoint: $e');
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error inactivating collectionPoint: $e')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    collectionPointNameController.dispose();
    collectionPointStatusController.dispose();
    collectionPointLocationController.dispose();
    collectionPointIdController.dispose();
    super.dispose();
  }

  void printcollectionPoints() {
    print('Current collectionPoints:');
    for (var collectionPoint in collectionPoints) {
      print(
        'Name: ${collectionPoint['name']}, Status: ${collectionPoint['status']}, Location: ${collectionPoint['location']}, Capacity: ${collectionPoint['capacity']}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Black background for the app bar
        title: const Text(
          'Add collectionPoints',
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
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink(),
              const SizedBox(height: 16),

              // Show the form if _showForm is true
              if (_showForm) ...[
                // collectionPoint Name Field
                _buildTextField(
                  controller: collectionPointNameController,
                  label: 'collectionPoint Name',
                  icon: Icons.location_city,
                ),
                const SizedBox(height: 16),

                // collectionPoint Status Field
                _buildTextField(
                  controller: collectionPointStatusController,
                  label: 'collectionPoint Status',
                  icon: Icons.info,
                ),
                const SizedBox(height: 16),

                // collectionPoint Location Field
                _buildTextField(
                  controller: collectionPointLocationController,
                  label: 'collectionPoint Location',
                  icon: Icons.place,
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

              // Display the added collectionPoints
              const Text(
                'collectionPoints:',
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
                        subtitle: Text('Status: ${collectionPoints[index]['status']}, Location: ${collectionPoints[index]['location']}, Capacity: ${collectionPoints[index]['capacity']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                setState(() {
                                  _showForm = true;
                                  editingIndex = index;
                                  collectionPointNameController.text = collectionPoints[index]['name']!;
                                  collectionPointStatusController.text =
                                      collectionPoints[index]['status']!;
                                  collectionPointLocationController.text =
                                      collectionPoints[index]['location']!;
                                  collectionPointIdController.text = collectionPoints[index]['_id']!;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.warning,
                                color: Colors.orange,
                              ),
                              onPressed: () => _inActivecollectionPoint(index),
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
      // Floating Action Button to add a new collectionPoint
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showForm = !_showForm; // Toggle form visibility
            if (!_showForm) {
              // Clear the form and reset editing index when hiding form.
              collectionPointNameController.clear();
              collectionPointStatusController.clear();
              collectionPointLocationController.clear();
              collectionPointIdController.clear();
              editingIndex = null;
            }
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