import 'package:flutter/material.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';

class ChangeDisasterScreen extends StatefulWidget {
  const ChangeDisasterScreen({super.key});

  @override
  State<ChangeDisasterScreen> createState() => _ChangeDisasterScreenState();
}

class _ChangeDisasterScreenState extends State<ChangeDisasterScreen> {
  String? _selectedDisasterId = AuthService().getDisasterId();
  List<Map<String, dynamic>> _disasterRoles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDisasterRoles();
  }

  Future<void> _loadDisasterRoles() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await TokenHttp().get('/auth/getUser');
      if (user != null && user['roles'] is List) {
        _disasterRoles = List<Map<String, dynamic>>.from(user['roles']);
      }
    } catch (e) {
      print('Error loading disaster roles: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load disaster roles: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleChangeDisaster() async {
    setState(() {
        _isLoading=true;
      });
    if (_selectedDisasterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a disaster')),
      );
      return;
    }

    try {
      final selectedDisaster = _disasterRoles.firstWhere(
        (disaster) => disaster['disasterId'] == _selectedDisasterId,
      );

      final roles = List<String>.from(selectedDisaster['roles'].map((role) => role.toString()));
      await AuthService().changeDisaster(_selectedDisasterId!, roles);
      await AuthService().loadAuthState();

      if (!mounted) return;
      // Navigator.pop(context); 
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/app',
        (route) => false,
      );
    } catch (e) {
      print('Error changing disaster: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change disaster: $e')),
      );
    } finally {
      setState(() {
        _isLoading=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Disaster'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedDisasterId,
                    items: _disasterRoles.map((disaster) {
                      return DropdownMenuItem<String>(
                        value: disaster['disasterId'],
                        child: Text(disaster['disasterName'] ?? disaster['disasterId']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDisasterId = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select Disaster',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _handleChangeDisaster,
                    child: const Text('Change Disaster'),
                  ),
                ],
              ),
            ),
    );
  }
}
