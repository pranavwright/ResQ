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
  String? selectedAnganwadiStatus;
  String? selectedChildrenMalnutritionStatus;
  String? selectedFoodAssistanceSufficient;
  String? selectedGovtNutritionDisruption;
  String? selectedHealthInsuranceStatus;
  String? foodAssistanceDetails;

  @override
  void initState() {
    super.initState();
    selectedAnganwadiStatus = widget.data.anganwadiStatus;
    selectedChildrenMalnutritionStatus = widget.data.childrenMalnutritionStatus;
    selectedFoodAssistanceSufficient = widget.data.foodAssistanceSufficient;
    selectedGovtNutritionDisruption = widget.data.govtNutritionDisruption;
    selectedHealthInsuranceStatus = widget.data.healthInsuranceStatus;
    foodAssistanceDetails = widget.data.foodAssistanceNeedDuration; // or other relevant field
  }

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
              // Anganwadi Status (Damaged: Yes/No)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Anganwadi Status (Damaged: Yes/No)', style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'Yes',
                          groupValue: selectedAnganwadiStatus,
                          onChanged: (value) {
                            setState(() {
                              selectedAnganwadiStatus = value;
                              widget.data.anganwadiStatus = value!;
                            });
                          },
                        ),
                        Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: selectedAnganwadiStatus,
                          onChanged: (value) {
                            setState(() {
                              selectedAnganwadiStatus = value;
                              widget.data.anganwadiStatus = value!;
                            });
                          },
                        ),
                        Text('No'),
                      ],
                    ),
                  ],
                ),
              ),
              // Children with Malnutrition (Yes/No)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Children with Malnutrition (Yes/No)', style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'Yes',
                          groupValue: selectedChildrenMalnutritionStatus,
                          onChanged: (value) {
                            setState(() {
                              selectedChildrenMalnutritionStatus = value;
                              widget.data.childrenMalnutritionStatus = value!;
                            });
                          },
                        ),
                        Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: selectedChildrenMalnutritionStatus,
                          onChanged: (value) {
                            setState(() {
                              selectedChildrenMalnutritionStatus = value;
                              widget.data.childrenMalnutritionStatus = value!;
                            });
                          },
                        ),
                        Text('No'),
                      ],
                    ),
                  ],
                ),
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
              // Present Food Assistance Sufficient (Yes/No)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Present Food Assistance Sufficient (Yes/No)', style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'Yes',
                          groupValue: selectedFoodAssistanceSufficient,
                          onChanged: (value) {
                            setState(() {
                              selectedFoodAssistanceSufficient = value;
                              widget.data.foodAssistanceSufficient = value!;
                              foodAssistanceDetails = ''; // Reset the text field if Yes is selected
                            });
                          },
                        ),
                        Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: selectedFoodAssistanceSufficient,
                          onChanged: (value) {
                            setState(() {
                              selectedFoodAssistanceSufficient = value;
                              widget.data.foodAssistanceSufficient = value!;
                            });
                          },
                        ),
                        Text('No'),
                      ],
                    ),
                    // Show TextFormField if "No" is selected
                    if (selectedFoodAssistanceSufficient == 'No')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'please specify'),
                        initialValue: foodAssistanceDetails,
                        onChanged: (value) {
                          setState(() {
                            foodAssistanceDetails = value;
                            widget.data.foodAssistanceNeedDuration = value;
                          });
                        },
                      ),
                  ],
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Food Assistance Need Duration'),
                initialValue: widget.data.foodAssistanceNeedDuration,
                onChanged: (value) => widget.data.foodAssistanceNeedDuration = value,
              ),
              // Disruption in Government Nutrition Service (Yes/No)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Disruption in Government Nutrition Service', style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'Yes',
                          groupValue: selectedGovtNutritionDisruption,
                          onChanged: (value) {
                            setState(() {
                              selectedGovtNutritionDisruption = value;
                              widget.data.govtNutritionDisruption = value!;
                            });
                          },
                        ),
                        Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: selectedGovtNutritionDisruption,
                          onChanged: (value) {
                            setState(() {
                              selectedGovtNutritionDisruption = value;
                              widget.data.govtNutritionDisruption = value!;
                            });
                          },
                        ),
                        Text('No'),
                      ],
                    ),
                  ],
                ),
              ),
              // Health Insurance Coverage (Yes/No)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Health Insurance Coverage (Yes/No)', style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'Yes',
                          groupValue: selectedHealthInsuranceStatus,
                          onChanged: (value) {
                            setState(() {
                              selectedHealthInsuranceStatus = value;
                              widget.data.healthInsuranceStatus = value!;
                            });
                          },
                        ),
                        Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: selectedHealthInsuranceStatus,
                          onChanged: (value) {
                            setState(() {
                              selectedHealthInsuranceStatus = value;
                              widget.data.healthInsuranceStatus = value!;
                            });
                          },
                        ),
                        Text('No'),
                      ],
                    ),
                  ],
                ),
              ),
              // Health Insurance Details (appears only if Health Insurance is Yes)
              if (selectedHealthInsuranceStatus == 'Yes')
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
