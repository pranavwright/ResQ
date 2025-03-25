import 'package:flutter/material.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';

class CampStatusScreen extends StatefulWidget {
  const CampStatusScreen({super.key});

  @override
  _CampStatusScreenState createState() => _CampStatusScreenState();
}

class _CampStatusScreenState extends State<CampStatusScreen> {
  // Define controllers for each text field
  final TextEditingController campNameController = TextEditingController();
  final TextEditingController campStatusController = TextEditingController();
  final TextEditingController campLocationController = TextEditingController();
  final TextEditingController campIdContorller = TextEditingController();

  List<Map<String, String>> camps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCamps().then((_) {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    });
  }

  // Flag to track if we are editing a camp
  int? editingIndex;

  // Flag to control the visibility of the form
  bool _showForm = false;

  Future<void> _fetchCamps() async {
    try {
      final response = await TokenHttp().get(
        '/disaster/getCamps?disasterId=${AuthService().getDisasterId()}',
      );
      print(response);
      if (mounted) {
        setState(() {
          camps = List<Map<String, String>>.from(
            response.map(
              (camp) => {
                'name': camp['name']?.toString() ?? '',
                'status': camp['status']?.toString() ?? '',
                'location': camp['location']?.toString() ?? '',
                '_id': camp['_id']?.toString() ?? '',
                'capacity': camp['capacity']?.toString() ?? '',
              },
            ),
          );
        });
      }
    } catch (e) {
      print('Error fetching camps: $e');
    }
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });
    final campName = campNameController.text;
    final campStatus = campStatusController.text;
    final campLocation = campLocationController.text;
    final campId = campIdContorller.text;

    if (campName.isEmpty || campStatus.isEmpty || campLocation.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill out all fields!')),
        );
      }
      return;
    }

    _fetchCamps().then((_) {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    });

    try {
      await TokenHttp().post('/disaster/postCamp', {
        'name': campName,
        '_id': campId,
        'status': campStatus,
        'location': campLocation,
        'disasterId': AuthService().getDisasterId(),
      });

      if (mounted) {
        campNameController.clear();
        campStatusController.clear();
        campLocationController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              editingIndex == null
                  ? 'Camp added successfully!'
                  : 'Camp updated successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error saving camp: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _inActiveCamp(int index) async {
    final campId = camps[index]['_id'];
    setState(() {
      _isLoading = true;
    });
    try {
      await TokenHttp().post('/disaster/postCamp', {
        '_id': campId,
        'status': 'inactive',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camp inactivated successfully!')),
        );
        _fetchCamps().then((_) {
          if (mounted)
            setState(() {
              _isLoading = false;
            });
        });
      }
    } catch (e) {
      print('Error deleting camp: $e');
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    campNameController.dispose();
    campStatusController.dispose();
    campLocationController.dispose();
    campIdContorller.dispose();
    super.dispose();
  }

  void printCamps() {
    print('Current Camps:');
    for (var camp in camps) {
      print(
        'Name: ${camp['name']}, Status: ${camp['status']}, Location: ${camp['location']}, Capacity: ${camp['capacity']}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Black background for the app bar
        title: const Text(
          'Add Camps',
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
                // Camp Name Field
                _buildTextField(
                  controller: campNameController,
                  label: 'Camp Name',
                  icon: Icons.location_city,
                ),

                // Camp Status Field
                _buildTextField(
                  controller: campStatusController,
                  label: 'Camp Status',
                  icon: Icons.info,
                ),
                const SizedBox(height: 16),

                // Camp Location Field
                _buildTextField(
                  controller: campLocationController,
                  label: 'Camp Location',
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

              // Display the added camps
              const Text(
                'Camps:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (camps.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: camps.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                          camps[index]['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Status: ${camps[index]['status']}, Location: ${camps[index]['location']}, Capacity: ${camps[index]['capacity']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _submitForm(),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.warning,
                                color: Colors.orange,
                              ),
                              onPressed: () => _inActiveCamp(index),
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
      // Floating Action Button to add a new camp
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
