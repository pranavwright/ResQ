import 'package:flutter/material.dart';
import 'package:resq/screens/familysurvay_home.dart';

class KSectionScreen extends StatefulWidget {
  final NeedAssessmentData data;

  const KSectionScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<KSectionScreen> createState() => _KSectionScreenState();
}

class _KSectionScreenState extends State<KSectionScreen> {
  // Controllers for Section K
  late TextEditingController additionalSupportRequiredController;

  @override
  void initState() {
    super.initState();
    // Initialize controller with the existing data for Section K
    additionalSupportRequiredController = TextEditingController(text: widget.data.additionalSupportRequired);
  }

  @override
  void dispose() {
    // Dispose controller to avoid memory leaks
    additionalSupportRequiredController.dispose();
    super.dispose();
  }

  void saveData() {
    // Save the changes back into the NeedAssessmentData object
    widget.data.additionalSupportRequired = additionalSupportRequiredController.text;

    // For demonstration, you can handle saving by sending the data to a backend, local storage, etc.
    print("Section K Updated: Additional Support Required: ${widget.data.additionalSupportRequired}");

    // Optionally, navigate back to the previous screen or the home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section K - Additional Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Support',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: additionalSupportRequiredController,
              decoration: const InputDecoration(
                labelText: '1. Any additional support required?',
                hintText: 'E.g., financial support, rehabilitation, etc.',
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
