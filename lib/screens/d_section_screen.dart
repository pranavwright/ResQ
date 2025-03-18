import 'package:flutter/material.dart';
import 'package:resq/screens/familysurvay_home.dart';

class DSectionScreen extends StatefulWidget {
  final NeedAssessmentData data;

  const DSectionScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<DSectionScreen> createState() => _DSectionScreenState();
}

class _DSectionScreenState extends State<DSectionScreen> {
  // Controllers for each field in Section D
  late TextEditingController shelterTypeController;
  late TextEditingController accommodationStatusController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing data for Section D
    shelterTypeController = TextEditingController(text: widget.data.shelterType);
    accommodationStatusController = TextEditingController(text: widget.data.accommodationStatus);
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    shelterTypeController.dispose();
    accommodationStatusController.dispose();
    super.dispose();
  }

  void saveData() {
    // Save the changes back into the NeedAssessmentData object
    widget.data.shelterType = shelterTypeController.text;
    widget.data.accommodationStatus = accommodationStatusController.text;

    // For demonstration, you can handle saving by sending the data to a backend, local storage, etc.
    print("Section D Updated: Shelter Type: ${widget.data.shelterType}, Accommodation Status: ${widget.data.accommodationStatus}");

    // Optionally, navigate back to the previous screen or the home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section D - Shelter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shelter',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: shelterTypeController,
              decoration: const InputDecoration(
                labelText: '1. Type of house (e.g., Permanent, Paadi)',
                hintText: 'Enter house type',
              ),
            ),
            TextField(
              controller: accommodationStatusController,
              decoration: const InputDecoration(
                labelText: '2. Accommodation in the aftermath of the disaster',
                hintText: 'Enter accommodation status (e.g., Relief Camps, Friends/Relatives)',
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveData,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
