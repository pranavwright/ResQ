import 'package:flutter/material.dart';
import 'package:resq/screens/familysurvay_home.dart';

class ISectionScreen extends StatefulWidget {
  final NeedAssessmentData data;

  const ISectionScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<ISectionScreen> createState() => _ISectionScreenState();
}

class _ISectionScreenState extends State<ISectionScreen> {
  // Controllers for each field in Section I
  late TextEditingController specialCategoryStatusController;
  late TextEditingController assistanceRequiredController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing data for Section I
    specialCategoryStatusController = TextEditingController(text: widget.data.specialCategoryStatus);
    assistanceRequiredController = TextEditingController(text: widget.data.assistanceRequired);
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    specialCategoryStatusController.dispose();
    assistanceRequiredController.dispose();
    super.dispose();
  }

  void saveData() {
    // Save the changes back into the NeedAssessmentData object
    widget.data.specialCategoryStatus = specialCategoryStatusController.text;
    widget.data.assistanceRequired = assistanceRequiredController.text;

    // For demonstration, you can handle saving by sending the data to a backend, local storage, etc.
    print("Section I Updated: Special Category Status: ${widget.data.specialCategoryStatus}, Assistance Required: ${widget.data.assistanceRequired}");

    // Optionally, navigate back to the previous screen or the home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section I - Special Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Special Category',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: specialCategoryStatusController,
              decoration: const InputDecoration(
                labelText: '1. Does the household belong to any special category?',
                hintText: 'E.g., Differently-abled, Elderly, etc.',
              ),
            ),
            TextField(
              controller: assistanceRequiredController,
              decoration: const InputDecoration(
                labelText: '2. What specific assistance is required?',
                hintText: 'E.g., Mobility aids, Financial support, etc.',
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
