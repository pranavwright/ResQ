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
              TextFormField(
                decoration: InputDecoration(labelText: 'Average Monthly Family Income'),
                initialValue: widget.data.avgMonthlyFamilyIncome.toString(),
                onChanged: (value) => widget.data.avgMonthlyFamilyIncome = double.tryParse(value) ?? 0.0,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Primary Source of Income'),
                initialValue: widget.data.primaryIncomeSource,
                onChanged: (value) => widget.data.primaryIncomeSource = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Livelihood Affected (Yes/No)'),
                initialValue: widget.data.livelihoodAffected,
                onChanged: (value) => widget.data.livelihoodAffected = value,
              ),
              if (widget.data.livelihoodAffected == 'Yes')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Employment Loss'),
                      initialValue: widget.data.employmentLoss,
                      onChanged: (value) => widget.data.employmentLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Business Loss'),
                      initialValue: widget.data.businessLoss,
                      onChanged: (value) => widget.data.businessLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Daily Wage Loss'),
                      initialValue: widget.data.dailyWageLoss,
                      onChanged: (value) => widget.data.dailyWageLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Breadwinner Loss'),
                      initialValue: widget.data.breadwinnerLoss,
                      onChanged: (value) => widget.data.breadwinnerLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Animal Loss'),
                      initialValue: widget.data.animalLoss,
                      onChanged: (value) => widget.data.animalLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Agricultural Land Loss'),
                      initialValue: widget.data.agriculturalLandLoss,
                      onChanged: (value) => widget.data.agriculturalLandLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Other Livelihood Loss'),
                      initialValue: widget.data.otherLivelihoodLoss,
                      onChanged: (value) => widget.data.otherLivelihoodLoss = value,
                    ),
                    if (widget.data.otherLivelihoodLoss == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Other Livelihood Loss Details'),
                        initialValue: widget.data.otherLivelihoodLossDetails,
                        onChanged: (value) => widget.data.otherLivelihoodLossDetails = value,
                      ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Agricultural Land Loss Area'),
                      initialValue: widget.data.agriculturalLandLossArea,
                      onChanged: (value) => widget.data.agriculturalLandLossArea = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Stored Crops Loss'),
                      initialValue: widget.data.storedCropsLoss,
                      onChanged: (value) => widget.data.storedCropsLoss = value,
                    ),
                    if (widget.data.storedCropsLoss == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Crop Type'),
                        initialValue: widget.data.cropType,
                        onChanged: (value) => widget.data.cropType = value,
                      ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Equipment Loss (Yes/No)'),
                      initialValue: widget.data.equipmentLoss,
                      onChanged: (value) => widget.data.equipmentLoss = value,
                    ),
                    if (widget.data.equipmentLoss == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Equipment Loss Details'),
                        initialValue: widget.data.equipmentLossDetails,
                        onChanged: (value) => widget.data.equipmentLossDetails = value,
                      ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Animal Husbandry Loss (Yes/No)'),
                      initialValue: widget.data.animalHusbandryLoss,
                      onChanged: (value) => widget.data.animalHusbandryLoss = value,
                    ),
                    if (widget.data.animalHusbandryLoss == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Animal Husbandry Loss Details'),
                        initialValue: widget.data.animalHusbandryLossDetails,
                        onChanged: (value) => widget.data.animalHusbandryLossDetails = value,
                      ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Shed Loss (Yes/No)'),
                      initialValue: widget.data.shedLoss,
                      onChanged: (value) => widget.data.shedLoss = value,
                    ),
                    if (widget.data.shedLoss == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Shed Loss Details'),
                        initialValue: widget.data.shedLossDetails,
                        onChanged: (value) => widget.data.shedLossDetails = value,
                      ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Equipment/Tools Loss (Yes/No)'),
                      initialValue: widget.data.equipmentToolsLoss,
                      onChanged: (value) => widget.data.equipmentToolsLoss = value,
                    ),
                    if (widget.data.equipmentToolsLoss == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Equipment/Tools Loss Details'),
                        initialValue: widget.data.equipmentToolsLossDetails,
                        onChanged: (value) => widget.data.equipmentToolsLossDetails = value,
                      ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Livelihood Insurance (Yes/No)'),
                      initialValue: widget.data.livelihoodInsurance,
                      onChanged: (value) => widget.data.livelihoodInsurance = value,
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