import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collection Point Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CollectionPointManagementScreen(collectionPointId: '1'),
    );
  }
}

class CollectionPointManagementScreen extends StatefulWidget {
  final String collectionPointId;

  const CollectionPointManagementScreen({super.key, required this.collectionPointId});

  @override
  _CollectionPointManagementScreenState createState() => _CollectionPointManagementScreenState();
}

class _CollectionPointManagementScreenState extends State<CollectionPointManagementScreen> {
  String phoneNumber = "+1 (555) 123-4567";
  bool isEditingPhone = false;
  TextEditingController phoneController = TextEditingController();

  List<Volunteer> volunteers = [
    Volunteer(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+1 (555) 111-2222',
      isActive: true,
      duties: [
        Duty(type: 'Food Sorting', date: DateTime(2023, 5, 10)),
        Duty(type: 'Distribution', date: DateTime(2023, 5, 15)),
      ],
    ),
    Volunteer(
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      phone: '+1 (555) 222-3333',
      isActive: true,
      duties: [
        Duty(type: 'Inventory', date: DateTime(2023, 5, 12)),
      ],
    ),
    Volunteer(
      id: '3',
      name: 'Robert Johnson',
      email: 'robert@example.com',
      phone: '+1 (555) 333-4444',
      isActive: false,
      duties: [
        Duty(type: 'Food Sorting', date: DateTime(2023, 4, 28)),
        Duty(type: 'Distribution', date: DateTime(2023, 4, 30)),
        Duty(type: 'Inventory', date: DateTime(2023, 5, 5)),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    phoneController.text = phoneNumber;
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoogleMapScreen(
                initialLocation: const LatLng(37.42796133580664, -122.085749655962),
              ),
            ),
          );
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
                  Icon(Icons.chevron_right, color: Colors.grey.shade600),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '123 Charity St, Helping Town, HT 12345',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: const Center(
                  child: Icon(Icons.map, size: 50, color: Colors.grey),
                ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone, color: Colors.blue.shade600, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Contact Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (!isEditingPhone)
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue.shade600),
                    onPressed: () {
                      setState(() {
                        isEditingPhone = true;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (isEditingPhone)
              Column(
                children: [
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                      hintText: 'Enter phone number',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isEditingPhone = false;
                            phoneController.text = phoneNumber;
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            phoneNumber = phoneController.text;
                            isEditingPhone = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Save', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              )
            else
              Text(
                phoneNumber,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              ),
          ],
        ),
      ),
    );
  }

  Card _buildVolunteersCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                      backgroundColor: volunteer.isActive 
                          ? Colors.purple.shade100 
                          : Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        color: volunteer.isActive 
                            ? Colors.purple.shade600 
                            : Colors.grey.shade600,
                      ),
                    ),
                    title: Text(
                      volunteer.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: volunteer.isActive 
                            ? Colors.black 
                            : Colors.grey.shade600,
                      ),
                    ),
                    subtitle: Text(
                      volunteer.email,
                      style: TextStyle(
                        color: volunteer.isActive 
                            ? Colors.grey.shade600 
                            : Colors.grey.shade400,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            volunteer.isActive ? Icons.toggle_on : Icons.toggle_off,
                            color: volunteer.isActive 
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
                        backgroundColor: volunteer.isActive 
                            ? Colors.purple.shade100 
                            : Colors.grey.shade300,
                        child: Icon(
                          Icons.person,
                          color: volunteer.isActive 
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
                    child: volunteer.duties.isEmpty
                        ? Center(
                            child: Text(
                              'No duties recorded yet',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: volunteer.duties.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
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
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  '${duty.date.day}/${duty.date.month}/${duty.date.year}',
                                  style: TextStyle(color: Colors.grey.shade600),
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) => email = value ?? '',
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
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            setState(() {
                              volunteers.add(Volunteer(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: name,
                                email: email,
                                phone: phone,
                                isActive: true,
                                duties: [],
                              ));
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$name added as volunteer'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Add Volunteer',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
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

class GoogleMapScreen extends StatelessWidget {
  final LatLng initialLocation;

  const GoogleMapScreen({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Point Location'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialLocation,
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('collection_point'),
            position: initialLocation,
            infoWindow: const InfoWindow(title: 'Collection Point'),
          ),
        },
      ),
    );
  }
}