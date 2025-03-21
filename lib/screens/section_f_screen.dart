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
  String? pensionBeneficiary;
  String? mgnregaBeneficiary;
  String? legalDocumentsLost;
  String? loanRepaymentPending;

  bool isOldAgePension = false;
  bool isWidowPension = false;
  bool isDivyangPension = false;
  bool isOtherPension = false;
  bool isOtherDocumentLoss = false; // Controls the "Other Document Loss Details"
  
  TextEditingController otherPensionController = TextEditingController();
  TextEditingController mgnregaDetailsController = TextEditingController();
  TextEditingController otherDocumentLossDetailsController = TextEditingController(); // Controller for text field
  
  @override
  void initState() {
    super.initState();
    pensionBeneficiary = widget.data.pensionBeneficiary;
    mgnregaBeneficiary = widget.data.mgnregaBeneficiary;
    legalDocumentsLost = widget.data.legalDocumentsLost;
    loanRepaymentPending = widget.data.loanRepaymentPending;
    mgnregaDetailsController.text = widget.data.mgnregaDetails; // Set initial value for text field
  }

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
              // Pension Beneficiary Radio Buttons
              Row(
                children: [
                  Text('Pension Beneficiary: ',style: TextStyle(fontSize: 16),),
                  Radio<String>(
                    value: 'Yes',
                    groupValue: pensionBeneficiary,
                    onChanged: (value) {
                      setState(() {
                        pensionBeneficiary = value;
                        widget.data.pensionBeneficiary = value!;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: pensionBeneficiary,
                    onChanged: (value) {
                      setState(() {
                        pensionBeneficiary = value;
                        widget.data.pensionBeneficiary = value!;
                      });
                    },
                  ),
                  Text('No'),
                ],
              ),
              if (widget.data.pensionBeneficiary == 'Yes')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: Text('Old Age Pension'),
                      value: isOldAgePension,
                      onChanged: (value) {
                        setState(() {
                          isOldAgePension = value!;
                          widget.data.pensionType = 'Old Age Pension';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Widow Pension'),
                      value: isWidowPension,
                      onChanged: (value) {
                        setState(() {
                          isWidowPension = value!;
                          widget.data.pensionType = 'Widow Pension';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Divyang Pension'),
                      value: isDivyangPension,
                      onChanged: (value) {
                        setState(() {
                          isDivyangPension = value!;
                          widget.data.pensionType = 'Divyang Pension';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Others'),
                      value: isOtherPension,
                      onChanged: (value) {
                        setState(() {
                          isOtherPension = value!;
                          widget.data.pensionType = 'Other';
                        });
                      },
                    ),
                    if (isOtherPension)
                      TextField(
                        controller: otherPensionController,
                        decoration: InputDecoration(
                          labelText: 'Specify Other Pension Type',
                          hintText: 'Enter other pension type',
                        ),
                      ),
                  ],
                ),

              // MGNREGA Beneficiary Radio Buttons
              Row(
                children: [
                  Text('MGNREGA Beneficiary: '),
                  Radio<String>(
                    value: 'Yes',
                    groupValue: mgnregaBeneficiary,
                    onChanged: (value) {
                      setState(() {
                        mgnregaBeneficiary = value;
                        widget.data.mgnregaBeneficiary = value!;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: mgnregaBeneficiary,
                    onChanged: (value) {
                      setState(() {
                        mgnregaBeneficiary = value;
                        widget.data.mgnregaBeneficiary = value!;
                      });
                    },
                  ),
                  Text('No'),
                ],
              ),
              if (widget.data.mgnregaBeneficiary == 'Yes')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: mgnregaDetailsController,
                      decoration: InputDecoration(
                        labelText: 'Enter MGNREGA Details',
                        hintText: 'Provide MGNREGA related details here',
                      ),
                      onChanged: (value) {
                        widget.data.mgnregaDetails = value; // Update the details in the data model
                      },
                    ),
                  ],
                ),

              // Legal Documents Lost Radio Buttons
              Row(
                children: [
                  Text('Legal Documents Lost: '),
                  Radio<String>(
                    value: 'Yes',
                    groupValue: legalDocumentsLost,
                    onChanged: (value) {
                      setState(() {
                        legalDocumentsLost = value;
                        widget.data.legalDocumentsLost = value!;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: legalDocumentsLost,
                    onChanged: (value) {
                      setState(() {
                        legalDocumentsLost = value;
                        widget.data.legalDocumentsLost = value!;
                      });
                    },
                  ),
                  Text('No'),
                ],
              ),
              if (widget.data.legalDocumentsLost == 'Yes')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: Text('Aadhar Card Loss'),
                      value: widget.data.aadharCardLoss.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.aadharCardLoss = value! ? 'Yes' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Government ID Loss'),
                      value: widget.data.governmentIDLoss.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.governmentIDLoss = value! ? 'Yes' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Passport Loss'),
                      value: widget.data.passportLoss.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.passportLoss = value! ? 'Yes' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Employment Card Loss'),
                      value: widget.data.employmentCardLoss.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.employmentCardLoss = value! ? 'Yes' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('PAN Card Loss'),
                      value: widget.data.panCardLoss.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.panCardLoss = value! ? 'Yes' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Insurance Card Loss'),
                      value: widget.data.insuranceCardLoss.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.insuranceCardLoss = value! ? 'Yes' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Driving License Loss'),
                      value: widget.data.drivingLicenseLoss.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.drivingLicenseLoss = value! ? 'Yes' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('ATM Card Loss'),
                      value: widget.data.atmCardLoss.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.atmCardLoss = value! ? 'Yes' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Ration Card Loss (Document)'),
                      value: widget.data.rationCardLossDoc.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.rationCardLossDoc = value! ? 'Yes' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Land Document Loss'),
                      value: widget.data.landDocumentLoss.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.landDocumentLoss = value! ? 'Yes' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Property Document Loss'),
                      value: widget.data.propertyDocumentLoss.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.propertyDocumentLoss = value! ? 'Yes' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Birth Certificate Loss'),
                      value: widget.data.birthCertificateLoss.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.birthCertificateLoss = value! ? 'Yes' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Marriage Certificate Loss'),
                      value: widget.data.marriageCertificateLoss.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.marriageCertificateLoss = value! ? 'Yes' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Educational Document Loss'),
                      value: widget.data.educationalDocumentLoss.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          widget.data.educationalDocumentLoss = value! ? 'Yes' : '';
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Other Document Loss'),
                      value: isOtherDocumentLoss,
                      onChanged: (value) {
                        setState(() {
                          isOtherDocumentLoss = value!;
                          if (!value) {
                            widget.data.otherDocumentLossDetails = ''; // Reset the details if checkbox is unchecked
                          }
                        });
                      },
                    ),
                    if (isOtherDocumentLoss) 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            title: Text('click and give the Other Loss Document  Details'),
                            value: widget.data.otherDocumentLossDetails.isNotEmpty,
                            onChanged: (value) {
                              setState(() {
                                widget.data.otherDocumentLossDetails = value! ? 'Other Details' : '';
                              });
                            },
                          ),
                          if (widget.data.otherDocumentLossDetails.isNotEmpty)
                            TextField(
                              controller: otherDocumentLossDetailsController,
                              decoration: InputDecoration(
                                labelText: 'Specify Other Document Loss Details',
                                hintText: 'Enter details about the other document loss',
                              ),
                              onChanged: (value) {
                                widget.data.otherDocumentLossDetails = value; // Update the other document loss details
                              },
                            ),
                        ],
                      ),
                  ],
                ),
              
              // Loan Repayment Pending Radio Buttons
              Row(
                children: [
                  Text('Loan Repayment Pending: '),
                  Radio<String>(
                    value: 'Yes',
                    groupValue: loanRepaymentPending,
                    onChanged: (value) {
                      setState(() {
                        loanRepaymentPending = value;
                        widget.data.loanRepaymentPending = value!;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: loanRepaymentPending,
                    onChanged: (value) {
                      setState(() {
                        loanRepaymentPending = value;
                        widget.data.loanRepaymentPending = value!;
                      });
                    },
                  ),
                  Text('No'),
                ],
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
