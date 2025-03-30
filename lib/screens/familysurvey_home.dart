import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_a_screen.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';

class FamilySurveyHomeScreen extends StatefulWidget {
  @override
  _FamilySurveyHomeScreenState createState() => _FamilySurveyHomeScreenState();
}

class _FamilySurveyHomeScreenState extends State<FamilySurveyHomeScreen> {
  // This list will hold our saved survey data.
  List<NeedAssessmentData> surveys = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data when screen loads
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await TokenHttp().get(
        '/families/meAddedFamilies?disasterId=${AuthService().getDisasterId()}',
      );
      
      if (response != null && response['list'] is List) {
        List<NeedAssessmentData> loadedFamilies = [];
        
        for (var familyJson in response['list']) {
          try {
            final family = NeedAssessmentData.fromJson(familyJson);
            loadedFamilies.add(family);
          } catch (parseError) {
            print("Error parsing family data: $parseError");
          }
        }
        
        setState(() {
          surveys = loadedFamilies;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e'))
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Need Assessment Surveys'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchData,
            child: surveys.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No surveys found.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _createNewSurvey,
                        child: const Text('Create New Survey'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: surveys.length,
                  itemBuilder: (context, index) {
                    final survey = surveys[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          survey.householdHead.isNotEmpty
                            ? survey.householdHead
                            : 'Survey ${index + 1}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Village/Ward: ${survey.villageWard}'),
                            Text('Members: ${survey.numMembers}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit Survey',
                          onPressed: () => _editSurvey(survey),
                        ),
                        onTap: () => _editSurvey(survey),
                      ),
                    );
                  },
                ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewSurvey,
        tooltip: 'Create New Survey',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _createNewSurvey() {
    final newSurvey = NeedAssessmentData(); // Create a new, empty survey
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScreenA(data: newSurvey)),
    ).then((value) {
      // Refresh data when returning from the survey form
      _fetchData();
    });
  }

  void _editSurvey(NeedAssessmentData surveyData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScreenA(data: surveyData)),
    ).then((value) {
      // Refresh data when returning from the survey form
      _fetchData();
    });
  }
}