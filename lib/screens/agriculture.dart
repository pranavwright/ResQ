import 'package:flutter/material.dart';
import 'package:resq/screens/social.dart';

class Agriculture extends StatefulWidget {
  const Agriculture({super.key});

  @override
  _AgricultureState createState() => _AgricultureState();
}

class _AgricultureState extends State<Agriculture> {
  // Radio button value (Yes or No)
  String? _hasLostItems = 'No'; // Default is 'No'

  // Animal Husbandry Radio button values
  String? _hasLostLivestock = 'No';
  String? _hasLostFeedingMaterials = 'No';
  String? _hasLostShelter = 'No';
  String? _hasLostFarmEquipment = 'No';

  // Controller for specifying the loss details
  final TextEditingController _lossDetailsController = TextEditingController();
  final TextEditingController _livestockDetailsController = TextEditingController();
  final TextEditingController _feedingMaterialsDetailsController = TextEditingController();
  final TextEditingController _shelterDetailsController = TextEditingController();
  final TextEditingController _farmEquipmentDetailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agriculture and Allied'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/skill',
                  (route) => false,
                ); // Pops the current screen off the navigation stack
          },
        ),
      ),
      body: SingleChildScrollView(  // Wrap the entire body in a SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Heading
              const Text(
                'Agriculture and Allied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20), // Space between heading and text fields

              // First Text Field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Did you incur loss of agricultural land (area)?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16), // Space between text fields

              // Second Text Field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Did you experience any loss of stored crops (quantity)?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16), // Space between text fields

              // Third Text Field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Type of crops?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16), // Space between text fields

              // Question: Did you lose any equipment/tools/vehicle?
              const Text(
                'Did you lose any equipment/tools/vehicle?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // Radio Button Yes
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Yes',
                        groupValue: _hasLostItems,
                        onChanged: (String? value) {
                          setState(() {
                            _hasLostItems = value;
                          });
                        },
                      ),
                      const Text('Yes'),
                    ],
                  ),
                  // Radio Button No
                  Row(
                    children: [
                      Radio<String>(
                        value: 'No',
                        groupValue: _hasLostItems,
                        onChanged: (String? value) {
                          setState(() {
                            _hasLostItems = value;
                          });
                        },
                      ),
                      const Text('No'),
                    ],
                  ),
                ],
              ),

              // If "Yes" is selected, show the text field to specify details
              if (_hasLostItems == 'Yes')
                Column(
                  children: [
                    const SizedBox(height: 16), // Space
                    const Text(
                      'Please specify what you lost:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8), // Space
                    TextField(
                      controller: _lossDetailsController,
                      decoration: const InputDecoration(
                        labelText: 'Loss Details',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),

              // Animal Husbandry Section
              const SizedBox(height: 20), // Space before Animal Husbandry section
              const Text(
                'Animal Husbandry',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16), // Space between the heading and radio buttons

              // Animal Husbandry Questions and Radio Buttons
              // 1. Did you lose livestock?
              const Text(
                'Have you suffered the loss of any Cattle or Poultry:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Yes',
                    groupValue: _hasLostLivestock,
                    onChanged: (String? value) {
                      setState(() {
                        _hasLostLivestock = value;
                      });
                    },
                  ),
                  const Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: _hasLostLivestock,
                    onChanged: (String? value) {
                      setState(() {
                        _hasLostLivestock = value;
                      });
                    },
                  ),
                  const Text('No'),
                ],
              ),
              if (_hasLostLivestock == 'Yes') 
                Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Please specify',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: _livestockDetailsController,
                      decoration: const InputDecoration(
                        labelText: 'Livestock details',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // 2. Did you lose feeding materials?
              const Text(
                'Have you lost any Poultry Shed or Cattle Shed:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Yes',
                    groupValue: _hasLostFeedingMaterials,
                    onChanged: (String? value) {
                      setState(() {
                        _hasLostFeedingMaterials = value;
                      });
                    },
                  ),
                  const Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: _hasLostFeedingMaterials,
                    onChanged: (String? value) {
                      setState(() {
                        _hasLostFeedingMaterials = value;
                      });
                    },
                  ),
                  const Text('No'),
                ],
              ),
              if (_hasLostFeedingMaterials == 'Yes') 
                Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Please specify',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: _feedingMaterialsDetailsController,
                      decoration: const InputDecoration(
                        labelText: 'Feeding materials details',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // 3. Did you lose shelter for animals?
              const Text(
                'Did you lose any equipment or Tools:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Yes',
                    groupValue: _hasLostShelter,
                    onChanged: (String? value) {
                      setState(() {
                        _hasLostShelter = value;
                      });
                    },
                  ),
                  const Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: _hasLostShelter,
                    onChanged: (String? value) {
                      setState(() {
                        _hasLostShelter = value;
                      });
                    },
                  ),
                  const Text('No'),
                ],
              ),
              if (_hasLostShelter == 'Yes') 
                Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Please specify:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: _shelterDetailsController,
                      decoration: const InputDecoration(
                        labelText: 'Shelter details',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // 4. Did you lose farm equipment?
              const Text(
                'Do you have any livelihood Insurance Coverage(agricultural land-crop/animals):',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Yes',
                    groupValue: _hasLostFarmEquipment,
                    onChanged: (String? value) {
                      setState(() {
                        _hasLostFarmEquipment = value;
                      });
                    },
                  ),
                  const Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: _hasLostFarmEquipment,
                    onChanged: (String? value) {
                      setState(() {
                        _hasLostFarmEquipment = value;
                      });
                    },
                  ),
                  const Text('No'),
                ],
              ),
              if (_hasLostFarmEquipment == 'Yes') 
                Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Please specify:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: _farmEquipmentDetailsController,
                      decoration: const InputDecoration(
                        labelText: 'Insurance details',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // "Next" Button to Navigate to Another Screen
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the next screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Social(), // Replace with your next screen
                      ),
                    );
                  },
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
