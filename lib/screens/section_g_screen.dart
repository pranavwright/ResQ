import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_h_screen.dart';
// Assuming you have ScreenH defined elsewhere
// import 'screen_h.dart';

class ScreenG extends StatefulWidget {
  final NeedAssessmentData data;

  ScreenG({required this.data});

  @override
  _ScreenGState createState() => _ScreenGState();
}

class _ScreenGState extends State<ScreenG> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section G: Special Categories and Kudumbashree'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Special Category'),
                initialValue: widget.data.specialCategory,
                onChanged: (value) => widget.data.specialCategory = value,
              ),
              if (widget.data.specialCategory == 'Others')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Other Special Category'),
                  initialValue: widget.data.otherSpecialCategory,
                  onChanged: (value) => widget.data.otherSpecialCategory = value,
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Kudumbashree Member (Yes/No)'),
                initialValue: widget.data.kudumbashreeMember,
                onChanged: (value) => widget.data.kudumbashreeMember = value,
              ),
              if (widget.data.kudumbashreeMember == 'Yes')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Kudumbashree NHG Name'),
                      initialValue: widget.data.kudumbashreeNHGName,
                      onChanged: (value) => widget.data.kudumbashreeNHGName = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Kudumbashree Internal Loan (Yes/No)'),
                      initialValue: widget.data.kudumbashreeInternalLoan,
                      onChanged: (value) => widget.data.kudumbashreeInternalLoan = value,
                    ),
                    if (widget.data.kudumbashreeInternalLoan == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Kudumbashree Internal Loan Amount'),
                        initialValue: widget.data.kudumbashreeInternalLoanAmount.toString(),
                        onChanged: (value) => widget.data.kudumbashreeInternalLoanAmount = double.tryParse(value) ?? 0.0,
                        keyboardType: TextInputType.number,
                      ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Kudumbashree Linkage Loan (Yes/No)'),
                      initialValue: widget.data.kudumbashreeLinkageLoan,
                      onChanged: (value) => widget.data.kudumbashreeLinkageLoan = value,
                    ),
                    if (widget.data.kudumbashreeLinkageLoan == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Kudumbashree Linkage Loan Amount'),
                        initialValue: widget.data.kudumbashreeLinkageLoanAmount.toString(),
                        onChanged: (value) => widget.data.kudumbashreeLinkageLoanAmount = double.tryParse(value) ?? 0.0,
                        keyboardType: TextInputType.number,
                      ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Kudumbashree Microenterprise Loan (Yes/No)'),
                      initialValue: widget.data.kudumbashreeMicroenterpriseLoan,
                      onChanged: (value) => widget.data.kudumbashreeMicroenterpriseLoan = value,
                    ),
                    if (widget.data.kudumbashreeMicroenterpriseLoan == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Kudumbashree Microenterprise Loan Amount'),
                        initialValue: widget.data.kudumbashreeMicroenterpriseLoanAmount.toString(),
                        onChanged: (value) => widget.data.kudumbashreeMicroenterpriseLoanAmount = double.tryParse(value) ?? 0.0,
                        keyboardType: TextInputType.number,
                      ),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenH(data: widget.data),
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