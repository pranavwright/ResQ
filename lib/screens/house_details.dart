import 'package:flutter/material.dart';

class HouseDetails extends StatefulWidget {
  const HouseDetails({super.key});

  @override
  _HouseDetailsState createState() => _HouseDetailsState();
}

class _HouseDetailsState extends State<HouseDetails> {
  // Create TextEditingControllers for each text field
  final TextEditingController houseNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController wardNumberController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController toiletController = TextEditingController();
  final TextEditingController tableController = TextEditingController();
  final TextEditingController chairController = TextEditingController();
  final TextEditingController fanController = TextEditingController();
  final TextEditingController lightController = TextEditingController();
  final TextEditingController bedController = TextEditingController();
  final TextEditingController accomadationController = TextEditingController();

  // Variable to manage the "Ready to Occupy" radio buttons
  String? _readyToOccupy = 'No';  // Default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details of the House'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            // Navigate back to the previous screen
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(  // Wrap the body with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title below the AppBar
              Text(
                'Details of the given house:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),  // Adds space below the title

              // House Name TextField
              TextField(
                controller: houseNameController,
                decoration: InputDecoration(
                  labelText: 'House Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),  // Adds space below the text field

              // Location TextField
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),  // Adds space below the text field

              // Owner TextField
              TextField(
                controller: ownerController,
                decoration: InputDecoration(
                  labelText: 'Owner of the House',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),  // Adds space below the text field

              // House Number TextField
              TextField(
                controller: houseNumberController,
                decoration: InputDecoration(
                  labelText: 'House Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),  // Adds space below the text field

              // Ward Number TextField
              TextField(
                controller: wardNumberController,
                decoration: InputDecoration(
                  labelText: 'Ward Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),  // Adds space below the text field

              // Contact Number TextField
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16), 
              // Toilet Count TextField (Only accepts numbers)
              TextField(
                controller: toiletController,
                decoration: InputDecoration(
                  labelText: 'Toilet Count',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,  // Only accept numbers
              ),
              SizedBox(height: 16),

              // Table Count TextField (Only accepts numbers)
              TextField(
                controller: tableController,
                decoration: InputDecoration(
                  labelText: 'Table Count',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,  // Only accept numbers
              ),
              SizedBox(height: 16),

              // Chair Count TextField (Only accepts numbers)
              TextField(
                controller: chairController,
                decoration: InputDecoration(
                  labelText: 'Chair Count',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,  // Only accept numbers
              ),
              SizedBox(height: 16),

              // Fan Count TextField (Only accepts numbers)
              TextField(
                controller: fanController,
                decoration: InputDecoration(
                  labelText: 'Fan Count',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,  // Only accept numbers
              ),
              SizedBox(height: 16),

              // Light Count TextField (Only accepts numbers)
              TextField(
                controller: lightController,
                decoration: InputDecoration(
                  labelText: 'Light Count',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,  // Only accept numbers
              ),
              SizedBox(height: 16),

              // Bed Count TextField (Only accepts numbers)
              TextField(
                controller: bedController,
                decoration: InputDecoration(
                  labelText: 'Bed Count',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,  // Only accept numbers
              ),
              SizedBox(height: 24),
              
              // Accommodation TextField
              TextField(
                controller: accomadationController,
                decoration: InputDecoration(
                  labelText: 'Maximum number of people can be accommodated',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,  // Only accept numbers
              ),
              SizedBox(height: 24),  // Adds space before the radio buttons

              // "Ready to Occupy" Question with Yes/No Radio Buttons
              Text(
                'Is the house ready to occupy?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Yes',
                        groupValue: _readyToOccupy,
                        onChanged: (String? value) {
                          setState(() {
                            _readyToOccupy = value;
                          });
                        },
                      ),
                      Text('Yes'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'No',
                        groupValue: _readyToOccupy,
                        onChanged: (String? value) {
                          setState(() {
                            _readyToOccupy = value;
                          });
                        },
                      ),
                      Text('No'),
                    ],
                  ),
                ],
              ),

              // Button to handle submission or navigation
              ElevatedButton(
                onPressed: () {
                  // Retrieve values from the text controllers and radio buttons
                  String houseName = houseNameController.text;
                  String location = locationController.text;
                  String owner = ownerController.text;
                  String houseNumber = houseNumberController.text;
                  String wardNumber = wardNumberController.text;
                  String contact = contactController.text;
                  String toiletCount = toiletController.text;
                  String tableCount = tableController.text;
                  String chairCount = chairController.text;
                  String fanCount = fanController.text;
                  String lightCount = lightController.text;
                  String bedCount = bedController.text;
                  String accomadation = accomadationController.text;
                  String readyToOccupy = _readyToOccupy ?? 'No';

                  // Print values for now
                  print('House Name: $houseName');
                  print('Location: $location');
                  print('Owner: $owner');
                  print('House Number: $houseNumber');
                  print('Ward Number: $wardNumber');
                  print('Contact: $contact');
                  print('Toilet Count: $toiletCount');
                  print('Table Count: $tableCount');
                  print('Chair Count: $chairCount');
                  print('Fan Count: $fanCount');
                  print('Light Count: $lightCount');
                  print('Bed Count: $bedCount');
                  print('Accommodation: $accomadation');
                  print('Ready to Occupy: $readyToOccupy');

                  // You can navigate to another screen or handle form submission here
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
