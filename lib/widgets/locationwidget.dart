import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? _locationMessage = "Fetching location...";
  String? _googleMapsLink; // To store the generated Google Maps link

  // Function to get the current location
  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // If services are disabled, ask the user to enable them
      _showLocationServicesDialog();
      return;
    }

    // Check if permission to access location is granted
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          _locationMessage = "Location permissions are denied.";
        });
        return;
      }
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Construct the Google Maps URL link
    _googleMapsLink = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';

    setState(() {
      _locationMessage = "Latitude: ${position.latitude}\nLongitude: ${position.longitude}";
    });

    // Optionally, you can open the link directly in Google Maps
    if (await canLaunch(_googleMapsLink!)) {
      await launch(_googleMapsLink!);
    } else {
      throw 'Could not launch $_googleMapsLink';
    }
  }

  // Show a dialog asking the user to enable location services
  void _showLocationServicesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
              'Please enable location services to continue using this feature.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Open device settings to enable location services
                await Geolocator.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Finder'),
        backgroundColor: Colors.green.shade300,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _locationMessage ?? "Fetching location...",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getLocation,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green.shade400),
                ),
                child: const Text('Get Current Location'),
              ),
              const SizedBox(height: 20),
              // Display the clickable Google Maps link
              if (_googleMapsLink != null)
                GestureDetector(
                  onTap: () async {
                    if (await canLaunch(_googleMapsLink!)) {
                      await launch(_googleMapsLink!);
                    } else {
                      throw 'Could not launch $_googleMapsLink';
                    }
                  },
                  child: Text(
                    'Open in Google Maps',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
