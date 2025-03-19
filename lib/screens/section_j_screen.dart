import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_k_screen.dart';

class ScreenJ extends StatefulWidget {
  final NeedAssessmentData data;

  ScreenJ({required this.data});

  @override
  _ScreenJState createState() => _ScreenJState();
}

class _ScreenJState extends State<ScreenJ> {
  void _addLoanDetail() {
    setState(() {
      widget.data.loanDetails.add(LoanDetail(
        bankName: '',
        branch: '',
        accountNumber: '',
        loanCategory: '',
        loanAmount: '',
        loanOutstanding: '',
      ));
    });
  }

  void _deleteLoanDetail(int index) {
    setState(() {
      widget.data.loanDetails.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section J: Loan Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loan Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.data.loanDetails.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      LoanDetailInput(
                        loanDetail: widget.data.loanDetails[index],
                        onChanged: (updatedLoanDetail) {
                          setState(() {
                            widget.data.loanDetails[index] = updatedLoanDetail;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteLoanDetail(index),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _addLoanDetail,
                    child: Text('Add Loan'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScreenK(data: widget.data),
                        ),
                      );
                    },
                    child: Text('Next'),
                  ),
                ],
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

  LoanDetailInput({
    required this.loanDetail,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Bank Name'),
              initialValue: loanDetail.bankName,
              onChanged: (value) {
                onChanged(loanDetail.copyWith(bankName: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Branch'),
              initialValue: loanDetail.branch,
              onChanged: (value) {
                onChanged(loanDetail.copyWith(branch: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Account Number'),
              initialValue: loanDetail.accountNumber,
              onChanged: (value) {
                onChanged(loanDetail.copyWith(accountNumber: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Loan Category'),
              initialValue: loanDetail.loanCategory,
              onChanged: (value) {
                onChanged(loanDetail.copyWith(loanCategory: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Loan Amount'),
              initialValue: loanDetail.loanAmount,
              onChanged: (value) {
                onChanged(loanDetail.copyWith(loanAmount: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Loan Outstanding'),
              initialValue: loanDetail.loanOutstanding,
              onChanged: (value) {
                onChanged(loanDetail.copyWith(loanOutstanding: value));
              },
            ),
          ],
        ),
      ),
    );
  }
}