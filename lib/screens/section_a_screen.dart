import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';

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
              TextFormField(
                decoration: InputDecoration(labelText: 'Ration Category'),
                initialValue: widget.data.rationCategory,
                onChanged: (value) => widget.data.rationCategory = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Caste'),
                initialValue: widget.data.caste,
                onChanged: (value) => widget.data.caste = value,
              ),
              if (widget.data.caste == 'Other')
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
                        gender: '',
                        relationship: '',
                      ),
                    );
                  });
                },
                child: Text('Add Member'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => ScreenB(data: widget.data),
                  //     ),
                  //   );
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

class MemberInput extends StatelessWidget {
  final Member member;
  final Function(Member) onChanged;

  MemberInput({
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
                onChanged(Member(
                  name: value,
                  age: member.age,
                  gender: member.gender,
                  relationship: member.relationship,
                ));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Age'),
              initialValue: member.age,
              onChanged: (value) {
                onChanged(Member(
                  name: member.name,
                  age: value,
                  gender: member.gender,
                  relationship: member.relationship,
                ));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Gender'),
              initialValue: member.gender,
              onChanged: (value) {
                onChanged(Member(
                  name: member.name,
                  age: member.age,
                  gender: value,
                  relationship: member.relationship,
                ));
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Relationship'),
              initialValue: member.relationship,
              onChanged: (value) {
                onChanged(Member(
                  name: member.name,
                  age: member.age,
                  gender: member.gender,
                  relationship: value,
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
