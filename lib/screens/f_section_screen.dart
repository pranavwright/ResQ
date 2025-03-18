import 'package:flutter/material.dart';
import 'package:resq/screens/familysurvay_home.dart';

class FSectionScreen extends StatefulWidget {
  final NeedAssessmentData data;

  const FSectionScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<FSectionScreen> createState() => _FSectionScreenState();
}

class _FSectionScreenState extends State<FSectionScreen> {
  // Controllers for each field in Section F
  late TextEditingController livelihoodStatusController;
  late TextEditingController livelihoodAssistanceRequiredController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing data for Section F
    livelihoodStatusController = TextEditingController(text: widget.data.livelihoodStatus);
    livelihoodAssistanceRequiredController = TextEditingController(text: widget.data.livelihoodAssistanceRequired);
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    livelihoodStatusController.dispose();
    livelihoodAssistanceRequiredController.dispose();
    super.dispose();
  }

  void saveData() {
    // Save the changes back into the NeedAssessmentData object
    widget.data.livelihoodStatus = livelihoodStatusController.text;
    widget.data.livelihoodAssistanceRequired = livelihoodAssistanceRequiredController.text;

    // For demonstration, you can handle saving by sending the data to a backend, local storage, etc.
    print("Section F Updated: Livelihood Status: ${widget.data.livelihoodStatus}, Assistance Required: ${widget.data.livelihoodAssistanceRequired}");

    // Optionally, navigate back to the previous screen or the home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section F - Livelihood'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Livelihood',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: livelihoodStatusController,
              decoration: const InputDecoration(
                labelText: '1. Employment Status',
                hintText: 'Employed/Self-employed/Unemployed/Other',
              ),
            ),
            TextField(
              controller: livelihoodAssistanceRequiredController,
              decoration: const InputDecoration(
                labelText: '2. Livelihood Assistance Required',
                hintText: 'Specify assistance needed (e.g., skill development, financial support)',
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
