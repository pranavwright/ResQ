import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_k_screen.dart';

class ScreenI extends StatefulWidget {
  final NeedAssessmentData data;

  ScreenI({required this.data});

  @override
  _ScreenIState createState() => _ScreenIState();
}

class _ScreenIState extends State<ScreenI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section I: Individual Member Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Individual Member Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.data.members.length,
                itemBuilder: (context, index) {
                  return IndividualMemberInput(
                    member: widget.data.members[index],
                    onChanged: (updatedMember) {
                      setState(() {
                        widget.data.members[index] = updatedMember;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 20),
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
        ),
      ),
    );
  }
}

class IndividualMemberInput extends StatelessWidget {
  final Member member;
  final Function(Member) onChanged;

  IndividualMemberInput({
    required this.member,
    required this.onChanged,
  }) {
    if (member.maritalStatus == '') {
      member.maritalStatus = 'Single';
    }
    if (member.previousStatus == '') {
      member.previousStatus = 'Unemployed';
    }
    if(member.employmentType == '')
    {
      member.employmentType = 'Others';
    }
  }

  final List<String> _maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
    'Other'
  ];
  final List<String> _previousStatusOptions = [
    'Employed',
    'Unemployed',
    'Self Employed',
    'Unemployed due to the disaster'
  ];
  final List<String> _employmentTypeOptions = [
    'Govt',
    'Private',
    'Plantation',
    'Agri/Allied',
    'Daily Wage',
    'Others'
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              initialValue: member.name,
              onChanged: (value) {
                onChanged(member.copyWith(name: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Age'),
              initialValue: member.age,
              onChanged: (value) {
                onChanged(member.copyWith(age: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Gender'),
              initialValue: member.gender,
              onChanged: (value) {
                onChanged(member.copyWith(gender: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Relationship'),
              initialValue: member.relationship,
              onChanged: (value) {
                onChanged(member.copyWith(relationship: value));
              },
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Marital Status'),
              value: member.maritalStatus ?? 'Single',
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(member.copyWith(maritalStatus: newValue));
                }
              },
              items: _maritalStatusOptions
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'L/D/M'),
              initialValue: member.ldm,
              onChanged: (value) {
                onChanged(member.copyWith(ldm: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Aadhar No.'),
              initialValue: member.aadharNo,
              onChanged: (value) {
                onChanged(member.copyWith(aadharNo: value));
              },
            ),
            // Grievously Injured (Radio Buttons)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('Grievously Injured: '),
                  Radio<String>(
                    value: 'Yes',
                    groupValue: member.grievouslyInjured,
                    onChanged: (value) {
                      onChanged(member.copyWith(grievouslyInjured: value!));
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: member.grievouslyInjured,
                    onChanged: (value) {
                      onChanged(member.copyWith(grievouslyInjured: value!));
                    },
                  ),
                  Text('No'),
                ],
              ),
            ),
            // Bedridden/Palliative (Radio Buttons)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('Bedridden/Palliative: '),
                  Radio<String>(
                    value: 'Yes',
                    groupValue: member.bedriddenPalliative,
                    onChanged: (value) {
                      onChanged(member.copyWith(bedriddenPalliative: value!));
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: member.bedriddenPalliative,
                    onChanged: (value) {
                      onChanged(member.copyWith(bedriddenPalliative: value!));
                    },
                  ),
                  Text('No'),
                ],
              ),
            ),
            // PWDS (Radio Buttons)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text('PWDS: '),
                      Radio<String>(
                        value: 'Yes',
                        groupValue: member.pwDs,
                        onChanged: (value) {
                          onChanged(member.copyWith(pwDs: value!));
                        },
                      ),
                      Text('Yes'),
                      Radio<String>(
                        value: 'No',
                        groupValue: member.pwDs,
                        onChanged: (value) {
                          onChanged(member.copyWith(pwDs: value!));
                        },
                      ),
                      Text('No'),
                    ],
                  ),
                ),
                if (member.pwDs == 'Yes')
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Specify PWDS Details'),
                    initialValue: member.pwDs,
                    onChanged: (value) {
                      onChanged(member.copyWith(pwDs: value));
                    },
                  ),
              ],
            ),

            // Psycho-Social Assistance (Radio Buttons)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('Psycho-Social Assistance: '),
                  Radio<String>(
                    value: 'Yes',
                    groupValue: member.psychoSocialAssistance,
                    onChanged: (value) {
                      onChanged(member.copyWith(psychoSocialAssistance: value!));
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: member.psychoSocialAssistance,
                    onChanged: (value) {
                      onChanged(member.copyWith(psychoSocialAssistance: value!));
                    },
                  ),
                  Text('No'),
                ],
              ),
            ),
            // Nursing Home Assistance (Radio Buttons)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('Nursing Home Assistance: '),
                  Radio<String>(
                    value: 'Yes',
                    groupValue: member.nursingHomeAssistance,
                    onChanged: (value) {
                      onChanged(member.copyWith(nursingHomeAssistance: value!));
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'No',
                    groupValue: member.nursingHomeAssistance,
                    onChanged: (value) {
                      onChanged(member.copyWith(nursingHomeAssistance: value!));
                    },
                  ),
                  Text('No'),
                ],
              ),
            ),
            // Assistive Devices (Radio Buttons)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text('Assistive Devices: '),
                      Radio<String>(
                        value: 'Yes',
                        groupValue: member.assistiveDevices,
                        onChanged: (value) {
                          onChanged(member.copyWith(assistiveDevices: value!));
                        },
                      ),
                      Text('Yes'),
                      Radio<String>(
                        value: 'No',
                        groupValue: member.assistiveDevices,
                        onChanged: (value) {
                          onChanged(member.copyWith(assistiveDevices: value!));
                        },
                      ),
                      Text('No'),
                    ],
                  ),
                ),
                if (member.assistiveDevices == 'Yes')
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Specify Assistive Devices'),
                    initialValue: member.assistiveDevices,
                    onChanged: (value) {
                      onChanged(member.copyWith(assistiveDevices: value));
                    },
                  ),
              ],
            ),
            // Special Medical Requirements (Radio Buttons)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(' Medical Requirements: '),
                      Radio<String>(
                        value: 'Yes',
                        groupValue: member.specialMedicalRequirements,
                        onChanged: (value) {
                          onChanged(member.copyWith(specialMedicalRequirements: value!));
                        },
                      ),
                      Text('Yes'),
                      Radio<String>(
                        value: 'No',
                        groupValue: member.specialMedicalRequirements,
                        onChanged: (value) {
                          onChanged(member.copyWith(specialMedicalRequirements: value!));
                        },
                      ),
                      Text('No'),
                    ],
                  ),
                ),
                if (member.specialMedicalRequirements == 'Yes')
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Specify Medical Requirements'),
                    initialValue: member.specialMedicalRequirements,
                    onChanged: (value) {
                      onChanged(member.copyWith(specialMedicalRequirements: value));
                    },
                  ),
              ],
            ),
            // Are Dropout (Radio Buttons)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text('Are Dropout: '),
                      Radio<String>(
                        value: 'Yes',
                        groupValue: member.areDropout,
                        onChanged: (value) {
                          onChanged(member.copyWith(areDropout: value!));
                        },
                      ),
                      Text('Yes'),
                      Radio<String>(
                        value: 'No',
                        groupValue: member.areDropout,
                        onChanged: (value) {
                          onChanged(member.copyWith(areDropout: value!));
                        },
                      ),
                      Text('No'),
                    ],
                  ),
                ),
                if (member.areDropout == 'Yes')
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Specify Dropout Reason'),
                    initialValue: member.areDropout,
                    onChanged: (value) {
                      onChanged(member.copyWith(areDropout: value));
                    },
                  ),
              ],
            ),

            // Types of Assistance - Transport (Radio Buttons)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text('Transportation: '),
                      Radio<String>(
                        value: 'Yes',
                        groupValue: member.typesOfAssistanceTransport,
                        onChanged: (value) {
                          onChanged(member.copyWith(typesOfAssistanceTransport: value!));
                        },
                      ),
                      Text('Yes'),
                      Radio<String>(
                        value: 'No',
                        groupValue: member.typesOfAssistanceTransport,
                        onChanged: (value) {
                          onChanged(member.copyWith(typesOfAssistanceTransport: value!));
                        },
                      ),
                      Text('No'),
                    ],
                  ),
                ),
                if (member.typesOfAssistanceTransport == 'Yes')
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Specify Transport Needs'),
                    initialValue: member.typesOfAssistanceTransport,
                    onChanged: (value) {
                      onChanged(member.copyWith(typesOfAssistanceTransport: value));
                    },
                  ),
              ],
            ),
            // Types of Assistance - Digital Device (Radio Buttons)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(' Digital Device: '),
                      Radio<String>(
                        value: 'Yes',
                        groupValue: member.typesOfAssistanceDigitalDevice,
                        onChanged: (value) {
                          onChanged(member.copyWith(typesOfAssistanceDigitalDevice: value!));
                        },
                      ),
                      Text('Yes'),
                      Radio<String>(
                        value: 'No',
                        groupValue: member.typesOfAssistanceDigitalDevice,
                        onChanged: (value) {
                          onChanged(member.copyWith(typesOfAssistanceDigitalDevice: value!));
                        },
                      ),
                      Text('No'),
                    ],
                  ),
                ),
                if (member.typesOfAssistanceDigitalDevice == 'Yes')
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Specify Device Needs'),
                    initialValue: member.typesOfAssistanceDigitalDevice,
                    onChanged: (value) {
                      onChanged(member.copyWith(typesOfAssistanceDigitalDevice: value));
                    },
                  ),
              ],
            ),
            // Types of Assistance - Study Materials (Radio Buttons)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text('Study Materials: '),
                      Radio<String>(
                        value: 'Yes',
                        groupValue: member.typesOfAssistanceStudyMaterials,
                        onChanged: (value) {
                          onChanged(member.copyWith(typesOfAssistanceStudyMaterials: value!));
                        },
                      ),
                      Text('Yes'),
                      Radio<String>(
                        value: 'No',
                        groupValue: member.typesOfAssistanceStudyMaterials,
                        onChanged: (value) {
                          onChanged(member.copyWith(typesOfAssistanceStudyMaterials: value!));
                        },
                      ),
                      Text('No'),
                    ],
                  ),
                ),
                if (member.typesOfAssistanceStudyMaterials == 'Yes')
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Specify Study Material Needs'),
                    initialValue: member.typesOfAssistanceStudyMaterials,
                    onChanged: (value) {
                      onChanged(member.copyWith(typesOfAssistanceStudyMaterials: value));
                    },
                  ),
              ],
            ),
            // Other fields remain unchanged...
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Previous Status'),
              value: member.previousStatus ?? 'Unemployed',
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(member.copyWith(previousStatus: newValue));
                }
              },
              items: _previousStatusOptions
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Employment Type'),
              value: member.employmentType ?? 'Others',
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(member.copyWith(employmentType: newValue));
                }
              },
              items: _employmentTypeOptions
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (member.employmentType == 'Others')
              TextFormField(
                decoration: InputDecoration(labelText: 'Specify Other Employment'),
                initialValue: member.employmentType,
                onChanged: (value) {
                  onChanged(member.copyWith(employmentType: value));
                },
              ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Education'),
              initialValue: member.education,
              onChanged: (value) {
                onChanged(member.copyWith(education: value));
              },
            ),

            TextFormField(
              decoration: InputDecoration(labelText: 'Salary'),
              initialValue: member.salary,
              onChanged: (value) {
                onChanged(member.copyWith(salary: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Class/Course'),
              initialValue: member.className,
              onChanged: (value) {
                onChanged(member.copyWith(className: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'School/Institution Name'),
              initialValue: member.schoolInstituteName,
              onChanged: (value) {
                onChanged(member.copyWith(schoolInstituteName: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Preferred Mode of Education'),
              initialValue: member.preferredModeOfEducation,
              onChanged: (value) {
                onChanged(member.copyWith(preferredModeOfEducation: value));
              },
            ),
          ],
        ),
      ),
    );
  }
}

