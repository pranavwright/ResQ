import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_i_screen.dart';

class ScreenH extends StatefulWidget {
  final NeedAssessmentData data;

  ScreenH({required this.data});

  @override
  _ScreenHState createState() => _ScreenHState();
}

class _ScreenHState extends State<ScreenH> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section H: Additional Support and Food Security'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Additional Support Required'),
                initialValue: widget.data.additionalSupportRequired,
                onChanged: (value) => widget.data.additionalSupportRequired = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Food Security Additional Information'),
                initialValue: widget.data.foodSecurityAdditionalInfo,
                onChanged: (value) => widget.data.foodSecurityAdditionalInfo = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenI(data: widget.data),
                    ),
                  );
                },
                child: Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}