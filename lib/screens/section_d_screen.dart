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
  String? vehicleLossTypeDetails;
    String? selectedShelterType;
 

  final List<String> _shelterTypeOptions = [
    'Permanent House',
    'House Built with Govt Assistance',
    'Rented',
    'Paadi (Layam)',
    'Others',
  ];


  @override
  void initState() {
    super.initState();
   selectedShelterType = widget.data.shelterType;
    selectedVehiclePossession = widget.data.vehiclePossession;
    selectedVehicleLoss = widget.data.vehicleLoss;
   selectedVehiclePossession = widget.data.vehiclePossession;
    selectedVehicleLoss = widget.data.vehicleLoss;
 if (selectedShelterType == '') {
      selectedShelterType = 'Permanent House';
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
