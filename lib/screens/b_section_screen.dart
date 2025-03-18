import 'package:flutter/material.dart';
import 'package:resq/screens/c_section_screen.dart';
import 'package:resq/screens/familysurvay_home.dart';

class BSectionScreen extends StatefulWidget {
  final NeedAssessmentData data;

  const BSectionScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<BSectionScreen> createState() => _BSectionScreenState();
}

class _BSectionScreenState extends State<BSectionScreen> {
  // Controllers for Section B
  late TextEditingController anganwadiStatusController;
  late TextEditingController childrenMalnutritionStatusController;
  late TextEditingController foodSecurityAdditionalInfoController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing data for Section B
    anganwadiStatusController = TextEditingController(text: widget.data.anganwadiStatus);
    childrenMalnutritionStatusController = TextEditingController(text: widget.data.childrenMalnutritionStatus);
    foodSecurityAdditionalInfoController = TextEditingController(text: widget.data.foodSecurityAdditionalInfo);
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    anganwadiStatusController.dispose();
    childrenMalnutritionStatusController.dispose();
    foodSecurityAdditionalInfoController.dispose();
    super.dispose();
  }

  void goToNextSection() {
    // Update the data object with the current section data
    widget.data.anganwadiStatus = anganwadiStatusController.text;
    widget.data.childrenMalnutritionStatus = childrenMalnutritionStatusController.text;
    widget.data.foodSecurityAdditionalInfo = foodSecurityAdditionalInfoController.text;

    // Navigate to the next section (Section C)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CSectionScreen(data: widget.data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section B - Food Security & Nutrition'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Food Security & Nutrition',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: anganwadiStatusController,
              decoration: const InputDecoration(
                labelText: '1. Is the Anganwadi damaged?',
                hintText: 'Yes/No',
              ),
            ),
            TextField(
              controller: childrenMalnutritionStatusController,
              decoration: const InputDecoration(
                labelText: '2. Are there any children with malnutrition?',
                hintText: 'Yes/No',
              ),
            ),
            TextField(
              controller: foodSecurityAdditionalInfoController,
              decoration: const InputDecoration(
                labelText: '3. Any other information related to food security?',
                hintText: 'E.g., food distribution, storage issues, etc.',
              ),
            ),
            const SizedBox(height: 20),

            // Button to go to the next section (Section C)
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
