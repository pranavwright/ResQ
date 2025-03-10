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
      appBar: AppBar(
        title: const Text("Household Profile"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Attractive color for AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/otp',
                  (route) => false,
                ); // Pops the current screen and goes back to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Household Info Text Fields (village/ward, house number, etc.)
              _buildTextField('Village/Ward'),
              const SizedBox(height: 10), // Added space between fields
              _buildTextField('House Number'),
              const SizedBox(height: 10),
              _buildTextField('Unique Household ID'),
              const SizedBox(height: 10),
              _buildTextField('Household Head'),
              const SizedBox(height: 10),
              _buildTextField('Address'),
              const SizedBox(height: 10),
              _buildTextField('Contact No'),
              const SizedBox(height: 10),
              _buildTextField('Ration Card No'),
              const SizedBox(height: 20),

              // Ration Card Category Checkboxes
              _buildSectionHeader('Ration Card Category:'),
              _buildCheckbox('Yellow', isYellowChecked, (bool? value) {
                setState(() {
                  isYellowChecked = value ?? false;
                });
              }),
              _buildCheckbox('White', isWhiteChecked, (bool? value) {
                setState(() {
                  isWhiteChecked = value ?? false;
                });
              }),
              _buildCheckbox('Pink', isPinkChecked, (bool? value) {
                setState(() {
                  isPinkChecked = value ?? false;
                });
              }),
              const SizedBox(height: 20),

              // Household Head Radio Buttons
              _buildSectionHeader('Household Head Category:'),
              _buildRadioOption('General'),
              _buildRadioOption('Other Backward'),
              _buildRadioOption('Scheduled Caste'),
              _buildRadioOption('Scheduled Tribe'),
              _buildRadioOption('Other'),
              const SizedBox(height: 20),

              // Family Members Input Fields
              const Text(
                'Family Members:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
                      
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Next Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/add-members',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 235, 229, 229), // Changed 'primary' to 'backgroundColor'
                ),
                child: const Text("Next"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build a simple text field with custom styling
  Widget _buildTextField(String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: const Color.fromARGB(255, 49, 43, 43)), // Attractive label color
        border: OutlineInputBorder(
          borderSide: BorderSide(color: const Color.fromARGB(255, 27, 24, 24)), // Border color
        ),
      ),
    );
  }

  // Function to build section headers
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
    );
  }

  // Function to build a checkbox option
  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(label, style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
      ],
    );
  }

  // Function to build radio button options for Household Head
  Widget _buildRadioOption(String label) {
    return Row(
      children: [
        Radio<String>(
          value: label,
          groupValue: householdHead,
          onChanged: (String? value) {
            setState(() {
              householdHead = value;
            });
          },
        ),
        Text(label, style: TextStyle(color: const Color.fromARGB(255, 1, 1, 1))),
      ],
    );
  }
}
