import 'package:flutter/material.dart';

class Shelter extends StatefulWidget {
  const Shelter({super.key});

  @override
  _ShelterState createState() => _ShelterState();
}

class _ShelterState extends State<Shelter> {
  // Variables to store the selected values for the radio buttons
  String? _question1Answer;
  String? _question2Answer;
  String? _question3Answer;
  String? _question4Answer;

  // New variable to store the answer for the new accommodation question
  String? _accommodationAnswer;

  // New variable to store the answer for the vehicle possession question
  String? _vehiclePossessionAnswer;

  // New variable to store the answer for vehicle type (Two/Three Wheeler, Four Wheeler, etc.)
  String? _vehicleTypeAnswer;

  // Controllers for the text fields
  TextEditingController _additionalNotesController = TextEditingController();
  TextEditingController _additionalField1Controller = TextEditingController(); // New TextField Controller 1
  TextEditingController _otherAccommodationController = TextEditingController(); // Controller for 'Others' accommodation field
  TextEditingController _vehicleDetailsController = TextEditingController(); // Controller for vehicle details field
  TextEditingController _vehicleNumberController = TextEditingController(); // Controller for vehicle number field
  TextEditingController _otherVehicleController = TextEditingController(); // Controller for 'Any Other' vehicle field

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shelter'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/helthnew',
                  (route) => false,
                ); // This will navigate to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title for the Radio Button Section
              Text(
                'Type of House :', // Title for the section
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),

              // First Question
              Text(
                '1:Permanent structure',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Yes',
                    groupValue: _question1Answer,
                    onChanged: (value) {
                      setState(() {
                        _question1Answer = value;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: _question1Answer,
                    onChanged: (value) {
                      setState(() {
                        _question1Answer = value;
                      });
                    },
                  ),
                  Text('No'),
                ],
              ),
              SizedBox(height: 20),

              // Second Question
              Text(
                '2:House built with government assistance',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Yes',
                    groupValue: _question2Answer,
                    onChanged: (value) {
                      setState(() {
                        _question2Answer = value;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: _question2Answer,
                    onChanged: (value) {
                      setState(() {
                        _question2Answer = value;
                      });
                    },
                  ),
                  Text('No'),
                ],
              ),
              SizedBox(height: 20),

              // Third Question
              Text(
                '3:Rented',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Yes',
                    groupValue: _question3Answer,
                    onChanged: (value) {
                      setState(() {
                        _question3Answer = value;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: _question3Answer,
                    onChanged: (value) {
                      setState(() {
                        _question3Answer = value;
                      });
                    },
                  ),
                  Text('No'),
                ],
              ),
              SizedBox(height: 20),

              // Fourth Question
              Text(
                '4:Paadi (Layam)',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Yes',
                    groupValue: _question4Answer,
                    onChanged: (value) {
                      setState(() {
                        _question4Answer = value;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: _question4Answer,
                    onChanged: (value) {
                      setState(() {
                        _question4Answer = value;
                      });
                    },
                  ),
                  Text('No'),
                ],
              ),

              SizedBox(height: 20),

              // Additional Text Field for other input (Not related to radio buttons)
              Text(
                'others:', // Title for the text field
                style: TextStyle(fontSize: 16),
              ),
              TextField(
                controller: _additionalNotesController, // Controller for the TextField
                decoration: InputDecoration(
                  hintText: 'if other specify...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4, // You can adjust the number of lines to your preference
              ),

              SizedBox(height: 20),

              // New Text Field 1
              Text(
                'extended(area) of residential land:', // Title for the first new text field
                style: TextStyle(fontSize: 16),
              ),
              TextField(
                controller: _additionalField1Controller, // Controller for the new text field
                decoration: InputDecoration(
                  hintText: 'specify...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4, // You can adjust the number of lines to your preference
              ),

              SizedBox(height: 20),

              // New Section: Accommodation in the aftermath of disaster
              Text(
                'Accommodation in the aftermath of disaster:',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Relief Camps',
                    groupValue: _accommodationAnswer,
                    onChanged: (value) {
                      setState(() {
                        _accommodationAnswer = value;
                      });
                    },
                  ),
                  Text('Relief Camps'),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Friends and Relatives',
                    groupValue: _accommodationAnswer,
                    onChanged: (value) {
                      setState(() {
                        _accommodationAnswer = value;
                      });
                    },
                  ),
                  Text('Friends and Relatives'),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Rented Room',
                    groupValue: _accommodationAnswer,
                    onChanged: (value) {
                      setState(() {
                        _accommodationAnswer = value;
                      });
                    },
                  ),
                  Text('Rented Room'),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Govt. Accommodation',
                    groupValue: _accommodationAnswer,
                    onChanged: (value) {
                      setState(() {
                        _accommodationAnswer = value;
                      });
                    },
                  ),
                  Text('Govt. Accommodation'),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Others',
                    groupValue: _accommodationAnswer,
                    onChanged: (value) {
                      setState(() {
                        _accommodationAnswer = value;
                      });
                    },
                  ),
                  Text('Others'),
                ],
              ),

              // Conditionally display the text field if 'Others' is selected
              if (_accommodationAnswer == 'Others')
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextField(
                    controller: _otherAccommodationController, // Controller for the 'Others' accommodation field
                    decoration: InputDecoration(
                      hintText: 'Specify where the accommodation is...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4, // You can adjust the number of lines to your preference
                  ),
                ),

              SizedBox(height: 20),

              // New Section: Vehicle Possession Question
              Text(
                'Do you possess any vehicle before disaster?',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Yes',
                    groupValue: _vehiclePossessionAnswer,
                    onChanged: (value) {
                      setState(() {
                        _vehiclePossessionAnswer = value;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: _vehiclePossessionAnswer,
                    onChanged: (value) {
                      setState(() {
                        _vehiclePossessionAnswer = value;
                      });
                    },
                  ),
                  Text('No'),
                ],
              ),

              // Conditionally display the vehicle type selection buttons and corresponding text fields if 'Yes' is selected
              if (_vehiclePossessionAnswer == 'Yes') ...[
                // Vehicle Type Selection
                Text(
                  'What type of vehicle did you possess?',
                  style: TextStyle(fontSize: 16),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _vehicleTypeAnswer = 'Two/Three Wheeler';
                          });
                        },
                        child: Text('Two/Three Wheeler'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _vehicleTypeAnswer = 'Four Wheeler';
                          });
                        },
                        child: Text('Four Wheeler'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _vehicleTypeAnswer = 'Any Other';
                          });
                        },
                        child: Text('Any Other'),
                      ),
                    ],
                  ),
                ),
                // Conditionally display the respective text fields based on the selected vehicle type
                if (_vehicleTypeAnswer != null)
                  Column(
                    children: [
                      TextField(
                        controller: _vehicleDetailsController,
                        decoration: InputDecoration(
                          hintText: 'Specify vehicle details...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _vehicleNumberController,
                        decoration: InputDecoration(
                          hintText: 'Vehicle number...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),

                // If the vehicle type is 'Any Other', show an additional text field
                if (_vehicleTypeAnswer == 'Any Other')
                  TextField(
                    controller: _otherVehicleController,
                    decoration: InputDecoration(
                      hintText: 'Specify the vehicle type...',
                      border: OutlineInputBorder(),
                    ),
                  ),
              ],

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/education-livilehood',
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
