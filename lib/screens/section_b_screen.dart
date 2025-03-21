import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_c_screen.dart';

class ScreenB extends StatefulWidget {
  final NeedAssessmentData data;

  ScreenB({required this.data});

  @override
  _ScreenBState createState() => _ScreenBState();
}

class _ScreenBState extends State<ScreenB> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section B: Livelihood and Assets'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Primary Occupation'),
                initialValue: widget.data.primaryOccupation,
                onChanged: (value) => widget.data.primaryOccupation = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Secondary Occupation'),
                initialValue: widget.data.secondaryOccupation,
                onChanged: (value) => widget.data.secondaryOccupation = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Land Ownership (Acres)'),
                initialValue: widget.data.agriculturalLandLossArea,
                onChanged: (value) => widget.data.agriculturalLandLossArea = value,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'House Type'),
                initialValue: widget.data.shelterType,
                onChanged: (value) => widget.data.shelterType = value,
              ),
              if (widget.data.shelterType == 'Others')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Other House Type'),
                  initialValue: widget.data.otherShelterType,
                  onChanged: (value) => widget.data.otherShelterType = value,
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Livestock (if any)'),
                initialValue: widget.data.animalHusbandryLossDetails,
                onChanged: (value) => widget.data.animalHusbandryLossDetails = value,
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Assets (e.g., Vehicle, Machinery)'),
                initialValue: widget.data.equipmentLossDetails,
                onChanged: (value) => widget.data.equipmentLossDetails = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Average Monthly Income'),
                initialValue: widget.data.avgMonthlyFamilyIncome.toString(),
                onChanged: (value) =>
                    widget.data.avgMonthlyFamilyIncome = double.tryParse(value) ?? 0.0,
                keyboardType: TextInputType.number,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: 'Debt (if any)'),
                initialValue: widget.data.loanRepaymentPending,
                onChanged: (value) => widget.data.loanRepaymentPending = value,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.data.loanDetails.length,
                itemBuilder: (context, index) {
                  return LoanDetailInput(
                    loanDetail: widget.data.loanDetails[index],
                    onChanged: (updatedLoanDetail) {
                      setState(() {
                        widget.data.loanDetails[index] = updatedLoanDetail;
                      });
                    },
                    onDelete: (){
                      setState((){
                        widget.data.loanDetails.removeAt(index);
                      });
                    },
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    widget.data.loanDetails.add(
                      LoanDetail(
                        bankName: "",
                        branch: "",
                        accountNumber: "",
                        loanCategory: "",
                        loanAmount: "",
                        loanOutstanding: "",
                      ),
                    );
                  });
                },
                child: Text('Add Loan Details'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenC(data: widget.data),
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

class LoanDetailInput extends StatelessWidget {
  final LoanDetail loanDetail;
  final Function(LoanDetail) onChanged;
  final VoidCallback onDelete;

  LoanDetailInput({
    required this.loanDetail,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Bank Name'),
              initialValue: loanDetail.bankName,
              onChanged: (value) {
                onChanged(LoanDetail(
                  bankName: value,
                  branch: loanDetail.branch,
                  accountNumber: loanDetail.accountNumber,
                  loanCategory: loanDetail.loanCategory,
                  loanAmount: loanDetail.loanAmount,
                  loanOutstanding: loanDetail.loanOutstanding,
                ));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Branch'),
              initialValue: loanDetail.branch,
              onChanged: (value) {
                onChanged(LoanDetail(
                  bankName: loanDetail.bankName,
                  branch: value,
                  accountNumber: loanDetail.accountNumber,
                  loanCategory: loanDetail.loanCategory,
                  loanAmount: loanDetail.loanAmount,
                  loanOutstanding: loanDetail.loanOutstanding,
                ));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Account Number'),
              initialValue: loanDetail.accountNumber,
              onChanged: (value) {
                onChanged(LoanDetail(
                  bankName: loanDetail.bankName,
                  branch: loanDetail.branch,
                  accountNumber: value,
                  loanCategory: loanDetail.loanCategory,
                  loanAmount: loanDetail.loanAmount,
                  loanOutstanding: loanDetail.loanOutstanding,
                ));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Loan Category'),
              initialValue: loanDetail.loanCategory,
              onChanged: (value) {
                onChanged(LoanDetail(
                  bankName: loanDetail.bankName,
                  branch: loanDetail.branch,
                  accountNumber: loanDetail.accountNumber,
                  loanCategory: value,
                  loanAmount: loanDetail.loanAmount,
                  loanOutstanding: loanDetail.loanOutstanding,
                ));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Loan Amount'),
              initialValue: loanDetail.loanAmount,
              onChanged: (value) {
                onChanged(LoanDetail(
                  bankName: loanDetail.bankName,
                  branch: loanDetail.branch,
                  accountNumber: loanDetail.accountNumber,
                  loanCategory: loanDetail.loanCategory,
                  loanAmount: value,
                  loanOutstanding: loanDetail.loanOutstanding,
                ));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Loan Outstanding'),
              initialValue: loanDetail.loanOutstanding,
              onChanged: (value) {
                onChanged(LoanDetail(
                  bankName: loanDetail.bankName,
                  branch: loanDetail.branch,
                  accountNumber: loanDetail.accountNumber,
                  loanCategory: loanDetail.loanCategory,
                  loanAmount: loanDetail.loanAmount,
                  loanOutstanding: value,
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

