import 'package:flutter/material.dart';

class AddFamilies extends StatefulWidget {
  const AddFamilies({super.key});

  @override
  _AddFamiliesState createState() => _AddFamiliesState();
}

class _AddFamiliesState extends State<AddFamilies> {
  bool isYellowChecked = false;
  bool isWhiteChecked = false;
  bool isPinkChecked = false;

  String? householdHead = "General"; // Default value is "General"

  // List to hold each family member's details
  List<Map<String, String>> familyMembers = [];

  // List of marital status options
  List<String> maritalStatusOptions = ['Single', 'Married', 'Divorced'];

  // Function to add a new family member to the list
  void addFamilyMember() {
    setState(() {
      familyMembers.add({
        'si.no': '',
        'name': '',
        'age': '',
        'gender': '',
        'position': '',
        'materialStatus': maritalStatusOptions[0], // Default to 'Single'
        'ldm': '',
        'aadhaar': '',
      });
    });
  }

  // Function to handle changes in the family member's input
  void handleInputChange(int index, String key, String value) {
    setState(() {
      familyMembers[index][key] = value;
    });
  }

  // Function to handle changes in marital status dropdown
  void handleMaritalStatusChange(int index, String value) {
    setState(() {
      familyMembers[index]['materialStatus'] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Household Profile")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Household Info Text Fields (village/ward, house number, etc.)
              TextField(
                decoration: const InputDecoration(labelText: 'Village/Ward'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'House Number'),
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Unique Household ID',
                ),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Household Head'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Contact No'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Ration Card No'),
              ),
              const SizedBox(height: 20),

              // Ration Card Category Checkboxes
              const Text(
                'Ration Card Category:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: isYellowChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isYellowChecked = value ?? false;
                      });
                    },
                  ),
                  const Text("Yellow"),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: isWhiteChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isWhiteChecked = value ?? false;
                      });
                    },
                  ),
                  const Text("White"),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: isPinkChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isPinkChecked = value ?? false;
                      });
                    },
                  ),
                  const Text("Pink"),
                ],
              ),
              const SizedBox(height: 20),

              // Household Head Radio Buttons
              const Text(
                'Household Head Category:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Radio<String>(
                    value: "General",
                    groupValue: householdHead,
                    onChanged: (String? value) {
                      setState(() {
                        householdHead = value;
                      });
                    },
                  ),
                  const Text("General"),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: "Other Backward",
                    groupValue: householdHead,
                    onChanged: (String? value) {
                      setState(() {
                        householdHead = value;
                      });
                    },
                  ),
                  const Text("Other Backward"),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: "Scheduled Caste",
                    groupValue: householdHead,
                    onChanged: (String? value) {
                      setState(() {
                        householdHead = value;
                      });
                    },
                  ),
                  const Text("Scheduled Caste"),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: "Scheduled Tribe",
                    groupValue: householdHead,
                    onChanged: (String? value) {
                      setState(() {
                        householdHead = value;
                      });
                    },
                  ),
                  const Text("Scheduled Tribe"),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: "Other",
                    groupValue: householdHead,
                    onChanged: (String? value) {
                      setState(() {
                        householdHead = value;
                      });
                    },
                  ),
                  const Text("Other"),
                ],
              ),
              const SizedBox(height: 20),

              // Family Members Input Fields
              const Text(
                'Family Members:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Dynamically display family members input fields
              ListView.builder(
                shrinkWrap: true,
                itemCount: familyMembers.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Family Member ${index + 1}'),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Name'),
                        onChanged:
                            (value) => handleInputChange(index, 'name', value),
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Age'),
                        onChanged:
                            (value) => handleInputChange(index, 'age', value),
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Gender'),
                        onChanged:
                            (value) =>
                                handleInputChange(index, 'gender', value),
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Position in the Family',
                        ),
                        onChanged:
                            (value) =>
                                handleInputChange(index, 'position', value),
                      ),
                      // Replace Marital Status TextField with Dropdown
                      DropdownButton<String>(
                        value: familyMembers[index]['materialStatus'],
                        onChanged: (String? value) {
                          handleMaritalStatusChange(index, value!);
                        },
                        items:
                            maritalStatusOptions.map((String status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                        hint: const Text("Select Marital Status"),
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'L/D/M'),
                        onChanged:
                            (value) => handleInputChange(index, 'ldm', value),
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Aadhaar No',
                        ),
                        onChanged:
                            (value) =>
                                handleInputChange(index, 'aadhaar', value),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
              // Button to add a new family member
              ElevatedButton(
                onPressed: addFamilyMember,
                child: const Text('Add Person'),
              ),
              const SizedBox(height: 20),

              // Next Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/foodand-health',
                    (route) => false,
                  );
                  // Implement your action here (e.g., submit the data)
                },
                child: const Text("Next"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
