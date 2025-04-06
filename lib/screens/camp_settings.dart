import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:resq/constants/api_constants.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';
import 'package:resq/widgets/locationwidget.dart' show LocationSelectionWidget;

class CampSettingsScreen extends StatefulWidget {
  @override
  _CampSettingsScreenState createState() => _CampSettingsScreenState();
}

class _CampSettingsScreenState extends State<CampSettingsScreen> {
  final List<Family> _families = [];
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  LatLng? _campLocation;
  String _currentAddress = 'No location selected';
  bool _isLoadingAddress = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _getCampSettings();
  }

  @override
  void dispose() {
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _getCampSettings() async {
    try {
      setState(() => _isLoadingAddress = true);

      final response = await TokenHttp().get(
        '/settings/getPoints?disasterId=${AuthService().getDisasterId()}&type=camp',
      );

      if (response['success']) {
        final settings = response['settings'];
        final locationLink = settings['locationString'] ?? "";

        setState(() {
          // Parse location
          if (locationLink.isNotEmpty) {
            try {
              final coords = locationLink.split(',');
              if (coords.length == 2) {
                _campLocation = LatLng(
                  double.parse(coords[0]),
                  double.parse(coords[1]),
                );
              }
            } catch (e) {
              debugPrint('Error parsing location: $e');
            }
          }

          // Update controllers
          _contactController.text = settings['contact'] ?? "";
          _emailController.text = settings['email'] ?? "";
        });

        // Fetch address if we have a location
        if (_campLocation != null) {
          await _fetchAddressFromLocation(_campLocation!);
        }
      } else {
        _showSnackBar('Could not get camp settings');
      }
    } catch (e) {
      _showSnackBar('Error loading camp settings: ${e.toString()}');
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _updateCampSettings() async {
    if (_isSaving) return;

    try {
      setState(() => _isSaving = true);

      String locationString = "";
      String googleMapsLink = "";
      if (_campLocation != null) {
        locationString = "${_campLocation!.latitude},${_campLocation!.longitude}";
        googleMapsLink = "https://www.google.com/maps?q=$locationString";
      }

      final response = await TokenHttp().post('/settings/updatePoints', {
        'disasterId': AuthService().getDisasterId(),
        'type': "camp",
        'location': googleMapsLink,
        'locationString': locationString,
        'contact': _contactController.text,
        'email': _emailController.text,
      });

      if (response['success']) {
        _showSnackBar('Camp settings updated successfully', isError: false);
        await _getCampSettings();
      } else {
        _showSnackBar(response['message'] ?? 'Failed to update camp settings');
      }
    } catch (e) {
      _showSnackBar('Error updating camp settings: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLoadingAddress = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _campLocation = LatLng(position.latitude, position.longitude);
      });

      if (_campLocation != null) {
        await _fetchAddressFromLocation(_campLocation!);
        await _updateCampSettings();
      }
    } catch (e) {
      _showSnackBar('Could not get current location');
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _fetchAddressFromLocation(LatLng location) async {
    setState(() => _isLoadingAddress = true);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentAddress = '${place.street}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      setState(() => _currentAddress = 'Address could not be determined');
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  Widget _buildStaticMapImage() {
    if (_campLocation == null) return Container();

    final lat = _campLocation!.latitude;
    final lng = _campLocation!.longitude;
    final staticMapUrl =
        'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=14&size=400x300&markers=color:red%7C$lat,$lng&key=${ApiConstants.GOOGLE_MAPS_API_KEY}';

    return Image.network(
      staticMapUrl,
      width: double.infinity,
      height: 150,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 40, color: Colors.grey.shade400),
            Text(
              'Map not available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        return loadingProgress == null
            ? child
            : const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<void> _updateCampLocation() async {
    final newLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectionWidget(
          initialLocation: _campLocation ?? const LatLng(0, 0),
          onLocationSelected: (LatLng location) {},
        ),
      ),
    );

    if (newLocation != null) {
      setState(() => _campLocation = newLocation);
      await _fetchAddressFromLocation(newLocation);
      await _updateCampSettings();
    }
  }

  void _showSnackBar(String message, {bool isError = true, int duration = 2}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: duration),
      ),
    );
  }

  int get _totalMembers {
    return _families.fold(
        0, (sum, family) => sum + (family.data?.members.length ?? 0));
  }

  int get _totalFamilies {
    return _families.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camp Settings'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationCard(),
            const SizedBox(height: 16),
            _buildCampInfoCard(),
            const SizedBox(height: 16),
            _buildFamiliesCard(),
          ],
        ),
      ),
    );
  }

  Card _buildLocationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _updateCampLocation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red.shade600, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.my_location, color: Colors.blue.shade600),
                    onPressed: _fetchCurrentLocation,
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade600),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _campLocation == null
                    ? Center(
                        child: Text(
                          'Set a location',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : _buildStaticMapImage(),
              ),
              if (_campLocation != null) ...[
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.pin_drop,
                        size: 16,
                        color: Colors.red.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Lat: ${_campLocation!.latitude.toStringAsFixed(6)}, Long: ${_campLocation!.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              if (_isLoadingAddress)
                const Center(child: CircularProgressIndicator())
              else
                Text(
                  _currentAddress,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Card _buildCampInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Camp Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Total Families', _totalFamilies.toString()),
            _buildInfoRow('Total Members', _totalMembers.toString()),
            const SizedBox(height: 16),
            const Text(
              'Contact Number',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Enter camp contact number',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Email Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Enter camp email address',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        if (_contactController.text.isNotEmpty &&
                            _emailController.text.isNotEmpty) {
                          _updateCampSettings();
                        } else {
                          _showSnackBar('Please fill all fields');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Camp Information'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _buildFamiliesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Family Members (${_totalFamilies} families)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_families.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'No families registered yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _families.length,
                itemBuilder: (context, index) {
                  final family = _families[index];
                  return ExpansionTile(
                    title: Text(
                      'Family ${family.id} - ${family.data?.householdHead ?? 'N/A'}',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildFamilyDetailRow(
                              'Address',
                              family.data?.address ?? 'N/A',
                            ),
                            _buildFamilyDetailRow(
                              'Contact',
                              family.data?.contactNo ?? 'N/A',
                            ),
                            _buildFamilyDetailRow(
                              'Members',
                              family.data?.members.length.toString() ?? '0',
                            ),
                            const SizedBox(height: 8),
                            ...(family.data?.members ?? []).map(
                              (member) => ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(member.name),
                                subtitle: Text(
                                  '${member.age} yrs, ${member.gender}',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildFamilyDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}