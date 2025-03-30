import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'dart:async';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng _selectedLocation = LatLng(20.5937, 78.9629); // Default to India
  bool _isApiLoaded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkApiStatus();
  }

  Future<void> _checkApiStatus() async {
    try {
      // Set API as loaded since the platform will handle availability
      setState(() {
        _isApiLoaded = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load Google Maps: ${e.toString()}';
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _saveLocation() {
    if (!_isApiLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Maps not initialized')));
      return;
    }
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Location')),
      body: _error != null
          ? Center(child: Text(_error!))
          : _isApiLoaded
              ? GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 12,
                  ),
                  onMapCreated: _onMapCreated,
                  onTap: _onMapTap,
                  markers: {
                    Marker(
                      markerId: MarkerId('selectedLocation'),
                      position: _selectedLocation,
                    ),
                  },
                  myLocationEnabled: true,
                )
              : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveLocation,
        child: Icon(Icons.check),
      ),
    );
  }
}