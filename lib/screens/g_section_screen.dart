import 'package:flutter/material.dart';
import 'package:resq/screens/familysurvay_home.dart';

class GSectionScreen extends StatefulWidget {
  final NeedAssessmentData data;

  const GSectionScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<GSectionScreen> createState() => _GSectionScreenState();
}

class _GSectionScreenState extends State<GSectionScreen> {
  // Controllers for each field in Section G
  late TextEditingController agriculturalLossController;
  late TextEditingController storedCropsLossController;
  late TextEditingController equipmentLossController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing data for Section G
    agriculturalLossController = TextEditingController(text: widget.data.agriculturalLoss);
    storedCropsLossController = TextEditingController(text: widget.data.storedCropsLoss);
    equipmentLossController = TextEditingController(text: widget.data.equipmentLoss);
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    agriculturalLossController.dispose();
    storedCropsLossController.dispose();
    equipmentLossController.dispose();
    super.dispose();
  }

  void saveData() {
    // Save the changes back into the NeedAssessmentData object
    widget.data.agriculturalLoss = agriculturalLossController.text;
    widget.data.storedCropsLoss = storedCropsLossController.text;
    widget.data.equipmentLoss = equipmentLossController.text;

    // For demonstration, you can handle saving by sending the data to a backend, local storage, etc.
    print("Section G Updated: Agricultural Loss: ${widget.data.agriculturalLoss}, Stored Crops Loss: ${widget.data.storedCropsLoss}, Equipment Loss: ${widget.data.equipmentLoss}");

    // Optionally, navigate back to the previous screen or the home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section G - Agriculture and Allied'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agriculture and Allied',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: agriculturalLossController,
              decoration: const InputDecoration(
                labelText: '1. Loss of agricultural land (area)',
                hintText: 'Enter area of loss',
              ),
            ),
            TextField(
              controller: storedCropsLossController,
              decoration: const InputDecoration(
                labelText: '2. Loss of stored crops (quantity)',
                hintText: 'Enter quantity of loss',
              ),
            ),
            TextField(
              controller: equipmentLossController,
              decoration: const InputDecoration(
                labelText: '3. Loss of equipment/tools',
                hintText: 'Enter lost items',
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
