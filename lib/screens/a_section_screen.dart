import 'package:flutter/material.dart';
import 'package:resq/screens/familysurvay_home.dart';
import '../main.dart'; // or wherever NeedAssessmentData is defined

class ASectionScreen extends StatefulWidget {
  final NeedAssessmentData data;
  const ASectionScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<ASectionScreen> createState() => _ASectionScreenState();
}

class _ASectionScreenState extends State<ASectionScreen> {
  // For demonstration, let's use controllers
  final TextEditingController villageWardController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController uniqueHouseholdIdController = TextEditingController();
  final TextEditingController householdHeadController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactNoController = TextEditingController();
  final TextEditingController rationCardController = TextEditingController();
  final TextEditingController rationCategoryController = TextEditingController();
  final TextEditingController casteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If user is coming back (navigating backwards), fill controllers with existing data
    villageWardController.text = widget.data.villageWard;
    houseNumberController.text = widget.data.houseNumber;
    uniqueHouseholdIdController.text = widget.data.uniqueHouseholdId;
    householdHeadController.text = widget.data.householdHead;
    addressController.text = widget.data.address;
    contactNoController.text = widget.data.contactNo;
    rationCardController.text = widget.data.rationCardNo;
    rationCategoryController.text = widget.data.rationCategory;
    casteController.text = widget.data.caste;
  }

  @override
  void dispose() {
    // Always dispose TextEditingControllers
    villageWardController.dispose();
    houseNumberController.dispose();
    uniqueHouseholdIdController.dispose();
    householdHeadController.dispose();
    addressController.dispose();
    contactNoController.dispose();
    rationCardController.dispose();
    rationCategoryController.dispose();
    casteController.dispose();
    super.dispose();
  }

  void saveAndNext() {
    // Save user input into widget.data
    widget.data.villageWard = villageWardController.text.trim();
    widget.data.houseNumber = houseNumberController.text.trim();
    widget.data.uniqueHouseholdId = uniqueHouseholdIdController.text.trim();
    widget.data.householdHead = householdHeadController.text.trim();
    widget.data.address = addressController.text.trim();
    widget.data.contactNo = contactNoController.text.trim();
    widget.data.rationCardNo = rationCardController.text.trim();
    widget.data.rationCategory = rationCategoryController.text.trim();
    widget.data.caste = casteController.text.trim();

    // Move to Section B, passing the same data
    Navigator.pushNamed(
      context,
      '/sectionB',
      arguments: widget.data,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section A - Household Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Household Profile (Section A)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: villageWardController,
              decoration: const InputDecoration(
                labelText: '1. Village/Ward',
              ),
            ),
            TextField(
              controller: houseNumberController,
              decoration: const InputDecoration(
                labelText: '2. House Number',
              ),
            ),
            TextField(
              controller: uniqueHouseholdIdController,
              decoration: const InputDecoration(
                labelText: '3. Unique household ID',
              ),
            ),
            TextField(
              controller: householdHeadController,
              decoration: const InputDecoration(
                labelText: '4. Household Head',
              ),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: '5. Address',
              ),
            ),
            TextField(
              controller: contactNoController,
              decoration: const InputDecoration(
                labelText: '6. Contact No.',
              ),
            ),
            TextField(
              controller: rationCardController,
              decoration: const InputDecoration(
                labelText: '7. Ration Card No.',
              ),
            ),
            TextField(
              controller: rationCategoryController,
              decoration: const InputDecoration(
                labelText: '8. Ration Category (White/Yellow/Pink?)',
              ),
            ),
            TextField(
              controller: casteController,
              decoration: const InputDecoration(
                labelText: '9. Caste of Household Head',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveAndNext,
              child: const Text('Next'),
            )
          ],
        ),
      ),
    );
  }
}
