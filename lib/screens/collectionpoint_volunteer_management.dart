import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';
import 'package:resq/widgets/locationwidget.dart' show LocationSelectionWidget;

class CollectionPointManagementScreen extends StatefulWidget {
  final String collectionPointId;

  const CollectionPointManagementScreen({
    super.key,
    required this.collectionPointId,
  });

  @override
  _CollectionPointManagementScreenState createState() =>
      _CollectionPointManagementScreenState();
}

class Volunteer {
  final String id;
  final String name;
  final String email;
  final String phone;
  bool isActive;
  final List<Duty> duties;

  Volunteer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.duties,
  });
}

class Duty {
  final String type;
  final DateTime date;

  Duty({required this.type, required this.date});
}

class _CollectionPointManagementScreenState
    extends State<CollectionPointManagementScreen> {
  // Current settings
  String phoneNumber = "";
  String email = "";
  String pointName = "";
  LatLng? _currentLocation;
  String _currentAddress = 'No location selected';
  bool _isLoadingAddress = false;
  bool _isSaving = false;

  // Editing controllers
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  // Volunteers list
  List<Volunteer> volunteers = [];

  @override
  void initState() {
    super.initState();
    _getsettings();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    phoneController.dispose();
    emailController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> _getsettings() async {
    try {
      setState(() {
        _isLoadingAddress = true;
      });

      final response = await TokenHttp().get(
        '/settings/getPoints?disasterId=${AuthService().getDisasterId()}&type=collectionPoint',
      );

      if (response['success']) {
        final settings = response['settings'];
        String locationLink = settings['locationString'] ?? "";

        setState(() {
          // Parse location
          if (locationLink.isNotEmpty) {
            try {
              final coords = locationLink.split(',');
              if (coords.length == 2) {
                _currentLocation = LatLng(
                  double.parse(coords[0]),
                  double.parse(coords[1]),
                );
              }
            } catch (e) {
              print('Error parsing location: $e');
            }
          }

          // Other settings
          phoneNumber = settings['contact'] ?? "";
          email = settings['email'] ?? "";
          pointName = settings['name'] ?? "Unnamed Collection Point";
          _currentAddress = pointName;

          // Update controllers
          phoneController.text = phoneNumber;
          emailController.text = email;
          nameController.text = pointName;

          // Volunteers
          volunteers =
              (settings['volunteer'] ?? [])
                  .map<Volunteer>(
                    (e) => Volunteer(
                      id: e['id'] ?? "",
                      name: e['name'] ?? "",
                      email: e['email'] ?? "",
                      phone: e['phoneNumber'] ?? "",
                      isActive: e['isActive'] ?? false,
                      duties: [],
                    ),
                  )
                  .toList();
        });

        // Fetch address if we have a location
        if (_currentLocation != null) {
          await _fetchAddressFromLocation(_currentLocation!);
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not get settings')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading settings: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _updateAllSettings() async {
    if (_isSaving) return;

    try {
      setState(() {
        _isSaving = true;
      });

      String locationString = "";
      String googleMapsLink = "";
      if (_currentLocation != null) {
        locationString =
            "${_currentLocation!.latitude},${_currentLocation!.longitude}";
        googleMapsLink = "https://www.google.com/maps?q=${locationString}";
      }

      final response = await TokenHttp().post('/settings/updatePoints', {
        'disasterId': AuthService().getDisasterId(),
        'pointId': AuthService().assignPlace,
        'location': googleMapsLink,
        'locationString': locationString,
        'contact': phoneController.text,
        'email': emailController.text,
        'name': nameController.text,
        'type': "collectionPoint",
      });

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings updated successfully')),
        );
        // Refresh settings after update
        await _getsettings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update: ${response['message'] ?? 'Unknown error'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating settings: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied'),
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      if (_currentLocation != null) {
        await _fetchAddressFromLocation(_currentLocation!);
        await _updateAllSettings(); // Auto-save new location
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get current location')),
      );
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _fetchAddressFromLocation(LatLng location) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _currentAddress =
              '${place.street}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Address could not be determined';
      });
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  void _toggleVolunteerStatus(int index) {
    setState(() {
      volunteers[index].isActive = !volunteers[index].isActive;
    });
  }

  void _showVolunteerDuties(Volunteer volunteer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            volunteer.isActive
                                ? Colors.purple.shade100
                                : Colors.grey.shade300,
                        child: Icon(
                          Icons.person,
                          color:
                              volunteer.isActive
                                  ? Colors.purple.shade600
                                  : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            volunteer.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            volunteer.email,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          Text(
                            volunteer.phone,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Duties Completed (${volunteer.duties.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child:
                        volunteer.duties.isEmpty
                            ? Center(
                              child: Text(
                                'No duties recorded yet',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            )
                            : ListView.separated(
                              controller: scrollController,
                              itemCount: volunteer.duties.length,
                              separatorBuilder:
                                  (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final duty = volunteer.duties[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                  title: Text(
                                    duty.type,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${duty.date.day}/${duty.date.month}/${duty.date.year}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddVolunteerForm() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String name = '';
    String email = '';
    String phone = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Add New Volunteer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter volunteer name';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value ?? '',
                ),

                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                  onSaved: (value) => phone = value ?? '',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            setState(() {
                              _isLoadingAddress = true;
                            });
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              await TokenHttp().post('/auth/addVolunteer', {
                                'disasterId': AuthService().getDisasterId(),
                                'pointId': widget.collectionPointId,
                                'name': name,
                                'phoneNumber': phone,
                                'email': email,
                              });

                              _getsettings();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$name added as volunteer'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              _isLoadingAddress = false;
                            });
                          } finally {
                            setState(() {
                              _isLoadingAddress = false;
                            });
                            dispose();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Add Volunteer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Point Management'),
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
            // Location Section
            _buildLocationCard(),
            const SizedBox(height: 16),
            // Contact Information Section
            _buildContactCard(),
            const SizedBox(height: 16),
            // Volunteers Section
            _buildVolunteersCard(),
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
        onTap: () async {
          final newLocation = await Navigator.push<LatLng>(
            context,
            MaterialPageRoute(
              builder:
                  (context) => LocationSelectionWidget(
                    initialLocation: _currentLocation ?? const LatLng(0, 0),
                    onLocationSelected: (LatLng location) {},
                  ),
            ),
          );

          if (newLocation != null) {
            setState(() {
              _currentLocation = newLocation;
            });
            await _fetchAddressFromLocation(newLocation);
            await _updateAllSettings(); // Auto-save when location changes
          }
        },
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation ?? const LatLng(0, 0),
                      zoom: 14,
                    ),
                    liteModeEnabled: true,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    myLocationButtonEnabled: false,
                    markers:
                        _currentLocation != null
                            ? {
                              Marker(
                                markerId: const MarkerId(
                                  'collection_point_marker',
                                ),
                                position: _currentLocation!,
                                infoWindow: const InfoWindow(
                                  title: 'Collection Point',
                                ),
                              ),
                            }
                            : {},
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoadingAddress)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _currentAddress,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Card _buildContactCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Point Name Field
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Collection Point Name',
                prefixIcon: const Icon(Icons.place),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Field
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email address';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isSaving
                        ? null
                        : () {
                          if (nameController.text.isNotEmpty &&
                              phoneController.text.isNotEmpty &&
                              emailController.text.isNotEmpty) {
                            _updateAllSettings();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields'),
                              ),
                            );
                          }
                        },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save All Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _buildVolunteersCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Colors.purple.shade600, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Volunteers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.purple.shade600),
                  onPressed: _showAddVolunteerForm,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (volunteers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'No volunteers assigned yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: volunteers.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final volunteer = volunteers[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor:
                          volunteer.isActive
                              ? Colors.purple.shade100
                              : Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        color:
                            volunteer.isActive
                                ? Colors.purple.shade600
                                : Colors.grey.shade600,
                      ),
                    ),
                    title: Text(
                      volunteer.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color:
                            volunteer.isActive
                                ? Colors.black
                                : Colors.grey.shade600,
                      ),
                    ),
                    subtitle: Text(
                      volunteer.email,
                      style: TextStyle(
                        color:
                            volunteer.isActive
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            volunteer.isActive
                                ? Icons.toggle_on
                                : Icons.toggle_off,
                            color:
                                volunteer.isActive
                                    ? Colors.green.shade600
                                    : Colors.grey.shade400,
                            size: 30,
                          ),
                          onPressed: () {
                            _toggleVolunteerStatus(index);
                          },
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      _showVolunteerDuties(volunteer);
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
