import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_a_screen.dart';

class FamilySurveyHomeScreen extends StatefulWidget {
  @override
  _FamilySurveyHomeScreenState createState() => _FamilySurveyHomeScreenState();
}

class _FamilySurveyHomeScreenState extends State<FamilySurveyHomeScreen> {
  // This list will hold our saved survey data.
  List<NeedAssessmentData> surveys = [
    // Sample Data 1
    NeedAssessmentData()
      ..householdHead = "Sample Head 1"
      ..villageWard = "Sample Ward 1"
      ..members = [
        Member(
          name: "Member 1.1",
          age: "30",
          gender: "Male",
          relationship: "Father",
        ),
        Member(
          name: "Member 1.2",
          age: "25",
          gender: "Female",
          relationship: "Mother",
        ),
      ],
    // Sample Data 2
    NeedAssessmentData()
      ..householdHead = "Sample Head 2"
      ..villageWard = "Sample Ward 2"
      ..members = [
        Member(
          name: "Member 2.1",
          age: "50",
          gender: "Male",
          relationship: "Head",
        ),
      ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Need Assessment Surveys')),
      body:
          surveys.isEmpty
              ? Center(child: Text('No surveys saved yet.'))
              : ListView.builder(
                itemCount: surveys.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        surveys[index].householdHead.isNotEmpty
                            ? surveys[index].householdHead
                            : 'Survey ${index + 1}',
                      ), // Display household head or a default name
                      subtitle: Text(
                        'Village/Ward: ${surveys[index].villageWard}',
                      ),
                      onTap: () {
                        _editSurvey(surveys[index]);
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewSurvey,
        tooltip: 'Create New Survey',
        child: Icon(Icons.add),
      ),
    );
  }

  void _createNewSurvey() {
    setState(() {
      final newSurvey = NeedAssessmentData(); // Create a new, empty survey
      surveys.add(newSurvey); // Add it to the list
      _editSurvey(newSurvey); // Navigate to edit it immediately
    });
  }

  void _editSurvey(NeedAssessmentData surveyData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScreenA(data: surveyData)),
    ).then((value) {
      // This 'then' block is important!
      // It's executed when we come back from ScreenA (or any edit screen).
      setState(() {
        // We call setState to rebuild the FamilySurveyHomeScreen and reflect any changes
        // that might have been made in the edit screen.
      });
    });
  }
}
