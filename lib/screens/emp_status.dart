import 'package:flutter/material.dart';
import 'package:resq/screens/skill.dart';

class EmpStatus extends StatefulWidget {
  const EmpStatus({super.key});

  @override
  _EmpStatusState createState() => _EmpStatusState();
}

class _EmpStatusState extends State<EmpStatus> {
  // List to hold data for multiple people
  List<Map<String, dynamic>> persons = [];

  // Initialize the first person in the list
  @override
  void initState() {
    super.initState();
    _addNewPerson();  // Add initial set of person details
  }

  // Function to add a new set of text controllers for person details
  void _addNewPerson() {
    setState(() {
      persons.add({
        'name': TextEditingController(),
        'Education': TextEditingController(),
        'checkboxes': List<bool>.from([false, false, false, false]),
        'checkboxes2': List<bool>.from([false, false, false, false, false, false]),
      });
    });
  }

  // Dispose controllers to avoid memory leaks
  @override
  void dispose() {
    for (var person in persons) {
      person.values.forEach((controller) {
        if (controller is TextEditingController) {
          controller.dispose();
        }
      });
    }
    super.dispose();
  }

  // Function to navigate to the next page
  void _navigateToNextPage() {
    // Navigate to the next page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Skill() ), // Replace with your actual next page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employment Status of totoal household members(18+)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
           Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/incomandlose',
                  (route) => false,
           );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Employment Status Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Dynamic form for each person
            Expanded(
              child: ListView.builder(
                itemCount: persons.length,
                itemBuilder: (context, index) {
                  final person = persons[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Person's Name
                          TextField(
                            controller: person['name'],
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Person's Occupation
                          TextField(
                            controller: person['education'],
                            decoration: const InputDecoration(
                              labelText: 'Education',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Employment Type Checkboxes
                          const Text(
                            'previuos status',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          for (int i = 0; i < 4; i++) ...[
                            CheckboxListTile(
                              title: Text(['Employed', 'Unemployed', 'Self-employed', 'Unemployed due to health condition'][i]),
                              value: person['checkboxes'][i],
                              onChanged: (bool? value) {
                                setState(() {
                                  person['checkboxes'][i] = value ?? false;
                                });
                              },
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Skills Checkboxes
                          const Text(
                            ' Employment',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          for (int i = 0; i < 6; i++) ...[
                            CheckboxListTile(
                              title: Text([
                                'govt:', 'private', 'platation', 'Agri/Allied', 'Daily wage', 'others'
                              ][i]),
                              value: person['checkboxes2'][i],
                              onChanged: (bool? value) {
                                setState(() {
                                  person['checkboxes2'][i] = value ?? false;
                                });
                              },
                            ),
                          ],
                          TextField(
                            controller: person['whether unemployed due to disaster'],
                            decoration: const InputDecoration(
                              labelText: 'whether unemployed due to disaster',
                              border: OutlineInputBorder(),
                            ),
                            
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: person['salary'],
                            decoration: const InputDecoration(
                              labelText: 'salary',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Add Button to add more persons
            Center(
              child: ElevatedButton(
                onPressed: _addNewPerson,
                child: const Text('Add Another Person'),
              ),
            ),

            // Next Button to navigate to the next page
            Center(
              child: ElevatedButton(
                onPressed: _navigateToNextPage,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
