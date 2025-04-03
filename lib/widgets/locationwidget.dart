import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show CameraPosition, GoogleMap, LatLng;
import 'package:resq/constants/api_constants.dart';
import 'package:universal_html/html.dart' as html if (dart.library.io) 'package:flutter/foundation.dart';

class LocationSelectionWidget extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationSelected;

  const LocationSelectionWidget({
    Key? key,
    required this.initialLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<LocationSelectionWidget> createState() => _LocationSelectionWidgetState();
}

class _LocationSelectionWidgetState extends State<LocationSelectionWidget> {
  late LatLng _selectedLocation;
  String _address = 'Loading address...';
  bool _isLoading = false;
  bool _isWebMapInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _getAddressFromLatLng(_selectedLocation);
    if (kIsWeb) _initializeWebMap();
  }

  Future<void> _initializeWebMap() async {
    // For web, we need to inject the Google Maps JavaScript API
    final apiKey = ApiConstants.GOOGLE_MAPS_API_KEY;
    if (apiKey.isNotEmpty) {
      final script = html.ScriptElement()
        ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey'
        ..async = true
        ..defer = true;
      html.document.body!.append(script);
      setState(() => _isWebMapInitialized = true);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _address = [
            if (place.street != null) place.street,
            if (place.locality != null) place.locality,
            if (place.country != null) place.country,
          ].where((part) => part != null).join(', ');
        });
      } else {
        setState(() => _address = 'Address not found');
      }
    } catch (e) {
      setState(() => _address = 'Failed to get address: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildMobileMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialLocation,
        zoom: 15,
      ),
      onCameraMove: (position) {
        _selectedLocation = position.target;
      },
      onCameraIdle: () {
        _getAddressFromLatLng(_selectedLocation);
      },
    );
  }

  Widget _buildWebMap() {
    if (!_isWebMapInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // For web, you would typically use google_maps_flutter_web
    // This is a placeholder - you'll need to implement the actual web map
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Web Map Implementation'),
          Text('Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}'),
          Text('Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}'),
          ElevatedButton(
            onPressed: () {
              // Simulate location change for web
              setState(() {
                _selectedLocation = LatLng(
                  _selectedLocation.latitude + 0.001,
                  _selectedLocation.longitude + 0.001,
                );
                _getAddressFromLatLng(_selectedLocation);
              });
            },
            child: const Text('Simulate Move'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onLocationSelected(_selectedLocation);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                kIsWeb ? _buildWebMap() : _buildMobileMap(),
                // Centered marker pin
                const IgnorePointer(
                  child: Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Selected Location',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Text(
                        _address,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    widget.onLocationSelected(_selectedLocation);
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm Location'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}