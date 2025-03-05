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

  // Controller for the new TextField
  TextEditingController _additionalNotesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shelter'),
        leading: BackButton(), // This adds the back arrow button in the AppBar
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
                'Permanent structure',
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
                'House built with government assistance',
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
                'Rented',
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
                'Paadi (Layam)',
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
            ],
          ),
        ),
      ),
    );
  }
}
