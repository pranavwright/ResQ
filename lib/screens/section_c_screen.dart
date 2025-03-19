import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_d_screen.dart';

class ScreenC extends StatefulWidget {
  final NeedAssessmentData data;

  ScreenC({required this.data});

  @override
  _ScreenCState createState() => _ScreenCState();
}

class _ScreenCState extends State<ScreenC> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section C: Health and Nutrition'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Number of Children in Anganwadi'),
                initialValue: widget.data.numChildrenAnganwadi.toString(),
                onChanged: (value) => widget.data.numChildrenAnganwadi = int.tryParse(value) ?? 0,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Anganwadi Status (Damaged: Yes/No)'),
                initialValue: widget.data.anganwadiStatus,
                onChanged: (value) => widget.data.anganwadiStatus = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Children with Malnutrition (Yes/No)'),
                initialValue: widget.data.childrenMalnutritionStatus,
                onChanged: (value) => widget.data.childrenMalnutritionStatus = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Number of Pregnant Women'),
                initialValue: widget.data.numPregnantWomen.toString(),
                onChanged: (value) => widget.data.numPregnantWomen = int.tryParse(value) ?? 0,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Number of Lactating Mothers'),
                initialValue: widget.data.numLactatingMothers.toString(),
                onChanged: (value) => widget.data.numLactatingMothers = int.tryParse(value) ?? 0,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Present Food Assistance Sufficient (Yes/No)'),
                initialValue: widget.data.foodAssistanceSufficient,
                onChanged: (value) => widget.data.foodAssistanceSufficient = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Food Assistance Need Duration'),
                initialValue: widget.data.foodAssistanceNeedDuration,
                onChanged: (value) => widget.data.foodAssistanceNeedDuration = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Disruption in Government Nutrition Service'),
                initialValue: widget.data.govtNutritionDisruption,
                onChanged: (value) => widget.data.govtNutritionDisruption = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Health Insurance Coverage (Yes/No)'),
                initialValue: widget.data.healthInsuranceStatus,
                onChanged: (value) => widget.data.healthInsuranceStatus = value,
              ),
              if (widget.data.healthInsuranceStatus == 'Yes')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Health Insurance Details'),
                  initialValue: widget.data.healthInsuranceDetails,
                  onChanged: (value) => widget.data.healthInsuranceDetails = value,
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenD(data: widget.data),
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