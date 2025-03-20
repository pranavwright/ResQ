import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_b_screen.dart';

class ScreenA extends StatefulWidget {
  final NeedAssessmentData data;

  ScreenA({required this.data});

  @override
  _ScreenAState createState() => _ScreenAState();
}

class _ScreenAState extends State<ScreenA> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section A: Household Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Village/Ward'),
                initialValue: widget.data.villageWard,
                onChanged: (value) => widget.data.villageWard = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'House Number'),
                initialValue: widget.data.houseNumber,
                onChanged: (value) => widget.data.houseNumber = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Household Head'),
                initialValue: widget.data.householdHead,
                onChanged: (value) => widget.data.householdHead = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Unique Household ID'),
                initialValue: widget.data.uniqueHouseholdId,
                onChanged: (value) => widget.data.uniqueHouseholdId = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                initialValue: widget.data.address,
                onChanged: (value) => widget.data.address = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contact No.'),
                initialValue: widget.data.contactNo,
                onChanged: (value) => widget.data.contactNo = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Ration Card No.'),
                initialValue: widget.data.rationCardNo,
                onChanged: (value) => widget.data.rationCardNo = value,
              ),
              // Ration Category Radio Buttons
              Text(
                'Ration Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Column(
                children: [
                  RadioListTile<String>(
                    title: Text('Yellow'),
                    value: 'Yellow',
                    groupValue: widget.data.rationCategory,
                    onChanged: (value) {
                      setState(() {
                        widget.data.rationCategory = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('White'),
                    value: 'White',
                    groupValue: widget.data.rationCategory,
                    onChanged: (value) {
                      setState(() {
                        widget.data.rationCategory = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Pink'),
                    value: 'Pink',
                    groupValue: widget.data.rationCategory,
                    onChanged: (value) {
                      setState(() {
                        widget.data.rationCategory = value!;
                      });
                    },
                  ),
                ],
              ),
              // Caste Radio Buttons
              Text(
                'Caste',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Column(
                children: [
                  RadioListTile<String>(
                    title: Text('General'),
                    value: 'General',
                    groupValue: widget.data.caste,
                    onChanged: (value) {
                      setState(() {
                        widget.data.caste = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Other Backward Class'),
                    value: 'Other Backward Class',
                    groupValue: widget.data.caste,
                    onChanged: (value) {
                      setState(() {
                        widget.data.caste = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Scheduled Caste'),
                    value: 'Scheduled Caste',
                    groupValue: widget.data.caste,
                    onChanged: (value) {
                      setState(() {
                        widget.data.caste = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Scheduled Tribe'),
                    value: 'Scheduled Tribe',
                    groupValue: widget.data.caste,
                    onChanged: (value) {
                      setState(() {
                        widget.data.caste = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Others'),
                    value: 'Others',
                    groupValue: widget.data.caste,
                    onChanged: (value) {
                      setState(() {
                        widget.data.caste = value!;
                      });
                    },
                  ),
                ],
              ),
              if (widget.data.caste == 'Others')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Other Caste'),
                  initialValue: widget.data.otherCaste,
                  onChanged: (value) => widget.data.otherCaste = value,
                ),
              SizedBox(height: 20),
              Text(
                'Demographics of Total Household Members',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.data.members.length,
                itemBuilder: (context, index) {
                  return MemberInput(
                    member: widget.data.members[index],
                    onChanged: (updatedMember) {
                      setState(() {
                        widget.data.members[index] = updatedMember;
                      });
                    },
                    onDelete: () {
                      setState(() {
                        widget.data.members.removeAt(index);
                      });
                    },
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    widget.data.members.add(
                      Member(
                        name: '',
                        age: '',
                        gender: 'Male', // Set a default gender
                        relationship: 'Son', // Set a default relationship
                      ),
                    );
                  });
                },
                child: Text('Add Member'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenB(data: widget.data),
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

class MemberInput extends StatefulWidget {
  final Member member;
  final Function(Member) onChanged;
  final VoidCallback onDelete;

  MemberInput({
    required this.member,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  _MemberInputState createState() => _MemberInputState();
}

class _MemberInputState extends State<MemberInput> {
  String? _selectedGender;
  String? _selectedRelationship;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.member.gender;
    _selectedRelationship = widget.member.relationship;
  }

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
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              initialValue: widget.member.name,
              onChanged: (value) {
                widget.onChanged(Member(
                  name: value,
                  age: widget.member.age,
                  gender: widget.member.gender,
                  relationship: widget.member.relationship,
                ));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Age'),
              initialValue: widget.member.age,
              onChanged: (value) {
                widget.onChanged(Member(
                  name: widget.member.name,
                  age: value,
                  gender: widget.member.gender,
                  relationship: widget.member.relationship,
                ));
              },
            ),

            // Gender dropdown using Material DropdownButton
            DropdownButton<String>(
              value: _selectedGender,
              hint: Text('Select Gender'),
              isExpanded: true,
              items: ['Male', 'Female', 'Other']
                  .map((gender) => DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                  widget.onChanged(Member(
                    name: widget.member.name,
                    age: widget.member.age,
                    gender: _selectedGender!,
                    relationship: widget.member.relationship,
                  ));
                });
              },
            ),

            // Relationship dropdown using Material DropdownButton
            DropdownButton<String>(
              value: _selectedRelationship,
              hint: Text('Select Relationship'),
              isExpanded: true,
              items: [
                'Father',
                'Mother',
                'Son',
                'Daughter',
                'Grand Mother',
                'Grand Father',
                'Other'
              ]
                  .map((relationship) => DropdownMenuItem<String>(
                        value: relationship,
                        child: Text(relationship),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRelationship = newValue;
                  widget.onChanged(Member(
                    name: widget.member.name,
                    age: widget.member.age,
                    gender: widget.member.gender,
                    relationship: _selectedRelationship!,
                  ));
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}