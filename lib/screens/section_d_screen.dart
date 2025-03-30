import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_e_screen.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';

class ScreenD extends StatefulWidget {
  final NeedAssessmentData data;

  ScreenD({required this.data});

  @override
  _ScreenDState createState() => _ScreenDState();
}

class _ScreenDState extends State<ScreenD> {
  String? selectedVehiclePossession;
  String? selectedVehicleLoss;
  String? selectedAccommodationStatus;
  String? vehicleLossTypeDetails;
  String? selectedShelterType;
  String? selectedCampId;

  List<Map<String, dynamic>> _camps = [];
  bool _isLoading = false;

  final List<String> _shelterTypeOptions = [
    'Permanent House',
    'House Built with Govt Assistance',
    'Rented',
    'Paadi (Layam)',
    'Others',
  ];

  final List<String> _accommodationStatusOptions = [
    'Relief Camps',
    'Friends/Relatives',
    'Rented House',
    'Govt Accommodation',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCamps();
    selectedVehiclePossession = widget.data.vehiclePossession;
    selectedVehicleLoss = widget.data.vehicleLoss;
    selectedAccommodationStatus = widget.data.accommodationStatus;
    selectedShelterType = widget.data.shelterType;
    selectedCampId = widget.data.campId;

    if (selectedAccommodationStatus == '') {
      selectedAccommodationStatus = 'Relief Camps';
    }
    if (selectedShelterType == '') {
      selectedShelterType = 'Permanent House';
    }
  }

  Future<void> _fetchCamps() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final campResponse = await TokenHttp().get(
        '/disaster/getCampNames?disasterId=${AuthService().getDisasterId()}',
      );

      if (campResponse != null && campResponse['list'] is List) {
        setState(() {
          _camps = List<Map<String, dynamic>>.from(
            campResponse['list'].map(
              (camp) => {
                '_id': camp['_id']?.toString() ?? '',
                'name': camp['name']?.toString() ?? '',
              },
            ),
          );
          if(selectedCampId==''){
            selectedCampId = _camps.isNotEmpty ? _camps[0]['_id'] : null;
            widget.data.campId = selectedCampId ?? '';
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching camps: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load camps: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Section D: Shelter and Accommodation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shelter Type Dropdown
              Text('Shelter Type/House Type', style: TextStyle(fontSize: 16)),
              DropdownButtonFormField<String>(
                value: selectedShelterType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedShelterType = newValue;
                    widget.data.shelterType = newValue ?? '';
                  });
                },
                items:
                    _shelterTypeOptions.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select Shelter Type',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // If "Others" is selected, show the text field to specify
              if (selectedShelterType == 'Others')
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Other Shelter Type',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: widget.data.otherShelterType,
                  onChanged: (value) => widget.data.otherShelterType = value,
                ),
              SizedBox(height: 20),

              // Residential Land Area
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Residential Land Area',
                  border: OutlineInputBorder(),
                ),
                initialValue: widget.data.residentialLandArea,
                onChanged: (value) => widget.data.residentialLandArea = value,
              ),
              SizedBox(height: 20),

              // Accommodation Status (Post-Disaster) Dropdown
              Text(
                'Accommodation Status (Post-Disaster)',
                style: TextStyle(fontSize: 16),
              ),
              DropdownButtonFormField<String>(
                value: selectedAccommodationStatus,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAccommodationStatus = newValue;
                    widget.data.accommodationStatus = newValue!;
                    if (newValue != 'Relief Camps') {
                      selectedCampId = null;
                      widget.data.campId = '';
                    }
                  });
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
                decoration: InputDecoration(
                  labelText: 'Select Accommodation Status',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              if (selectedAccommodationStatus == 'Relief Camps')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Camp Name', style: TextStyle(fontSize: 16)),
                    _isLoading
                        ? CircularProgressIndicator()
                        : _camps.isEmpty
                        ? Text(
                          "No camps available. Please check with administrator.",
                        )
                        : DropdownButtonFormField<String>(
                          value:
                              selectedCampId ??
                              (_camps.isNotEmpty ? _camps[0]['_id'] : null),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCampId = newValue;
                              widget.data.campId = newValue ?? '';
                            });
                          },
                          items:
                              _camps.map<DropdownMenuItem<String>>((camp) {
                                return DropdownMenuItem<String>(
                                  value: camp['_id'],
                                  child: Text(camp['name'] ?? ''),
                                );
                              }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Select Camp',
                            border: OutlineInputBorder(),
                          ),
                        ),
                  ],
                ),

              if (selectedAccommodationStatus == 'Others')
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Other Accommodation Details',
                  ),
                  initialValue: widget.data.otherAccommodation,
                  onChanged: (value) => widget.data.otherAccommodation = value,
                ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle Possession Before Disaster (Yes/No)',
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'Yes',
                          groupValue: selectedVehiclePossession,
                          onChanged: (value) {
                            setState(() {
                              selectedVehiclePossession = value;
                              widget.data.vehiclePossession = value!;
                            });
                          },
                        ),
                        Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: selectedVehiclePossession,
                          onChanged: (value) {
                            setState(() {
                              selectedVehiclePossession = value;
                              widget.data.vehiclePossession = value!;
                            });
                          },
                        ),
                        Text('No'),
                      ],
                    ),
                  ],
                ),
              ),

              if (widget.data.vehiclePossession == 'Yes')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Vehicle Type'),
                  initialValue: widget.data.vehicleType,
                  onChanged: (value) => widget.data.vehicleType = value,
                ),

              if (widget.data.vehicleType == 'Any other')
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Other Vehicle Details',
                  ),
                  initialValue: widget.data.otherVehicleType,
                  onChanged: (value) => widget.data.otherVehicleType = value,
                ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle Loss (Post-Disaster) (Yes/No)',
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'Yes',
                          groupValue: selectedVehicleLoss,
                          onChanged: (value) {
                            setState(() {
                              selectedVehicleLoss = value;
                              widget.data.vehicleLoss = value!;
                            });
                          },
                        ),
                        Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: selectedVehicleLoss,
                          onChanged: (value) {
                            setState(() {
                              selectedVehicleLoss = value;
                              widget.data.vehicleLoss = value!;
                            });
                          },
                        ),
                        Text('No'),
                      ],
                    ),
                  ],
                ),
              ),

              if (widget.data.vehicleLoss == 'Yes')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Vehicle Loss Type',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'e.g., Tow Wheeler, Three Wheeler, Other',
                        ),
                        initialValue: vehicleLossTypeDetails,
                        onChanged: (value) {
                          setState(() {
                            vehicleLossTypeDetails = value;
                            widget.data.vehicleLossType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              if (widget.data.vehicleLossType == 'Other')
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Other Vehicle Loss Details',
                  ),
                  initialValue: widget.data.otherVehicleLossType,
                  onChanged:
                      (value) => widget.data.otherVehicleLossType = value,
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenE(data: widget.data),
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
