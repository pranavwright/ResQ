import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'dart:convert';

import 'package:resq/utils/http/token_http.dart'; // Import for JSON encoding

class ScreenK extends StatelessWidget {
  final NeedAssessmentData data;

  ScreenK({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen K: Review and Submit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Your Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // Display all the data here, for example:
              Text('Village/Ward: ${data.villageWard}'),
              Text('House Number: ${data.houseNumber}'),
              Text('Household Head: ${data.householdHead}'),
              // ... Display other fields similarly ...
              Text('Members:'),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: data.members.length,
                itemBuilder: (context, index) {
                  return Text(
                    '  - ${data.members[index].name}, Age: ${data.members[index].age}, Gender: ${data.members[index].gender}',
                  );
                },
              ),
              Text('Loan Details:'),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: data.loanDetails.length,
                itemBuilder: (context, index) {
                  return Text(
                    '  - Bank: ${data.loanDetails[index].bankName}, Loan: ${data.loanDetails[index].loanCategory}',
                  );
                },
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Print the data to the console as JSON
                  print(
                    jsonEncode(data.toJson()),
                  ); 
                  TokenHttp().post('/families/addFamily', {...data.toJson(), 'disasterId': AuthService().getDisasterId()});
                  // Show a success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Data submitted successfully!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context); // Navigate back after submission
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
