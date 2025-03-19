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
            TextFormField(
              decoration: InputDecoration(labelText: 'Grievously Injured'),
              initialValue: member.grievouslyInjured,
              onChanged: (value) {
                onChanged(member.copyWith(grievouslyInjured: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Bedridden/Palliative'),
              initialValue: member.bedriddenPalliative,
              onChanged: (value) {
                onChanged(member.copyWith(bedriddenPalliative: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'PWDS'),
              initialValue: member.pwDs,
              onChanged: (value) {
                onChanged(member.copyWith(pwDs: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Psycho-Social Assistance'),
              initialValue: member.psychoSocialAssistance,
              onChanged: (value) {
                onChanged(member.copyWith(psychoSocialAssistance: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Nursing Home Assistance'),
              initialValue: member.nursingHomeAssistance,
              onChanged: (value) {
                onChanged(member.copyWith(nursingHomeAssistance: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Assistive Devices'),
              initialValue: member.assistiveDevices,
              onChanged: (value) {
                onChanged(member.copyWith(assistiveDevices: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Special Medical Requirements'),
              initialValue: member.specialMedicalRequirements,
              onChanged: (value) {
                onChanged(member.copyWith(specialMedicalRequirements: value));
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
              decoration: InputDecoration(labelText: 'Are Dropout'),
              initialValue: member.areDropout,
              onChanged: (value) {
                onChanged(member.copyWith(areDropout: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Preferred Mode of Education'),
              initialValue: member.preferredModeOfEducation,
              onChanged: (value) {
                onChanged(member.copyWith(preferredModeOfEducation: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Types of Assistance - Transport'),
              initialValue: member.typesOfAssistanceTransport,
              onChanged: (value) {
                onChanged(member.copyWith(typesOfAssistanceTransport: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Types of Assistance - Digital Device'),
              initialValue: member.typesOfAssistanceDigitalDevice,
              onChanged: (value) {
                onChanged(member.copyWith(typesOfAssistanceDigitalDevice: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Types of Assistance - Study Materials'),
              initialValue: member.typesOfAssistanceStudyMaterials,
              onChanged: (value)
              {
                onChanged(member.copyWith(typesOfAssistanceStudyMaterials: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Types of Assistance - Any Other Specific Requirement'),
              initialValue: member.typesOfAssistanceAnyOtherSpecificRequirement,
              onChanged: (value) {
                onChanged(member.copyWith(typesOfAssistanceAnyOtherSpecificRequirement: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Present Skill Set'),
              initialValue: member.presentSkillSet,
              onChanged: (value) {
                onChanged(member.copyWith(presentSkillSet: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Type of Livelihood Assistance Required'),
              initialValue: member.typeOfLivelihoodAssistanceRequired,
              onChanged: (value) {
                onChanged(member.copyWith(typeOfLivelihoodAssistanceRequired: value));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Type of Skilling Assistance Required'),
              initialValue: member.typeOfSkillingAssistanceRequired,
              onChanged: (value) {
                onChanged(member.copyWith(typeOfSkillingAssistanceRequired: value));
              },
            ),
          ],
        ),
      ),
    );
  }
}