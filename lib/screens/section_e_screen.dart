import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_f_screen.dart';

class ScreenE extends StatefulWidget {
  final NeedAssessmentData data;

  ScreenE({required this.data});

  @override
  _ScreenEState createState() => _ScreenEState();
}

class _ScreenEState extends State<ScreenE> {
  String? livelihoodAffected;

  @override
  void initState() {
    super.initState();
    livelihoodAffected = widget.data.livelihoodAffected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section E: Livelihood Impact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Average Monthly Family Income Text Field
              TextFormField(
                decoration: InputDecoration(labelText: 'Average Monthly Family Income'),
                initialValue: widget.data.avgMonthlyFamilyIncome.toString(),
                onChanged: (value) => widget.data.avgMonthlyFamilyIncome = double.tryParse(value) ?? 0.0,
                keyboardType: TextInputType.number,
              ),

              // Primary Source of Income Text Field
              TextFormField(
                decoration: InputDecoration(labelText: 'Primary Source of Income'),
                initialValue: widget.data.primaryIncomeSource,
                onChanged: (value) => widget.data.primaryIncomeSource = value,
              ),

              // Livelihood Affected Radio Buttons
              Row(
                children: [
                  Text('Livelihood Affected losses: '),
                  Radio<String>(
                    value: 'Yes',
                    groupValue: livelihoodAffected,
                    onChanged: (value) {
                      setState(() {
                        livelihoodAffected = value;
                        widget.data.livelihoodAffected = value!;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: livelihoodAffected,
                    onChanged: (value) {
                      setState(() {
                        livelihoodAffected = value;
                        widget.data.livelihoodAffected = value!;
                      });
                    },
                  ),
                  Text('No'),
                ],
              ),

              // If Livelihood Affected is 'Yes', show additional checkboxes
              if (livelihoodAffected == 'Yes')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: Text('Employment Loss'),
                      value: widget.data.employmentLoss == 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.data.employmentLoss = value! ? 'Yes' : 'No';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Business Loss'),
                      value: widget.data.businessLoss == 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.data.businessLoss = value! ? 'Yes' : 'No';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Daily Wage Loss'),
                      value: widget.data.dailyWageLoss == 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.data.dailyWageLoss = value! ? 'Yes' : 'No';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Breadwinner Loss'),
                      value: widget.data.breadwinnerLoss == 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.data.breadwinnerLoss = value! ? 'Yes' : 'No';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Animal Loss'),
                      value: widget.data.animalLoss == 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.data.animalLoss = value! ? 'Yes' : 'No';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Agricultural Land Loss'),
                      value: widget.data.agriculturalLandLoss == 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.data.agriculturalLandLoss = value! ? 'Yes' : 'No';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Other Livelihood Loss'),
                      value: widget.data.otherLivelihoodLoss == 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.data.otherLivelihoodLoss = value! ? 'Yes' : 'No';
                        });
                      },
                    ),
                    if (widget.data.otherLivelihoodLoss == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Other Livelihood Loss Details'),
                        initialValue: widget.data.otherLivelihoodLossDetails,
                        onChanged: (value) => widget.data.otherLivelihoodLossDetails = value,
                      ),
                    CheckboxListTile(
                      title: Text('Agricultural Land Loss Area'),
                      value: widget.data.agriculturalLandLossArea.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.agriculturalLandLossArea = value! ? 'Area lost' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Stored Crops Loss'),
                      value: widget.data.storedCropsLoss == 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.data.storedCropsLoss = value! ? 'Yes' : 'No';
                        });
                      },
                    ),
                    if (widget.data.storedCropsLoss == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Crop Type'),
                        initialValue: widget.data.cropType,
                        onChanged: (value) => widget.data.cropType = value,
                      ),
                    CheckboxListTile(
                      title: Text('Equipment Loss'),
                      value: widget.data.equipmentLoss == 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.data.equipmentLoss = value! ? 'Yes' : 'No';
                        });
                      },
                    ),
                    if (widget.data.equipmentLoss == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Equipment Loss Details'),
                        initialValue: widget.data.equipmentLossDetails,
                        onChanged: (value) => widget.data.equipmentLossDetails = value,
                      ),
                    CheckboxListTile(
                      title: Text('Animal Husbandry Loss'),
                      value: widget.data.animalHusbandryLoss == 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.data.animalHusbandryLoss = value! ? 'Yes' : 'No';
                        });
                      },
                    ),
                    if (widget.data.animalHusbandryLoss == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Animal Husbandry Loss Details'),
                        initialValue: widget.data.animalHusbandryLossDetails,
                        onChanged: (value) => widget.data.animalHusbandryLossDetails = value,
                      ),
                    CheckboxListTile(
                      title: Text('Shed Loss'),
                      value: widget.data.shedLoss == 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.data.shedLoss = value! ? 'Yes' : 'No';
                        });
                      },
                    ),
                    if (widget.data.shedLoss == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Shed Loss Details'),
                        initialValue: widget.data.shedLossDetails,
                        onChanged: (value) => widget.data.shedLossDetails = value,
                      ),
                    CheckboxListTile(
                      title: Text('Equipment/Tools Loss'),
                      value: widget.data.equipmentToolsLoss == 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.data.equipmentToolsLoss = value! ? 'Yes' : 'No';
                        });
                      },
                    ),
                    if (widget.data.equipmentToolsLoss == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Equipment/Tools Loss Details'),
                        initialValue: widget.data.equipmentToolsLossDetails,
                        onChanged: (value) => widget.data.equipmentToolsLossDetails = value,
                      ),
                    CheckboxListTile(
                      title: Text('Livelihood Insurance'),
                      value: widget.data.livelihoodInsurance == 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.data.livelihoodInsurance = value! ? 'Yes' : 'No';
                        });
                      },
                    ),
                    if (widget.data.livelihoodInsurance == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Livelihood Insurance Details'),
                        initialValue: widget.data.livelihoodInsuranceDetails,
                        onChanged: (value) => widget.data.livelihoodInsuranceDetails = value,
                      ),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenF(data: widget.data),
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
