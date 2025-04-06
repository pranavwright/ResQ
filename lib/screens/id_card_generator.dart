import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:resq/constants/api_constants.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';

class IdCardGenerator extends StatefulWidget {
  const IdCardGenerator({super.key});

  @override
  _IdCardGeneratorState createState() => _IdCardGeneratorState();
}

class _IdCardGeneratorState extends State<IdCardGenerator> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> admins = [];
  List<String> selectedUserIds = [];

  bool _isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    setState(() => _isLoading = true);
    try {
      final getRoles = await TokenHttp().get(
        '/auth/getAdmins?disasterId=${AuthService().getDisasterId()}',
      );
      if (getRoles is List) {
        admins = getRoles.whereType<Map<String, dynamic>>().toList();
      } else if (getRoles is Map && getRoles['data'] is List) {
        admins = (getRoles['data'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    } catch (e) {
      print("Error fetching admins: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleUserSelection(String id) {
    setState(() {
      if (selectedUserIds.contains(id)) {
        selectedUserIds.remove(id);
      } else {
        selectedUserIds.add(id);
      }
    });
  }

  List<Map<String, dynamic>> get _filteredAdmins {
    if (searchQuery.isEmpty) return admins;
    return admins.where((admin) {
      final name = (admin['name'] ?? '').toLowerCase();
      final phone = (admin['phoneNumber'] ?? '').toLowerCase();
      return name.contains(searchQuery.toLowerCase()) ||
          phone.contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _generateIdCards() async {
    if (selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No users selected')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/auth/generateIdCards');
    final token = await AuthService().getToken(); // Use your token fetch method

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'disasterId': AuthService().getDisasterId(),
        'userIds': selectedUserIds,
      }),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/generated_id_cards.pdf');
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF downloaded. Opening...')),
      );

      await OpenFile.open(file.path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate: ${response.statusCode}')),
      );
    }
    } catch (e) {
      print("Error generating ID cards: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Roles'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _generateIdCards,
            tooltip: 'Download ID Cards',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) =>
                        setState(() => searchQuery = value.trim()),
                    decoration: InputDecoration(
                      labelText: 'Search by name or phone',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredAdmins.isEmpty
                      ? const Center(child: Text('No matching admins found.'))
                      : ListView.builder(
                          itemCount: _filteredAdmins.length,
                          itemBuilder: (context, index) {
                            final admin = _filteredAdmins[index];
                            final id = admin['_id'];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: ListTile(
                                leading: Checkbox(
                                  value: selectedUserIds.contains(id),
                                  onChanged: (_) => _toggleUserSelection(id),
                                ),
                                title: Text(admin['name'] ?? 'N/A'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Phone: ${admin['phoneNumber']}'),
                                    if (admin['label'] != null)
                                      Text('Label: ${admin['label']}'),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
