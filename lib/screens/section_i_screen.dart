import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_k_screen.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';

class ScreenI extends StatefulWidget {
  final NeedAssessmentData data;

  ScreenI({required this.data});

  @override
  _ScreenIState createState() => _ScreenIState();
}

class _ScreenIState extends State<ScreenI> {
  List<Map<String, dynamic>> _camps = [];
  bool _isCampLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCamps();
  }

  Future<void> _fetchCamps() async {
    try {
      setState(() {
        _isCampLoading = true;
      });

      final campResponse = await TokenHttp().get(
        '/disaster/getCampNames?disasterId=${AuthService().getDisasterId()}',
      );

      if (campResponse != null && campResponse['list'] is List) {
        final camps = List<Map<String, dynamic>>.from(
          campResponse['list'].map(
            (camp) => {
              '_id': camp['_id']?.toString() ?? '',
              'name': camp['name']?.toString() ?? '',
            },
          ),
        );

        // Ensure unique camp IDs
        final uniqueCamps =
            camps
                .fold<Map<String, Map<String, dynamic>>>(
                  {},
                  (map, camp) => map..putIfAbsent(camp['_id'], () => camp),
                )
                .values
                .toList();

        setState(() {
          _camps = uniqueCamps;
        });
        setState(() {
          _camps = uniqueCamps;
          _isCampLoading = false;
        });
      } else {
        setState(() {
          _isCampLoading = false;
        });
        throw Exception('Invalid camp data format');
      }
    } catch (e) {
      setState(() {
        _isCampLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load camps. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Section I: Individual Member Details')),
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
              SizedBox(height: 16),
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
                    camps: _camps,
                    isCampLoading: _isCampLoading,
                  );
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreenK(data: widget.data),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IndividualMemberInput extends StatefulWidget {
  final Member member;
  final Function(Member) onChanged;
  final List<Map<String, dynamic>> camps;
  final bool isCampLoading;

  IndividualMemberInput({
    required this.member,
    required this.onChanged,
    required this.camps,
    required this.isCampLoading,
  });

  @override
  _IndividualMemberInputState createState() => _IndividualMemberInputState();
}

class _IndividualMemberInputState extends State<IndividualMemberInput> {
  final List<String> _accommodationStatusOptions = [
    'Relief Camps',
    'Friends/Relatives',
    'Rented House',
    'Govt Accommodation',
    'Others',
  ];

  final List<String> _maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
    'Other',
  ];

  final List<String> _previousStatusOptions = [
    'Employed',
    'Unemployed',
    'Self Employed',
    'Unemployed due to the disaster',
  ];

  final List<String> _employmentTypeOptions = [
    'Govt',
    'Private',
    'Plantation',
    'Agri/Allied',
    'Daily Wage',
    'Others',
  ];

  late String selectedAccommodationStatus;
  String? selectedCampId;

  @override
  void initState() {
    super.initState();
    selectedAccommodationStatus =
        widget.member.accommodationStatus.isNotEmpty
            ? widget.member.accommodationStatus
            : 'Relief Camps';

    // Initialize camp ID safely
    if (selectedAccommodationStatus == 'Relief Camps' &&
        widget.camps.isNotEmpty) {
      selectedCampId =
          widget.member.campId.isNotEmpty &&
                  widget.camps.any((c) => c['_id'] == widget.member.campId)
              ? widget.member.campId
              : widget.camps.first['_id'];
    } else {
      selectedCampId = null;
    }

    // Initialize empty fields with default values
    widget.member.maritalStatus ??= 'Single';
    widget.member.previousStatus ??= 'Unemployed';
    widget.member.employmentType ??= 'Others';
  }

  String? _getValidCampId() {
    if (widget.camps.isEmpty) return null;

    // Check if current campId exists in camps list
    if (widget.member.campId.isNotEmpty &&
        widget.camps.any((camp) => camp['_id'] == widget.member.campId)) {
      return widget.member.campId;
    }

    // Return first camp ID as default
    return widget.camps.first['_id'];
  }

  Widget _buildRadioGroup({
    required String title,
    required String groupValue,
    required Function(String) onChanged,
    String? detailValue,
    String? detailHint,
    Function(String)? onDetailChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Radio<String>(
              value: 'Yes',
              groupValue: groupValue,
              onChanged: (value) => onChanged(value!),
            ),
            Text('Yes'),
            Radio<String>(
              value: 'No',
              groupValue: groupValue,
              onChanged: (value) => onChanged(value!),
            ),
            Text('No'),
          ],
        ),
        if (groupValue == 'Yes' && onDetailChanged != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: detailHint,
                border: OutlineInputBorder(),
              ),
              initialValue: detailValue,
              onChanged: onDetailChanged,
            ),
          ),
        SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String? _getDropdownValue() {
      // Return null if camps is empty
      if (widget.camps.isEmpty) {
        return null;
      }

      // Check if selectedCampId is valid
      if (selectedCampId != null) {
        bool campExists = false;

        // Check manually to avoid any issues
        for (var camp in widget.camps) {
          if (camp['_id'] == selectedCampId) {
            campExists = true;
            break;
          }
        }

        if (campExists) {
          return selectedCampId;
        }
      }

      // Select a default value if needed
      if (widget.camps.isNotEmpty) {
        // Use the first camp as default
        selectedCampId = widget.camps[0]['_id'];
        // Update the member with this campId
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onChanged(widget.member.copyWith(campId: selectedCampId));
        });
        return selectedCampId;
      }

      // Last resort - return null
      return null;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 20),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Section
            Text(
              'Basic Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              initialValue: widget.member.name,
              onChanged:
                  (value) =>
                      widget.onChanged(widget.member.copyWith(name: value)),
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              initialValue: widget.member.age,
              keyboardType: TextInputType.number,
              onChanged:
                  (value) =>
                      widget.onChanged(widget.member.copyWith(age: value)),
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              initialValue: widget.member.gender,
              onChanged:
                  (value) =>
                      widget.onChanged(widget.member.copyWith(gender: value)),
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Relationship',
                border: OutlineInputBorder(),
              ),
              initialValue: widget.member.relationship,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(relationship: value),
                  ),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Marital Status',
                border: OutlineInputBorder(),
              ),
              value: widget.member.maritalStatus,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  widget.onChanged(
                    widget.member.copyWith(maritalStatus: newValue),
                  );
                }
              },
              items:
                  _maritalStatusOptions.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'L/D/M',
                border: OutlineInputBorder(),
              ),
              initialValue: widget.member.ldm,
              onChanged:
                  (value) =>
                      widget.onChanged(widget.member.copyWith(ldm: value)),
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Aadhar No.',
                border: OutlineInputBorder(),
              ),
              initialValue: widget.member.aadharNo,
              keyboardType: TextInputType.number,
              onChanged:
                  (value) =>
                      widget.onChanged(widget.member.copyWith(aadharNo: value)),
            ),
            SizedBox(height: 20),

            // Health Status Section
            Text(
              'Health Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildRadioGroup(
              title: 'Grievously Injured:',
              groupValue: widget.member.grievouslyInjured,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(grievouslyInjured: value),
                  ),
            ),
            _buildRadioGroup(
              title: 'Bedridden/Palliative:',
              groupValue: widget.member.bedriddenPalliative,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(bedriddenPalliative: value),
                  ),
            ),
            _buildRadioGroup(
              title: 'PWDS:',
              groupValue: widget.member.pwDs,
              onChanged:
                  (value) =>
                      widget.onChanged(widget.member.copyWith(pwDs: value)),
            ),
            _buildRadioGroup(
              title: 'Psycho-Social Assistance:',
              groupValue: widget.member.psychoSocialAssistance,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(psychoSocialAssistance: value),
                  ),
            ),
            _buildRadioGroup(
              title: 'Nursing Home Assistance:',
              groupValue: widget.member.nursingHomeAssistance,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(nursingHomeAssistance: value),
                  ),
            ),
            _buildRadioGroup(
              title: 'Assistive Devices:',
              groupValue: widget.member.assistiveDevices,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(assistiveDevices: value),
                  ),
            ),
            _buildRadioGroup(
              title: 'Special Medical Requirements:',
              groupValue: widget.member.specialMedicalRequirements,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(specialMedicalRequirements: value),
                  ),
            ),
            SizedBox(height: 20),

            // Education Section
            Text(
              'Education Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildRadioGroup(
              title: 'Are Dropout:',
              groupValue: widget.member.areDropout,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(areDropout: value),
                  ),
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Class/Course',
                border: OutlineInputBorder(),
              ),
              initialValue: widget.member.className,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(className: value),
                  ),
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'School/Institution Name',
                border: OutlineInputBorder(),
              ),
              initialValue: widget.member.schoolInstituteName,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(schoolInstituteName: value),
                  ),
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Preferred Mode of Education',
                border: OutlineInputBorder(),
              ),
              initialValue: widget.member.preferredModeOfEducation,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(preferredModeOfEducation: value),
                  ),
            ),
            SizedBox(height: 20),

            // Employment Section
            Text(
              'Employment Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Previous Status',
                border: OutlineInputBorder(),
              ),
              value: widget.member.previousStatus,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  widget.onChanged(
                    widget.member.copyWith(previousStatus: newValue),
                  );
                }
              },
              items:
                  _previousStatusOptions.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Employment Type',
                border: OutlineInputBorder(),
              ),
              value: widget.member.employmentType,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  widget.onChanged(
                    widget.member.copyWith(employmentType: newValue),
                  );
                }
              },
              items:
                  _employmentTypeOptions.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            SizedBox(height: 12),
            if (widget.member.employmentType == 'Others')
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Specify Other Employment',
                  border: OutlineInputBorder(),
                ),
                initialValue: widget.member.employmentType,
                onChanged:
                    (value) => widget.onChanged(
                      widget.member.copyWith(employmentType: value),
                    ),
              ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Education',
                border: OutlineInputBorder(),
              ),
              initialValue: widget.member.education,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(education: value),
                  ),
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Salary',
                border: OutlineInputBorder(),
              ),
              initialValue: widget.member.salary,
              keyboardType: TextInputType.number,
              onChanged:
                  (value) =>
                      widget.onChanged(widget.member.copyWith(salary: value)),
            ),
            SizedBox(height: 20),

            // Assistance Needs Section
            Text(
              'Assistance Needs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildRadioGroup(
              title: 'Transportation:',
              groupValue: widget.member.typesOfAssistanceTransport,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(typesOfAssistanceTransport: value),
                  ),
            ),
            _buildRadioGroup(
              title: 'Digital Device:',
              groupValue: widget.member.typesOfAssistanceDigitalDevice,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(
                      typesOfAssistanceDigitalDevice: value,
                    ),
                  ),
            ),
            _buildRadioGroup(
              title: 'Study Materials:',
              groupValue: widget.member.typesOfAssistanceStudyMaterials,
              onChanged:
                  (value) => widget.onChanged(
                    widget.member.copyWith(
                      typesOfAssistanceStudyMaterials: value,
                    ),
                  ),
            ),
            SizedBox(height: 20),

            // Accommodation Status Section
            Text(
              'Accommodation Status (Post-Disaster)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Accommodation Status',
                border: OutlineInputBorder(),
              ),
              value: selectedAccommodationStatus,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedAccommodationStatus = newValue;
                    widget.onChanged(
                      widget.member.copyWith(
                        accommodationStatus: newValue,
                        campId:
                            newValue == 'Relief Camps' ? selectedCampId : '',
                      ),
                    );
                  });
                }
              },
              items:
                  _accommodationStatusOptions.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            SizedBox(height: 12),
            if (selectedAccommodationStatus == 'Relief Camps') ...[
              Text(
                'Select Camp',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              widget.isCampLoading
                  ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : widget.camps.isEmpty
                  ? Text(
                    "No camps available. Please check with administrator.",
                    style: TextStyle(color: Colors.red),
                  )
                  : Builder(
                    builder: (context) {
                      // DEBUG: Print to verify what camps and selection we have
                      print(
                        'Camps: ${widget.camps.map((c) => "${c['_id']}: ${c['name']}").join(', ')}',
                      );
                      print('Selected Camp ID: $selectedCampId');

                      // Find a valid camp ID to use
                      String? validCampId = null;

                      // If we have a selectedCampId and it exists in the camps list, use it
                      if (selectedCampId != null &&
                          widget.camps.any(
                            (camp) => camp['_id'] == selectedCampId,
                          )) {
                        validCampId = selectedCampId;
                      }
                      // Otherwise use the first camp ID if available
                      else if (widget.camps.isNotEmpty) {
                        validCampId = widget.camps[0]['_id'];
                        // Also update selectedCampId to keep in sync
                        selectedCampId = validCampId;
                      }

                      print('Using valid camp ID: $validCampId');

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Camp',
                          border: OutlineInputBorder(),
                        ),
                        value: validCampId,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedCampId = newValue;
                              widget.onChanged(
                                widget.member.copyWith(campId: newValue),
                              );
                            });
                          }
                        },
                        items:
                            widget.camps.map<DropdownMenuItem<String>>((camp) {
                              return DropdownMenuItem<String>(
                                value: camp['_id'],
                                child: Text(camp['name'] ?? 'Unknown Camp'),
                              );
                            }).toList(),
                      );
                    },
                  ),
              SizedBox(height: 12),
            ],
            if (selectedAccommodationStatus == 'Others') ...[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Other Accommodation Details',
                  border: OutlineInputBorder(),
                ),
                initialValue: widget.member.otherAccommodation,
                onChanged:
                    (value) => widget.onChanged(
                      widget.member.copyWith(otherAccommodation: value),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
