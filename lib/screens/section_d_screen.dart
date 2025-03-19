import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/section_e_screen.dart';

class ScreenD extends StatefulWidget {
  final NeedAssessmentData data;

  ScreenD({required this.data});

  @override
  _ScreenDState createState() => _ScreenDState();
}

class _ScreenDState extends State<ScreenD> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section D: Shelter and Accommodation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Shelter Type'),
                initialValue: widget.data.shelterType,
                onChanged: (value) => widget.data.shelterType = value,
              ),
              if (widget.data.shelterType == 'Others')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Other Shelter Type'),
                  initialValue: widget.data.otherShelterType,
                  onChanged: (value) => widget.data.otherShelterType = value,
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Residential Land Area'),
                initialValue: widget.data.residentialLandArea,
                onChanged: (value) => widget.data.residentialLandArea = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Accommodation Status (Post-Disaster)'),
                initialValue: widget.data.accommodationStatus,
                onChanged: (value) => widget.data.accommodationStatus = value,
              ),
              if (widget.data.accommodationStatus == 'Others')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Other Accommodation Details'),
                  initialValue: widget.data.otherAccommodation,
                  onChanged: (value) => widget.data.otherAccommodation = value,
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Vehicle Possession Before Disaster (Yes/No)'),
                initialValue: widget.data.vehiclePossession,
                onChanged: (value) => widget.data.vehiclePossession = value,
              ),
              if (widget.data.vehiclePossession == 'Yes')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Vehicle Type'),
                  initialValue: widget.data.vehicleType,
                  onChanged: (value) => widget.data.vehicleType = value,
                ),
              if (widget.data.vehicleType == 'Any other')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Other Vehicle Details'),
                  initialValue: widget.data.otherVehicleType,
                  onChanged: (value) => widget.data.otherVehicleType = value,
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Vehicle Loss (Post-Disaster) (Yes/No)'),
                initialValue: widget.data.vehicleLoss,
                onChanged: (value) => widget.data.vehicleLoss = value,
              ),
              if (widget.data.vehicleLoss == 'Yes')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Vehicle Loss Type'),
                  initialValue: widget.data.vehicleLossType,
                  onChanged: (value) => widget.data.vehicleLossType = value,
                ),
              if (widget.data.vehicleLossType == 'Any other')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Other Vehicle Loss Details'),
                  initialValue: widget.data.otherVehicleLossType,
                  onChanged: (value) => widget.data.otherVehicleLossType = value,
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