import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_g_screen.dart';

class ScreenF extends StatefulWidget {
  final NeedAssessmentData data;

  ScreenF({required this.data});

  @override
  _ScreenFState createState() => _ScreenFState();
}

class _ScreenFState extends State<ScreenF> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section F: Social Security and Legal Assistance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Pension Beneficiary (Yes/No)'),
                initialValue: widget.data.pensionBeneficiary,
                onChanged: (value) => widget.data.pensionBeneficiary = value,
              ),
              if (widget.data.pensionBeneficiary == 'Yes')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Pension Type'),
                      initialValue: widget.data.pensionType,
                      onChanged: (value) => widget.data.pensionType = value,
                    ),
                    if (widget.data.pensionType == 'Others')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Other Pension Type'),
                        initialValue: widget.data.otherPensionType,
                        onChanged: (value) => widget.data.otherPensionType = value,
                      ),
                  ],
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'MGNREGA Beneficiary (Yes/No)'),
                initialValue: widget.data.mgnregaBeneficiary,
                onChanged: (value) => widget.data.mgnregaBeneficiary = value,
              ),
              if (widget.data.mgnregaBeneficiary == 'Yes')
                TextFormField(
                  decoration: InputDecoration(labelText: 'MGNREGA Details'),
                  initialValue: widget.data.mgnregaDetails,
                  onChanged: (value) => widget.data.mgnregaDetails = value,
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Legal Documents Lost (Yes/No)'),
                initialValue: widget.data.legalDocumentsLost,
                onChanged: (value) => widget.data.legalDocumentsLost = value,
              ),
              if (widget.data.legalDocumentsLost == 'Yes')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Aadhar Card Loss'),
                      initialValue: widget.data.aadharCardLoss,
                      onChanged: (value) => widget.data.aadharCardLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Government ID Loss'),
                      initialValue: widget.data.governmentIDLoss,
                      onChanged: (value) => widget.data.governmentIDLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Passport Loss'),
                      initialValue: widget.data.passportLoss,
                      onChanged: (value) => widget.data.passportLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Employment Card Loss'),
                      initialValue: widget.data.employmentCardLoss,
                      onChanged: (value) => widget.data.employmentCardLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'PAN Card Loss'),
                      initialValue: widget.data.panCardLoss,
                      onChanged: (value) => widget.data.panCardLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Insurance Card Loss'),
                      initialValue: widget.data.insuranceCardLoss,
                      onChanged: (value) => widget.data.insuranceCardLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Driving License Loss'),
                      initialValue: widget.data.drivingLicenseLoss,
                      onChanged: (value) => widget.data.drivingLicenseLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'ATM Card Loss'),
                      initialValue: widget.data.atmCardLoss,
                      onChanged: (value) => widget.data.atmCardLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Ration Card Loss (Document)'),
                      initialValue: widget.data.rationCardLossDoc,
                      onChanged: (value) => widget.data.rationCardLossDoc = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Land Document Loss'),
                      initialValue: widget.data.landDocumentLoss,
                      onChanged: (value) => widget.data.landDocumentLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Property Document Loss'),
                      initialValue: widget.data.propertyDocumentLoss,
                      onChanged: (value) => widget.data.propertyDocumentLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Birth Certificate Loss'),
                      initialValue: widget.data.birthCertificateLoss,
                      onChanged: (value) => widget.data.birthCertificateLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Marriage Certificate Loss'),
                      initialValue: widget.data.marriageCertificateLoss,
                      onChanged: (value) => widget.data.marriageCertificateLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Educational Document Loss'),
                      initialValue: widget.data.educationalDocumentLoss,
                      onChanged: (value) => widget.data.educationalDocumentLoss = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Other Document Loss'),
                      initialValue: widget.data.otherDocumentLoss,
                      onChanged: (value) => widget.data.otherDocumentLoss = value,
                    ),
                    if (widget.data.otherDocumentLoss == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Other Document Loss Details'),
                        initialValue: widget.data.otherDocumentLossDetails,
                        onChanged: (value) => widget.data.otherDocumentLossDetails = value,
                      ),
                  ],
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Loan Repayment Pending (Yes/No)'),
                initialValue: widget.data.loanRepaymentPending,
                onChanged: (value) => widget.data.loanRepaymentPending = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenG(data: widget.data),
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