import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resq/models/NeedAssessmentData.dart';


class CampSettingsScreen extends StatefulWidget {
  @override
  _CampSettingsScreenState createState() => _CampSettingsScreenState();
}

class _CampSettingsScreenState extends State<CampSettingsScreen> {
  final List<Family> _families =[];
  String _campContactNumber = '9876543210';
  String _campEmail = 'camp@example.com'; // New email field
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // New controller
  LatLng? _campLocation;

  @override
  void initState() {
    super.initState();
    _contactController.text = _campContactNumber;
    _emailController.text = _campEmail; // Initialize email controller
  }

  @override
  void dispose() {
    _contactController.dispose();
    _emailController.dispose(); // Dispose email controller
    super.dispose();
  }

  Future<void> _updateCampLocation() async {
    final location = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GoogleMapScreen()),
    );

    if (location != null) {
      setState(() {
        _campLocation = location;
      });
    }
  }



  void _updateContactInfo() {
    setState(() {
      _campContactNumber = _contactController.text;
      _campEmail = _emailController.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contact information updated successfully!')),
    );
  }

  int get _totalMembers {
    return _families.fold(0, (sum, family) => sum + (family.data?.members.length ?? 0));
  }

  int get _totalFamilies {
    return _families.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camp Settings')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Camp Location Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Camp Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (_campLocation != null)
                      Text(
                        'Lat: ${_campLocation!.latitude.toStringAsFixed(4)}, '
                        'Lng: ${_campLocation!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _updateCampLocation,
                      icon: Icon(Icons.map),
                      label: Text('Set Camp Location'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Camp Information Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Camp Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow('Total Families', _totalFamilies.toString()),
                    _buildInfoRow('Total Members', _totalMembers.toString()),
                    SizedBox(height: 16),
                    
                    // Contact Number Field
                    Text(
                      'Contact Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter camp contact number',
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Email Field
                    Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter camp email address',
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Update Button
                    ElevatedButton(
                      onPressed: _updateContactInfo,
                      child: Text('Update Contact Information'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Family Members Section (remains the same)
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Family Members (${_totalFamilies} families)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _families.length,
                      itemBuilder: (context, index) {
                        final family = _families[index];
                        return ExpansionTile(
                          title: Text(
                            'Family ${family.id} - ${family.data?.householdHead ?? 'N/A'}',
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
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
                                  SizedBox(height: 8),
                                  ...(family.data?.members ?? []).map(
                                    (member) => ListTile(
                                      leading: Icon(Icons.person),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildFamilyDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// GoogleMapScreen remains the same

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController mapController;
  LatLng _selectedLocation = LatLng(0, 0);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _saveLocation() {
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Location")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedLocation,
          zoom: 12,
        ),
        onMapCreated: _onMapCreated,
        onTap: _onTap,
        markers: {
          Marker(
            markerId: MarkerId('selectedLocation'),
            position: _selectedLocation,
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveLocation,
        child: Icon(Icons.check),
      ),
    );
  }
}
