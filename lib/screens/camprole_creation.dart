import 'package:flutter/material.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';

class CamproleCreation extends StatefulWidget {
  const CamproleCreation({super.key});

  @override
  _CamproleCreationState createState() => _CamproleCreationState();
}

class _CamproleCreationState extends State<CamproleCreation> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  List<Map<String, dynamic>> roles = [];

  int? editingIndex;
  bool _showForm = false;

  String role = '';
  String label = '';
  String assignedTo = '';
  String location = '';
  String validationMessage = '';

  List<String> roleOptions = [
    'Statistics',
    'Camp Admin',
    'Collection Point Admin',
    'Survey Officials',
    'Verify Officials',
  ];

  List<String> labelOptions = [
    'Volunteer',
    'Police',
    'Teacher',
    'Government Official',
    'Medical Staff',
    'NGO Worker',
    'Military',
    'Other',
  ];

  List<Map<String, dynamic>> campLocationOptions = [];
  List<Map<String, dynamic>> colpLocationOptions = [];
  List<Map<String, dynamic>> admins = [];

  bool _isLoading = true;
  bool _isEditingExistingUser = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final camps = await TokenHttp().get(
        '/disaster/getCamps?disasterId=${AuthService().getDisasterId()}',
      );

      final collectionPoints = await TokenHttp().get(
        '/disaster/getCollectionPoints?disasterId=${AuthService().getDisasterId()}',
      );

      final getRoles = await TokenHttp().get(
        '/auth/getAdmins?disasterId=${AuthService().getDisasterId()}',
      );

      campLocationOptions.clear();
      colpLocationOptions.clear();

      if (camps is List) {
        for (var camp in camps) {
          if (camp != null && camp['name'] != null) {
            campLocationOptions.add(camp);
          }
        }
      } else if (camps is Map &&
          camps['data'] != null &&
          camps['data'] is List) {
        for (var camp in camps['data']) {
          if (camp != null && camp['name'] != null) {
            campLocationOptions.add(camp);
          }
        }
      }

      if (collectionPoints is List) {
        for (var point in collectionPoints) {
          if (point != null && point['name'] != null) {
            colpLocationOptions.add(point);
          }
        }
      } else if (collectionPoints is Map &&
          collectionPoints['data'] != null &&
          collectionPoints['data'] is List) {
        for (var point in collectionPoints['data']) {
          if (point != null && point['name'] != null) {
            colpLocationOptions.add(point);
          }
        }
      }

      admins.clear();
      if (getRoles is List) {
        admins.addAll(getRoles.whereType<Map<String, dynamic>>());
      } else if (getRoles is Map &&
          getRoles['data'] != null &&
          getRoles['data'] is List) {
        admins.addAll(getRoles['data'].whereType<Map<String, dynamic>>());
      }
    } catch (e) {
      print("Error fetching data: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addAdminToDisaster(
    String name,
    String phoneNumber,
    String role,
    String label,
    String assignedTo,
  ) async {
    setState(() => _isLoading = true);
    try {
      await TokenHttp().post('/auth/register', {
        'name': name,
        'phoneNumber': phoneNumber,
        'role':
            role == 'Camp Admin'
                ? 'campAdmin'
                : role == 'Collection Point Admin'
                ? 'collectionPointAdmin'
                : role == 'Statistics'
                ? 'stat'
                : role == 'Survey Officials'
                ? 'surveyOfficial'
                : 'verifyOfficial',
        'label': label,
        'assignPlace':
            role == 'Camp Admin' || role == 'Collection Point Admin'
                ? assignedTo
                : null,
        'disasterId': AuthService().getDisasterId(),
      });
      await _fetchData();
    } catch (e) {
      print("Error adding admin: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add admin: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> deleteAdmins(String id, String role) async {
    setState(() => _isLoading = true);
    try {
      await TokenHttp().post('/auth/revokeAdmin', {
        '_id': id,
        'disasterId': AuthService().getDisasterId(),
        'role': role,
      });
      await _fetchData();
    } catch (e) {
      print("Error deleting admin: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete admin: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Role Creation',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_showForm) ...[
                        if (!_isEditingExistingUser) ...[
                          _buildTextField(
                            controller: nameController,
                            label: 'Name',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone,
                          ),
                          const SizedBox(height: 16),
                        ],
                        _buildDropdownField(
                          label: 'Label',
                          value: label,
                          items: labelOptions,
                          onChanged: (value) => setState(() => label = value!),
                          icon: Icons.label,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          label: 'Assigned To',
                          value: role,
                          items: roleOptions,
                          onChanged:
                              (value) => setState(() {
                                role = value!;
                                location = '';
                              }),
                        ),
                        const SizedBox(height: 16),
                        if (role == 'Camp Admin')
                          _buildDropdownField(
                            label: 'Location',
                            value: location,
                            items:
                                campLocationOptions
                                    .map((e) => (e['name'] ?? '').toString())
                                    .toList(),
                            onChanged:
                                (value) => setState(() => location = value!),
                            icon: Icons.location_on,
                          ),
                        if (role == 'Collection Point Admin')
                          _buildDropdownField(
                            label: 'Location',
                            value: location,
                            items:
                                colpLocationOptions
                                    .map((e) => (e['name'] ?? '').toString())
                                    .toList(),
                            onChanged:
                                (value) => setState(() => location = value!),
                            icon: Icons.location_on,
                          ),
                        if (validationMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.red[50],
                            child: Text(
                              validationMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if ((!nameController.text.isEmpty ||
                                    _isEditingExistingUser) &&
                                (!phoneController.text.isEmpty ||
                                    _isEditingExistingUser) &&
                                role.isNotEmpty &&
                                label.isNotEmpty) {
                              if ((role == 'Camp Admin' ||
                                      role == 'Collection Point Admin') &&
                                  location.isEmpty) {
                                setState(() {
                                  validationMessage =
                                      'Please select a Location.';
                                });
                                return;
                              }
                              Map<String, dynamic> locationObject;
                              final campLocation = campLocationOptions
                                  .firstWhere(
                                    (loc) => loc['name'] == location,
                                    orElse: () => <String, dynamic>{},
                                  );
                              final colpLocation = colpLocationOptions
                                  .firstWhere(
                                    (loc) => loc['name'] == location,
                                    orElse: () => <String, dynamic>{},
                                  );
                              locationObject =
                                  campLocation.isNotEmpty
                                      ? campLocation
                                      : colpLocation.isNotEmpty
                                      ? colpLocation
                                      : {'_id': ''};

                              _addAdminToDisaster(
                                nameController.text,
                                phoneController.text,
                                role,
                                label,
                                locationObject['_id'] ?? '',
                              );
                              if (!_isEditingExistingUser) {
                                nameController.clear();
                                phoneController.clear();
                              }
                              role = '';
                              location = '';
                              label = '';
                              setState(() {
                                _showForm = false;
                                _isEditingExistingUser = false;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill out all fields!'),
                                ),
                              );
                            }
                          },
                          child: Text(
                            _isEditingExistingUser
                                ? 'Add Another Role'
                                : 'Submit',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                      const Text(
                        'All Roles:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 80.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: admins.length,
                          itemBuilder: (context, index) {
                            final admin = admins[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      12,
                                      16,
                                      4,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                admin['name'] ?? 'N/A',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Phone: ${admin['phoneNumber'] ?? 'N/A'}',
                                              ),
                                              if (admin['label'] != null)
                                                Text(
                                                  'Label: ${admin['label']}',
                                                ),
                                              if (admin['assignPlace'] != null)
                                                Text(
                                                  'Assigned Place: ${admin['assignPlace']['name'] ?? 'N/A'}',
                                                ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {
                                            nameController.text =
                                                admin['name'] ?? '';
                                            phoneController.text =
                                                admin['phoneNumber'] ?? '';
                                            setState(() {
                                              _isEditingExistingUser = true;
                                              _showForm = true;
                                              role = '';
                                              label = '';
                                              location = '';
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (admin['assignedRoles'] != null &&
                                      (admin['assignedRoles'] as List)
                                          .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        12,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Assigned Roles:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 8.0,
                                            runSpacing: 8.0,
                                            children:
                                                (admin['assignedRoles']
                                                        as List<dynamic>?)
                                                    ?.map<Widget>((
                                                      assignedRole,
                                                    ) {
                                                      return ElevatedButton.icon(
                                                        style: ElevatedButton.styleFrom(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 6,
                                                              ),
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                        ),
                                                        onPressed:
                                                            () => deleteAdmins(
                                                              admin["_id"],
                                                              assignedRole,
                                                            ),
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                          size: 16,
                                                        ),
                                                        label: Text(
                                                          assignedRole ?? 'N/A',
                                                        ),
                                                      );
                                                    })
                                                    .toList() ??
                                                [],
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
                  ),
                ),
              ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showForm = !_showForm;
                  _isEditingExistingUser = false;
                  if (!_showForm) {
                    nameController.clear();
                    phoneController.clear();
                    role = '';
                    location = '';
                    label = '';
                    validationMessage = '';
                  }
                });
              },
              child: Icon(
                _showForm ? Icons.cancel : Icons.add,
                color: Colors.white,
              ),
              backgroundColor: Colors.black,
              tooltip: _showForm ? 'Cancel' : 'Add Role',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon ?? Icons.assignment),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          items.map((String option) {
            return DropdownMenuItem<String>(value: option, child: Text(option));
          }).toList(),
    );
  }
}
