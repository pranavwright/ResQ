import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_b_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenA extends StatefulWidget {
  final NeedAssessmentData data;

  ScreenA({required this.data});

  @override
  _ScreenAState createState() => _ScreenAState();
}

class _ScreenAState extends State<ScreenA> {
  // Method to add a new member
  void _addMember() {
    setState(() {
      widget.data.members.add(Member(name: '', age: '', gender: 'Male', relationship: 'Other')); // Initialize with default values
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Section A: Household Profile',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF08708E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernTextFormField(
                labelText: 'Village/Ward',
                initialValue: widget.data.villageWard,
                onChanged: (value) => widget.data.villageWard = value,
              ),
              _buildModernTextFormField(
                labelText: 'House Number',
                initialValue: widget.data.houseNumber,
                onChanged: (value) => widget.data.houseNumber = value,
              ),
              _buildModernTextFormField(
                labelText: 'Household Head',
                initialValue: widget.data.householdHead,
                onChanged: (value) => widget.data.householdHead = value,
              ),
              _buildModernTextFormField(
                labelText: 'Unique Household ID',
                initialValue: widget.data.uniqueHouseholdId,
                onChanged: (value) => widget.data.uniqueHouseholdId = value,
              ),
              _buildModernTextFormField(
                labelText: 'Address',
                initialValue: widget.data.address,
                onChanged: (value) => widget.data.address = value,
              ),
              _buildModernTextFormField(
                labelText: 'Contact No.',
                initialValue: widget.data.contactNo,
                onChanged: (value) => widget.data.contactNo = value,
                keyboardType: TextInputType.phone,
              ),
              _buildModernTextFormField(
                labelText: 'Ration Card No.',
                initialValue: widget.data.rationCardNo,
                onChanged: (value) => widget.data.rationCardNo = value,
              ),
              _buildSectionTitle('Ration Category'),
              _buildRadioListTile(
                title: 'Yellow',
                value: 'Yellow',
                groupValue: widget.data.rationCategory,
                onChanged: (value) {
                  setState(() {
                    widget.data.rationCategory = value!;
                  });
                },
              ),
              _buildRadioListTile(
                title: 'White',
                value: 'White',
                groupValue: widget.data.rationCategory,
                onChanged: (value) {
                  setState(() {
                    widget.data.rationCategory = value!;
                  });
                },
              ),
              _buildRadioListTile(
                title: 'Pink',
                value: 'Pink',
                groupValue: widget.data.rationCategory,
                onChanged: (value) {
                  setState(() {
                    widget.data.rationCategory = value!;
                  });
                },
              ),
              _buildSectionTitle('Caste'),
              _buildRadioListTile(
                title: 'General',
                value: 'General',
                groupValue: widget.data.caste,
                onChanged: (value) {
                  setState(() {
                    widget.data.caste = value!;
                  });
                },
              ),
              _buildRadioListTile(
                title: 'Other Backward Class',
                value: 'Other Backward Class',
                groupValue: widget.data.caste,
                onChanged: (value) {
                  setState(() {
                    widget.data.caste = value!;
                  });
                },
              ),
              _buildRadioListTile(
                title: 'Scheduled Caste',
                value: 'Scheduled Caste',
                groupValue: widget.data.caste,
                onChanged: (value) {
                  setState(() {
                    widget.data.caste = value!;
                  });
                },
              ),
              _buildRadioListTile(
                title: 'Scheduled Tribe',
                value: 'Scheduled Tribe',
                groupValue: widget.data.caste,
                onChanged: (value) {
                  setState(() {
                    widget.data.caste = value!;
                  });
                },
              ),
              _buildRadioListTile(
                title: 'Others',
                value: 'Others',
                groupValue: widget.data.caste,
                onChanged: (value) {
                  setState(() {
                    widget.data.caste = value!;
                  });
                },
              ),
              if (widget.data.caste == 'Others')
                _buildModernTextFormField(
                  labelText: 'Other Caste',
                  initialValue: widget.data.otherCaste,
                  onChanged: (value) => widget.data.otherCaste = value,
                ),
              const SizedBox(height: 30),
              _buildSectionTitle('Demographics of Total Household Members'),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
              const SizedBox(height: 10), // Added space before the button
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: _addMember, // Call the _addMember method
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF08708E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Add Member', // Button text
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreenB(data: widget.data),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF08708E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom method for consistent TextFormField styling
  Widget _buildModernTextFormField({
    required String labelText,
    String? initialValue,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: keyboardType,
        initialValue: initialValue,
        onChanged: onChanged,
        style: GoogleFonts.urbanist(),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.urbanist(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF08708E), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  // Custom method for consistent RadioListTile styling
  Widget _buildRadioListTile<T>({
    required String title,
    required T value,
    required T? groupValue,
    void Function(T?)? onChanged,
  }) {
    return RadioListTile<T>(
      title: Text(
        title,
        style: GoogleFonts.urbanist(),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: const Color(0xFF08708E),
    );
  }

  // Custom method for consistent section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: GoogleFonts.urbanist(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF08708E),
        ),
      ),
    );
  }

  //Custom dropdown
  Widget _buildDropdownButton<T>({
    required T? value,
    required String hint,
    required List<String> items,
    void Function(T?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        hint: Text(
          hint,
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        onChanged: onChanged,
        isExpanded: true,
        items: items.map<DropdownMenuItem<T>>((String item) {
          return DropdownMenuItem<T>(
            value: item as T,
            child: Text(
              item,
              style: GoogleFonts.urbanist(),
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF08708E), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: GoogleFonts.urbanist(),
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
  bool _genderOtherSelected = false;
  bool _relationshipOtherSelected = false;
  TextEditingController _otherGenderController = TextEditingController();
  TextEditingController _otherRelationshipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (['Male', 'Female', 'Other'].contains(widget.member.gender)) {
      _selectedGender = widget.member.gender;
      if (widget.member.gender == 'Other') {
        _genderOtherSelected = true;
        _otherGenderController.text = widget.member.gender ?? ""; // corrected this line
      }
    } else {
      _selectedGender = null;
    }

    final validRelationships = [
      'Father',
      'Mother',
      'Son',
      'Daughter',
      'Grand Mother',
      'Grand Father',
      'Other'
    ];
    if (validRelationships.contains(widget.member.relationship)) {
      _selectedRelationship = widget.member.relationship;
      if (widget.member.relationship == "Other") {
        _relationshipOtherSelected = true;
        _otherRelationshipController.text =
            widget.member.relationship ?? ""; // corrected this line
      }
    } else {
      _selectedRelationship = null;
    }
  }

  @override
  void dispose() {
    _otherGenderController.dispose();
    _otherRelationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            _buildModernTextFormField(
              labelText: 'Name',
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
            _buildModernTextFormField(
              labelText: 'Age',
              initialValue: widget.member.age,
              onChanged: (value) {
                widget.onChanged(Member(
                  name: value,
                  age: value,
                  gender: widget.member.gender,
                  relationship: widget.member.relationship,
                ));
              },
              keyboardType: TextInputType.number,
            ),
            _buildDropdownButton<String>(
              value: _selectedGender,
              hint: 'Select Gender',
              items: ['Male', 'Female', 'Other'],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                  _genderOtherSelected = newValue == 'Other';
                  widget.onChanged(
                    Member(
                      name: widget.member.name,
                      age: widget.member.age,
                      gender: _selectedGender ?? 'Male',
                      relationship: widget.member.relationship,
                    ),
                  );
                });
              },
            ),
            if (_genderOtherSelected)
              _buildModernTextFormField(
                labelText: 'Other Gender',
                controller: _otherGenderController,
                onChanged: (value) {
                  String genderValue = value.isNotEmpty ? value : "Other";
                  widget.onChanged(
                    Member(
                      name: widget.member.name,
                      age: widget.member.age,
                      gender: genderValue,
                      relationship: widget.member.relationship,
                    ),
                  );
                },
              ),
            _buildDropdownButton<String>(
              value: _selectedRelationship,
              hint: 'Select Relationship',
              items: [
                'Father',
                'Mother',
                'Son',
                'Daughter',
                'Grand Mother',
                'Grand Father',
                'Other'
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRelationship = newValue;
                  _relationshipOtherSelected = newValue == 'Other';
                  widget.onChanged(
                    Member(
                      name: widget.member.name,
                      age: widget.member.age,
                      gender: widget.member.gender,
                      relationship: _selectedRelationship ?? 'Other',
                    ),
                  );
                });
              },
            ),
            if (_relationshipOtherSelected)
              _buildModernTextFormField(
                labelText: 'Other Relationship',
                controller: _otherRelationshipController,
                onChanged: (value) {
                  String relationshipValue = value.isNotEmpty ? value : "Other";
                  widget.onChanged(
                    Member(
                      name: widget.member.name,
                      age: widget.member.age,
                      gender: widget.member.gender,
                      relationship: relationshipValue,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Custom method for consistent TextFormField styling
  Widget _buildModernTextFormField({
    required String labelText,
    String? initialValue,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        initialValue: initialValue,
        onChanged: onChanged,
        style: GoogleFonts.urbanist(),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.urbanist(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF08708E), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  // Custom method for consistent RadioListTile styling
  Widget _buildRadioListTile<T>({
    required String title,
    required T value,
    required T? groupValue,
    void Function(T?)? onChanged,
  }) {
    return RadioListTile<T>(
      title: Text(
        title,
        style: GoogleFonts.urbanist(),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: const Color(0xFF08708E),
    );
  }

  // Custom method for consistent section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: GoogleFonts.urbanist(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF08708E),
        ),
      ),
    );
  }

  //Custom dropdown
  Widget _buildDropdownButton<T>({
    required T? value,
    required String hint,
    required List<String> items,
    void Function(T?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        hint: Text(
          hint,
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        onChanged: onChanged,
        isExpanded: true,
        items: items.map<DropdownMenuItem<T>>((String item) {
          return DropdownMenuItem<T>(
            value: item as T,
            child: Text(
              item,
              style: GoogleFonts.urbanist(),
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF08708E), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: GoogleFonts.urbanist(),
      ),
    );
  }
}

