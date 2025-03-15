import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddFamilies extends StatefulWidget {
  const AddFamilies({super.key});

  @override
  _AddFamiliesState createState() => _AddFamiliesState();
}

class _AddFamiliesState extends State<AddFamilies> {
  String? selectedRationCardCategory = 'Yellow'; // Default selection for Ration Card
  String? householdHead = "General"; 
  String village = '';
  String houseNumber = '';
  String uniqueHouseholdID = '';
  String householdHeadName = '';
  String address = '';
  String contactNo = '';
  String rationCardNo = '';

  // List to hold each family member's details
  List<Map<String, String>> familyMembers = [];

  // List of marital status options
  List<String> maritalStatusOptions = ['Single', 'Married', 'Divorced'];

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

  // Function to collect and print data when 'Next' button is clicked
  void nextData() {
    // Storing all the form data in a Map
    Map<String, dynamic> formData = {
      'Village/Ward': village,
      'House Number': houseNumber,
      'Unique Household ID': uniqueHouseholdID,
      'Household Head': householdHeadName,
      'Address': address,
      'Contact No': contactNo,
      'Ration Card No': rationCardNo,
      'Ration Card Category': selectedRationCardCategory,
      'Household Head Category': householdHead,
      'Family Members': familyMembers,
    };

    // Printing all the collected data in the console
    // print("Collected Form Data:");
    // print("Village/Ward: $village");
    // print("House Number: $houseNumber");
    // print("Unique Household ID: $uniqueHouseholdID");
    // print("Household Head: $householdHeadName");
    // print("Address: $address");
    // print("Contact No: $contactNo");
    // print("Ration Card No: $rationCardNo");
    // print("Ration Card Category: $selectedRationCardCategory");
    // print("Household Head Category: $householdHead");

    // Printing the family members list
    // print("Family Members:");
    // for (var member in familyMembers) {
    //   print("Name: ${member['name']}, Age: ${member['age']}, Gender: ${member['gender']}, "
    //       "Position: ${member['position']}, Marital Status: ${member['materialStatus']}, "
    //       "LDM: ${member['ldm']}, Aadhaar: ${member['aadhaar']}");
    // }

    // Passing the data to the next screen using Navigator
    Navigator.pushNamed(
      context,
      '/add-members',
      arguments: formData, // Passing the collected data to the next screen
    );
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
              '/otp', // Navigate back to OTP screen
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Village/Ward', (value) => village = value),
              const SizedBox(height: 10),
              _buildTextField('House Number', (value) => houseNumber = value),
              const SizedBox(height: 10),
              _buildTextField('Unique Household ID', (value) => uniqueHouseholdID = value),
              const SizedBox(height: 10),
              _buildTextField('Household Head', (value) => householdHeadName = value),
              const SizedBox(height: 10),
              _buildTextField('Address', (value) => address = value),
              const SizedBox(height: 10),
              _buildTextField('Contact No', (value) => contactNo = value, isNumber: true),
              const SizedBox(height: 10),
              _buildTextField('Ration Card No', (value) => rationCardNo = value, isNumber: true),
              const SizedBox(height: 20),

              // Ration Card Category Radio Buttons
              _buildSectionHeader('Ration Card Category:'),
              _buildRadioOption('Yellow', selectedRationCardCategory),
              _buildRadioOption('White', selectedRationCardCategory),
              _buildRadioOption('Pink', selectedRationCardCategory),
              const SizedBox(height: 20),

              // Household Head Radio Buttons
              _buildSectionHeader('Household Head Category:'),
              _buildRadioOption('General', householdHead),
              _buildRadioOption('Other Backward', householdHead),
              _buildRadioOption('Scheduled Caste', householdHead),
              _buildRadioOption('Scheduled Tribe', householdHead),
              _buildRadioOption('Other', householdHead),
              const SizedBox(height: 20),

              // Family Members Input Fields
              const SizedBox(height: 10),

              // Dynamically display family members input fields
              ListView.builder(
                shrinkWrap: true,
                itemCount: familyMembers.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField('Name', (value) => handleInputChange(index, 'name', value)),
                      _buildTextField('Age', (value) => handleInputChange(index, 'age', value), isNumber: true),
                      _buildTextField('Gender', (value) => handleInputChange(index, 'gender', value)),
                      _buildTextField('Position', (value) => handleInputChange(index, 'position', value)),
                      _buildMaritalStatusDropdown(index),
                      _buildTextField('LDM', (value) => handleInputChange(index, 'ldm', value)),
                      _buildTextField('Aadhaar', (value) => handleInputChange(index, 'aadhaar', value), isNumber: true),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // Next Button
              ElevatedButton(
                onPressed: nextData, // Pass data to the next page
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 235, 229, 229),
                ),
                child: const Text("Next"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build a simple text field with custom styling and optional number validation
  Widget _buildTextField(
    String label,
    Function(String) onChanged, {
    bool isNumber = false,
  }) {
    return TextField(
      onChanged: onChanged,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 49, 43, 43),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 27, 24, 24),
          ),
        ),
      ),
    );
  }

  // Function to build section headers
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  // Function to build radio button options
  Widget _buildRadioOption(String label, String? groupValue) {
    return Row(
      children: [
        Radio<String>(
          value: label,
          groupValue: groupValue,
          onChanged: (String? value) {
            setState(() {
              if (groupValue == selectedRationCardCategory) {
                selectedRationCardCategory = value; // Update the ration card category
              } else {
                householdHead = value; // Update the household head category
              }
            });
          },
        ),
        Text(label),
      ],
    );
  }

  // Function to build the marital status dropdown for family members
  Widget _buildMaritalStatusDropdown(int index) {
    return DropdownButton<String>(
      value: familyMembers[index]['materialStatus'],
      onChanged: (String? newValue) {
        handleMaritalStatusChange(index, newValue ?? maritalStatusOptions[0]);
      },
      items: maritalStatusOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
