import 'package:flutter/material.dart';
import 'package:resq/screens/d_section_screen.dart';
import 'package:resq/screens/familysurvay_home.dart';

class CSectionScreen extends StatefulWidget {
  final NeedAssessmentData data;

  const CSectionScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<CSectionScreen> createState() => _CSectionScreenState();
}

class _CSectionScreenState extends State<CSectionScreen> {
  // Controllers for Section C
  late TextEditingController healthInsuranceStatusController;
  late TextEditingController specialAssistanceRequiredController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing data for Section C
    healthInsuranceStatusController = TextEditingController(text: widget.data.healthInsuranceStatus);
    specialAssistanceRequiredController = TextEditingController(text: widget.data.specialAssistanceRequired);
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    healthInsuranceStatusController.dispose();
    specialAssistanceRequiredController.dispose();
    super.dispose();
  }

  void goToNextSection() {
    // Update the data object with the current section data
    widget.data.healthInsuranceStatus = healthInsuranceStatusController.text;
    widget.data.specialAssistanceRequired = specialAssistanceRequiredController.text;

    // Navigate to the next section (Section D)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DSectionScreen(data: widget.data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section C - Health'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: healthInsuranceStatusController,
              decoration: const InputDecoration(
                labelText: '1. Do you have health insurance coverage?',
                hintText: 'Yes/No',
              ),
            ),
            TextField(
              controller: specialAssistanceRequiredController,
              decoration: const InputDecoration(
                labelText: '2. Does any family member require special assistance?',
                hintText: 'Yes/No/Specify',
              ),
            ),
            const SizedBox(height: 20),

            // Button to go to the next section (Section D)
            ElevatedButton(
              onPressed: goToNextSection,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
