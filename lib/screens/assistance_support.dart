import 'package:flutter/material.dart';
import 'package:resq/screens/familysurvay_home.dart';

class AssistanceSupport extends StatefulWidget {
  const AssistanceSupport({super.key});

  @override
  _AssistanceSupportState createState() => _AssistanceSupportState();
}

class _AssistanceSupportState extends State<AssistanceSupport> {
  String? _selectedAnswer; // Variable to store the selected answer
  TextEditingController _detailsController = TextEditingController(); // Controller for the text field

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/kudumbasree',
              (route) => false,
            ); // Pops the current screen and goes back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Any Specific Assistance or Support needed?',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20), // Space between the text and radio buttons

            // Radio buttons for Yes/No
            Row(
              children: [
                Radio<String>(
                  value: 'Yes',
                  groupValue: _selectedAnswer,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedAnswer = value;
                    });
                  },
                ),
                const Text('Yes'),
                Radio<String>(
                  value: 'No',
                  groupValue: _selectedAnswer,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedAnswer = value;
                    });
                  },
                ),
                const Text('No'),
              ],
            ),

            // Show TextField only if 'Yes' is selected
            if (_selectedAnswer == 'Yes') 
              Column(
                children: [
                  const SizedBox(height: 20),
                  TextField(
                    controller: _detailsController,
                    decoration: const InputDecoration(
                      labelText: 'Please specify',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20), // Space between the text and button

            // Submit button
            ElevatedButton(
              onPressed: () {
                // Action to be performed when the button is pressed
                // For now, show a snackbar and navigate to the next screen

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_selectedAnswer == 'Yes'
                        ? 'Assistance request submitted! Details: ${_detailsController.text}'
                        : 'Assistance request submitted!'),
                  ),
                );

                // Navigate to the ConfirmationPage after the form is submitted
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => const FamilysurvayHome()),
                // );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
