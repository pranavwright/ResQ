import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_h_screen.dart'; // Assuming you have ScreenH defined elsewhere

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
              // Special Category Yes/No Radio Buttons
              Row(
                children: [
                  Expanded(child: Text('Special Category (Yes/No):')),
                  Radio<String>(
                    value: 'Yes',
                    groupValue: widget.data.specialCategory,
                    onChanged: (value) {
                      setState(() {
                        widget.data.specialCategory = value!;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: widget.data.specialCategory,
                    onChanged: (value) {
                      setState(() {
                        widget.data.specialCategory = value!;
                      });
                    },
                  ),
                  Text('No'),
                ],
              ),
              // Show "Other Special Category" field only if "Yes" is selected
              if (widget.data.specialCategory == 'Yes')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Other Special Category'),
                  initialValue: widget.data.otherSpecialCategory,
                  onChanged: (value) => widget.data.otherSpecialCategory = value,
                ),

              // Kudumbashree Member Yes/No Radio Buttons
              Row(
                children: [
                  Expanded(child: Text('Kudumbashree Member (Yes/No):')),
                  Radio<String>(
                    value: 'Yes',
                    groupValue: widget.data.kudumbashreeMember,
                    onChanged: (value) {
                      setState(() {
                        widget.data.kudumbashreeMember = value!;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: widget.data.kudumbashreeMember,
                    onChanged: (value) {
                      setState(() {
                        widget.data.kudumbashreeMember = value!;
                      });
                    },
                  ),
                  Text('No'),
                ],
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
                    // Kudumbashree Internal Loan Yes/No Radio Buttons
                    Row(
                      children: [
                        Expanded(child: Text('Kudumbashree Internal Loan (Yes/No):')),
                        Radio<String>(
                          value: 'Yes',
                          groupValue: widget.data.kudumbashreeInternalLoan,
                          onChanged: (value) {
                            setState(() {
                              widget.data.kudumbashreeInternalLoan = value!;
                            });
                          },
                        ),
                        Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: widget.data.kudumbashreeInternalLoan,
                          onChanged: (value) {
                            setState(() {
                              widget.data.kudumbashreeInternalLoan = value!;
                            });
                          },
                        ),
                        Text('No'),
                      ],
                    ),
                    if (widget.data.kudumbashreeInternalLoan == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Kudumbashree Internal Loan Amount'),
                        initialValue: widget.data.kudumbashreeInternalLoanAmount.toString(),
                        onChanged: (value) => widget.data.kudumbashreeInternalLoanAmount = double.tryParse(value) ?? 0.0,
                        keyboardType: TextInputType.number,
                      ),
                    // Kudumbashree Linkage Loan Yes/No Radio Buttons
                    Row(
                      children: [
                        Expanded(child: Text('Kudumbashree Linkage Loan (Yes/No):')),
                        Radio<String>(
                          value: 'Yes',
                          groupValue: widget.data.kudumbashreeLinkageLoan,
                          onChanged: (value) {
                            setState(() {
                              widget.data.kudumbashreeLinkageLoan = value!;
                            });
                          },
                        ),
                        Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: widget.data.kudumbashreeLinkageLoan,
                          onChanged: (value) {
                            setState(() {
                              widget.data.kudumbashreeLinkageLoan = value!;
                            });
                          },
                        ),
                        Text('No'),
                      ],
                    ),
                    if (widget.data.kudumbashreeLinkageLoan == 'Yes')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Kudumbashree Linkage Loan Amount'),
                        initialValue: widget.data.kudumbashreeLinkageLoanAmount.toString(),
                        onChanged: (value) => widget.data.kudumbashreeLinkageLoanAmount = double.tryParse(value) ?? 0.0,
                        keyboardType: TextInputType.number,
                      ),
                    // Kudumbashree Microenterprise Loan Yes/No Radio Buttons
                    Row(
                      children: [
                        Expanded(child: Text('Kudumbashree Microenterprise Loan (Yes/No):')),
                        Radio<String>(
                          value: 'Yes',
                          groupValue: widget.data.kudumbashreeMicroenterpriseLoan,
                          onChanged: (value) {
                            setState(() {
                              widget.data.kudumbashreeMicroenterpriseLoan = value!;
                            });
                          },
                        ),
                        Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: widget.data.kudumbashreeMicroenterpriseLoan,
                          onChanged: (value) {
                            setState(() {
                              widget.data.kudumbashreeMicroenterpriseLoan = value!;
                            });
                          },
                        ),
                        Text('No'),
                      ],
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
