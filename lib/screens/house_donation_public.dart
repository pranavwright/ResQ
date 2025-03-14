import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resq/screens/googlemapscreen.dart';
import 'package:resq/screens/login_screen.dart';

class HouseDonationPublic extends StatefulWidget {
  const HouseDonationPublic({super.key});

  @override
  _HouseDonationPublicState createState() => _HouseDonationPublicState();
}

class _HouseDonationPublicState extends State<HouseDonationPublic> {
  // Create TextEditingController for each text field
  final TextEditingController housenameController = TextEditingController();
  final TextEditingController locationofthehouseController = TextEditingController();
  final TextEditingController ownerofthehouseController = TextEditingController();
  final TextEditingController housenumberController = TextEditingController();
  final TextEditingController wardnumberController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController squarefeetcontactController = TextEditingController();

  // Variable for Dropdown (House Condition)
  String? conditionValue = 'Excellent';

  // Function to open Google Maps and get the location
  Future<void> _selectLocationFromMap() async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleMapScreen(), // Navigate to GoogleMapScreen
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        locationofthehouseController.text =
            'Lat: ${selectedLocation.latitude}, Lng: ${selectedLocation.longitude}'; // Update the text field with the selected location
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('House Donation'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // This will pop the current screen off the navigation stack
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title below the AppBar
            Text(
              'Please provide house donation details:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),  // Adds space below the title

            // House Name TextField
            TextField(
              controller: housenameController, // Assign controller here
              decoration: InputDecoration(
                labelText: 'House Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            
            // Location of the house TextField
            GestureDetector(
              onTap: _selectLocationFromMap, // Open Google Maps when tapped
              child: AbsorbPointer(
                child: TextField(
                  controller: locationofthehouseController, // Assign controller here
                  decoration: InputDecoration(
                    labelText: 'Location of the house',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: ownerofthehouseController, // Assign controller here
              decoration: InputDecoration(
                labelText: 'Owner of the house',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: housenumberController, // Assign controller here
              decoration: InputDecoration(
                labelText: 'House number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: wardnumberController, // Assign controller here
              decoration: InputDecoration(
                labelText: 'Ward number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: contactController, // Assign controller here
              decoration: InputDecoration(
                labelText: 'Contact number of the owner',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: squarefeetcontactController, // Assign controller here
              decoration: InputDecoration(
                labelText: 'Square feet',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            
            // Dropdown for House Condition
            DropdownButtonFormField<String>(
              value: conditionValue,  // The current selected value
              items: ['Excellent', 'Good', 'Poor'].map((String condition) {
                return DropdownMenuItem<String>(
                  value: condition,
                  child: Text(condition),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  conditionValue = newValue;
                });
              },
              decoration: InputDecoration(
                labelText: 'Remarks',
                border: OutlineInputBorder(),
              ),
            ),

            Spacer(),  // Pushes the "Next" button to the bottom
            Center( // Centers the "Next" button
              child: ElevatedButton(
                onPressed: () {
                  // Retrieve the values from the controllers
                  String name = housenameController.text;
                  String location = locationofthehouseController.text;
                  String owner = ownerofthehouseController.text;
                  String housenumber = housenumberController.text;
                  String ward = wardnumberController.text;
                  String contact = contactController.text;
                  String squarefeet =squarefeetcontactController.text;
                  String condition = conditionValue ?? 'Excellent';  // If null, use 'Excellent'

                  // You can now pass these values to the next screen or store them
                  print('House Name: $name, Location: $location, Owner: $owner, House number: $housenumber, Ward: $ward, Contact: $contact, Condition: $condition, Square feet: $squarefeet');

                  // Navigate to the next page (HouseDetails)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
