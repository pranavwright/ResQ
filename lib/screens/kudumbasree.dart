import 'package:flutter/material.dart';

class Kudumbasree extends StatefulWidget {
  const Kudumbasree({super.key});

  @override
  _KudumbasreeState createState() => _KudumbasreeState();
}

class _KudumbasreeState extends State<Kudumbasree> {
  // Variables to hold the selected values of the radio buttons for each question
  String? _question1Answer;
  String? _question2Answer;
  String? _question3Answer;
  String? _question4Answer;

  // Text controllers for each of the "Yes" questions' text fields
  TextEditingController _question1TextController = TextEditingController();
  TextEditingController _question2TextController = TextEditingController();
  TextEditingController _question3TextController = TextEditingController();
  TextEditingController _question4TextController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers to avoid memory leaks
    _question1TextController.dispose();
    _question2TextController.dispose();
    _question3TextController.dispose();
    _question4TextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kudumbasree'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Action to go back to the previous screen
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/special',
              (route) => false,
            ); // This pops the current screen
          },
        ),
      ),
      body: SingleChildScrollView(  // Wrap the body in SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question 1
            const Text(
              'Are you a member of any Kudumbashree community:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Yes',
                  groupValue: _question1Answer,
                  onChanged: (String? value) {
                    setState(() {
                      _question1Answer = value;
                    });
                  },
                ),
                const Text('Yes'),
                Radio<String>(
                  value: 'No',
                  groupValue: _question1Answer,
                  onChanged: (String? value) {
                    setState(() {
                      _question1Answer = value;
                    });
                  },
                ),
                const Text('No'),
              ],
            ),
            // Show text field when 'Yes' is selected for Question 1
            if (_question1Answer == 'Yes')
              TextField(
                controller: _question1TextController,
                decoration: const InputDecoration(
                  labelText: 'What is the name of your Neighborhood Group (NHG):',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 20),

            // Question 2
            const Text(
              '2. Have you taken any internal loans through your NHG:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Yes',
                  groupValue: _question2Answer,
                  onChanged: (String? value) {
                    setState(() {
                      _question2Answer = value;
                    });
                  },
                ),
                const Text('Yes'),
                Radio<String>(
                  value: 'No',
                  groupValue: _question2Answer,
                  onChanged: (String? value) {
                    setState(() {
                      _question2Answer = value;
                    });
                  },
                ),
                const Text('No'),
              ],
            ),
            // Show text field when 'Yes' is selected for Question 2
            if (_question2Answer == 'Yes')
              TextField(
                controller: _question2TextController,
                decoration: const InputDecoration(
                  labelText: 'Specify the amount:',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 20),

            // Question 3
            const Text(
              '3. Have you taken any linkage loans through your NHG?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Yes',
                  groupValue: _question3Answer,
                  onChanged: (String? value) {
                    setState(() {
                      _question3Answer = value;
                    });
                  },
                ),
                const Text('Yes'),
                Radio<String>(
                  value: 'No',
                  groupValue: _question3Answer,
                  onChanged: (String? value) {
                    setState(() {
                      _question3Answer = value;
                    });
                  },
                ),
                const Text('No'),
              ],
            ),
            // Show text field when 'Yes' is selected for Question 3
            if (_question3Answer == 'Yes')
              TextField(
                controller: _question3TextController,
                decoration: const InputDecoration(
                  labelText: 'Specify the amount:',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 20),

            // Question 4
            const Text(
              '4. Have you taken any micro-enterprise loans through your NHG:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Yes',
                  groupValue: _question4Answer,
                  onChanged: (String? value) {
                    setState(() {
                      _question4Answer = value;
                    });
                  },
                ),
                const Text('Yes'),
                Radio<String>(
                  value: 'No',
                  groupValue: _question4Answer,
                  onChanged: (String? value) {
                    setState(() {
                      _question4Answer = value;
                    });
                  },
                ),
                const Text('No'),
              ],
            ),
            // Show text field when 'Yes' is selected for Question 4
            if (_question4Answer == 'Yes')
              TextField(
                controller: _question4TextController,
                decoration: const InputDecoration(
                  labelText: 'Please specify the amount:',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 20),

            // Next Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/assistance', // Replace with your next route
                  (route) => false,
                );
                // Implement your action here (e.g., submit the data)
              },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
