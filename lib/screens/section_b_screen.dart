import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';

class BSectionScreen extends StatefulWidget {
  final NeedAssessmentData data;

  const BSectionScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<BSectionScreen> createState() => _BSectionScreenState();
}

class _BSectionScreenState extends State<BSectionScreen> {
  final TextEditingController anganwadiStatusController = TextEditingController();
  final TextEditingController childrenMalnutritionStatusController = TextEditingController();
  final TextEditingController foodSecurityAdditionalInfoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    anganwadiStatusController.text = widget.data.anganwadiStatus;
    childrenMalnutritionStatusController.text = widget.data.childrenMalnutritionStatus;
    foodSecurityAdditionalInfoController.text = widget.data.foodSecurityAdditionalInfo;
  }

  void _goToNextSection() {
    widget.data.anganwadiStatus = anganwadiStatusController.text;
    widget.data.childrenMalnutritionStatus = childrenMalnutritionStatusController.text;
    widget.data.foodSecurityAdditionalInfo = foodSecurityAdditionalInfoController.text;

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CSectionScreen(data: widget.data),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Section B - Food Security & Nutrition")),
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
            const Text(
              'Family Members:',
              style: TextStyle(fontSize: 18),
            ),
            // Display members and allow editing
            for (var i = 0; i < widget.data.members.length; i++)
              MemberCard(index: i + 1, member: widget.data.members[i]),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _goToNextSection,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  final int index;
  final Member member;

  MemberCard({Key? key, required this.index, required this.member}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Member #$index',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: TextEditingController(text: member.name),
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: TextEditingController(text: member.age),
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            TextField(
              controller: TextEditingController(text: member.relationship),
              decoration: const InputDecoration(labelText: 'Relationship to Household Head'),
            ),
            TextField(
              controller: TextEditingController(text: member.gender),
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
          ],
        ),
      ),
    );
  }
}
