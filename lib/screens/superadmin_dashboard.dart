import 'package:flutter/material.dart';
import 'package:resq/screens/login_screen.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:resq/services/apk_service.dart';

void main() {
  runApp(DisasterManagementApp());
}

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

  Disaster({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.dateOccurred,
    required this.description,
    required this.severity,
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

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.assignedDisasterIds,
    this.isActive = true,
  });
}

class SuperAdminDashboard extends StatefulWidget {
  @override
  _SuperAdminDashboardState createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  // Sample data for demonstration
  List<Disaster> disasters = [
    Disaster(
      id: '1',
      name: 'Hurricane Alex',
      type: 'Hurricane',
      location: 'Florida, USA',
      dateOccurred: DateTime(2025, 1, 15),
      description: 'Category 3 hurricane affecting coastal areas',
      severity: 'High',
      isActive: true,
    ),
    Disaster(
      id: '2',
      name: 'Earthquake Sumatra',
      type: 'Earthquake',
      location: 'Sumatra, Indonesia',
      dateOccurred: DateTime(2025, 2, 20),
      description: 'Magnitude 6.5 earthquake with multiple aftershocks',
      severity: 'Critical',
      isActive: false,
    ),
  ];

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

  @override
  void initState() {
    super.initState();
    _updateScreens();
  }

  void _updateScreens() {
    setState(() {
      _screens.clear();
      _screens.addAll([
        DisasterManagementScreen(
          disasters: disasters,
          onDeactivateDisaster: _deactivateDisaster,
          onCreateDisaster: _showAddDisasterDialog,
        ),
        AdminManagementScreen(
          admins: admins,
          disasters: disasters,
          onCreateAdmin: _showAddAdminDialog,
        ),
      ]);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _deactivateDisaster(String disasterId) {
    setState(() {
      final index = disasters.indexWhere((d) => d.id == disasterId);
      if (index != -1) {
        disasters[index].isActive = false;
        _updateScreens();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Disaster deactivated successfully')),
    );
  }

  void _showAddDisasterDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String type = '';
    String location = '';
    String description = '';
    String severity = 'Medium';

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Type'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter disaster type';
                      }
                      return null;
                    },
                    onSaved: (value) => type = value!,
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
                      ),
                    );
                    _updateScreens();
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Disaster created successfully')),
                  );
                }
              },
            ),
          ],
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
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber),
            label: 'Disasters',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Admins'),
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

  DisasterManagementScreen({
    required this.disasters,
    required this.onDeactivateDisaster,
    required this.onCreateDisaster,
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
                'Active Disasters (${disasters.where((d) => d.isActive).length})',
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
                            '${disaster.type} • ${disaster.location} • ${disaster.dateOccurred.toLocal().toString().split(' ')[0]}',
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

// Add after DisasterManagementScreen build method (around line 522)
class ApkUploadSection extends StatefulWidget {
  @override
  _ApkUploadSectionState createState() => _ApkUploadSectionState();
}

// Add after DisasterManagementScreen build method (around line 522)
class _ApkUploadSectionState extends State<ApkUploadSection> {
  final ApkService _apkService = ApkService();
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

        // Upload APK
        final downloadUrl = await _apkService.uploadApk(
          fileName,
          file.bytes!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('APK uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() => _selectedFileName = file.name);
      }
    } catch (e) {
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
              icon: Icon(_isUploading ? Icons.hourglass_empty : Icons.upload_file),
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


class DisasterDetailScreen extends StatelessWidget {
  final Disaster disaster;

  DisasterDetailScreen({required this.disaster});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(disaster.name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          disaster.isActive
                              ? Icons.warning_amber
                              : Icons.history,
                          color: disaster.isActive ? Colors.red : Colors.grey,
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            disaster.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
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
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            disaster.severity,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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
                    SizedBox(height: 16),
                    _detailRow(Icons.category, 'Type', disaster.type),
                    _detailRow(
                      Icons.location_on,
                      'Location',
                      disaster.location,
                    ),
                    _detailRow(
                      Icons.calendar_today,
                      'Date Occurred',
                      disaster.dateOccurred.toLocal().toString().split(' ')[0],
                    ),
                    _detailRow(
                      Icons.info,
                      'Status',
                      disaster.isActive ? 'Active' : 'Deactivated',
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(disaster.description, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Stats & Resources',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // This section would display statistics and resources related to the disaster
            // For demonstration, we'll add placeholder cards
            Card(
              child: ListTile(
                leading: Icon(Icons.people),
                title: Text('Affected Population'),
                subtitle: Text('12,500 people'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.local_hospital),
                title: Text('Medical Resources'),
                subtitle: Text('8 medical teams deployed'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.home),
                title: Text('Shelter Status'),
                subtitle: Text('15 shelters active, 2,300 people housed'),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Response Timeline',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Timeline of response actions
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _timelineItem(
                      'Initial Response',
                      '${disaster.dateOccurred.toLocal().toString().split(' ')[0]}',
                      'Emergency teams deployed to affected areas',
                    ),
                    _timelineItem(
                      'Assessment Complete',
                      '${disaster.dateOccurred.add(Duration(days: 1)).toLocal().toString().split(' ')[0]}',
                      'Damage and needs assessment completed',
                    ),
                    _timelineItem(
                      'Aid Distribution',
                      '${disaster.dateOccurred.add(Duration(days: 2)).toLocal().toString().split(' ')[0]}',
                      'Started distribution of food, water, and medical supplies',
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

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(String title, String date, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Spacer(),
            Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 8),
          child: Container(
            margin: EdgeInsets.only(left: 4),
            padding: EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(description),
            ),
          ),
        ),
      ],
    );
  }
}

class AdminManagementScreen extends StatelessWidget {
  final List<Admin> admins;
  final List<Disaster> disasters;
  final VoidCallback onCreateAdmin;

  AdminManagementScreen({
    required this.admins,
    required this.disasters,
    required this.onCreateAdmin,
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
                'Admin Users (${admins.length})',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.person_add),
                label: Text('Add Admin'),
                onPressed: onCreateAdmin,
              ),
            ],
          ),
        ),
        Expanded(
          child:
              admins.isEmpty
                  ? Center(child: Text('No admins added yet'))
                  : ListView.builder(
                    itemCount: admins.length,
                    itemBuilder: (context, index) {
                      final admin = admins[index];
                      final assignedDisasters =
                          disasters
                              .where(
                                (d) => admin.assignedDisasterIds.contains(d.id),
                              )
                              .toList();

                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red[100],
                            child: Text(
                              admin.name
                                  .split(' ')
                                  .map((s) => s[0])
                                  .take(2)
                                  .join('')
                                  .toUpperCase(),
                              style: TextStyle(color: Colors.red[900]),
                            ),
                          ),
                          title: Text(
                            admin.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${admin.role} • ${admin.email}'),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _adminDetailRow(
                                    Icons.email,
                                    'Email',
                                    admin.email,
                                  ),
                                  _adminDetailRow(
                                    Icons.phone,
                                    'Phone',
                                    admin.phone,
                                  ),
                                  _adminDetailRow(
                                    Icons.work,
                                    'Role',
                                    admin.role,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Assigned Disasters:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  if (assignedDisasters.isEmpty)
                                    Text('No disasters assigned')
                                  else
                                    ...assignedDisasters.map(
                                      (disaster) => Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              disaster.isActive
                                                  ? Icons.warning_amber
                                                  : Icons.history,
                                              color:
                                                  disaster.isActive
                                                      ? Colors.red
                                                      : Colors.grey,
                                              size: 16,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                disaster.name,
                                                style: TextStyle(
                                                  color:
                                                      disaster.isActive
                                                          ? null
                                                          : Colors.grey,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    disaster.isActive
                                                        ? (disaster.severity ==
                                                                'Critical'
                                                            ? Colors.red
                                                            : disaster
                                                                    .severity ==
                                                                'High'
                                                            ? Colors.orange
                                                            : disaster
                                                                    .severity ==
                                                                'Medium'
                                                            ? Colors.yellow
                                                            : Colors.green)
                                                        : Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                disaster.severity,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color:
                                                      disaster.severity ==
                                                                  'Medium' ||
                                                              disaster.severity ==
                                                                  'Low'
                                                          ? Colors.black
                                                          : Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      OutlinedButton.icon(
                                        icon: Icon(Icons.edit),
                                        label: Text('Edit'),
                                        onPressed: () {
                                          // Edit admin functionality
                                        },
                                      ),
                                      OutlinedButton.icon(
                                        icon: Icon(Icons.delete),
                                        label: Text('Deactivate'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        onPressed: () {
                                          // Deactivate admin functionality
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

  Widget _adminDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
