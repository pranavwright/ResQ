import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:resq/constants/india_states.dart';
import 'package:resq/screens/login_screen.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:resq/utils/http/token_http.dart';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class DisasterManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disaster Management',
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red[900],
          foregroundColor: Colors.white,
        ),
      ),
      home: SuperAdminDashboard(),
    );
  }
}

class Disaster {
  final String id;
  final String name;
  final String type;
  final String location;
  final DateTime dateOccurred;
  final String description;
  final String severity;
  bool isActive;
  final String state;
  final String district;

  Disaster({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.dateOccurred,
    required this.description,
    required this.severity,
    required this.state,
    required this.district,
    this.isActive = true,
  });
}

class Admin {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final List<String> assignedDisasterIds;
  final bool isActive;
  final List<String> assignedRoles;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.assignedDisasterIds,
    this.isActive = true,
    List<String>? assignedRoles,
  }) : this.assignedRoles = assignedRoles ?? const [];
}

class SuperAdminDashboard extends StatefulWidget {
  @override
  _SuperAdminDashboardState createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final List<String> _indianStates = IndianStates.state;
  final Map<String, List<String>> _districtByState =
      IndianStates.districtByState;

  List<Disaster> disasters = [];

  @override
  void initState() {
    super.initState();
    _fetchDisasters().then((_) {
      if (mounted) _updateScreens();
    });
  }

  Future<void> _fetchDisasters() async {
    final response = await TokenHttp().get('/disaster/getDisasters');
    if (response is List) {
      disasters =
          response.map((data) {
            final Map<String, dynamic> disasterData =
                data as Map<String, dynamic>;
            return Disaster(
              id: disasterData['_id']?.toString() ?? '',
              name: disasterData['name']?.toString() ?? '',
              type: disasterData['type']?.toString() ?? '',
              location: disasterData['location']?.toString() ?? '',
              dateOccurred:
                  disasterData['startDate'] != null
                      ? DateTime.parse(disasterData['startDate'].toString())
                      : DateTime.now(),
              description: disasterData['description']?.toString() ?? '',
              severity: disasterData['severity']?.toString() ?? 'Medium',
              state: disasterData['state']?.toString() ?? '',
              district: disasterData['district']?.toString() ?? '',
              isActive: disasterData['status']?.toString() == 'active',
            );
          }).toList();
    } else if (response is Map && response.containsKey('disasters')) {
      final disastersData = response['disasters'] as List;
      disasters =
          disastersData.map((data) {
            final Map<String, dynamic> disasterData =
                data as Map<String, dynamic>;
            return Disaster(
              id: disasterData['_id']?.toString() ?? '',
              name: disasterData['name']?.toString() ?? '',
              type: disasterData['type']?.toString() ?? '',
              location: disasterData['location']?.toString() ?? '',
              dateOccurred:
                  disasterData['startDate'] != null
                      ? DateTime.parse(disasterData['startDate'].toString())
                      : DateTime.now(),
              description: disasterData['description']?.toString() ?? '',
              severity: disasterData['severity']?.toString() ?? 'Medium',
              state: disasterData['state']?.toString() ?? '',
              district: disasterData['district']?.toString() ?? '',
              isActive: disasterData['status']?.toString() == 'active',
            );
          }).toList();
    } else {
      disasters = [];
    }
    setState(() {});
  }

  List<Admin> admins = [
    Admin(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+1 234 567 8901',
      role: 'Field Coordinator',
      assignedDisasterIds: ['1'],
      isActive: true,
    ),
    Admin(
      id: '2',
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      phone: '+1 987 654 3210',
      role: 'Resource Manager',
      assignedDisasterIds: ['1', '2'],
      isActive: true,
    ),
  ];

  int _selectedIndex = 0;

  final List<Widget> _screens = [];
  String state = '';
  String district = '';

  void _updateScreens() {
    setState(() {
      _screens.clear();
      _screens.addAll([
        DisasterManagementScreen(
          disasters: disasters,
          onDeactivateDisaster: _deactivateDisaster,
          onCreateDisaster: _showAddDisasterDialog,
          indianStates: _indianStates,
          districtByState: _districtByState,
        ),

        // Add the App Management Screen
        SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ApkUploadSection(),
            ],
          ),
        ),
      ]);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _deactivateDisaster(String disasterId) async {
    await TokenHttp().post('/disaster/postDisaster', {
      '_id': disasterId,
      'status': 'inactive',
    });
    setState(() {
      final index = disasters.indexWhere((d) => d.id == disasterId);
      if (index != -1) {
        disasters[index].isActive = false;
        _fetchDisasters().then((_) {
          if (mounted) _updateScreens();
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Disaster deactivated successfully')),
    );
  }

  void _showAddDisasterDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String type = 'LandSlide';
    String location = '';
    String description = '';
    String severity = 'Medium';
    String selectedState =
        _indianStates.first; // Initialize with a default value
    String selectedDistrict = _districtByState[selectedState]?.first ?? '';
    DateTime selectedDate = DateTime.now(); // Initialize with current date/time

    // Format the date for display
    TextEditingController dateController = TextEditingController(
      text:
          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year} ${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}",
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Create New Disaster'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Disaster Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter disaster name';
                          }
                          return null;
                        },
                        onSaved: (value) => name = value!,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Type'),
                        value: type,
                        items:
                            [
                                  'LandSlide',
                                  'Flood',
                                  'Hurrican',
                                  'Critical',
                                  'Earthquakes',
                                  'Virus Break Through',
                                  'Tsunami',
                                  'Drought',
                                ]
                                .map(
                                  (label) => DropdownMenuItem(
                                    value: label,
                                    child: Text(label),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          type = value!;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Location'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter location';
                          }
                          return null;
                        },
                        onSaved: (value) => location = value!,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                        onSaved: (value) => description = value!,
                      ),
                      // State Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'State'),
                        value: selectedState,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedState = newValue;
                              // Update districts based on the selected state.
                              selectedDistrict =
                                  _districtByState[selectedState]?.first ??
                                  ''; // Default to the first district or empty
                            });
                          }
                        },
                        items:
                            _indianStates.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please select state'
                                    : null,
                        onSaved: (value) => state = value!,
                      ),
                      // District Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'District'),
                        value: selectedDistrict,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedDistrict = newValue;
                            });
                          }
                        },
                        items:
                            _districtByState[selectedState]
                                ?.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                })
                                .toList() ??
                            [], // Provide an empty list if no districts for the state
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please select district'
                                    : null,
                        onSaved: (value) => district = value!,
                      ),
                      TextFormField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Date & Time',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          // Date picker
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2026),
                          );

                          if (pickedDate != null) {
                            // Time picker after date selection
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDate),
                            );

                            if (pickedTime != null) {
                              // Update the date and time
                              setState(() {
                                selectedDate = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );

                                // Update the text field
                                dateController.text =
                                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year} ${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
                              });
                            }
                          }
                        },
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Severity'),
                        value: severity,
                        items:
                            ['Low', 'Medium', 'High', 'Critical']
                                .map(
                                  (label) => DropdownMenuItem(
                                    value: label,
                                    child: Text(label),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          severity = value!;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Create'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      TokenHttp().post('/disaster/postDisaster', {
                        'name': name,
                        'type': type,
                        'location': location,
                        'description': description,
                        'startDate': selectedDate.toIso8601String(),
                        'status': 'active',
                        'state': selectedState,
                        'district': selectedDistrict,
                        'severity': severity,
                      });

                      setState(() {
                        disasters.add(
                          Disaster(
                            id: (disasters.length + 1).toString(),
                            name: name,
                            type: type,
                            location: location,
                            dateOccurred: DateTime.now(),
                            description: description,
                            severity: severity,
                            state: selectedState,
                            district: selectedDistrict,
                          ),
                        );
                        _updateScreens();
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Disaster created successfully'),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _logout() {
    AuthService().logout().then((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    });
  }

  void _showAddAdminDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String email = '';
    String phone = '';
    String role = 'Field Coordinator';
    List<String> selectedDisasterIds = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Admin'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Full Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter admin name';
                          }
                          return null;
                        },
                        onSaved: (value) => name = value!,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onSaved: (value) => email = value!,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Phone'),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                        onSaved: (value) => phone = value!,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Role'),
                        value: role,
                        items:
                            [
                                  'Field Coordinator',
                                  'Resource Manager',
                                  'Communications Officer',
                                  'Medical Coordinator',
                                ]
                                .map(
                                  (label) => DropdownMenuItem(
                                    value: label,
                                    child: Text(label),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            role = value!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Assign to Disasters:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...disasters
                          .where((d) => d.isActive)
                          .map(
                            (disaster) => CheckboxListTile(
                              title: Text(disaster.name),
                              subtitle: Text(disaster.type),
                              value: selectedDisasterIds.contains(disaster.id),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedDisasterIds.add(disaster.id);
                                  } else {
                                    selectedDisasterIds.remove(disaster.id);
                                  }
                                });
                              },
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Add Admin'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      if (selectedDisasterIds.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please assign at least one disaster',
                            ),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        admins.add(
                          Admin(
                            id: (admins.length + 1).toString(),
                            name: name,
                            email: email,
                            phone: phone,
                            role: role,
                            assignedDisasterIds: selectedDisasterIds,
                          ),
                        );
                      });

                      Navigator.of(context).pop();
                      _updateScreens();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Admin added successfully')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disaster Management SuperAdmin'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout();
            },
          ),
        ],
      ),
      body:
          _screens.isEmpty
              ? Center(child: CircularProgressIndicator())
              : _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber),
            label: 'Disasters',
          ),
          BottomNavigationBarItem(
            // Add this new item
            icon: Icon(Icons.app_settings_alt),
            label: 'App Management',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            _showAddDisasterDialog();
          } else {
            _showAddAdminDialog();
          }
        },
        child: Icon(Icons.add),
        tooltip: _selectedIndex == 0 ? 'Create Disaster' : 'Add Admin',
      ),
    );
  }
}

class DisasterManagementScreen extends StatelessWidget {
  final List<Disaster> disasters;
  final Function(String) onDeactivateDisaster;
  final VoidCallback onCreateDisaster;
  final List<String> indianStates;
  final Map<String, List<String>> districtByState;

  DisasterManagementScreen({
    required this.disasters,
    required this.onDeactivateDisaster,
    required this.onCreateDisaster,
    required this.indianStates,
    required this.districtByState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Disasters (${disasters?.where((d) => d.isActive).length ?? 0})',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Create Disaster'),
                    onPressed: onCreateDisaster,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child:
              disasters.isEmpty
                  ? Center(child: Text('No disasters created yet'))
                  : ListView.builder(
                    itemCount: disasters.length,
                    itemBuilder: (context, index) {
                      final disaster = disasters[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Icon(
                                disaster.isActive
                                    ? Icons.warning_amber
                                    : Icons.history,
                                color:
                                    disaster.isActive
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  disaster.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        disaster.isActive ? null : Colors.grey,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      disaster.isActive
                                          ? (disaster.severity == 'Critical'
                                              ? Colors.red
                                              : disaster.severity == 'High'
                                              ? Colors.orange
                                              : disaster.severity == 'Medium'
                                              ? Colors.yellow
                                              : Colors.green)
                                          : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  disaster.severity,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        disaster.severity == 'Medium' ||
                                                disaster.severity == 'Low'
                                            ? Colors.black
                                            : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${disaster.type} • ${disaster.state} • ${disaster.district} • ${disaster.dateOccurred.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              color: disaster.isActive ? null : Colors.grey,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(disaster.description),
                                  SizedBox(height: 16),
                                  Text(
                                    'State: ${disaster.state}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text('District: ${disaster.district}'),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      OutlinedButton.icon(
                                        icon: Icon(Icons.visibility),
                                        label: Text('View Details'),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      DisasterDetailScreen(
                                                        disaster: disaster,
                                                      ),
                                            ),
                                          );
                                        },
                                      ),
                                      if (disaster.isActive)
                                        ElevatedButton.icon(
                                          icon: Icon(Icons.block),
                                          label: Text('Deactivate'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    title: Text(
                                                      'Confirm Deactivation',
                                                    ),
                                                    content: Text(
                                                      'Are you sure you want to deactivate this disaster? '
                                                      'Once deactivated, its details will still be visible but cannot be modified.',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        child: Text('Cancel'),
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                      ),
                                                      ElevatedButton(
                                                        child: Text(
                                                          'Deactivate',
                                                        ),
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              foregroundColor:
                                                                  Colors.white,
                                                            ),
                                                        onPressed: () {
                                                          onDeactivateDisaster(
                                                            disaster.id,
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

class ApkUploadSection extends StatefulWidget {
  @override
  _ApkUploadSectionState createState() => _ApkUploadSectionState();
}

class _ApkUploadSectionState extends State<ApkUploadSection> {
  final TokenHttp _tokenHttp = TokenHttp();
  bool _isUploading = false;
  String? _selectedFileName;

  Future<void> _pickAndUploadApk() async {
    try {
      setState(() => _isUploading = true);

      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['apk'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = 'resq-v${DateTime.now().millisecondsSinceEpoch}.apk';

        // Create a temporary file from the bytes
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');

        if (file.bytes != null) {
          // Web platform returns bytes
          await tempFile.writeAsBytes(file.bytes!);
        } else if (file.path != null) {
          // Mobile platforms return a file path
          final originalFile = File(file.path!);
          await originalFile.copy(tempFile.path);
        } else {
          throw Exception("Couldn't access file data");
        }

        // Upload APK using TokenHttp
        final response = await _tokenHttp.uploadFile(
          endpoint: '/settings/uploadApk',
          file: tempFile,
          fieldName: 'apkFile',
          fileName: fileName,
          additionalFields: {
            'version': DateTime.now().millisecondsSinceEpoch.toString(),
            'appName': 'ResQ',
          },
        );

        // Clean up the temp file
        if (await tempFile.exists()) {
          await tempFile.delete();
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('APK uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() => _selectedFileName = file.name);
      }
    } catch (e) {
      print('Error uploading APK: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading APK: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Version Management',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_selectedFileName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Selected file: $_selectedFileName',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUploadApk,
              icon: Icon(
                _isUploading ? Icons.hourglass_empty : Icons.upload_file,
              ),
              label: Text(_isUploading ? 'Uploading...' : 'Upload New APK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DisasterDetailScreen extends StatefulWidget {
  final Disaster disaster;

  DisasterDetailScreen({required this.disaster});

  @override
  _DisasterDetailScreenState createState() => _DisasterDetailScreenState();
}

class _DisasterDetailScreenState extends State<DisasterDetailScreen> {
  List<Admin> admins = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    setState(() => isLoading = true);
    try {
      final response = await TokenHttp().get(
        '/auth/getAdmins?disasterId=${widget.disaster.id}',
      );

      if (response is List) {
        admins =
            response.map((data) {
              final Map<String, dynamic> adminData =
                  data as Map<String, dynamic>;
              return Admin(
                id: adminData['_id']?.toString() ?? '',
                name: adminData['name']?.toString() ?? '',
                email: adminData['email']?.toString() ?? '',
                phone: adminData['phoneNumber']?.toString() ?? '',
                role: adminData['role']?.toString() ?? '',
                assignedDisasterIds:
                    adminData['assignedDisasterIds'] != null
                        ? List<String>.from(adminData['assignedDisasterIds'])
                        : [],
                isActive: adminData['status']?.toString() == 'active',
                assignedRoles:
                    adminData['assignedRoles'] != null
                        ? List<String>.from(adminData['assignedRoles'])
                        : [],
              );
            }).toList();
      } else {
        admins = [];
      }
    } catch (e) {
      print("Error fetching admins: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load admins: $e')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _addAdminToDisaster(
    String name,
    String phoneNumber,
    String role,
  ) async {
    setState(() => isLoading = true);
    try {
      final response = await TokenHttp().post('/auth/register', {
        'name': name,
        'phoneNumber': phoneNumber,
        'role': role == "Collector" ? "admin" : "stat",
        'disasterId': widget.disaster.id,
      });
      _fetchAdmins();
    } catch (e) {
      print("Error fetching admins: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load admins: $e')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> deleteAdmins(String id, String role) async {
    setState(() => isLoading = true);
    try {
      await TokenHttp().post('/auth/revokeAdmin', {
        '_id': id,
        'disasterId': widget.disaster.id,
        'role': role,
      });
      _fetchAdmins();
    } catch (e) {
      print("Error fetching admins: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load admins: $e')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showAddAdminDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String phone = '';
    String role = 'Collector';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Admin to Disaster'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Full Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter admin name';
                      }
                      return null;
                    },
                    onSaved: (value) => name = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                    onSaved: (value) => phone = value!,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Role'),
                    value: role,
                    items:
                        ['Collector', 'Statistics Dept']
                            .map(
                              (label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      role = value!;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add Admin'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();

                  _addAdminToDisaster(name, phone, role);
                  Navigator.of(context).pop();
                  _fetchAdmins(); // Refresh the admin list
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _openGoogleMaps() async {
    final location = widget.disaster.location.split(',');
    if (location.length == 2) {
      final latitude = location[0].trim();
      final longitude = location[1].trim();
      final url =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open Google Maps.')));
      }
    } else {
      if (await canLaunchUrl(Uri.parse(widget.disaster.location))) {
        await launchUrl(Uri.parse(widget.disaster.location));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open Google Maps.')));
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid location format.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Disaster Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.disaster.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Type: ${widget.disaster.type}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _openGoogleMaps,
                child: Text('Open Google Maps'),
              ),
              SizedBox(height: 8),
              Text(
                'State: ${widget.disaster.state}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'District: ${widget.disaster.district}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Date: ${widget.disaster.dateOccurred.toLocal().toString()}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Severity: ${widget.disaster.severity}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      widget.disaster.severity == 'Critical'
                          ? Colors.red
                          : widget.disaster.severity == 'High'
                          ? Colors.orange
                          : widget.disaster.severity == 'Medium'
                          ? Colors.yellow
                          : Colors.green,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Description:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(widget.disaster.description, style: TextStyle(fontSize: 16)),
              SizedBox(height: 24),

              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Assigned Admins (${admins.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.person_add),
                            label: Text('Add Admin'),
                            onPressed: () {
                              _showAddAdminDialog();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (admins.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text('No admins assigned to this disaster'),
                          ),
                        )
                      else
                        ...admins
                            .map(
                              (admin) => Card(
                                margin: EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(
                                    admin.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Wrap(
                                    spacing: 8.0,
                                    children:
                                        admin.assignedRoles
                                            .map(
                                              (role) => Chip(
                                                label: Text(
                                                  role == "admin"
                                                      ? "Collector"
                                                      : role == "stat"
                                                      ? " Statistics Dept"
                                                      : role,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                  leading: CircleAvatar(
                                    child: Icon(Icons.person),
                                    backgroundColor: Colors.blue.shade100,
                                  ),
                                  trailing: SizedBox(
                                    height: 50,
                                    child:
                                        admin.assignedRoles.isEmpty
                                            ? Text(
                                              "No roles",
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            )
                                            : SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children:
                                                    admin.assignedRoles.map((
                                                      role,
                                                    ) {
                                                      String roleName =
                                                          role == "admin"
                                                              ? "Collector"
                                                              : role == "stat"
                                                              ? " Statistics Dept"
                                                              : role;
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              left: 8.0,
                                                            ),
                                                        child: ElevatedButton.icon(
                                                          icon: Icon(
                                                            Icons.delete,
                                                            size: 16,
                                                          ),
                                                          label: Text(
                                                            'Revoke $roleName',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.red[400],
                                                            foregroundColor:
                                                                Colors.white,
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 0,
                                                                ),
                                                            minimumSize: Size(
                                                              80,
                                                              36,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            deleteAdmins(
                                                              admin.id,
                                                              role,
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    }).toList(),
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
