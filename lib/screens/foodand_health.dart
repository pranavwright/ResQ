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
  // New variable for the family insurance question
  String? _familyInsuranceStatus;
  String? _insuranceDetails;

  // Variables for TextField inputs
  TextEditingController _childrenEnrolledController = TextEditingController();
  TextEditingController _malnutritionChildrenController = TextEditingController();
  TextEditingController _pregnantWomenController = TextEditingController();
  TextEditingController _lactatingWomenController = TextEditingController();
  TextEditingController _foodAssistanceDurationController = TextEditingController();
  TextEditingController _foodAssistanceReasonController = TextEditingController();

  @override
  void dispose() {
    // Dispose the controllers to avoid memory leaks
    _childrenEnrolledController.dispose();
    _malnutritionChildrenController.dispose();
    _pregnantWomenController.dispose();
    _lactatingWomenController.dispose();
    _foodAssistanceDurationController.dispose();
    _foodAssistanceReasonController.dispose();
    super.dispose();
  }

  void _printCollectedData() {
    print("Food and Health Data:");
    print("Anganwadi Center Damaged: $_angawadiCenterStatus");
    print("Food Assistance Sufficient: $_foodAssistanceStatus");
    print("Nutrition Disruption: $_nutritionDisruptionStatus");
    print("Family Insurance: $_familyInsuranceStatus");
    print("Family Insurance Details: $_insuranceDetails");
    print("Children Enrolled in Anganwadi: ${_childrenEnrolledController.text}");
    print("Malnutrition Children: ${_malnutritionChildrenController.text}");
    print("Pregnant Women: ${_pregnantWomenController.text}");
    print("Lactating Women: ${_lactatingWomenController.text}");
    print("Food Assistance Duration: ${_foodAssistanceDurationController.text}");
    print("Food Assistance Reason: ${_foodAssistanceReasonController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food and Health'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(
                  context,
                  '/add-members',
                  arguments: {}
                );
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
                  controller: _childrenEnrolledController,
                  decoration: InputDecoration(
                    labelText: 'Total number of children enrolled in Anganwadi centers',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _malnutritionChildrenController,
                  decoration: InputDecoration(
                    labelText: 'Are there any children with malnutrition?',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _pregnantWomenController,
                  decoration: InputDecoration(
                    labelText: 'Pregnant women in the family',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _lactatingWomenController,
                  decoration: InputDecoration(
                    labelText: 'Lactating women in the family',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _foodAssistanceDurationController,
                  decoration: InputDecoration(
                    labelText: 'How long do you need food assistance?',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                // Radio Buttons for the three questions
                Text('Is the Anganwadi center damaged?'),
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

                Text('Is the present food assistance sufficient?'),
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
                if (_foodAssistanceStatus == 'No')
                  Column(
                    children: [
                      SizedBox(height: 10),
                      TextField(
                        controller: _foodAssistanceReasonController,
                        decoration: InputDecoration(
                          labelText: 'Please explain why the current food assistance is insufficient',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                
                SizedBox(height: 20),

                Text('Is there any disruption in government nutrition services?'),
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

                Text('Do you have any family insurance?'),
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
                if (_familyInsuranceStatus == 'Yes')
                  Column(
                    children: [
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Please specify your family insurance details',
                          border: OutlineInputBorder(),
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

                ElevatedButton(
                  onPressed: () {
                    _printCollectedData(); // Call the print function
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/helthnew',
                      (route) => false,
                    );
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
