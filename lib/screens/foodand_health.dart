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
  TextEditingController _foodAssistanceDetailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food and Health'),
        leading: BackButton(), // This adds the back arrow in the AppBar
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
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Are there any children with malnutrition?',
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Pregnant women in the family',
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Lactating women in the family',
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'How long do you need food assistance?',
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
                        controller: _foodAssistanceDetailsController,
                        decoration: InputDecoration(
                          labelText: 'Please explain why the current food assistance is insufficient',
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
                ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/shelter',
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
