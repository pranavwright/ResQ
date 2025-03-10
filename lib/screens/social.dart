import 'package:flutter/material.dart';
import 'package:resq/screens/personal_loan.dart';

class Social extends StatefulWidget {
  const Social({super.key});

  @override
  _Social createState() => _Social();
}

class _Social extends State<Social> {
  // Variable to hold the selected value of radio buttons
  String? _selectedOption;
  String? _hasBeneficiaryOption;

  // Controllers for the "Others" text field and new question text field
  final TextEditingController _othersController = TextEditingController();
  final TextEditingController _beneficiaryDetailsController = TextEditingController();

  // List to track which checkboxes are selected
  List<String> _selectedCheckboxOptions = [];
  final TextEditingController _othersCheckboxController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Security '),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
             Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/agriculture',
                  (route) => false,
                );// Pops the current screen off the navigation stack
          },
        ),
      ),
      body: SingleChildScrollView( // Wrap the entire body in a SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              const Text(
                'Social Security ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20), // Space between heading and radio buttons

              // Question with radio buttons
              const Text(
                'Are you or anyone in your family currently a beneficiary of any pension:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16), // Space between question and radio buttons

              // Radio button options for Pension Type
              Row(
                children: [
                  Radio<String>(
                    value: 'old age pention',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                  const Text('Old Age Pension'),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'widow pention',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                  const Text('Widow Pension'),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'divyang pention',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                  const Text('Divyang Pension'),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'others',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                  const Text('Others'),
                ],
              ),

              // If "Others" is selected, show the text field to specify the pension type
              if (_selectedOption == 'others') 
                Column(
                  children: [
                    const SizedBox(height: 16), // Space before the text field
                    const Text(
                      'Please specify the type of pension:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8), // Space between label and text field
                    TextField(
                      controller: _othersController,
                      decoration: const InputDecoration(
                        labelText: 'Specify the pension type',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),

              // New Question: Are you eligible for a loan?
              const SizedBox(height: 20),
              const Text(
                'Is any one in your family a beneficiary of MGNREGA Scheme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16), // Space between question and radio buttons

              // Radio button options for loan eligibility
              Row(
                children: [
                  Radio<String>(
                    value: 'Yes',
                    groupValue: _hasBeneficiaryOption,
                    onChanged: (String? value) {
                      setState(() {
                        _hasBeneficiaryOption = value;
                      });
                    },
                  ),
                  const Text('Yes'),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'No',
                    groupValue: _hasBeneficiaryOption,
                    onChanged: (String? value) {
                      setState(() {
                        _hasBeneficiaryOption = value;
                      });
                    },
                  ),
                  const Text('No'),
                ],
              ),

              // If "Yes" is selected for loan eligibility, show the text field to specify
              if (_hasBeneficiaryOption == 'Yes') 
                Column(
                  children: [
                    const SizedBox(height: 16), // Space before the text field
                    const Text(
                      'Please specify details about the loan:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8), // Space between label and text field
                    TextField(
                      controller: _beneficiaryDetailsController,
                      decoration: const InputDecoration(
                        labelText: 'Specify loan details',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),

              // New Question with 2 checkbox options
              const SizedBox(height: 20),
              const Text(
                'Have you lost any of the following legal documents:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16), // Space between question and checkboxes

              // List of 2 checkbox options
              CheckboxListTile(
                title: const Text('No loss'),
                value: _selectedCheckboxOptions.contains('No loss'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('No loss');
                    } else {
                      _selectedCheckboxOptions.remove('No loss');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Adhar card'),
                value: _selectedCheckboxOptions.contains('Adhar card'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('Adhar card');
                    } else {
                      _selectedCheckboxOptions.remove('Adhar card');
                    }
                  });
                },
              ),
               CheckboxListTile(
                title: const Text('Government id card'),
                value: _selectedCheckboxOptions.contains('Government id card'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('Government id card');
                    } else {
                      _selectedCheckboxOptions.remove('Government id card');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Passport '),
                value: _selectedCheckboxOptions.contains('Passport '),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('Passport');
                    } else {
                      _selectedCheckboxOptions.remove('Passport');
                    }
                  });
                },
              ),
               CheckboxListTile(
                title: const Text('Employment Card'),
                value: _selectedCheckboxOptions.contains('Employment Card'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('Employment Card');
                    } else {
                      _selectedCheckboxOptions.remove('Employment Card');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Pan Card'),
                value: _selectedCheckboxOptions.contains('Pan Card'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('Pan Card');
                    } else {
                      _selectedCheckboxOptions.remove('Pan Card');
                    }
                  });
                },
              ),
               CheckboxListTile(
                title: const Text('Insurance Card'),
                value: _selectedCheckboxOptions.contains('Insurance Card'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('Insurance Card');
                    } else {
                      _selectedCheckboxOptions.remove('Insurance Card');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Driving License'),
                value: _selectedCheckboxOptions.contains('Driving License'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('Driving License');
                    } else {
                      _selectedCheckboxOptions.remove('Driving License');
                    }
                  });
                },
              ),
               CheckboxListTile(
                title: const Text('ATM Card'),
                value: _selectedCheckboxOptions.contains('ATM Card'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('ATM Card');
                    } else {
                      _selectedCheckboxOptions.remove('ATM Card');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Ration Card'),
                value: _selectedCheckboxOptions.contains('Ration Card'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('Ration Card');
                    } else {
                      _selectedCheckboxOptions.remove('Ration Card');
                    }
                  });
                },
              ),
               CheckboxListTile(
                title: const Text('Land Document'),
                value: _selectedCheckboxOptions.contains('Land Document'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('Land Document');
                    } else {
                      _selectedCheckboxOptions.remove('Land Document');
                    }
                  });
                },
              ),
               CheckboxListTile(
                title: const Text('Property Document'),
                value: _selectedCheckboxOptions.contains('Property Document'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('Property Document');
                    } else {
                      _selectedCheckboxOptions.remove('Property Document');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text(' Birth certificate'),
                value: _selectedCheckboxOptions.contains('Birth certificate'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('Birth certificate');
                    } else {
                      _selectedCheckboxOptions.remove('Birth certificate');
                    }
                  });
                },
              ),
               CheckboxListTile(
                title: const Text('Marriage Certificate'),
                value: _selectedCheckboxOptions.contains('Marriage Certificate'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('Marriage Certificate');
                    } else {
                      _selectedCheckboxOptions.remove('Marriage Certificate');
                    }
                  });
                },
              ),
               CheckboxListTile(
                title: const Text('Educational'),
                value: _selectedCheckboxOptions.contains('Educational'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('Educational');
                    } else {
                      _selectedCheckboxOptions.remove('Educational');
                    }
                  });
                },
              ),
               CheckboxListTile(
                title: const Text('Others'),
                value: _selectedCheckboxOptions.contains('Others'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedCheckboxOptions.add('Others');
                    } else {
                      _selectedCheckboxOptions.remove('Others');
                    }
                  });
                },
              ),
              // Add more CheckboxListTiles here as needed...

              // If "Others" is selected in checkboxes, show the text field to specify
              if (_selectedCheckboxOptions.contains('Others'))
                Column(
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Please specify the document you lost:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _othersCheckboxController,
                      decoration: const InputDecoration(
                        labelText: 'Specify the document',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),

              // Add Next Button
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the next page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PersonalLoan()),
                    );
                  },
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
