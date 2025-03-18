import 'package:flutter/material.dart';
import 'package:resq/screens/familysurvay_home.dart';

class ESectionScreen extends StatefulWidget {
  final NeedAssessmentData data;

  const ESectionScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<ESectionScreen> createState() => _ESectionScreenState();
}

class _ESectionScreenState extends State<ESectionScreen> {
  // Controllers for each field in Section E
  late TextEditingController childrenEducationStatusController;
  late TextEditingController educationAssistanceRequiredController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing data for Section E
    childrenEducationStatusController = TextEditingController(text: widget.data.childrenEducationStatus);
    educationAssistanceRequiredController = TextEditingController(text: widget.data.educationAssistanceRequired);
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    childrenEducationStatusController.dispose();
    educationAssistanceRequiredController.dispose();
    super.dispose();
  }

  void saveData() {
    // Save the changes back into the NeedAssessmentData object
    widget.data.childrenEducationStatus = childrenEducationStatusController.text;
    widget.data.educationAssistanceRequired = educationAssistanceRequiredController.text;

    // For demonstration, you can handle saving by sending the data to a backend, local storage, etc.
    print("Section E Updated: Education Status: ${widget.data.childrenEducationStatus}, Assistance Required: ${widget.data.educationAssistanceRequired}");

    // Optionally, navigate back to the previous screen or the home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section E - Education'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Education',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: childrenEducationStatusController,
              decoration: const InputDecoration(
                labelText: '1. Are children in the household enrolled in school?',
                hintText: 'Yes/No',
              ),
            ),
            TextField(
              controller: educationAssistanceRequiredController,
              decoration: const InputDecoration(
                labelText: '2. Any specific education assistance required (e.g., study materials, digital devices, transportation)?',
                hintText: 'Yes/No/Specify',
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
