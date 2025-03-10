import 'package:flutter/material.dart';
import 'package:resq/screens/foodand_health.dart';

class AddMembers extends StatefulWidget {
  const AddMembers({super.key});

  @override
  _AddMembersState createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  // List to hold data for multiple member details
  List<Map<String, dynamic>> memberDetailsList = [];

  // Initialize one member detail set
  @override
  void initState() {
    super.initState();
    _addNewMemberDetail();  // Add initial set of member details
  }

  // Function to add a new set of text controllers for member details
  void _addNewMemberDetail() {
    setState(() {
      memberDetailsList.add({
        'Name:': TextEditingController(),
        'Age:': TextEditingController(),
        'Gender:': 'Male',  // Default value (String) for dropdown
        'Position on the family:': TextEditingController(),
        'Material status:': 'Single',  // Default value (String) for dropdown
        'L/D/M:': TextEditingController(),
        'Adhaar No:': TextEditingController(),
      });
    });
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    for (var memberDetail in memberDetailsList) {
      memberDetail.values.whereType<TextEditingController>().forEach((controller) {
        controller.dispose();
      });
    }
    super.dispose();
  }

  // Function to navigate back to the previous screen
  void _goBack() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/otp',
      (route) => false,
    );
  }

  // Function to navigate to the next screen
  void _goNext() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FoodandHealth()), // Navigate to the NextPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Members'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),  // Back arrow icon
          onPressed: _goBack, // Calls the go back function
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Familymember Details:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Dynamic form for each member detail set
            Expanded(
              child: ListView.builder(
                itemCount: memberDetailsList.length,
                itemBuilder: (context, index) {
                  final memberDetails = memberDetailsList[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Field 1: Name
                          TextField(
                            controller: memberDetails['Name:'],
                            decoration: const InputDecoration(
                              labelText: 'Name:',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Field 2: Age
                          TextField(
                            controller: memberDetails['Age:'],
                            decoration: const InputDecoration(
                              labelText: 'Age:',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Field 3: Gender (Dropdown)
                          DropdownButtonFormField<String>(
                            value: memberDetails['Gender:'], // Now 'Gender:' is a String
                            decoration: const InputDecoration(
                              labelText: 'Gender:',
                              border: OutlineInputBorder(),
                            ),
                            items: ['Male', 'Female']
                                .map((gender) => DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(gender),
                                    ))
                                .toList(),
                            onChanged: (newValue) {
                              setState(() {
                                memberDetails['Gender:'] = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 8),

                          // Field 4: Position on the family
                          TextField(
                            controller: memberDetails['Position on the family:'],
                            decoration: const InputDecoration(
                              labelText: 'Position on the family:',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Field 5: Marital Status (Dropdown)
                          DropdownButtonFormField<String>(
                            value: memberDetails['Material status:'], // Now 'Material status:' is a String
                            decoration: const InputDecoration(
                              labelText: 'Marital status:',
                              border: OutlineInputBorder(),
                            ),
                            items: ['Single', 'Married', 'Divorced']
                                .map((status) => DropdownMenuItem<String>(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: (newValue) {
                              setState(() {
                                memberDetails['Material status:'] = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 8),

                          // Field 6: L/D/M
                          TextField(
                            controller: memberDetails['L/D/M:'],
                            decoration: const InputDecoration(
                              labelText: 'L/D/M:',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Field 7: Adhaar No
                          TextField(
                            controller: memberDetails['Adhaar No:'],
                            decoration: const InputDecoration(
                              labelText: 'Adhaar No:',
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

            // Add Button to add more sets of member details
            Center(
              child: ElevatedButton(
                onPressed: _addNewMemberDetail,
                child: const Text('Add Another Member'),
              ),
            ),

            // Next Button to navigate to the next page
            Center(
              child: ElevatedButton(
                onPressed: _goNext, // Calls the goNext function
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
