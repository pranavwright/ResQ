import 'package:flutter/material.dart';
import 'package:resq/screens/a_section_screen.dart';

// Model class for need assessment data
class NeedAssessmentData {
  String villageWard = '';
  String houseNumber = '';
  String householdHead = '';
  String address = '';
  String contactNo = '';
  String rationCardNo = '';
  String rationCategory = '';
  String caste = '';
  String anganwadiStatus = '';
  String childrenMalnutritionStatus = '';
  String healthInsuranceStatus = '';
  String specialAssistanceRequired = '';
  String shelterType = '';
  String accommodationStatus = '';
  String childrenEducationStatus = '';
  String livelihoodStatus = '';
  String agriculturalLoss = '';
  String pensionStatus = '';
  String loanRepaymentStatus = '';
  String specialCategoryStatus = '';
  String kudumbashreeMembership = '';
  String additionalSupportRequired = '';
  String uniqueHouseholdId = ''; // Unique ID for each household
  String educationAssistanceRequired = '';
  String livelihoodAssistanceRequired =
      ''; // Assistance required for livelihood
  String storedCropsLoss = ''; // Loss of stored crops
  String equipmentLoss = ''; // Loss of equipment/tools
  String outstandingLoans = ''; // Any outstanding loans (Yes/No)
  String assistanceRequired = '';
  String kudumbashreeSupportRequired = '';
  String foodSecurityAdditionalInfo = '';
}

class Familysurveyhome extends StatelessWidget {
  Familysurveyhome({Key? key}) : super(key: key);

  // Sample survey data for demonstration (based on the PDF fields)
  final List<NeedAssessmentData> surveys = [
    NeedAssessmentData()
      ..villageWard = 'Wayanad'
      ..houseNumber = '123'
      ..householdHead = 'John Doe'
      ..address = 'Wayanad, Kerala'
      ..contactNo = '9876543210'
      ..rationCardNo = 'R12345'
      ..rationCategory = 'White'
      ..caste = 'General'
      ..anganwadiStatus = 'Yes'
      ..childrenMalnutritionStatus = 'No'
      ..healthInsuranceStatus = 'Yes'
      ..specialAssistanceRequired = 'None'
      ..shelterType = 'Permanent'
      ..accommodationStatus = 'Relief Camp'
      ..childrenEducationStatus = 'Yes'
      ..livelihoodStatus = 'Employed'
      ..agriculturalLoss = 'None'
      ..pensionStatus = 'Yes'
      ..loanRepaymentStatus = 'Pending'
      ..specialCategoryStatus = 'None'
      ..kudumbashreeMembership = 'Yes'
      ..additionalSupportRequired = 'None',
    // You can add more survey entries as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Surveys'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add button logic (for now just prints the action)
              print("Add new survey");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ASectionScreen(data: NeedAssessmentData()),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Recent Surveys',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: surveys.length,
              itemBuilder: (context, index) {
                final survey = surveys[index];
                return SurveyCard(
                  data: survey,
                  onEdit: () {
                    // Edit button logic
                    // Navigate to the edit screen and pass the survey data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ASectionScreen(data: survey),
                      ),
                    );
                    print('Edit survey for ${survey.householdHead}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SurveyCard extends StatelessWidget {
  final NeedAssessmentData data;
  final VoidCallback onEdit;

  const SurveyCard({Key? key, required this.data, required this.onEdit})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            data.villageWard[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          data.householdHead,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Status: ${data.anganwadiStatus}'),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
