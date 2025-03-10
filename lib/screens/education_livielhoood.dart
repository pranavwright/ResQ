import 'package:flutter/material.dart';

class EducationLivielhoood extends StatefulWidget {
  const EducationLivielhoood({super.key});

  @override
  _EducationLivielhooodState createState() => _EducationLivielhooodState();
}

class _EducationLivielhooodState extends State<EducationLivielhoood> {
  // List to hold data for multiple children
  List<Map<String, dynamic>> childrenList = [];

  // Function to add a new child details form
  void _addNewChild() {
    setState(() {
      childrenList.add({
        'name': TextEditingController(),
        'classCourse': TextEditingController(),
        'schoolInstitution': TextEditingController(),
        'otherRequirements': TextEditingController(),
        'dropoutAnswer': null,  // String value for radio button answers
        'shiftSchoolAnswer': null,  // String value for radio button answers
        'modeOfEducation': null,  // String value for radio button answers
        'studyMaterialsAnswer': null,  // String value for radio button answers
        'digitalDevicesAnswer': null,  // String value for radio button answers
        'transportationAnswer': null,  // String value for radio button answers
      });
    });
  }

  // Dispose controllers to avoid memory leaks
  @override
  void dispose() {
    for (var child in childrenList) {
      child.values.forEach((controller) {
        if (controller is TextEditingController) {
          controller.dispose();
        }
      });
    }
    super.dispose();
  }

  // Function to navigate to the next page
  void _navigateToNextPage() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/incomandlose',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education and Livelihood'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/shelter',
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(  // Wrap entire page in SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Details of family members requiring special assistance:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Dynamic form for each child
            // ListView.builder is no longer wrapped inside the SingleChildScrollView
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // Disable internal scrolling of ListView
              itemCount: childrenList.length,
              itemBuilder: (context, index) {
                final child = childrenList[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Field
                        TextField(
                          controller: child['name'],
                          decoration: const InputDecoration(
                            labelText: 'Name of Child',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Class/Course Field
                        TextField(
                          controller: child['classCourse'],
                          decoration: const InputDecoration(
                            labelText: 'Class/Course',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // School/Institution Field
                        TextField(
                          controller: child['schoolInstitution'],
                          decoration: const InputDecoration(
                            labelText: 'School/Institution',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Dropout Radio Button
                        const Text('Has the child dropped out?'),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Yes',
                              groupValue: child['dropoutAnswer'],
                              onChanged: (value) {
                                setState(() {
                                  child['dropoutAnswer'] = value;
                                });
                              },
                            ),
                            const Text('Yes'),
                            Radio<String>(
                              value: 'No',
                              groupValue: child['dropoutAnswer'],
                              onChanged: (value) {
                                setState(() {
                                  child['dropoutAnswer'] = value;
                                });
                              },
                            ),
                            const Text('No'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Willing to Shift to Another School
                        const Text('Are you willing to shift to another school?'),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Yes',
                              groupValue: child['shiftSchoolAnswer'],
                              onChanged: (value) {
                                setState(() {
                                  child['shiftSchoolAnswer'] = value;
                                });
                              },
                            ),
                            const Text('Yes'),
                            Radio<String>(
                              value: 'No',
                              groupValue: child['shiftSchoolAnswer'],
                              onChanged: (value) {
                                setState(() {
                                  child['shiftSchoolAnswer'] = value;
                                });
                              },
                            ),
                            const Text('No'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Preferred Mode of Education (Regular or Open)
                        const Text('Preferred Mode of Education:'),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Regular',
                              groupValue: child['modeOfEducation'],
                              onChanged: (value) {
                                setState(() {
                                  child['modeOfEducation'] = value;
                                });
                              },
                            ),
                            const Text('Regular (R)'),
                            Radio<String>(
                              value: 'Open',
                              groupValue: child['modeOfEducation'],
                              onChanged: (value) {
                                setState(() {
                                  child['modeOfEducation'] = value;
                                });
                              },
                            ),
                            const Text('Open (O)'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Study Materials Radio Button (Yes or No)
                        const Text('Does the child have study materials?'),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Yes',
                              groupValue: child['studyMaterialsAnswer'],
                              onChanged: (value) {
                                setState(() {
                                  child['studyMaterialsAnswer'] = value;
                                });
                              },
                            ),
                            const Text('Yes'),
                            Radio<String>(
                              value: 'No',
                              groupValue: child['studyMaterialsAnswer'],
                              onChanged: (value) {
                                setState(() {
                                  child['studyMaterialsAnswer'] = value;
                                });
                              },
                            ),
                            const Text('No'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Digital Devices Radio Button (Yes or No)
                        const Text('Does the child have digital devices?'),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Yes',
                              groupValue: child['digitalDevicesAnswer'],
                              onChanged: (value) {
                                setState(() {
                                  child['digitalDevicesAnswer'] = value;
                                });
                              },
                            ),
                            const Text('Yes'),
                            Radio<String>(
                              value: 'No',
                              groupValue: child['digitalDevicesAnswer'],
                              onChanged: (value) {
                                setState(() {
                                  child['digitalDevicesAnswer'] = value;
                                });
                              },
                            ),
                            const Text('No'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Transportation Radio Button (Yes or No)
                        const Text('Does the child have access to transportation?'),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Yes',
                              groupValue: child['transportationAnswer'],
                              onChanged: (value) {
                                setState(() {
                                  child['transportationAnswer'] = value;
                                });
                              },
                            ),
                            const Text('Yes'),
                            Radio<String>(
                              value: 'No',
                              groupValue: child['transportationAnswer'],
                              onChanged: (value) {
                                setState(() {
                                  child['transportationAnswer'] = value;
                                });
                              },
                            ),
                            const Text('No'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Any Other Specified Requirements
                        TextField(
                          controller: child['otherRequirements'],
                          decoration: const InputDecoration(
                            labelText: 'Any Other Specified Requirement',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Button to Add Members at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: _addNewChild, // Add a new child form
                child: const Text("Add Members"),
              ),
            ),
            const SizedBox(height: 16),

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
