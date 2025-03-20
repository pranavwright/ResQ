import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_j_screen.dart';
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
  });

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
            TextFormField(
              decoration: InputDecoration(labelText: 'Marital Status'),
              initialValue: member.maritalStatus,
              onChanged: (value) {
                onChanged(member.copyWith(maritalStatus: value));
              },
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

            // Special Medical Requirements (Radio Buttons)
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

            // Are Dropout (Radio Buttons)
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

            // Types of Assistance - Transport (Radio Buttons)
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

            // Types of Assistance - Digital Device (Radio Buttons)
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

            // Types of Assistance - Study Materials (Radio Buttons)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(' Study Materials: '),
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

            // Other fields remain unchanged...
            TextFormField(
              decoration: InputDecoration(labelText: 'Education'),
              initialValue: member.education,
              onChanged: (value) {
                onChanged(member.copyWith(education: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Previous Status'),
              initialValue: member.previousStatus,
              onChanged: (value) {
                onChanged(member.copyWith(previousStatus: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Employment Type'),
              initialValue: member.employmentType,
              onChanged: (value) {
                onChanged(member.copyWith(employmentType: value));
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
              decoration: InputDecoration(labelText: 'Unemployed Due to Disaster'),
              initialValue: member.unemployedDueToDisaster,
              onChanged: (value) {
                onChanged(member.copyWith(unemployedDueToDisaster: value));
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
