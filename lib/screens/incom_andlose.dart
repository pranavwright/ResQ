import 'package:flutter/material.dart';
import 'package:resq/screens/emp_status.dart';

class IncomAndlose extends StatefulWidget {
  const IncomAndlose({super.key});

  @override
  _IncomAndloseState createState() => _IncomAndloseState();
}

class _IncomAndloseState extends State<IncomAndlose> {
  // Variable to store the selected value for the radio buttons
  String? _selectedOption;
  String? _yesNoAnswer;  // Variable to store the answer for the Yes/No question
  List<String> _selectedCheckboxes = [];  // List to store selected checkboxes
  TextEditingController _incomeSourceController = TextEditingController();
  TextEditingController _otherController = TextEditingController(); // Text controller for "Other"

  // The list of options for checkboxes
  final List<String> checkboxOptions = [
    'Employment Loss',
    'Loss in Business',
    'Income Loss to daily wage worker',
    'Loss of breadwinner',
    'Loss in animal husbandry',
    'Loss of agricultural land and crops',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Livelihood"),
        // Adding a back arrow in the AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // This will navigate back to the previous screen
            Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/education-livilehood',
                  (route) => false,
                );
          },
        ),
      ),
      body: SingleChildScrollView(  // Make the body scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The question with the 7 radio options
              Text(
                "What was your average monthly family income?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              
              // The 7 radio buttons for the different options
              Column(
                children: [
                  RadioListTile<String>(
                    title: Text("Less than 5000"),
                    value: 'Less than 5000',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text("5000 to 10000"),
                    value: '5000 to 10000',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text("10000 to 20000"),
                    value: '10000 to 20000',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text("20000 to 30000"),
                    value: '20000 to 30000',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text("30000 to 40000"),
                    value: '30000 to 40000',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text("40000 to 50000"),
                    value: '40000 to 50000',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text("Above 50000"),
                    value: 'Above 50000',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),

              // The Yes/No question with buttons
              Text(
                "Source of livelihood affected or not:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _yesNoAnswer = 'Yes';
                      });
                    },
                    child: Text("Yes"),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _yesNoAnswer = 'No';
                      });
                    },
                    child: Text("No"),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Show checkboxes only if 'Yes' is selected for the livelihood affected question
              if (_yesNoAnswer == 'Yes') ...[
                Text(
                  "Select affected sources of livelihood:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...checkboxOptions.map((option) {
                  return CheckboxListTile(
                    title: Text(option),
                    value: _selectedCheckboxes.contains(option),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedCheckboxes.add(option);
                        } else {
                          _selectedCheckboxes.remove(option);
                        }

                        // If "Other" is selected, show the additional text field
                        if (_selectedCheckboxes.contains('Other')) {
                          // Ensure that the text field is displayed when "Other" is checked
                        }
                      });
                    },
                  );
                }).toList(),
              ],
              SizedBox(height: 16),

              // Display a text field when "Other" is selected in checkboxes
              if (_selectedCheckboxes.contains('Other')) ...[
                Text(
                  "Please specify:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _otherController,
                  decoration: InputDecoration(
                    labelText: "specify the lose",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
              ],

              // The question for the primary source of income with a text field
              Text(
                "What is the primary source of your income?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _incomeSourceController,
                decoration: InputDecoration(
                  labelText: 'Enter your primary income source',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // The Next button to navigate to the next page
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the NextPage when pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EmpStatus()),
                    );
                  },
                  child: Text("Next"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
