import 'package:flutter/material.dart';
import 'package:resq/screens/shelter.dart'; // Assuming this is your next screen.

class HealthNew extends StatefulWidget {
  const HealthNew({super.key});

  @override
  _HealthNewState createState() => _HealthNewState();
}

class _HealthNewState extends State<HealthNew> {
  // List to hold data for multiple health details
  List<Map<String, TextEditingController>> healthDetailsList = [];

  // Initialize one health detail set
  @override
  void initState() {
    super.initState();
    _addNewHealthDetail(); // Add initial set of health details
  }

  // Function to add a new set of text controllers for health details
  void _addNewHealthDetail() {
    setState(() {
      healthDetailsList.add({
        'name': TextEditingController(),
        'grievInjured': TextEditingController(),
        'bedRidden': TextEditingController(),
        'pwds': TextEditingController(),
        'psychoSocial': TextEditingController(),
        'nursingHome': TextEditingController(),
        'assistiveDevices': TextEditingController(),
        'specialMedical': TextEditingController(),
        'pwdsDetails': TextEditingController(), // Additional field for PwDs
        'assistiveDevicesDetails': TextEditingController(), // Additional field for Assistive Devices
        'specialMedicalDetails': TextEditingController(), // Additional field for Special Medical Requirements
      });
    });
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    for (var healthDetail in healthDetailsList) {
      healthDetail.values.forEach((controller) {
        controller.dispose();
      });
    }
    super.dispose();
  }

  // Function to navigate to the next page
  void _navigateToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Shelter()), // Navigate to the next page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/foodand-health',
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
              'Enter Health Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Dynamic form for each health detail set
            Expanded(
              child: ListView.builder(
                itemCount: healthDetailsList.length,
                itemBuilder: (context, index) {
                  final healthDetails = healthDetailsList[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name TextField
                          TextField(
                            controller: healthDetails['name'],
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Grievously Injured Radio Buttons
                          const Text('Grievously Injured:'),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Yes',
                                groupValue: healthDetails['grievInjured']?.text,
                                onChanged: (value) {
                                  setState(() {
                                    healthDetails['grievInjured']?.text = value!;
                                  });
                                },
                              ),
                              const Text('Yes'),
                              Radio<String>(
                                value: 'No',
                                groupValue: healthDetails['grievInjured']?.text,
                                onChanged: (value) {
                                  setState(() {
                                    healthDetails['grievInjured']?.text = value!;
                                  });
                                },
                              ),
                              const Text('No'),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Bed-ridden/Palliative Care Radio Buttons
                          const Text('Bed-ridden/Palliative Care:'),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Yes',
                                groupValue: healthDetails['bedRidden']?.text,
                                onChanged: (value) {
                                  setState(() {
                                    healthDetails['bedRidden']?.text = value!;
                                  });
                                },
                              ),
                              const Text('Yes'),
                              Radio<String>(
                                value: 'No',
                                groupValue: healthDetails['bedRidden']?.text,
                                onChanged: (value) {
                                  setState(() {
                                    healthDetails['bedRidden']?.text = value!;
                                  });
                                },
                              ),
                              const Text('No'),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // PwDs (Persons with Disabilities) Radio Buttons
                          const Text('PwDs:'),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Yes',
                                groupValue: healthDetails['pwds']?.text,
                                onChanged: (value) {
                                  setState(() {
                                    healthDetails['pwds']?.text = value!;
                                  });
                                },
                              ),
                              const Text('Yes'),
                              Radio<String>(
                                value: 'No',
                                groupValue: healthDetails['pwds']?.text,
                                onChanged: (value) {
                                  setState(() {
                                    healthDetails['pwds']?.text = value!;
                                  });
                                },
                              ),
                              const Text('No'),
                            ],
                          ),
                          // Show PwDs details if "Yes" is selected
                          if (healthDetails['pwds']?.text == 'Yes')
                            TextField(
                              controller: healthDetails['pwdsDetails'],
                              decoration: const InputDecoration(
                                labelText: 'specify and Provide details for PwDs',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          const SizedBox(height: 8),

                          // Psycho-socio assistance/emotional distress Radio Buttons
                          const Text('Psycho-social Assistance / Emotional Distress:'),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Yes',
                                groupValue: healthDetails['psychoSocial']?.text,
                                onChanged: (value) {
                                  setState(() {
                                    healthDetails['psychoSocial']?.text = value!;
                                  });
                                },
                              ),
                              const Text('Yes'),
                              Radio<String>(
                                value: 'No',
                                groupValue: healthDetails['psychoSocial']?.text,
                                onChanged: (value) {
                                  setState(() {
                                    healthDetails['psychoSocial']?.text = value!;
                                  });
                                },
                              ),
                              const Text('No'),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Nursing home assistance for elderly Radio Buttons
                          const Text('Nursing Home Assistance for Elderly:'),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Yes',
                                groupValue: healthDetails['nursingHome']?.text,
                                onChanged: (value) {
                                  setState(() {
                                    healthDetails['nursingHome']?.text = value!;
                                  });
                                },
                              ),
                              const Text('Yes'),
                              Radio<String>(
                                value: 'No',
                                groupValue: healthDetails['nursingHome']?.text,
                                onChanged: (value) {
                                  setState(() {
                                    healthDetails['nursingHome']?.text = value!;
                                  });
                                },
                              ),
                              const Text('No'),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Assistive Devices Radio Buttons
                          const Text('Needs for Assistive Devices:'),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Yes',
                                groupValue: healthDetails['assistiveDevices']?.text,
                                onChanged: (value) {
                                  setState(() {
                                    healthDetails['assistiveDevices']?.text = value!;
                                  });
                                },
                              ),
                              const Text('Yes'),
                              Radio<String>(
                                value: 'No',
                                groupValue: healthDetails['assistiveDevices']?.text,
                                onChanged: (value) {
                                  setState(() {
                                    healthDetails['assistiveDevices']?.text = value!;
                                  });
                                },
                              ),
                              const Text('No'),
                            ],
                          ),
                          // Show Assistive Devices details if "Yes" is selected
                          if (healthDetails['assistiveDevices']?.text == 'Yes')
                            TextField(
                              controller: healthDetails['assistiveDevicesDetails'],
                              decoration: const InputDecoration(
                                labelText: ' specify and Provide details for Assistive Devices',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          const SizedBox(height: 8),

                          // Special Medical Requirements Radio Buttons
                          const Text('Needs for Special Medical Requirements:'),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Yes',
                                groupValue: healthDetails['specialMedical']?.text,
                                onChanged: (value) {
                                  setState(() {
                                    healthDetails['specialMedical']?.text = value!;
                                  });
                                },
                              ),
                              const Text('Yes'),
                              Radio<String>(
                                value: 'No',
                                groupValue: healthDetails['specialMedical']?.text,
                                onChanged: (value) {
                                  setState(() {
                                    healthDetails['specialMedical']?.text = value!;
                                  });
                                },
                              ),
                              const Text('No'),
                            ],
                          ),
                          // Show Special Medical details if "Yes" is selected
                          if (healthDetails['specialMedical']?.text == 'Yes')
                            TextField(
                              controller: healthDetails['specialMedicalDetails'],
                              decoration: const InputDecoration(
                                labelText: 'specify and Provide details for Special Medical Requirements',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Add Another Health Details Button
            Center(
              child: ElevatedButton(
                onPressed: _addNewHealthDetail,
                child: const Text('Add Another person'),
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
