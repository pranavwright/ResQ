import 'package:flutter/material.dart';
import 'package:resq/screens/agriculture.dart';
import 'package:resq/screens/otp_screen.dart';

class Skill extends StatefulWidget {
  const Skill({super.key});

  @override
  _SkillState createState() => _SkillState();
}

class _SkillState extends State<Skill> {
  // List to hold data for multiple skill details
  List<Map<String, TextEditingController>> skillDetailsList = [];

  // Initialize one skill detail set
  @override
  void initState() {
    super.initState();
    _addNewSkillDetail();  // Add initial set of skill details
  }

  // Function to add a new set of text controllers for skill details
  void _addNewSkillDetail() {
    setState(() {
      skillDetailsList.add({
        'Name': TextEditingController(),
        'Present skill set': TextEditingController(),
        'Type of livelihood assistance required': TextEditingController(),
        ' Type of skilling assistance required': TextEditingController(),
      });
    });
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    for (var skillDetail in skillDetailsList) {
      skillDetail.values.forEach((controller) {
        controller.dispose();
      });
    }
    super.dispose();
  }

  // Function to navigate to the next page (you can replace `NextPage` with your actual next page)
  void _navigateToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Agriculture()),  // Navigate to the next page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
           Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/emp-status',
                  (route) => false,
                ); // Pops the current screen off the navigation stack
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your skills:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Dynamic form for each skill detail set
            Expanded(
              child: ListView.builder(
                itemCount: skillDetailsList.length,
                itemBuilder: (context, index) {
                  final skillDetails = skillDetailsList[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Skill 1
                          TextField(
                            controller: skillDetails['Name'],
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Skill 2
                          TextField(
                            controller: skillDetails['Present skill set'],
                            decoration: const InputDecoration(
                              labelText: 'Present skill set',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Skill 3
                          TextField(
                            controller: skillDetails['Type of livelihood assistance required'],
                            decoration: const InputDecoration(
                              labelText: 'Type of livelihood assistance required',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Skill 4
                          TextField(
                            controller: skillDetails['Type of skilling assistance required'],
                            decoration: const InputDecoration(
                              labelText: 'Type of skilling assistance required',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Add Button
            Center(
              child: ElevatedButton(
                onPressed: _addNewSkillDetail,
                child: const Text('Add Another child'),
              ),
            ),

            // Next Button to navigate to the next page
            Center(
              child: ElevatedButton(
                onPressed: _navigateToNextPage, // Navigate to next page
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
