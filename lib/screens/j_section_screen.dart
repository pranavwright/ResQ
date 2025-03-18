import 'package:flutter/material.dart';
import 'package:resq/screens/familysurvay_home.dart';

class JSectionScreen extends StatefulWidget {
  final NeedAssessmentData data;

  const JSectionScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<JSectionScreen> createState() => _JSectionScreenState();
}

class _JSectionScreenState extends State<JSectionScreen> {
  // Controllers for each field in Section J
  late TextEditingController kudumbashreeMembershipController;
  late TextEditingController kudumbashreeSupportRequiredController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing data for Section J
    kudumbashreeMembershipController = TextEditingController(text: widget.data.kudumbashreeMembership);
    kudumbashreeSupportRequiredController = TextEditingController(text: widget.data.kudumbashreeSupportRequired);
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    kudumbashreeMembershipController.dispose();
    kudumbashreeSupportRequiredController.dispose();
    super.dispose();
  }

  void saveData() {
    // Save the changes back into the NeedAssessmentData object
    widget.data.kudumbashreeMembership = kudumbashreeMembershipController.text;
    widget.data.kudumbashreeSupportRequired = kudumbashreeSupportRequiredController.text;

    // For demonstration, you can handle saving by sending the data to a backend, local storage, etc.
    print("Section J Updated: Kudumbashree Membership: ${widget.data.kudumbashreeMembership}, Support Required: ${widget.data.kudumbashreeSupportRequired}");

    // Optionally, navigate back to the previous screen or the home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section J - Kudumbashree'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kudumbashree',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: kudumbashreeMembershipController,
              decoration: const InputDecoration(
                labelText: '1. Is the household a member of Kudumbashree?',
                hintText: 'Yes/No',
              ),
            ),
            TextField(
              controller: kudumbashreeSupportRequiredController,
              decoration: const InputDecoration(
                labelText: '2. Any specific support or requirements needed from Kudumbashree?',
                hintText: 'E.g., training, financial support, etc.',
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
