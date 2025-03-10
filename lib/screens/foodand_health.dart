import 'package:flutter/material.dart';

class FoodandHealth extends StatefulWidget {
  const FoodandHealth({super.key});

  @override
  _FoodandHealthState createState() => _FoodandHealthState();
}

class _FoodandHealthState extends State<FoodandHealth> {
  // Variables to store the selected values for the radio buttons
  String? _angawadiCenterStatus;
  String? _foodAssistanceStatus;
  String? _nutritionDisruptionStatus;
  // New Variables for the radio buttons
  // New variable for the family insurance question
  String? _familyInsuranceStatus;
  String? _insuranceDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food and Health'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/add-members',
                  (route) => false,
                );// This will navigate to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food Security and Nutrition',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),

                // TextFields with basic questions
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Total number of children enrolled in Anganwadi centers',
                    border: OutlineInputBorder(), // Added outline border
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Are there any children with malnutrition?',
                    border: OutlineInputBorder(), // Added outline border
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Pregnant women in the family',
                    border: OutlineInputBorder(), // Added outline border
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Lactating women in the family',
                    border: OutlineInputBorder(), // Added outline border
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'How long do you need food assistance?',
                    border: OutlineInputBorder(), // Added outline border
                  ),
                ),
                SizedBox(height: 20),

                // Radio Buttons for the three questions
                Text(
                  'Is the Anganwadi center damaged?',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Yes',
                      groupValue: _angawadiCenterStatus,
                      onChanged: (value) {
                        setState(() {
                          _angawadiCenterStatus = value;
                        });
                      },
                    ),
                    Text('Yes'),
                    Radio<String>(
                      value: 'No',
                      groupValue: _angawadiCenterStatus,
                      onChanged: (value) {
                        setState(() {
                          _angawadiCenterStatus = value;
                        });
                      },
                    ),
                    Text('No'),
                  ],
                ),
                SizedBox(height: 20),

                Text(
                  'Is the present food assistance sufficient?',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Yes',
                      groupValue: _foodAssistanceStatus,
                      onChanged: (value) {
                        setState(() {
                          _foodAssistanceStatus = value;
                        });
                      },
                    ),
                    Text('Yes'),
                    Radio<String>(
                      value: 'No',
                      groupValue: _foodAssistanceStatus,
                      onChanged: (value) {
                        setState(() {
                          _foodAssistanceStatus = value;
                        });
                      },
                    ),
                    Text('No'),
                  ],
                ),
                // Conditionally showing the TextField when "No" is selected for food assistance
                if (_foodAssistanceStatus == 'No') 
                  Column(
                    children: [
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Please explain why the current food assistance is insufficient',
                          border: OutlineInputBorder(), // Added outline border
                        ),
                      ),
                    ],
                  ),
                
                SizedBox(height: 20),

                Text(
                  'Is there any disruption in government nutrition services to children, adolescent girls, pregnant women, and lactating mothers?',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Yes',
                      groupValue: _nutritionDisruptionStatus,
                      onChanged: (value) {
                        setState(() {
                          _nutritionDisruptionStatus = value;
                        });
                      },
                    ),
                    Text('Yes'),
                    Radio<String>(
                      value: 'No',
                      groupValue: _nutritionDisruptionStatus,
                      onChanged: (value) {
                        setState(() {
                          _nutritionDisruptionStatus = value;
                        });
                      },
                    ),
                    Text('No'),
                  ],
                ),
                SizedBox(height: 20),

                // Heading "HEALTH"
               
                SizedBox(height: 20),

                // Family Insurance Radio Button
                Text(
                  'Do you have any family insurance?',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Yes',
                      groupValue: _familyInsuranceStatus,
                      onChanged: (value) {
                        setState(() {
                          _familyInsuranceStatus = value;
                        });
                      },
                    ),
                    Text('Yes'),
                    Radio<String>(
                      value: 'No',
                      groupValue: _familyInsuranceStatus,
                      onChanged: (value) {
                        setState(() {
                          _familyInsuranceStatus = value;
                        });
                      },
                    ),
                    Text('No'),
                  ],
                ),

                // Conditionally showing the TextField when "Yes" is selected for family insurance
                if (_familyInsuranceStatus == 'Yes') 
                  Column(
                    children: [
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Please specify your family insurance details',
                          border: OutlineInputBorder(), // Added outline border
                        ),
                        onChanged: (value) {
                          setState(() {
                            _insuranceDetails = value;
                          });
                        },
                      ),
                    ],
                  ),
                
                SizedBox(height: 20),

                // Next Button to navigate to the next page
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/helthnew',
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
      ),
    );
  }
}
